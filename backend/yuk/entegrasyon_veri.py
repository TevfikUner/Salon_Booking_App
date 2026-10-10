"""Flutter entegrasyon testleri (App/integration_test) için sabit veri.

    python yuk/entegrasyon_veri.py          (AUTH_MODE=dev olan yerel/test sunucusunda)

Kurar (her çalıştırmada sıfırdan):
- "Entegrasyon Salonu": her gün 00:00–23:30 açık (test günün hangi saatinde koşarsa koşsun boş saat bulunsun),
  1 berber, 2 hizmet
- Onaylı işletme hesabı  uid=entegrasyon-isletme  → bu salonun paneli
- Bugün, başlama saati geçmiş (henüz otomatik tamamlanmamış) bir randevu → panelde "Tamamlandı" testi için
- Müşteri uid=entegrasyon-musteri SİLİNİR: test kaydı kendisi yapar
Production'da çalışmaz.
"""
import os
import sys
from datetime import timedelta

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import models  # noqa: E402
from config import ayarlar  # noqa: E402
from database import SessionLocal  # noqa: E402
from zaman import simdi  # noqa: E402

if ayarlar().uretim_mi:
    sys.exit("Production veritabanında çalıştırılamaz.")

SALON_ADI = "Entegrasyon Salonu"


def main() -> None:
    db = SessionLocal()
    try:
        eski = db.query(models.Salon).filter(models.Salon.ad == SALON_ADI).all()
        for s in eski:
            db.query(models.Randevu).filter(models.Randevu.salon_id == s.id).delete()
        db.query(models.Isletme).filter(models.Isletme.firebase_uid == "entegrasyon-isletme").delete()
        for uid in ("entegrasyon-musteri", "entegrasyon-gecmis"):
            m = db.query(models.Musteri).filter(models.Musteri.firebase_uid == uid).first()
            if m:
                db.query(models.Randevu).filter(models.Randevu.musteri_id == m.id).delete()
                db.query(models.BeklemeListesi).filter(models.BeklemeListesi.musteri_id == m.id).delete()
                db.delete(m)
        db.flush()

        salon = eski[0] if eski else models.Salon(ad=SALON_ADI)
        salon.sehir, salon.ilce, salon.aktif = "Konya", "Selçuklu", True
        salon.acilis_saati, salon.kapanis_saati = "00:00", "23:30"
        salon.pazar_acilis_saati, salon.pazar_kapanis_saati = "00:00", "23:30"
        salon.kapali_gunler = ""
        db.add(salon)
        db.flush()

        berber = db.query(models.Berber).filter(models.Berber.salon_id == salon.id).first()
        if not berber:
            berber = models.Berber(salon_id=salon.id, ad="Test", soyad="Usta", uzmanlik="Usta")
            db.add(berber)
        if not db.query(models.Hizmet).filter(models.Hizmet.salon_id == salon.id).first():
            db.add_all([models.Hizmet(salon_id=salon.id, ad="Saç Kesimi", fiyat=300, sure=30),
                        models.Hizmet(salon_id=salon.id, ad="Sakal", fiyat=150, sure=15)])
        db.flush()

        db.add(models.Isletme(firebase_uid="entegrasyon-isletme", ad="Test", soyad="İşletme", telefon="05320000000",
                              email="isletme@entegrasyon.test", isletme_adi=SALON_ADI, durum="onaylandi",
                              salon_id=salon.id))
        gecmis = models.Musteri(firebase_uid="entegrasyon-gecmis", ad="Geçmiş", soyad="Müşteri",
                                telefon="05329999999", kvkk_onay_tarihi=simdi().isoformat())
        db.add(gecmis)
        db.flush()

        # Başlamış ama bitişi + 60 dk dolmamış → otomatik tamamlanmaz, panelde "Tamamlandı" düğmesi görünür
        bas = max(simdi() - timedelta(minutes=15), simdi().replace(hour=0, minute=0))
        hizmet = db.query(models.Hizmet).filter(models.Hizmet.salon_id == salon.id).first()
        r = models.Randevu(musteri_id=gecmis.id, berber_id=berber.id, salon_id=salon.id,
                           tarih=bas.date().isoformat(), saat=bas.strftime("%H:%M"), sure_dk=30, durum="onaylandi",
                           toplam_fiyat=hizmet.fiyat, olusturma=simdi().isoformat(), kaynak="panel")
        r.hizmetler = [hizmet]
        db.add(r)
        db.commit()
        print(f"salon_id={salon.id} berber_id={berber.id} gecmis_randevu={r.tarih} {r.saat}")
    finally:
        db.close()


if __name__ == "__main__":
    main()
