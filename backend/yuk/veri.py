"""Yük testi veri seti: 50 salon × 4 berber, salon başına 8 hizmet, 1000 müşteri (yük-musteri-0..999).

    DATABASE_URL=postgresql://... python yuk/veri.py

Tüm tabloları temizler. Yalnızca test veritabanında çalıştırın (ORTAM=production'da reddeder).
"""
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import text  # noqa: E402

import models  # noqa: E402
from config import ayarlar  # noqa: E402
from database import SessionLocal, engine  # noqa: E402

if ayarlar().uretim_mi:
    sys.exit("Production veritabanında çalıştırılamaz.")

SEHIRLER = ["İstanbul", "Ankara", "İzmir", "Konya", "Antalya", "Bursa"]
MENU = [("Saç Kesimi", 300, 30), ("Sakal", 150, 15), ("Saç & Sakal", 450, 45), ("Çocuk", 200, 20),
        ("Fön", 100, 15), ("Cilt Bakımı", 200, 20), ("Keratin", 500, 60), ("Boya", 500, 60)]


def main(salon_sayisi: int = 50, berber: int = 4, musteri: int = 1000) -> None:
    random.seed(42)
    tablolar = [t for t in reversed(models.Base.metadata.sorted_tables) if t.name != "alembic_version"]
    with engine.begin() as c:
        if engine.dialect.name == "postgresql":
            # ID sayaçları da sıfırlanmalı: locustfile salon 1..50 / berber 1..200 varsayar
            c.execute(text("TRUNCATE " + ", ".join(t.name for t in tablolar) + " RESTART IDENTITY CASCADE"))
        else:
            for t in tablolar:
                c.execute(t.delete())
    db = SessionLocal()
    for i in range(salon_sayisi):
        s = models.Salon(ad=f"Yük Salonu {i}", sehir=SEHIRLER[i % len(SEHIRLER)], ilce=f"İlçe {i % 7}",
                         acilis_saati="09:00", kapanis_saati="21:00", konum_lat=37 + random.random() * 4,
                         konum_long=27 + random.random() * 10, puan=round(3.5 + random.random() * 1.5, 1))
        db.add(s)
        db.flush()
        for j in range(berber):
            db.add(models.Berber(salon_id=s.id, ad=f"Berber{j}", soyad=f"S{i}", uzmanlik="Usta"))
        for ad, fiyat, sure in MENU:
            db.add(models.Hizmet(salon_id=s.id, ad=ad, fiyat=fiyat, sure=sure))
    for k in range(musteri):
        db.add(models.Musteri(firebase_uid=f"yuk-musteri-{k}", ad=f"Müşteri{k}", soyad="Yük",
                              telefon=f"0532{k:07d}", kvkk_onay_tarihi="2026-10-10T00:00:00"))
    db.commit()
    print(f"{salon_sayisi} salon, {salon_sayisi * berber} berber, {salon_sayisi * len(MENU)} hizmet, {musteri} müşteri")


if __name__ == "__main__":
    main()
