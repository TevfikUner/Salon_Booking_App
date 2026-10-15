from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy import case, func, or_
from sqlalchemy.orm import Session, joinedload

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


class DegerlendirmeIstegi(BaseModel):
    randevu_id: int
    puan: int
    yorum: str | None = Field(default=None, max_length=2000)


@router.post("")
def degerlendirme_gonder(veri: DegerlendirmeIstegi, kimlik: Kimlik = Depends(kimlik_gerekli),
                         db: Session = Depends(get_db)):
    """Müşteri tamamlanan randevusunu bir kez değerlendirir (1-5). Yorum kişisel veri olduğundan gövdede gelir
    (URL'deki sorgu parametreleri proxy/erişim loglarına düşer)."""
    return _degerlendir(db, kimlik, veri.randevu_id, veri.puan, veri.yorum)


@router.post("/ekle", deprecated=True)
def degerlendirme_ekle(
    randevu_id: int,
    puan: int,
    yorum: str | None = None,
    kimlik: Kimlik = Depends(kimlik_gerekli),
    db: Session = Depends(get_db),
):
    """Eski istemciler için (yorum sorgu parametresinde). Yeni istemciler POST /degerlendirmeler kullanır."""
    return _degerlendir(db, kimlik, randevu_id, puan, yorum)


def _degerlendir(db: Session, kimlik: Kimlik, randevu_id: int, puan: int, yorum: str | None) -> dict:
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
    tamamlanan = tamamlanan_sayilari(db, [berber_id]).get(berber_id, 0)
    if not liste:
        return {"ortalama_puan": None, "toplam": 0, "tamamlanan": tamamlanan, "yorumlar": []}
    return {
        "ortalama_puan": round(sum(d.puan for d in liste) / len(liste), 2),
        "toplam": len(liste),
        "tamamlanan": tamamlanan,
        "yorumlar": [{"puan": d.puan, "yorum": d.yorum, "tarih": d.tarih, "musteri": _kisa_ad(d.musteri)}
                     for d in liste[:50]],
    }


def tamamlanan_sayilari(db: Session, berber_idler: list[int]) -> dict[int, int]:
    """Berber başına tamamlanan randevu sayısı ("120 tıraş") — tek gruplu sorgu."""
    if not berber_idler:
        return {}
    return dict(db.query(models.Randevu.berber_id, func.count(models.Randevu.id)).filter(
        models.Randevu.berber_id.in_(berber_idler), models.Randevu.durum == "tamamlandi",
    ).group_by(models.Randevu.berber_id).all())


def degerlendirme_sayilari(db: Session, berber_idler: list[int]) -> dict[int, int]:
    if not berber_idler:
        return {}
    return dict(db.query(models.Degerlendirme.berber_id, func.count(models.Degerlendirme.id)).filter(
        models.Degerlendirme.berber_id.in_(berber_idler)).group_by(models.Degerlendirme.berber_id).all())


@router.get("/salon/{salon_id}")
def salon_degerlendirmeleri(salon_id: int, sayfa: int = Query(1, ge=1), adet: int = Query(20, ge=1, le=50),
                            db: Session = Depends(get_db)):
    """Salonun değerlendirmeleri: ortalama, 1–5 dağılımı ve sayfalı liste (yorum yazılanlar önce, yeniden eskiye)."""
    dagilim = {str(p): 0 for p in range(5, 0, -1)}
    for puan, sayi in db.query(models.Degerlendirme.puan, func.count(models.Degerlendirme.id)).filter(
            models.Degerlendirme.salon_id == salon_id).group_by(models.Degerlendirme.puan):
        if puan is not None and 1 <= puan <= 5:
            dagilim[str(puan)] = sayi
    toplam = sum(dagilim.values())
    ortalama = round(sum(int(p) * s for p, s in dagilim.items()) / toplam, 2) if toplam else None
    yorumsuz = or_(models.Degerlendirme.yorum.is_(None), models.Degerlendirme.yorum == "")
    satirlar = db.query(models.Degerlendirme).filter(models.Degerlendirme.salon_id == salon_id) \
        .options(joinedload(models.Degerlendirme.musteri), joinedload(models.Degerlendirme.berber)) \
        .order_by(case((yorumsuz, 1), else_=0), models.Degerlendirme.id.desc()) \
        .offset((sayfa - 1) * adet).limit(adet + 1).all()
    return {
        "ortalama_puan": ortalama,
        "toplam": toplam,
        "dagilim": dagilim,
        "sayfa": sayfa,
        "sonraki_var": len(satirlar) > adet,
        "yorumlar": [{"puan": d.puan, "yorum": d.yorum, "tarih": d.tarih, "musteri": _kisa_ad(d.musteri),
                      "berber": f"{d.berber.ad} {d.berber.soyad}".strip() if d.berber else ""}
                     for d in satirlar[:adet]],
    }
