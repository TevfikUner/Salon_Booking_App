from depolama import depolama, dosya_anahtari, resmi_oku
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from auth import admin_dogrula
from sqlalchemy.orm import Session
from database import get_db
import models
import slot_servisi as ss
from routers.degerlendirmeler import degerlendirme_sayilari

router = APIRouter(prefix="/berberler", tags=["Berber Yönetimi"])

@router.post("/ekle")
def berber_ekle(
    ad: str,
    soyad: str,
    uzmanlik: str,  # Buraya "Usta", "Kalfa" gibi değerler gireceğiz
    foto_url: str = None,
    puan: float = 5.0,
    salon_id: int | None = None,
    db: Session = Depends(get_db),
    _: None = Depends(admin_dogrula)  # 🔒 Sadece admin ekleyebilir
):
    yeni_berber = models.Berber(
        ad=ad,
        soyad=soyad,
        uzmanlik=uzmanlik,
        foto_url=foto_url,
        puan=puan,
        salon_id=salon_id,
    )
    db.add(yeni_berber)
    db.commit()
    db.refresh(yeni_berber)
    return {
        "mesaj": "Yeni personel kadroya katıldı.",
        "berber": f"{yeni_berber.ad} ({yeni_berber.uzmanlik})"
    }
@router.get("/")
def berberleri_listele(salon_id: int | None = None, hizmet_ids: list[int] | None = Query(default=None),
                       db: Session = Depends(get_db)):
    """Aktif personel. `hizmet_ids` verilirse (salonla birlikte) her berbere `uygun` (seçilen hizmetlerin hepsini
    veriyor mu), vermedikleri ve bu berberdeki toplam fiyat/süre eklenir; uygunlar önce gelir."""
    q = db.query(models.Berber).filter(models.Berber.aktif.is_(True))
    if salon_id is not None:
        q = q.filter(models.Berber.salon_id == salon_id)
    berberler = q.order_by(models.Berber.id).all()
    sayilar = degerlendirme_sayilari(db, [b.id for b in berberler])
    liste = [{"id": b.id, "ad": b.ad, "soyad": b.soyad, "uzmanlik": b.uzmanlik, "foto_url": b.foto_url,
              "puan": b.puan, "salon_id": b.salon_id, "instagram_username": b.instagram_username,
              "degerlendirme_sayisi": sayilar.get(b.id, 0)}
             for b in berberler]
    if salon_id is None or not hizmet_ids:
        return liste
    hizmetler = ss.hizmetleri_coz(db, salon_id, hizmet_ids)
    ayarlar_ = ss.berber_ayarlari(db, [b.id for b in berberler])
    for x in liste:
        kalemler = [(h, ss.kalem(h, ayarlar_[x["id"]].get(h.id))) for h in hizmetler]
        uygun = [k for _, k in kalemler if k is not None]
        x["uygun"] = len(uygun) == len(kalemler)
        x["vermedigi_hizmetler"] = [h.ad for h, k in kalemler if k is None]
        x["toplam_fiyat"] = sum(k.fiyat for k in uygun) if x["uygun"] else None
        x["toplam_sure_dk"] = sum(k.sure for k in uygun) if x["uygun"] else None
    return sorted(liste, key=lambda x: not x["uygun"])

@router.put("/guncelle/{berber_id}")
def berber_guncelle(
    berber_id: int,
    ad: str = None,
    soyad: str = None,
    uzmanlik: str = None,
    foto_url: str = None,
    puan: float = None,
    db: Session = Depends(get_db),
    _: None = Depends(admin_dogrula)  # 🔒 Sadece admin güncelleyebilir
):
    berber = db.query(models.Berber).filter(models.Berber.id == berber_id).first()
    if not berber:
        raise HTTPException(status_code=404, detail="Berber bulunamadı.")

    if ad:

        berber.ad = ad
    if soyad:
        berber.soyad = soyad
    if uzmanlik:
        berber.uzmanlik = uzmanlik
    if foto_url:
        berber.foto_url = foto_url
    if puan is not None:
        berber.puan = puan

    db.commit()
    db.refresh(berber)
    return {"mesaj": "Berber bilgileri güncellendi.", "berber": f"{berber.ad} {berber.soyad}"}

@router.delete("/sil/{berber_id}")
def berber_sil(
    berber_id: int,
    db: Session = Depends(get_db),
    _: None = Depends(admin_dogrula)
):
    berber = db.query(models.Berber).filter(models.Berber.id == berber_id).first()
    if not berber:
        raise HTTPException(status_code=404, detail="Berber bulunamadı.")

    berber.aktif = False  # geçmiş randevular bozulmasın
    db.commit()
    return {"mesaj": f"{berber.ad} {berber.soyad} kadrodan çıkarıldı."}


# ============================================================
# BERBER İZİN YÖNETİMİ (7. Özellik)
# ============================================================

@router.post("/izin-ekle")
def berber_izin_ekle(
    berber_id: int,
    tarih: str,
    aciklama: str = None,
    db: Session = Depends(get_db),
    _: None = Depends(admin_dogrula)
):
    """Belirli bir berbere belirli bir gün için izin tanımlar."""
    from datetime import datetime
    try:
        datetime.strptime(tarih, "%Y-%m-%d")
    except ValueError:
        raise HTTPException(status_code=400, detail="Tarih formatı hatalı. Doğru format: YYYY-MM-DD") from None

    berber = db.query(models.Berber).filter(models.Berber.id == berber_id).first()
    if not berber:
        raise HTTPException(status_code=404, detail="Berber bulunamadı.")

    # Aynı gün zaten izinli mi?
    var_mi = db.query(models.BerberIzin).filter(
        models.BerberIzin.berber_id == berber_id,
        models.BerberIzin.tarih == tarih
    ).first()
    if var_mi:
        raise HTTPException(status_code=400, detail=f"{berber.ad} zaten o gün izinli.")

    yeni = models.BerberIzin(berber_id=berber_id, tarih=tarih, aciklama=aciklama)
    db.add(yeni)
    db.commit()
    return {"mesaj": f"{berber.ad} için {tarih} izin günü eklendi.", "aciklama": aciklama}


@router.delete("/izin-sil/{izin_id}")
def berber_izin_sil(
    izin_id: int,
    db: Session = Depends(get_db),
    _: None = Depends(admin_dogrula)
):
    izin = db.query(models.BerberIzin).filter(models.BerberIzin.id == izin_id).first()
    if not izin:
        raise HTTPException(status_code=404, detail="İzin kaydı bulunamadı.")
    db.delete(izin)
    db.commit()
    return {"mesaj": "İzin günü kaldırıldı."}


@router.get("/izinler/{berber_id}")
def berber_izinleri(berber_id: int, db: Session = Depends(get_db)):
    """Bir berberin tüm izin günlerini listeler. Herkese açık olduğundan izin açıklaması (örn. sağlık nedeni
    gibi kişisel bilgi içerebilir) döndürülmez."""
    izinler = db.query(models.BerberIzin).filter(
        models.BerberIzin.berber_id == berber_id
    ).order_by(models.BerberIzin.tarih).all()
    return [{"id": i.id, "tarih": i.tarih} for i in izinler]


# ============================================================
# FOTOĞRAF UPLOAD (8. Özellik)
# ============================================================

@router.post("/foto-yukle/{berber_id}")
def berber_foto_yukle(
    berber_id: int,
    foto: UploadFile = File(...),
    db: Session = Depends(get_db),
    _: None = Depends(admin_dogrula)
):
    """Berber profil fotoğrafını yükler (JPG/PNG/WebP, en fazla 5 MB) ve URL'yi kaydeder."""
    berber = db.query(models.Berber).filter(models.Berber.id == berber_id).first()
    if not berber:
        raise HTTPException(status_code=404, detail="Berber bulunamadı.")

    icerik, uzanti = resmi_oku(foto)
    d = depolama()
    eski = berber.foto_url
    berber.foto_url = d.kaydet(dosya_anahtari("berberler", f"berber_{berber_id}", icerik, uzanti), icerik, uzanti)
    db.commit()
    if eski != berber.foto_url:
        d.sil(eski)
    return {"mesaj": "Fotoğraf başarıyla yüklendi.", "foto_url": berber.foto_url}
