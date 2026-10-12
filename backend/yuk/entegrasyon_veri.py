"""Flutter entegrasyon testleri (App/integration_test) için sabit veri.

    python yuk/entegrasyon_veri.py          (AUTH_MODE=dev olan yerel/test sunucusunda)

Kurar (her çalıştırmada sıfırdan):
- "Entegrasyon Salonu": her gün 00:00–23:30 açık (test günün hangi saatinde koşarsa koşsun boş saat bulunsun),
  1 berber, 2 hizmet
- Onaylı işletme hesabı  uid=entegrasyon-isletme  → bu salonun paneli
- Bugün, başlama saati geçmiş (henüz otomatik tamamlanmamış) bir randevu → panelde "Tamamlandı" testi için
- Müşteri uid=entegrasyon-musteri ve entegrasyon-kampanya SİLİNİR: testler kaydı kendisi yapar
- Yeni özellikler (yeni_ozellikler_test.dart): "İkinci Kalfa" Sakal vermez; "Sakal %20" kampanyası her gün;
  uid=entegrasyon-tekrar'ın 7 gün önce tamamlanmış randevusu (tekrar al); yarın 10:00 sürüklenecek randevu
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
            db.query(models.Kampanya).filter(models.Kampanya.salon_id == s.id).delete()
            for (bid,) in db.query(models.Berber.id).filter(models.Berber.salon_id == s.id):
                db.query(models.BerberHizmet).filter(models.BerberHizmet.berber_id == bid).delete()
            s.sadakat_esik = s.sadakat_yuzde = None
            s.min_onceden_dk = 0
        db.query(models.Isletme).filter(models.Isletme.firebase_uid == "entegrasyon-isletme").delete()
        for uid in ("entegrasyon-musteri", "entegrasyon-gecmis", "entegrasyon-kampanya", "entegrasyon-tekrar"):
            m = db.query(models.Musteri).filter(models.Musteri.firebase_uid == uid).first()
            if m:
                db.query(models.Randevu).filter(models.Randevu.musteri_id == m.id).delete()
                db.query(models.BeklemeListesi).filter(models.BeklemeListesi.musteri_id == m.id).delete()
                db.query(models.MusteriNotu).filter(models.MusteriNotu.musteri_id == m.id).delete()
                db.delete(m)
        db.flush()

        salon = eski[0] if eski else models.Salon(ad=SALON_ADI)
        salon.sehir, salon.ilce, salon.aktif = "Konya", "Selçuklu", True
        salon.acilis_saati, salon.kapanis_saati = "00:00", "23:30"
        salon.pazar_acilis_saati, salon.pazar_kapanis_saati = "00:00", "23:30"
        salon.kapali_gunler = ""
        db.add(salon)
        db.flush()

        berberler = db.query(models.Berber).filter(models.Berber.salon_id == salon.id).order_by(models.Berber.id).all()
        if not berberler:
            berberler = [models.Berber(salon_id=salon.id, ad="Test", soyad="Usta", uzmanlik="Usta")]
            db.add(berberler[0])
            db.flush()
        berber = berberler[0]
        if len(berberler) < 2:
            berberler.append(models.Berber(salon_id=salon.id, ad="İkinci", soyad="Kalfa", uzmanlik="Kalfa"))
            db.add(berberler[1])
        for b in berberler:
            b.aktif, b.kapali_gunler = True, ""
        if not db.query(models.Hizmet).filter(models.Hizmet.salon_id == salon.id).first():
            db.add_all([models.Hizmet(salon_id=salon.id, ad="Saç Kesimi", fiyat=300, sure=30),
                        models.Hizmet(salon_id=salon.id, ad="Sakal", fiyat=150, sure=15)])
        db.flush()
        kesim, sakal = (db.query(models.Hizmet).filter(models.Hizmet.salon_id == salon.id, models.Hizmet.ad == ad).first()
                        for ad in ("Saç Kesimi", "Sakal"))
        db.add(models.BerberHizmet(berber_id=berberler[1].id, hizmet_id=sakal.id, veriyor=False))
        db.add(models.Kampanya(salon_id=salon.id, ad="Sakal Kampanyası", yuzde=20, hizmet_idler=str(sakal.id),
                               olusturma=simdi().isoformat()))

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

        # Tekrar al: 7 gün önce tamamlanmış randevusu olan müşteri
        tekrar = models.Musteri(firebase_uid="entegrasyon-tekrar", ad="Tekrar", soyad="Müşteri",
                                telefon="05328888888", kvkk_onay_tarihi=simdi().isoformat())
        db.add(tekrar)
        db.flush()
        t = models.Randevu(musteri_id=tekrar.id, berber_id=berber.id, salon_id=salon.id,
                           tarih=(simdi() - timedelta(days=7)).date().isoformat(), saat="10:00", sure_dk=30,
                           durum="tamamlandi", toplam_fiyat=kesim.fiyat, olusturma=simdi().isoformat())
        t.hizmetler = [kesim]
        db.add(t)
        # Panel takviminde sürüklenecek: yarın 10:00
        y = models.Randevu(musteri_id=gecmis.id, berber_id=berber.id, salon_id=salon.id,
                           tarih=(simdi() + timedelta(days=1)).date().isoformat(), saat="10:00", sure_dk=30,
                           durum="onaylandi", toplam_fiyat=kesim.fiyat, olusturma=simdi().isoformat(), kaynak="panel")
        y.hizmetler = [kesim]
        db.add(y)
        db.commit()
        print(f"salon_id={salon.id} berber_id={berber.id} gecmis_randevu={r.tarih} {r.saat}")
    finally:
        db.close()


if __name__ == "__main__":
    main()
