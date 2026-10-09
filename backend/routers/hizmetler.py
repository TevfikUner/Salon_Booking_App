from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import or_
from sqlalchemy.orm import Session

import models
from auth import admin_dogrula
from database import get_db

router = APIRouter(prefix="/hizmetler", tags=["Hizmet Menüsü"])


def _json(h: models.Hizmet) -> dict:
    return {"id": h.id, "ad": h.ad, "fiyat": h.fiyat, "sure": h.sure, "aciklama": h.aciklama, "salon_id": h.salon_id}


@router.get("/")
def hizmetleri_listele(salon_id: int | None = None, db: Session = Depends(get_db)):
    """salon_id verilirse o salonun hizmetleri (+ varsa ortak hizmetler); verilmezse ortak hizmetler."""
    q = db.query(models.Hizmet).filter(models.Hizmet.aktif.is_(True))
    if salon_id is not None:
        q = q.filter(or_(models.Hizmet.salon_id == salon_id, models.Hizmet.salon_id.is_(None)))
    else:
        q = q.filter(models.Hizmet.salon_id.is_(None))
    return [_json(h) for h in q.order_by(models.Hizmet.id).all()]


# ── Admin (işletmeler kendi hizmetlerini /panel/hizmetler ile yönetir) ──

@router.post("/ekle", dependencies=[Depends(admin_dogrula)])
def hizmet_ekle(ad: str, fiyat: float, sure: int, aciklama: str | None = None, salon_id: int | None = None,
                db: Session = Depends(get_db)):
    h = models.Hizmet(ad=ad, fiyat=fiyat, sure=sure, aciklama=aciklama, salon_id=salon_id)
    db.add(h)
    db.commit()
    return {"mesaj": "Hizmet eklendi.", "id": h.id}


@router.put("/guncelle/{hizmet_id}", dependencies=[Depends(admin_dogrula)])
def hizmet_guncelle(hizmet_id: int, ad: str | None = None, fiyat: float | None = None, sure: int | None = None,
                    aciklama: str | None = None, db: Session = Depends(get_db)):
    h = db.get(models.Hizmet, hizmet_id)
    if not h:
        raise HTTPException(status_code=404, detail="Hizmet bulunamadı.")
    if ad:
        h.ad = ad
    if fiyat is not None:
        h.fiyat = fiyat
    if sure is not None:
        h.sure = sure
    if aciklama:
        h.aciklama = aciklama
    db.commit()
    return {"mesaj": "Hizmet güncellendi.", "hizmet": h.ad, "yeni_fiyat": h.fiyat}


@router.delete("/sil/{hizmet_id}", dependencies=[Depends(admin_dogrula)])
def hizmet_sil(hizmet_id: int, db: Session = Depends(get_db)):
    h = db.get(models.Hizmet, hizmet_id)
    if not h:
        raise HTTPException(status_code=404, detail="Hizmet bulunamadı.")
    h.aktif = False  # geçmiş randevular bu hizmete referans veriyor
    db.commit()
    return {"mesaj": f"'{h.ad}' hizmeti menüden kaldırıldı."}
