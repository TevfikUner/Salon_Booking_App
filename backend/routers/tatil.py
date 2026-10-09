from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from auth import admin_dogrula
import models

router = APIRouter(prefix="/tatil", tags=["Tatil & Kapalı Günler"])


@router.post("/ekle")
def tatil_ekle(
    tarih: str,
    aciklama: str = None,
    salon_id: int | None = None,
    db: Session = Depends(get_db),
    _: None = Depends(admin_dogrula)  # 🔒 Sadece admin
):
    """
    Admin belirli bir günü kapalı ilan eder.
    tarih formatı: YYYY-MM-DD (örn: 2025-04-23)
    """
    # Format kontrolü
    try:
        from datetime import datetime
        datetime.strptime(tarih, "%Y-%m-%d")
    except ValueError:
        raise HTTPException(status_code=400, detail="Tarih formatı hatalı. Doğru format: YYYY-MM-DD") from None

    # Zaten var mı?
    var_mi = db.query(models.TatilGunu).filter(models.TatilGunu.tarih == tarih,
                                               models.TatilGunu.salon_id == salon_id).first()
    if var_mi:
        raise HTTPException(status_code=400, detail=f"{tarih} zaten tatil olarak işaretli.")

    yeni = models.TatilGunu(tarih=tarih, aciklama=aciklama, salon_id=salon_id)
    db.add(yeni)
    db.commit()
    return {"mesaj": f"{tarih} tatil günü olarak eklendi.", "aciklama": aciklama}


@router.delete("/sil/{tarih}")
def tatil_sil(
    tarih: str,
    db: Session = Depends(get_db),
    _: None = Depends(admin_dogrula)  # 🔒 Sadece admin
):
    """Belirtilen tarihi tatil listesinden kaldırır."""
    tatil = db.query(models.TatilGunu).filter(models.TatilGunu.tarih == tarih,
                                              models.TatilGunu.salon_id.is_(None)).first()
    if not tatil:
        raise HTTPException(status_code=404, detail="Bu tarih tatil listesinde yok.")

    db.delete(tatil)
    db.commit()
    return {"mesaj": f"{tarih} tatil listesinden kaldırıldı."}


@router.get("/liste")
def tatil_listesi(salon_id: int | None = None, db: Session = Depends(get_db)):
    """Genel tatiller + (salon_id verilirse) o salonun kapalı günleri."""
    from sqlalchemy import or_
    q = db.query(models.TatilGunu)
    if salon_id is not None:
        q = q.filter(or_(models.TatilGunu.salon_id.is_(None), models.TatilGunu.salon_id == salon_id))
    else:
        q = q.filter(models.TatilGunu.salon_id.is_(None))
    return [{"tarih": t.tarih, "aciklama": t.aciklama, "salon_id": t.salon_id}
            for t in q.order_by(models.TatilGunu.tarih).all()]
