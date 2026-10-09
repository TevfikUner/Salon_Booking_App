from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

import models
from auth import Kimlik, admin_dogrula, kimlik_gerekli
from database import get_db
from zaman import simdi

router = APIRouter(prefix="/isletmeler", tags=["İşletme Başvurusu"])


@router.post("/kayit")
def isletme_kayit(
    ad: str,
    soyad: str,
    telefon: str,
    email: str,
    isletme_adi: str,
    kimlik: Kimlik = Depends(kimlik_gerekli),
    db: Session = Depends(get_db),
):
    """İşletme sahibi başvurusu. UID oturum anahtarından alınır; durum 'beklemede' başlar."""
    if db.query(models.Isletme).filter(models.Isletme.firebase_uid == kimlik.uid).first():
        raise HTTPException(status_code=400, detail="Bu hesapla zaten bir işletme başvurusu var.")
    yeni = models.Isletme(firebase_uid=kimlik.uid, ad=ad.strip(), soyad=soyad.strip(), telefon=telefon.strip(),
                          email=email.strip(), isletme_adi=isletme_adi.strip(), durum="beklemede",
                          olusturma=simdi().isoformat(timespec="seconds"))
    db.add(yeni)
    db.commit()
    return {"mesaj": "İşletme başvurunuz alındı! Onay bekleniyor.", "id": yeni.id, "durum": yeni.durum}


@router.get("/durum")
def isletme_durum(kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)):
    isletme = db.query(models.Isletme).filter(models.Isletme.firebase_uid == kimlik.uid).first()
    if not isletme:
        raise HTTPException(status_code=404, detail="İşletme başvurusu bulunamadı.")
    return {"id": isletme.id, "isletme_adi": isletme.isletme_adi, "durum": isletme.durum,
            "salon_id": isletme.salon_id}


# ── Admin: başvuru yönetimi ──────────────────────────────────

@router.get("/", dependencies=[Depends(admin_dogrula)])
def isletmeleri_listele(durum: str | None = None, db: Session = Depends(get_db)):
    q = db.query(models.Isletme)
    if durum:
        q = q.filter(models.Isletme.durum == durum)
    return [{"id": i.id, "isletme_adi": i.isletme_adi, "ad": i.ad, "soyad": i.soyad, "telefon": i.telefon,
             "email": i.email, "durum": i.durum, "salon_id": i.salon_id, "olusturma": i.olusturma}
            for i in q.order_by(models.Isletme.id.desc()).all()]


@router.post("/{isletme_id}/onayla", dependencies=[Depends(admin_dogrula)])
def isletme_onayla(isletme_id: int, salon_id: int | None = None, sehir: str | None = None, ilce: str | None = None,
                   db: Session = Depends(get_db)):
    """Başvuruyu onaylar. salon_id verilirse mevcut salona bağlar, verilmezse işletme adıyla yeni salon açar."""
    i = db.get(models.Isletme, isletme_id)
    if not i:
        raise HTTPException(status_code=404, detail="Başvuru bulunamadı.")
    if salon_id is not None:
        if not db.get(models.Salon, salon_id):
            raise HTTPException(status_code=404, detail="Salon bulunamadı.")
        i.salon_id = salon_id
    elif not i.salon_id:
        salon = models.Salon(ad=i.isletme_adi, telefon=i.telefon, whatsapp=i.telefon, sehir=sehir, ilce=ilce)
        db.add(salon)
        db.flush()
        i.salon_id = salon.id
    i.durum = "onaylandi"
    db.commit()
    return {"mesaj": f"{i.isletme_adi} onaylandı.", "salon_id": i.salon_id}


@router.post("/{isletme_id}/reddet", dependencies=[Depends(admin_dogrula)])
def isletme_reddet(isletme_id: int, db: Session = Depends(get_db)):
    i = db.get(models.Isletme, isletme_id)
    if not i:
        raise HTTPException(status_code=404, detail="Başvuru bulunamadı.")
    i.durum = "reddedildi"
    db.commit()
    return {"mesaj": f"{i.isletme_adi} başvurusu reddedildi."}
