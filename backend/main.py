import logging
import os
from contextlib import asynccontextmanager

from apscheduler.schedulers.background import BackgroundScheduler
from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError, OperationalError

from config import ayarlar
from database import SessionLocal
from gozlem import IstekLoguAraKatmani, loglamayi_kur, sentry_kur
from koruma import BoyutSiniriAraKatmani, hiz_siniri_asildi, limiter
from routers import (berberler, degerlendirmeler, dukkan, hesap, hizmetler, isletmeler, kurumsal, musteriler, panel,
                     randevular, raporlar, salonlar, tatil, yasal)
from zamanlayici import gorevleri_ekle

loglamayi_kur()
sentry_kur()
log = logging.getLogger("premium_berber")
a = ayarlar()


@asynccontextmanager
async def lifespan(_: FastAPI):
    zamanlayici = None
    if a.scheduler_enabled:
        zamanlayici = BackgroundScheduler(timezone=a.zaman_dilimi)
        gorevleri_ekle(zamanlayici)
        zamanlayici.start()
        log.info("Zamanlayıcı bu süreçte başlatıldı (görevler DB kilidiyle tek örnekte çalışır).")
    yield
    if zamanlayici:
        zamanlayici.shutdown(wait=False)


app = FastAPI(
    title="Premium Berber API",
    version=a.surum,
    lifespan=lifespan,
    docs_url="/docs" if a.dokumanlar_acik else None,
    redoc_url=None,
    openapi_url="/openapi.json" if a.dokumanlar_acik else None,
)

# Ara katmanlar (son eklenen en dışta çalışır)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, hiz_siniri_asildi)
app.add_middleware(SlowAPIMiddleware)
app.add_middleware(BoyutSiniriAraKatmani)
app.add_middleware(
    CORSMiddleware,
    allow_origins=a.cors_listesi,
    allow_credentials=False,  # kimlik Authorization header ile taşınır, cookie yok
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
    allow_headers=["Authorization", "Content-Type", "Idempotency-Key", "X-Request-ID"],
)
app.add_middleware(IstekLoguAraKatmani)


# ── Hata yanıtları: kullanıcıya her zaman Türkçe ve ham iç hata olmadan ──
# (beklenmeyen istisnalar IstekLoguAraKatmani'nda istek kodlu 500'e çevrilir)
@app.exception_handler(OperationalError)
@app.exception_handler(DBAPIError)
async def veritabani_hatasi(_: Request, exc: Exception):
    log.error("Veritabanı hatası: %s", exc.__class__.__name__, exc_info=exc)
    return JSONResponse(status_code=503, headers={"Retry-After": "5"},
                        content={"detail": "Hizmet geçici olarak kullanılamıyor. Lütfen birazdan tekrar deneyin."})


@app.exception_handler(RequestValidationError)
async def dogrulama_hatasi(_: Request, exc: RequestValidationError):
    return JSONResponse(status_code=422, content={"detail": "Girilen bilgileri kontrol edin.", "hatalar": [
        {"alan": ".".join(str(x) for x in e.get("loc", [])[1:]), "mesaj": e.get("msg")} for e in exc.errors()]})


os.makedirs(os.path.join(a.uploads_dir, "berberler"), exist_ok=True)
app.mount("/uploads", StaticFiles(directory=a.uploads_dir), name="uploads")

for r in (hesap, musteriler, salonlar, dukkan, randevular, berberler, hizmetler, isletmeler, panel, degerlendirmeler,
          tatil, raporlar, kurumsal, yasal):
    app.include_router(r.router)


@app.get("/", include_in_schema=False)
@limiter.exempt
def home():
    return {"durum": "ok", "servis": "Premium Berber API", "surum": a.surum}


@app.get("/health", tags=["Sistem"])
@app.get("/saglik", include_in_schema=False)
@limiter.exempt
def health():
    """Yük dengeleyici / Render sağlık kontrolü. DB'ye erişilemiyorsa 503."""
    db = SessionLocal()
    try:
        db.execute(text("SELECT 1"))
        return {"durum": "ok", "veritabani": "ok", "surum": a.surum}
    except Exception:
        log.warning("Sağlık kontrolü: veritabanına erişilemiyor")
        return JSONResponse(status_code=503, content={"durum": "hata", "veritabani": "erişilemiyor"})
    finally:
        db.close()
