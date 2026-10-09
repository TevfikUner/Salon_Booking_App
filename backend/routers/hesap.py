"""Oturumdaki kullanıcının rolü ve bağlamı — uygulama girişte buna göre yönlendirir."""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

import models
from auth import Kimlik, kimlik_gerekli, kullanici_cozumle
from database import get_db

router = APIRouter(tags=["Hesap"])


@router.get("/ben")
def ben(kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)):
    k = kullanici_cozumle(db, kimlik)

    # Personel daveti: işletmenin girdiği e-postayla ilk girişte hesabı berbere bağla.
    # E-posta DOĞRULANMIŞ olmalı; aksi halde biri personelin adresiyle hesap açıp salon verisine erişebilirdi.
    if k.rol == "musteri" and kimlik.email and kimlik.email_dogrulandi:
        davet = db.query(models.Berber).filter(models.Berber.email == kimlik.email.lower(),
                                               models.Berber.firebase_uid.is_(None),
                                               models.Berber.aktif.is_(True)).first()
        if davet:
            davet.firebase_uid = kimlik.uid
            db.commit()
            k = kullanici_cozumle(db, kimlik)

    salon = db.get(models.Salon, k.salon_id) if k.salon_id else None
    return {
        "uid": kimlik.uid,
        "rol": k.rol,
        "musteri_kayitli": bool(k.musteri and not k.musteri.silindi),
        "kvkk_onay": bool(k.musteri and k.musteri.kvkk_onay_tarihi),
        "email_dogrulandi": kimlik.email_dogrulandi,
        "isletme": {"id": k.isletme.id, "isletme_adi": k.isletme.isletme_adi, "durum": k.isletme.durum,
                    "salon_id": k.isletme.salon_id} if k.isletme else None,
        "berber": {"id": k.berber.id, "ad": f"{k.berber.ad} {k.berber.soyad}".strip()} if k.berber else None,
        "salon": {"id": salon.id, "ad": salon.ad} if salon else None,
    }
