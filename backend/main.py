import logging
import os
from contextlib import asynccontextmanager

from apscheduler.schedulers.background import BackgroundScheduler
from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text
from sqlalchemy.orm import Session

import gorevler
from config import ayarlar
from database import get_db
from routers import (berberler, degerlendirmeler, dukkan, hesap, hizmetler, isletmeler, kurumsal, musteriler, panel,
                     randevular, raporlar, tatil)

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s")
log = logging.getLogger("premium_berber")


@asynccontextmanager
async def lifespan(_: FastAPI):
    scheduler = None
    if ayarlar().scheduler_enabled:
        scheduler = BackgroundScheduler(timezone=ayarlar().zaman_dilimi)
        scheduler.add_job(gorevler.hatirlatma_gorevi, "interval", minutes=5, id="hatirlatma", max_instances=1)
        scheduler.add_job(gorevler.tamamlama_ve_degerlendirme_gorevi, "interval", minutes=5, id="tamamlama",
                          max_instances=1)
        scheduler.start()
        log.info("Zamanlayıcı başlatıldı.")
    yield
    if scheduler:
        scheduler.shutdown(wait=False)


app = FastAPI(title="Premium Berber API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=ayarlar().cors_listesi,
    allow_credentials=False,  # kimlik Authorization header ile taşınır, cookie yok
    allow_methods=["*"],
    allow_headers=["*"],
)

os.makedirs(os.path.join(ayarlar().uploads_dir, "berberler"), exist_ok=True)
app.mount("/uploads", StaticFiles(directory=ayarlar().uploads_dir), name="uploads")

for r in (hesap, musteriler, dukkan, randevular, berberler, hizmetler, isletmeler, panel, degerlendirmeler, tatil,
          raporlar, kurumsal):
    app.include_router(r.router)


@app.get("/")
def home():
    return {"durum": "ok", "servis": "Premium Berber API"}


@app.get("/saglik")
def saglik(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"durum": "ok"}
