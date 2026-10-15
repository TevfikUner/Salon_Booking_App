"""Kötüye kullanıma karşı koruma: hız sınırı (slowapi) ve istek gövdesi boyut sınırı."""
from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse
from slowapi import Limiter
from slowapi.errors import RateLimitExceeded
from starlette.datastructures import Headers
from starlette.types import ASGIApp, Receive, Scope, Send

from config import ayarlar


def istemci_ip(request: Request) -> str:
    """Gerçek istemci adresi. X-Forwarded-For'un solu istemcinin kendi yazdığı değer olabilir (proxy temizlemez,
    yalnızca sona ekler); bu yüzden GUVENILIR_PROXY_SAYISI kadar sağdan sayılır. 0 ise başlık yok sayılır."""
    n = ayarlar().guvenilir_proxy_sayisi
    if n > 0:
        adresler = [x.strip() for x in ",".join(request.headers.getlist("x-forwarded-for")).split(",") if x.strip()]
        if len(adresler) >= n:  # daha azsa proxy'den gelmemiş demektir → başlığa güvenilmez
            return adresler[-n]
    return request.client.host if request.client else "bilinmiyor"


def istemci_anahtari(request: Request) -> str:
    """Doğrulanmış oturum varsa kullanıcı başına (aynı Wi-Fi'daki herkes tek IP'ye düşmesin), yoksa IP başına sınır.
    Token doğrulanmadan anahtar üretilmez: rastgele "Bearer xyz" ile her istekte yeni kova açılamaz."""
    from auth import istek_kimligi

    try:
        kimlik = istek_kimligi(request)
    except HTTPException:
        kimlik = None
    return f"k:{kimlik.uid}" if kimlik else "ip:" + istemci_ip(request)


limiter = Limiter(
    key_func=istemci_anahtari,
    default_limits=[ayarlar().rate_limit_varsayilan],
    storage_uri=ayarlar().rate_limit_storage_uri,
    enabled=ayarlar().rate_limit_enabled,
    headers_enabled=False,
)

# Uç bazında sınırlar (tek yerde, okunur olsun diye)
SINIR_KAYIT = "5/minute"            # müşteri / işletme kaydı
SINIR_GIRIS = "30/minute"           # /ben — her girişte çağrılır
SINIR_RANDEVU = "10/minute"         # randevu oluşturma
SINIR_PANEL_YAZMA = "60/minute"     # işletme paneli değişiklikleri
SINIR_HASSAS = "3/minute"           # hesap silme
SINIR_FOTO = "10/minute"            # profil fotoğrafı yükleme


def hiz_siniri_asildi(_: Request, __: RateLimitExceeded) -> JSONResponse:
    return JSONResponse(
        status_code=429,
        content={"detail": "Çok fazla istek gönderdiniz. Lütfen biraz bekleyip tekrar deneyin."},
        headers={"Retry-After": "60"},
    )


FOTO_YUKLEME_SINIRI = 6 * 1024 * 1024
FOTO_YUKLEME_YOLLARI = ("/berberler/foto-yukle", "/musteriler/profil-foto")
_COK_BUYUK = "İstek çok büyük."


class BoyutSiniriAraKatmani:
    """Gövde boyutu üst sınırı. Content-Length varsa ona bakarak baştan reddeder. Yoksa (Transfer-Encoding: chunked)
    gövdeyi sınıra kadar burada okur, aşılırsa 413 döner, aşılmazsa okunanı uygulamaya aynen yeniden sunar
    (bellek en fazla sınır kadar). Fotoğraf yükleme ucu daha yüksek sınıra sahiptir ve içeriği ayrıca denetler.
    Saf ASGI: gövde akışına BaseHTTPMiddleware'den erişilemez; akış sırasında hata yükseltmek de işe yaramaz
    (iç katmanlar onu ExceptionGroup'a sarar, FastAPI 400'e çevirir)."""

    def __init__(self, app: ASGIApp):
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send):
        if scope["type"] != "http":
            return await self.app(scope, receive, send)
        sinir = FOTO_YUKLEME_SINIRI if scope["path"].startswith(FOTO_YUKLEME_YOLLARI) else ayarlar().maks_istek_boyutu
        basliklar = Headers(scope=scope)
        uzunluk = basliklar.get("content-length")
        if uzunluk is not None or "transfer-encoding" not in basliklar:
            if uzunluk and uzunluk.isdigit() and int(uzunluk) > sinir:
                return await self._cok_buyuk(scope, receive, send)
            return await self.app(scope, receive, send)

        govde = bytearray()
        while True:
            mesaj = await receive()
            if mesaj["type"] == "http.disconnect":
                return
            govde += mesaj.get("body", b"")
            if len(govde) > sinir:
                return await self._cok_buyuk(scope, receive, send)
            if not mesaj.get("more_body", False):
                break

        verildi = False

        async def tekrar_receive():
            nonlocal verildi
            if not verildi:
                verildi = True
                return {"type": "http.request", "body": bytes(govde), "more_body": False}
            return await receive()

        await self.app(scope, tekrar_receive, send)

    @staticmethod
    async def _cok_buyuk(scope: Scope, receive: Receive, send: Send):
        await JSONResponse(status_code=413, content={"detail": _COK_BUYUK})(scope, receive, send)
