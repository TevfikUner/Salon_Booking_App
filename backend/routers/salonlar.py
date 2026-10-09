"""Keşfet: salon listesi (filtre + konuma göre sıralama), salon detayı, filtre seçenekleri."""
import math

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

import models
from auth import Kimlik, kimlik_istege_bagli
from database import get_db

router = APIRouter(prefix="/salonlar", tags=["Keşfet"])

_TR_KUCUK = str.maketrans({"I": "ı", "İ": "i"})
_ASCII = str.maketrans("ıiğüşöçâîû", "iiguso caiu".replace(" ", ""))


def normalize(metin: str | None) -> str:
    """Türkçe büyük/küçük harf ve aksan farkını yok sayan karşılaştırma anahtarı.
    "İstanbul", "ISTANBUL", "istanbul" → "istanbul"; "Selçuklu" ↔ "Selcuklu"."""
    return (metin or "").strip().translate(_TR_KUCUK).lower().translate(_ASCII)


def mesafe_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """Haversine — iki koordinat arasındaki kuş uçuşu mesafe."""
    r = 6371.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp, dl = math.radians(lat2 - lat1), math.radians(lng2 - lng1)
    a = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * r * math.asin(math.sqrt(a))


def _salon_ozet(s: models.Salon, mesafe: float | None = None) -> dict:
    return {
        "id": s.id,
        "ad": s.ad,
        "adres": s.adres,
        "telefon": s.telefon,
        "foto_url": s.foto_url,
        "sehir": s.sehir,
        "ilce": s.ilce,
        "puan": s.puan,
        "acilis_saati": s.acilis_saati,
        "kapanis_saati": s.kapanis_saati,
        "pazar_acilis_saati": s.pazar_acilis_saati,
        "pazar_kapanis_saati": s.pazar_kapanis_saati,
        "kapali_gunler": s.kapali_gunler,
        "mesafe_km": round(mesafe, 1) if mesafe is not None else None,
    }


@router.get("")
def salonlari_listele(
    sehir: str | None = None,
    ilce: str | None = None,
    lat: float | None = Query(default=None, ge=-90, le=90),
    lng: float | None = Query(default=None, ge=-180, le=180),
    db: Session = Depends(get_db),
):
    """Aktif salonlar. Şehir/ilçe filtresi harf duyarsızdır. Konum verilirse yakından uzağa sıralanır."""
    salonlar = db.query(models.Salon).filter(models.Salon.aktif.is_(True)).all()
    if sehir:
        salonlar = [s for s in salonlar if normalize(s.sehir) == normalize(sehir)]
    if ilce:
        salonlar = [s for s in salonlar if normalize(s.ilce) == normalize(ilce)]
    if lat is not None and lng is not None:
        konumlu = [(s, mesafe_km(lat, lng, s.konum_lat, s.konum_long))
                   for s in salonlar if s.konum_lat is not None and s.konum_long is not None]
        konumsuz = [s for s in salonlar if s.konum_lat is None or s.konum_long is None]
        konumlu.sort(key=lambda x: x[1])
        return [_salon_ozet(s, m) for s, m in konumlu] + [_salon_ozet(s) for s in konumsuz]
    salonlar.sort(key=lambda s: (-(s.puan or 0), s.ad))
    return [_salon_ozet(s) for s in salonlar]


@router.get("/filtreler")
def filtre_secenekleri(db: Session = Depends(get_db)):
    """Salonu olan şehir ve ilçeler."""
    salonlar = db.query(models.Salon).filter(models.Salon.aktif.is_(True)).all()
    ilceler: dict[str, set] = {}
    for s in salonlar:
        if s.sehir:
            ilceler.setdefault(s.sehir, set())
            if s.ilce:
                ilceler[s.sehir].add(s.ilce)
    return {"sehirler": sorted(ilceler), "ilceler": {k: sorted(v) for k, v in ilceler.items()}}


@router.get("/{salon_id}")
def salon_detay(salon_id: int, kimlik: Kimlik | None = Depends(kimlik_istege_bagli), db: Session = Depends(get_db)):
    """Salon detayı: iletişim, konum, çalışma saatleri, ekip (oturum varsa favori bilgisiyle)."""
    salon = db.query(models.Salon).filter(models.Salon.id == salon_id, models.Salon.aktif.is_(True)).first()
    if not salon:
        raise HTTPException(status_code=404, detail="Salon bulunamadı.")
    fotograflar = db.query(models.SalonFotograf).filter(models.SalonFotograf.salon_id == salon_id) \
        .order_by(models.SalonFotograf.sira).all()
    berberler = db.query(models.Berber).filter(models.Berber.salon_id == salon_id, models.Berber.aktif.is_(True)) \
        .order_by(models.Berber.id).all()
    favori_idler: set[int] = set()
    if kimlik:
        m = db.query(models.Musteri).filter(models.Musteri.firebase_uid == kimlik.uid).first()
        if m:
            favori_idler = {b.id for b in m.favori_berberler}
    return {
        **_salon_ozet(salon),
        "instagram": salon.instagram_url,
        "whatsapp": salon.whatsapp,
        "konum": {"lat": salon.konum_lat, "lng": salon.konum_long},
        "fotograflar": [{"id": f.id, "foto_url": f.foto_url, "sira": f.sira} for f in fotograflar],
        "berberler": [{"id": b.id, "ad": b.ad, "soyad": b.soyad, "uzmanlik": b.uzmanlik, "puan": b.puan,
                       "foto_url": b.foto_url, "favori": b.id in favori_idler} for b in berberler],
    }
