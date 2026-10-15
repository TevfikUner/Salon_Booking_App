import secrets

from fastapi import APIRouter, Depends, File, HTTPException, Request, UploadFile
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

import models
from auth import Kimlik, kimlik_gerekli, kimlik_gerekli_iptal_kontrollu, musteri_gerekli, musteri_getir_veya_olustur
from database import get_db
from depolama import depolama, dosya_anahtari, resmi_oku
from hesap_servisi import firebase_kullanicisini_sil, hesabi_anonimlestir
from koruma import SINIR_FOTO, SINIR_HASSAS, SINIR_KAYIT, limiter
from zaman import simdi

router = APIRouter(prefix="/musteriler", tags=["Müşteri"])


class KayitVerisi(BaseModel):
    ad: str = Field(min_length=1, max_length=60)
    soyad: str = Field(default="", max_length=60)
    telefon: str = Field(default="", max_length=20)
    kvkk_onay: bool = False
    ticari_ileti_izni: bool = False


@router.post("/kayit")
@limiter.limit(SINIR_KAYIT)
def musteri_kayit(request: Request, veri: KayitVerisi, kimlik: Kimlik = Depends(kimlik_gerekli),
                  db: Session = Depends(get_db)):
    """Uygulamada hesap oluşturulduktan sonra çağrılır. KVKK aydınlatma onayı zorunludur."""
    if not veri.kvkk_onay:
        raise HTTPException(status_code=400, detail="Devam etmek için KVKK Aydınlatma Metni'ni onaylamalısınız.")
    m = musteri_getir_veya_olustur(db, kimlik)
    m.ad, m.soyad, m.telefon = veri.ad.strip(), veri.soyad.strip(), veri.telefon.strip()
    m.kvkk_onay_tarihi = simdi().isoformat(timespec="seconds")
    m.ticari_ileti_izni = veri.ticari_ileti_izni
    db.commit()
    return {"mesaj": "Kayıt tamamlandı.", "id": m.id}


@router.post("/ekle", deprecated=True)
def musteri_ekle(ad: str, soyad: str = "", telefon: str = "", kimlik: Kimlik = Depends(kimlik_gerekli),
                 db: Session = Depends(get_db)):
    """Eski istemciler için. UID artık parametreden değil, oturum anahtarından alınır."""
    m = musteri_getir_veya_olustur(db, kimlik, ad, soyad, telefon)
    db.commit()
    return {"mesaj": "Müşteri kaydedildi.", "id": m.id}


@router.patch("/fcm-token-guncelle")
def fcm_token_guncelle(fcm_token: str, kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)):
    """Cihazın push token'ını kaydeder. İşletme/personel hesapları için de müşteri kaydı tutulur
    (bildirimler tek tablodan gider)."""
    # Aynı cihaz başka hesapta kayıtlıysa oradan kaldır (cihazı devralan hesap bildirimleri alır)
    db.query(models.Musteri).filter(models.Musteri.fcm_token == fcm_token,
                                    models.Musteri.firebase_uid != kimlik.uid).update({"fcm_token": None})
    m = musteri_getir_veya_olustur(db, kimlik)
    m.fcm_token = fcm_token
    db.commit()
    return {"mesaj": "Cihaz bildirimlere kaydedildi."}


def profil_getir(kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)):
    m = db.query(models.Musteri).filter(models.Musteri.firebase_uid == kimlik.uid).first()
    if not m:
        return {"ad": "", "soyad": "", "telefon": "", "favori_berber_id": None, "kvkk_onay": False,
                "ticari_ileti_izni": False, "foto_url": None}
    return {"ad": m.ad or "", "soyad": m.soyad or "", "telefon": m.telefon or "",
            "favori_berber_id": m.favori_berber_id, "kvkk_onay": bool(m.kvkk_onay_tarihi),
            "ticari_ileti_izni": m.ticari_ileti_izni, "foto_url": m.foto_url}


router.add_api_route("/profil", profil_getir, methods=["GET"])


@router.post("/profil-foto")
@limiter.limit(SINIR_FOTO)
def profil_foto_yukle(request: Request, foto: UploadFile = File(...), kimlik: Kimlik = Depends(kimlik_gerekli),
                      db: Session = Depends(get_db)):
    """İsteğe bağlı profil fotoğrafı (JPG/PNG/WebP, en fazla 5 MB). Dosya adı tahmin edilemez (rastgele önek +
    içerik özeti); eski fotoğraf depodan silinir."""
    icerik, uzanti = resmi_oku(foto)
    m = musteri_getir_veya_olustur(db, kimlik)
    d = depolama()
    eski = m.foto_url
    m.foto_url = d.kaydet(dosya_anahtari("musteriler", secrets.token_hex(8), icerik, uzanti), icerik, uzanti)
    db.commit()
    d.sil(eski)
    return {"mesaj": "Fotoğraf başarıyla yüklendi.", "foto_url": m.foto_url}


@router.delete("/profil-foto")
def profil_foto_sil(m: models.Musteri = Depends(musteri_gerekli), db: Session = Depends(get_db)):
    eski, m.foto_url = m.foto_url, None
    db.commit()
    depolama().sil(eski)
    return {"mesaj": "Profil fotoğrafı kaldırıldı."}


class ProfilVerisi(BaseModel):
    ad: str = Field(max_length=60)
    soyad: str = Field(max_length=60)
    telefon: str = Field(max_length=20)


def profil_guncelle_json(veri: ProfilVerisi, kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)):
    m = musteri_getir_veya_olustur(db, kimlik)
    m.ad, m.soyad, m.telefon = veri.ad.strip(), veri.soyad.strip(), veri.telefon.strip()
    db.commit()
    return {"mesaj": "Profil başarıyla güncellendi"}


router.add_api_route("/profil", profil_guncelle_json, methods=["PUT"])


@router.put("/profil-guncelle", deprecated=True)
def profil_guncelle(ad: str | None = None, soyad: str | None = None, telefon: str | None = None,
                    m: models.Musteri = Depends(musteri_gerekli), db: Session = Depends(get_db)):
    if ad:
        m.ad = ad
    if soyad:
        m.soyad = soyad
    if telefon:
        m.telefon = telefon
    db.commit()
    return {"mesaj": "Profil güncellendi.", "yeni_bilgiler": {"ad": m.ad, "soyad": m.soyad}}


def favori_toggle(berber_id: int, kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)):
    m = musteri_getir_veya_olustur(db, kimlik)
    berber = db.get(models.Berber, berber_id)
    if not berber:
        raise HTTPException(status_code=404, detail="Berber bulunamadı.")
    if berber in m.favori_berberler:
        m.favori_berberler.remove(berber)
        db.commit()
        return {"mesaj": f"{berber.ad} {berber.soyad} favorilerden çıkarıldı.", "favori": False}
    m.favori_berberler.append(berber)
    db.commit()
    return {"mesaj": f"{berber.ad} {berber.soyad} favorilere eklendi!", "favori": True}


def favori_listele(kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)):
    m = db.query(models.Musteri).filter(models.Musteri.firebase_uid == kimlik.uid).first()
    if not m:
        return []
    return [{
        "berber_id": b.id,
        "ad": b.ad,
        "soyad": b.soyad,
        "berber_ad": f"{b.ad} {b.soyad}".strip(),
        "salon_id": b.salon_id,
        "salon_ad": b.salon.ad if b.salon else "",
        "uzmanlik": b.uzmanlik,
        "puan": b.puan,
        "foto_url": b.foto_url,
    } for b in m.favori_berberler if b.aktif]


router.add_api_route("/favori-toggle", favori_toggle, methods=["POST"])
router.add_api_route("/favoriler", favori_listele, methods=["GET"])


@router.delete("/hesabim")
@limiter.limit(SINIR_HASSAS)
def hesap_sil(request: Request, kimlik: Kimlik = Depends(kimlik_gerekli_iptal_kontrollu),
              db: Session = Depends(get_db)):
    """KVKK / mağaza gereği hesap silme.

    Kişisel veriler anonimleştirilir; gelecek randevular iptal edilir. İşletmenin muhasebe
    kayıtları için geçmiş randevular kimliksiz olarak kalır. Token, Firebase'e sorularak (iptal/devre dışı
    kontrolüyle) doğrulanır ve Firebase kullanıcısı sunucuda silinir; `firebase_silindi` false ise
    (yerel geliştirme, servis hesabı yok) istemci kendi tarafında siler.
    """
    hesabi_anonimlestir(db, kimlik.uid)
    return {"mesaj": "Hesabınız ve kişisel verileriniz silindi.", "firebase_silindi": firebase_kullanicisini_sil(kimlik.uid)}
