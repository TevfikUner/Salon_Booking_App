from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

import models
from auth import Kimlik, kimlik_gerekli
from database import get_db
from zaman import simdi

router = APIRouter(prefix="/degerlendirmeler", tags=["Değerlendirme & Puan"])


def _kisa_ad(m: models.Musteri | None) -> str:
    if not m or m.silindi:
        return "Anonim"
    soyad = (m.soyad or "").strip()
    return f"{m.ad} {soyad[0]}." if soyad else (m.ad or "Anonim")


@router.post("/ekle")
def degerlendirme_ekle(
    randevu_id: int,
    puan: int,
    yorum: str | None = None,
    kimlik: Kimlik = Depends(kimlik_gerekli),
    db: Session = Depends(get_db),
):
    """Müşteri tamamlanan randevusunu bir kez değerlendirir (1-5)."""
    if not (1 <= puan <= 5):
        raise HTTPException(status_code=400, detail="Puan 1 ile 5 arasında olmalı.")
    randevu = db.get(models.Randevu, randevu_id)
    if not randevu:
        raise HTTPException(status_code=404, detail="Randevu bulunamadı.")
    if not randevu.musteri or randevu.musteri.firebase_uid != kimlik.uid:
        raise HTTPException(status_code=403, detail="Bu randevu size ait değil.")
    if randevu.durum != "tamamlandi":
        raise HTTPException(status_code=400, detail="Sadece tamamlanan randevuları değerlendirebilirsiniz.")
    if randevu.puan is not None or db.query(models.Degerlendirme).filter_by(randevu_id=randevu_id).first():
        raise HTTPException(status_code=400, detail="Bu randevuyu zaten değerlendirdiniz.")

    yorum = (yorum or "").strip()[:500] or None
    db.add(models.Degerlendirme(musteri_id=randevu.musteri_id, berber_id=randevu.berber_id, salon_id=randevu.salon_id,
                                randevu_id=randevu_id, puan=puan, yorum=yorum, tarih=simdi().date().isoformat()))
    randevu.puan, randevu.yorum = puan, yorum
    db.flush()

    berber = db.get(models.Berber, randevu.berber_id)
    ort = db.query(func.avg(models.Degerlendirme.puan)).filter(models.Degerlendirme.berber_id == berber.id).scalar()
    berber.puan = round(float(ort or puan), 2)
    if randevu.salon_id:
        salon = db.get(models.Salon, randevu.salon_id)
        s_ort = db.query(func.avg(models.Degerlendirme.puan)).filter(
            models.Degerlendirme.salon_id == salon.id).scalar()
        salon.puan = round(float(s_ort or puan), 2)
    db.commit()
    return {"mesaj": "Değerlendirmeniz için teşekkürler!", "verilen_puan": puan, "berber_yeni_puan": berber.puan}


@router.get("/berber/{berber_id}")
def berber_degerlendirmeleri(berber_id: int, db: Session = Depends(get_db)):
    liste = db.query(models.Degerlendirme).filter(models.Degerlendirme.berber_id == berber_id) \
        .order_by(models.Degerlendirme.id.desc()).all()
    if not liste:
        return {"ortalama_puan": None, "toplam": 0, "yorumlar": []}
    return {
        "ortalama_puan": round(sum(d.puan for d in liste) / len(liste), 2),
        "toplam": len(liste),
        "yorumlar": [{"puan": d.puan, "yorum": d.yorum, "tarih": d.tarih, "musteri": _kisa_ad(d.musteri)}
                     for d in liste[:50]],
    }
