"""Kötüye kullanıma karşı koruma: hız sınırı (slowapi) ve istek gövdesi boyut sınırı."""
import hashlib

from fastapi import Request
from fastapi.responses import JSONResponse
from slowapi import Limiter
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address
from starlette.middleware.base import BaseHTTPMiddleware

from config import ayarlar


def istemci_anahtari(request: Request) -> str:
    """Oturum varsa kullanıcı başına (aynı Wi-Fi'daki herkes tek IP'ye düşmesin), yoksa IP başına sınır."""
    yetki = request.headers.get("authorization", "")
    if yetki.lower().startswith("bearer ") and len(yetki) > 10:
        return "k:" + hashlib.sha256(yetki[7:].encode()).hexdigest()[:24]
    return "ip:" + get_remote_address(request)


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


def hiz_siniri_asildi(_: Request, __: RateLimitExceeded) -> JSONResponse:
    return JSONResponse(
        status_code=429,
        content={"detail": "Çok fazla istek gönderdiniz. Lütfen biraz bekleyip tekrar deneyin."},
        headers={"Retry-After": "60"},
    )


FOTO_YUKLEME_SINIRI = 6 * 1024 * 1024


class BoyutSiniriAraKatmani(BaseHTTPMiddleware):
    """Content-Length üst sınırı. Fotoğraf yükleme ucu daha yüksek sınıra sahiptir ve içeriği ayrıca denetler."""

    async def dispatch(self, request: Request, call_next):
        uzunluk = request.headers.get("content-length")
        if uzunluk and uzunluk.isdigit():
            sinir = FOTO_YUKLEME_SINIRI if request.url.path.startswith("/berberler/foto-yukle") \
                else ayarlar().maks_istek_boyutu
            if int(uzunluk) > sinir:
                return JSONResponse(status_code=413, content={"detail": "İstek çok büyük."})
        return await call_next(request)
