"""Yük/yarış testinden sonra veri bütünlüğü: aynı berberde ÇAKIŞAN iki aktif randevu var mı?

    DATABASE_URL=postgresql://... python yuk/dogrula.py
Çıkış kodu 0 = çift randevu yok.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import text  # noqa: E402

from database import engine  # noqa: E402

# Bloklar slot_servisi.blok_dk ile aynı: süre 30'a yukarı yuvarlanır
SORGU = text("""
WITH r AS (
  SELECT id, berber_id, tarih,
         CAST(substr(saat, 1, 2) AS INTEGER) * 60 + CAST(substr(saat, 4, 2) AS INTEGER) AS bas,
         ((sure_dk + 29) / 30) * 30 AS blok
  FROM randevular WHERE durum = 'onaylandi'
)
SELECT a.id, b.id, a.berber_id, a.tarih
FROM r a JOIN r b ON a.berber_id = b.berber_id AND a.tarih = b.tarih AND a.id < b.id
 AND a.bas < b.bas + b.blok AND b.bas < a.bas + a.blok
""")

with engine.connect() as c:
    cakisma = c.execute(SORGU).fetchall()
    aktif = c.execute(text("SELECT count(*) FROM randevular WHERE durum = 'onaylandi'")).scalar()
    iptal = c.execute(text("SELECT count(*) FROM randevular WHERE durum = 'iptal'")).scalar()
print(f"aktif randevu={aktif} iptal={iptal} ÇAKIŞAN ÇİFT={len(cakisma)}")
for satir in cakisma[:10]:
    print("  ", satir)
sys.exit(1 if cakisma else 0)
