"""Gözlemlenebilirlik: yapılandırılmış (JSON) loglama, istek kimliği, erişim logu, Sentry."""
import contextvars
import json
import logging
import sys
import time
import uuid

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse
from starlette.requests import Request

from config import ayarlar

istek_kimligi: contextvars.ContextVar[str] = contextvars.ContextVar("istek_kimligi", default="-")
log = logging.getLogger("premium_berber.erisim")


class JsonBicim(logging.Formatter):
    """Tek satırlık JSON log: Render / Datadog / Loki gibi araçlar alanlara göre filtreleyebilir."""

    def format(self, kayit: logging.LogRecord) -> str:
        veri = {
            "zaman": self.formatTime(kayit, "%Y-%m-%dT%H:%M:%S"),
            "seviye": kayit.levelname,
            "kaynak": kayit.name,
            "mesaj": kayit.getMessage(),
            "istek_id": istek_kimligi.get(),
        }
        for alan in ("yontem", "yol", "durum", "sure_ms", "ip"):
            if hasattr(kayit, alan):
                veri[alan] = getattr(kayit, alan)
        if kayit.exc_info:
            veri["hata"] = self.formatException(kayit.exc_info)
        return json.dumps(veri, ensure_ascii=False)


def loglamayi_kur() -> None:
    a = ayarlar()
    isleyici = logging.StreamHandler(sys.stdout)
    if a.log_format == "json":
        isleyici.setFormatter(JsonBicim())
    else:
        isleyici.setFormatter(logging.Formatter("%(asctime)s %(levelname)s %(name)s [%(istek_id)s]: %(message)s"))
        isleyici.addFilter(_IstekKimligiFiltresi())
    kok = logging.getLogger()
    kok.handlers[:] = [isleyici]
    kok.setLevel(a.log_level)
    # uvicorn'un kendi erişim logu yerine aşağıdaki ara katman (süre + istek kimliği ile) kullanılır
    logging.getLogger("uvicorn.access").disabled = True
    for ad in ("uvicorn", "uvicorn.error", "gunicorn.error"):
        logging.getLogger(ad).handlers[:] = []
        logging.getLogger(ad).propagate = True


class _IstekKimligiFiltresi(logging.Filter):
    def filter(self, kayit: logging.LogRecord) -> bool:
        kayit.istek_id = istek_kimligi.get()
        return True


class IstekLoguAraKatmani(BaseHTTPMiddleware):
    """Her isteğe kimlik verir (X-Request-ID), süresini ölçer ve tek satır erişim logu yazar."""

    async def dispatch(self, request: Request, call_next):
        kimlik = request.headers.get("x-request-id") or uuid.uuid4().hex[:12]
        jeton = istek_kimligi.set(kimlik)
        baslangic = time.perf_counter()
        durum = 500
        try:
            try:
                yanit = await call_next(request)
            except Exception:
                # Ham istisna/yığın izi kullanıcıya gitmez; destek için kısa bir kod döner
                log.exception("Beklenmeyen hata")
                yanit = JSONResponse(status_code=500, content={
                    "detail": f"Beklenmeyen bir hata oluştu. Sorun sürerse destek ekibine bu kodu iletin: {kimlik}"})
            durum = yanit.status_code
            yanit.headers["X-Request-ID"] = kimlik
            return yanit
        finally:
            sure = round((time.perf_counter() - baslangic) * 1000, 1)
            if request.url.path not in ("/health", "/saglik"):
                log.info("istek", extra={"yontem": request.method, "yol": request.url.path, "durum": durum,
                                         "sure_ms": sure, "ip": request.client.host if request.client else None})
            istek_kimligi.reset(jeton)


def sentry_kur() -> bool:
    """SENTRY_DSN tanımlıysa hata izlemeyi açar; değilse sessizce kapalı kalır."""
    a = ayarlar()
    if not a.sentry_dsn:
        return False
    import sentry_sdk

    sentry_sdk.init(
        dsn=a.sentry_dsn,
        environment=a.ortam,
        release=f"premium-berber@{a.surum}",
        traces_sample_rate=a.sentry_traces_sample_rate,
        send_default_pii=False,  # KVKK: IP/kimlik gönderme
    )
    return True
