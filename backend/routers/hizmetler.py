from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import or_
from sqlalchemy.orm import Session

import fiyat_servisi as fs
import models
import slot_servisi as ss
from auth import admin_dogrula
from database import get_db

router = APIRouter(prefix="/hizmetler", tags=["Hizmet Menüsü"])


def _json(h: models.Hizmet) -> dict:
    return {"id": h.id, "ad": h.ad, "fiyat": h.fiyat, "sure": h.sure, "aciklama": h.aciklama, "salon_id": h.salon_id}


@router.get("/")
def hizmetleri_listele(salon_id: int | None = None, berber_id: int | None = None, db: Session = Depends(get_db)):
    """salon_id verilirse o salonun hizmetleri (+ varsa ortak hizmetler); verilmezse ortak hizmetler.

    - `berber_id` ile: yalnızca o berberin verdiği hizmetler, fiyat/süre o berbere göre.
    - Yalnızca salonla: her hizmete personel arasındaki fiyat/süre aralığı (`fiyat_min` … `sure_max`) eklenir;
      hiçbir personelin vermediği hizmet listelenmez.
    """
    if berber_id is not None:
        berber, salon = ss.berber_ve_salon(db, berber_id)
        salon_id = salon.id
    q = db.query(models.Hizmet).filter(models.Hizmet.aktif.is_(True))
    if salon_id is not None:
        q = q.filter(or_(models.Hizmet.salon_id == salon_id, models.Hizmet.salon_id.is_(None)))
    else:
        q = q.filter(models.Hizmet.salon_id.is_(None))
    hizmetler = q.order_by(models.Hizmet.id).all()
    if salon_id is None:
        return [_json(h) for h in hizmetler]
    kampanyalar = fs.aktif_kampanyalar(db, salon_id)

    def kampanya_yuzde(h: models.Hizmet) -> int:
        """Bu hizmete uyan aktif kampanyaların en yükseği (gün/saat koşulu salon detayında gösterilir)."""
        return max((k.yuzde for k in kampanyalar if fs.hizmete_uyar(k, h.id)), default=0)

    if berber_id is not None:
        ayar = ss.berber_ayarlari(db, [berber_id])[berber_id]
        return [{**_json(h), "fiyat": k.fiyat, "sure": k.sure, "kampanya_yuzde": kampanya_yuzde(h)}
                for h in hizmetler if (k := ss.kalem(h, ayar.get(h.id)))]
    berber_idler = [b for (b,) in db.query(models.Berber.id).filter(models.Berber.salon_id == salon_id,
                                                                     models.Berber.aktif.is_(True))]
    ayarlar_ = ss.berber_ayarlari(db, berber_idler)
    sonuc = []
    for h in hizmetler:
        kalemler = [k for b in berber_idler if (k := ss.kalem(h, ayarlar_[b].get(h.id)))]
        if berber_idler and not kalemler:
            continue
        kalemler = kalemler or [ss.Kalem(h, h.fiyat, h.sure)]
        sonuc.append({**_json(h), "kampanya_yuzde": kampanya_yuzde(h),
                      "fiyat_min": min(k.fiyat for k in kalemler), "fiyat_max": max(k.fiyat for k in kalemler),
                      "sure_min": min(k.sure for k in kalemler), "sure_max": max(k.sure for k in kalemler)})
    return sonuc


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
