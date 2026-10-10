"""Zamanlanmış görevlerin tek tanımı. Web süreci (SCHEDULER_ENABLED=true ise) ve worker.py bunu kullanır.

Her görev `gorev_kilidi.kilitli_calistir` ile sarılıdır: kaç süreç çalışırsa çalışsın görev aynı anda tek
örnekte yürür, bildirimler çift gitmez.
"""
from datetime import timedelta

from apscheduler.schedulers.base import BaseScheduler

import gorevler
import models
from database import SessionLocal
from gorev_kilidi import kilitli_calistir
from zaman import simdi

ARALIK_DK = 5


def idempotency_temizle() -> int:
    """24 saatten eski idempotency anahtarlarını siler."""
    db = SessionLocal()
    try:
        sinir = (simdi() - timedelta(hours=24)).isoformat(timespec="seconds")
        sayi = db.query(models.IdempotencyAnahtari).filter(models.IdempotencyAnahtari.olusturma < sinir).delete()
        db.commit()
        return sayi
    finally:
        db.close()


GOREVLER = {
    "hatirlatma": (gorevler.hatirlatma_gorevi, ARALIK_DK),
    "tamamlama": (gorevler.tamamlama_ve_degerlendirme_gorevi, ARALIK_DK),
    "idempotency_temizlik": (idempotency_temizle, 60),
}


def gorevleri_ekle(zamanlayici: BaseScheduler) -> None:
    for ad, (fonk, dakika) in GOREVLER.items():
        zamanlayici.add_job(
            kilitli_calistir, "interval", minutes=dakika, id=ad, max_instances=1, coalesce=True,
            kwargs={"ad": ad, "gorev": fonk, "sure_sn": dakika * 60 - 10},
        )
