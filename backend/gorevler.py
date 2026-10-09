"""Zamanlanmış görevler (APScheduler, 5 dakikada bir)."""
import logging
from datetime import timedelta

import models
import randevu_servisi as rs
import slot_servisi as ss
from bildirim import bildirim_gonder
from database import SessionLocal
from zaman import simdi

log = logging.getLogger(__name__)

HATIRLATMA_PENCERE_DK = (50, 70)  # randevuya ~1 saat kala


def hatirlatma_gorevi() -> int:
    db = SessionLocal()
    try:
        an = simdi()
        gunler = [an.date().isoformat(), (an.date() + timedelta(days=1)).isoformat()]
        randevular = db.query(models.Randevu).filter(
            models.Randevu.tarih.in_(gunler),
            models.Randevu.durum == "onaylandi",
            models.Randevu.hatirlatma_gonderildi.is_(False),
        ).all()
        sayi = 0
        for r in randevular:
            kalan = (ss.randevu_baslangic(r) - an).total_seconds() / 60
            if HATIRLATMA_PENCERE_DK[0] <= kalan <= HATIRLATMA_PENCERE_DK[1]:
                if r.musteri and r.musteri.fcm_token:
                    salon = r.salon.ad if r.salon else "salon"
                    bildirim_gonder(r.musteri.fcm_token, "Randevunuza 1 saat kaldı ⏰",
                                    f"Bugün {r.saat}'de {salon} randevunuz var. Görüşmek üzere!",
                                    {"type": "randevu", "randevu_id": r.id})
                r.hatirlatma_gonderildi = True
                sayi += 1
            elif kalan < HATIRLATMA_PENCERE_DK[0]:
                r.hatirlatma_gonderildi = True  # pencere kaçtıysa tekrar deneme
        db.commit()
        return sayi
    except Exception:
        log.exception("Hatırlatma görevi hata verdi")
        db.rollback()
        return 0
    finally:
        db.close()


def tamamlama_ve_degerlendirme_gorevi() -> int:
    db = SessionLocal()
    try:
        tamamlananlar = rs.gecmisleri_tamamla(db)
        for r in tamamlananlar:
            rs.degerlendirme_iste(db, r)
        return len(tamamlananlar)
    except Exception:
        log.exception("Tamamlama görevi hata verdi")
        db.rollback()
        return 0
    finally:
        db.close()
