"""İşletme paneli: Bugünün Akışı, randevu durumları, personel, hizmet, tatil/izin, rapor, salon ayarları.

Yetki: onaylı işletme sahibi (kendi salonu), admin (?salon_id=), personel (yalnızca okuma + kendi randevuları).
"""
from collections import Counter
from urllib.parse import quote

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field, field_validator
from sqlalchemy.orm import Session

import models
import randevu_servisi as rs
import slot_servisi as ss
from auth import PanelBaglami, panel_baglami, panel_yonetici
from database import get_db
from zaman import bugun, saat_dk, simdi

router = APIRouter(prefix="/panel", tags=["İşletme Paneli"])


# ─────────────────────────── Yardımcılar ───────────────────────────

def telefon_e164(tel: str | None) -> str | None:
    """'0532 123 45 67' / '5321234567' / '+90532…' → '905321234567'."""
    if not tel:
        return None
    rakam = "".join(c for c in tel if c.isdigit())
    if rakam.startswith("90") and len(rakam) == 12:
        return rakam
    if rakam.startswith("0") and len(rakam) == 11:
        return "9" + rakam
    if len(rakam) == 10 and rakam.startswith("5"):
        return "90" + rakam
    return rakam or None


def whatsapp_onay_linki(r: models.Randevu) -> str | None:
    tel = telefon_e164(r.musteri.telefon if r.musteri else None)
    if not tel:
        return None
    y, a, g = r.tarih.split("-")
    hizmet = ", ".join(h.ad for h in r.hizmetler)
    metin = (f"Merhaba {r.musteri.ad}, {r.salon.ad} olarak {g}.{a}.{y} {r.saat} "
             f"({hizmet}) randevunuzu hatırlatırız. Geliyorsanız lütfen 'Evet' yazarak onaylayın. "
             f"Gelemeyecekseniz haber verirseniz sıradaki müşterimize yer açabiliriz. Teşekkürler!")
    return f"https://wa.me/{tel}?text={quote(metin)}"


def _randevu_panel_json(db: Session, r: models.Randevu, skor_cache: dict) -> dict:
    if r.musteri_id not in skor_cache:
        skor_cache[r.musteri_id] = rs.guven_skoru(db, r.musteri_id)
    return {
        "id": r.id,
        "tarih": r.tarih,
        "saat": r.saat,
        "bitis": ss.bitis_saati(r),
        "sure_dk": r.sure_dk,
        "durum": r.durum,
        "kaynak": r.kaynak,
        "notlar": r.notlar,
        "toplam_fiyat": r.toplam_fiyat,
        "berber": {"id": r.berber_id, "ad": f"{r.berber.ad} {r.berber.soyad}".strip() if r.berber else ""},
        "musteri": {
            "id": r.musteri_id,
            "ad": f"{r.musteri.ad} {r.musteri.soyad}".strip() if r.musteri else "",
            "telefon": r.musteri.telefon if r.musteri else "",
        },
        "hizmetler": [{"id": h.id, "ad": h.ad, "fiyat": h.fiyat, "sure": h.sure} for h in r.hizmetler],
        "guven": skor_cache[r.musteri_id],
        "whatsapp_link": whatsapp_onay_linki(r) if r.durum == "onaylandi" else None,
    }


def _salon_randevusu(db: Session, randevu_id: int, p: PanelBaglami) -> models.Randevu:
    r = db.get(models.Randevu, randevu_id)
    if not r or r.salon_id != p.salon_id:
        raise HTTPException(status_code=404, detail="Randevu bulunamadı.")
    if p.berber_id is not None and r.berber_id != p.berber_id:
        raise HTTPException(status_code=403, detail="Yalnızca kendi randevularınızı yönetebilirsiniz.")
    return r


def _salon(db: Session, p: PanelBaglami) -> models.Salon:
    s = db.get(models.Salon, p.salon_id)
    if not s:
        raise HTTPException(status_code=404, detail="Salon bulunamadı.")
    return s


# ─────────────────────────── Bugünün Akışı (imza özellik) ───────────────────────────

@router.get("/akis")
def gunun_akisi(tarih: str | None = None, p: PanelBaglami = Depends(panel_baglami), db: Session = Depends(get_db)):
    """Seçilen günün (varsayılan bugün) randevuları saat sırasıyla + özet + güven skorları."""
    hedef = tarih or bugun().isoformat()
    ss.tarih_dogrula(hedef)
    salon = _salon(db, p)
    q = db.query(models.Randevu).filter(models.Randevu.salon_id == salon.id, models.Randevu.tarih == hedef)
    if p.berber_id is not None:
        q = q.filter(models.Randevu.berber_id == p.berber_id)
    randevular = q.order_by(models.Randevu.saat, models.Randevu.berber_id).all()
    cache: dict = {}
    liste = [_randevu_panel_json(db, r, cache) for r in randevular]

    gecerli = [r for r in randevular if r.durum != "iptal"]
    an = simdi()
    siradaki = None
    if hedef == an.date().isoformat():
        simdi_dk = an.hour * 60 + an.minute
        for x in liste:
            if x["durum"] == "onaylandi" and saat_dk(x["bitis"]) > simdi_dk:
                siradaki = x
                break

    berberler = db.query(models.Berber).filter(models.Berber.salon_id == salon.id, models.Berber.aktif.is_(True))
    if p.berber_id is not None:
        berberler = berberler.filter(models.Berber.id == p.berber_id)
    doluluk = []
    for b in berberler.all():
        m = ss.gun_musaitligi(db, salon, b.id, hedef, ss.ayarlar().slot_dk)
        dolu_dk = sum(r.sure_dk or 0 for r in gecerli if r.berber_id == b.id and r.durum == "onaylandi")
        doluluk.append({"berber_id": b.id, "ad": f"{b.ad} {b.soyad}".strip(), "bos_slot": len(m.musait),
                        "toplam_slot": len(m.tum), "dolu_dk": dolu_dk, "kapali_neden": m.kapali_neden})

    return {
        "tarih": hedef,
        "salon": {"id": salon.id, "ad": salon.ad},
        "ozet": {
            "randevu_sayisi": len(gecerli),
            "bekleyen": sum(1 for r in gecerli if r.durum == "onaylandi"),
            "tamamlanan": sum(1 for r in gecerli if r.durum == "tamamlandi"),
            "gelmedi": sum(1 for r in gecerli if r.durum == "gelmedi"),
            "iptal": sum(1 for r in randevular if r.durum == "iptal"),
            "toplam_sure_dk": sum(r.sure_dk or 0 for r in gecerli if r.durum != "gelmedi"),
            "beklenen_ciro": round(sum(r.toplam_fiyat or 0 for r in gecerli if r.durum in ("onaylandi", "tamamlandi")), 2),
            "gerceklesen_ciro": round(sum(r.toplam_fiyat or 0 for r in gecerli if r.durum == "tamamlandi"), 2),
            "riskli_sayisi": sum(1 for x in liste if x["durum"] == "onaylandi" and x["guven"]["etiket"] == "Riskli"),
        },
        "siradaki": siradaki,
        "doluluk": doluluk,
        "randevular": liste,
    }


class DurumIstegi(BaseModel):
    durum: str


@router.patch("/randevular/{randevu_id}/durum")
def randevu_durum(randevu_id: int, veri: DurumIstegi, p: PanelBaglami = Depends(panel_baglami),
                  db: Session = Depends(get_db)):
    r = _salon_randevusu(db, randevu_id, p)
    rs.durum_guncelle(db, r, veri.durum)
    return {"mesaj": "Randevu güncellendi.", "durum": r.durum}


class PanelRandevuIstegi(BaseModel):
    berber_id: int
    tarih: str
    saat: str
    hizmet_ids: list[int]
    musteri_ad: str = Field(min_length=1, max_length=80)
    musteri_telefon: str = Field(default="", max_length=20)
    notlar: str | None = Field(default=None, max_length=300)


@router.post("/randevular")
def panel_randevu_ekle(veri: PanelRandevuIstegi, p: PanelBaglami = Depends(panel_baglami),
                       db: Session = Depends(get_db)):
    """Telefonla/kapıdan gelen müşteri için randevu (takvim tek kaynak kalsın)."""
    berber, _ = ss.berber_ve_salon(db, veri.berber_id)
    if berber.salon_id != p.salon_id or (p.berber_id is not None and p.berber_id != berber.id):
        raise HTTPException(status_code=403, detail="Bu personel için randevu ekleyemezsiniz.")
    tel = veri.musteri_telefon.strip()
    musteri = None
    if tel:
        musteri = db.query(models.Musteri).filter(models.Musteri.telefon == tel,
                                                  models.Musteri.silindi.is_(False)).first()
    if not musteri:
        parca = veri.musteri_ad.strip().split(" ", 1)
        musteri = models.Musteri(ad=parca[0], soyad=parca[1] if len(parca) > 1 else "", telefon=tel,
                                 olusturma=simdi().isoformat(timespec="seconds"))
        db.add(musteri)
        db.flush()
    r = ss.randevu_olustur(db, musteri, berber.id, veri.tarih, veri.saat, veri.hizmet_ids, kaynak="panel",
                           notlar=veri.notlar)
    return {"mesaj": "Randevu eklendi.", "randevu": _randevu_panel_json(db, r, {})}


@router.get("/musait-saatler")
def panel_musait(berber_id: int, tarih: str, hizmet_ids: list[int] = Query(...),
                 p: PanelBaglami = Depends(panel_baglami), db: Session = Depends(get_db)):
    berber, salon = ss.berber_ve_salon(db, berber_id)
    if salon.id != p.salon_id:
        raise HTTPException(status_code=403, detail="Bu personel sizin salonunuzda değil.")
    sure = sum(h.sure for h in ss.hizmetleri_coz(db, salon.id, hizmet_ids))
    m = ss.gun_musaitligi(db, salon, berber.id, tarih, sure)
    return {"musait_saatler": m.musait, "kapali_neden": m.kapali_neden, "toplam_sure_dk": sure}


# ─────────────────────────── Personel ───────────────────────────

class PersonelVerisi(BaseModel):
    ad: str = Field(min_length=1, max_length=60)
    soyad: str = Field(default="", max_length=60)
    uzmanlik: str = Field(default="Berber", max_length=40)
    email: str | None = Field(default=None, max_length=120)
    whatsapp_no: str | None = None


def _personel_json(b: models.Berber) -> dict:
    return {"id": b.id, "ad": b.ad, "soyad": b.soyad, "uzmanlik": b.uzmanlik, "puan": b.puan,
            "foto_url": b.foto_url, "email": b.email, "hesap_bagli": bool(b.firebase_uid), "aktif": b.aktif}


@router.get("/personel")
def personel_listele(p: PanelBaglami = Depends(panel_baglami), db: Session = Depends(get_db)):
    q = db.query(models.Berber).filter(models.Berber.salon_id == p.salon_id, models.Berber.aktif.is_(True))
    return [_personel_json(b) for b in q.order_by(models.Berber.id).all()]


@router.post("/personel")
def personel_ekle(veri: PersonelVerisi, p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    b = models.Berber(salon_id=p.salon_id, ad=veri.ad.strip(), soyad=veri.soyad.strip(), uzmanlik=veri.uzmanlik,
                      email=(veri.email or "").strip().lower() or None, whatsapp_no=veri.whatsapp_no, puan=5.0)
    db.add(b)
    db.commit()
    return _personel_json(b)


@router.put("/personel/{berber_id}")
def personel_guncelle(berber_id: int, veri: PersonelVerisi, p: PanelBaglami = Depends(panel_yonetici),
                      db: Session = Depends(get_db)):
    b = db.get(models.Berber, berber_id)
    if not b or b.salon_id != p.salon_id:
        raise HTTPException(status_code=404, detail="Personel bulunamadı.")
    b.ad, b.soyad, b.uzmanlik = veri.ad.strip(), veri.soyad.strip(), veri.uzmanlik
    b.email = (veri.email or "").strip().lower() or None
    b.whatsapp_no = veri.whatsapp_no
    db.commit()
    return _personel_json(b)


@router.delete("/personel/{berber_id}")
def personel_cikar(berber_id: int, p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    b = db.get(models.Berber, berber_id)
    if not b or b.salon_id != p.salon_id:
        raise HTTPException(status_code=404, detail="Personel bulunamadı.")
    gelecek = db.query(models.Randevu).filter(models.Randevu.berber_id == b.id, models.Randevu.durum == "onaylandi",
                                              models.Randevu.tarih >= bugun().isoformat()).count()
    if gelecek:
        raise HTTPException(status_code=400,
                            detail=f"Bu personelin {gelecek} aktif randevusu var. Önce randevuları iptal edin veya taşıyın.")
    b.aktif = False  # geçmiş randevular bozulmasın diye kalıcı silinmez
    b.firebase_uid = None
    db.commit()
    return {"mesaj": f"{b.ad} {b.soyad} kadrodan çıkarıldı."}


# ─────────────────────────── Hizmetler ───────────────────────────

class HizmetVerisi(BaseModel):
    ad: str = Field(min_length=1, max_length=80)
    fiyat: float = Field(ge=0, le=100000)
    sure: int = Field(ge=5, le=480)
    aciklama: str | None = Field(default=None, max_length=300)


def _hizmet_json(h: models.Hizmet) -> dict:
    return {"id": h.id, "ad": h.ad, "fiyat": h.fiyat, "sure": h.sure, "aciklama": h.aciklama, "salon_id": h.salon_id}


@router.get("/hizmetler")
def hizmet_listele(p: PanelBaglami = Depends(panel_baglami), db: Session = Depends(get_db)):
    q = db.query(models.Hizmet).filter(models.Hizmet.salon_id == p.salon_id, models.Hizmet.aktif.is_(True))
    return [_hizmet_json(h) for h in q.order_by(models.Hizmet.id).all()]


@router.post("/hizmetler")
def hizmet_ekle(veri: HizmetVerisi, p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    h = models.Hizmet(salon_id=p.salon_id, **veri.model_dump())
    db.add(h)
    db.commit()
    return _hizmet_json(h)


@router.put("/hizmetler/{hizmet_id}")
def hizmet_guncelle(hizmet_id: int, veri: HizmetVerisi, p: PanelBaglami = Depends(panel_yonetici),
                    db: Session = Depends(get_db)):
    h = db.get(models.Hizmet, hizmet_id)
    if not h or h.salon_id != p.salon_id or not h.aktif:
        raise HTTPException(status_code=404, detail="Hizmet bulunamadı.")
    for k, v in veri.model_dump().items():
        setattr(h, k, v)  # mevcut randevuların fiyat/süresi mühürlü olduğu için etkilenmez
    db.commit()
    return _hizmet_json(h)


@router.delete("/hizmetler/{hizmet_id}")
def hizmet_kaldir(hizmet_id: int, p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    h = db.get(models.Hizmet, hizmet_id)
    if not h or h.salon_id != p.salon_id:
        raise HTTPException(status_code=404, detail="Hizmet bulunamadı.")
    h.aktif = False
    db.commit()
    return {"mesaj": f"'{h.ad}' menüden kaldırıldı."}


# ─────────────────────────── Tatil & izin ───────────────────────────

class GunVerisi(BaseModel):
    tarih: str
    aciklama: str | None = Field(default=None, max_length=120)

    @field_validator("tarih")
    @classmethod
    def _tarih(cls, v: str) -> str:
        ss.tarih_dogrula(v)
        return v


def _etkilenen_randevular(db: Session, salon_id: int, tarih: str, berber_id: int | None = None) -> int:
    q = db.query(models.Randevu).filter(models.Randevu.salon_id == salon_id, models.Randevu.tarih == tarih,
                                        models.Randevu.durum == "onaylandi")
    if berber_id:
        q = q.filter(models.Randevu.berber_id == berber_id)
    return q.count()


@router.get("/tatil")
def tatil_listele(p: PanelBaglami = Depends(panel_baglami), db: Session = Depends(get_db)):
    tatiller = db.query(models.TatilGunu).filter(models.TatilGunu.salon_id == p.salon_id,
                                                 models.TatilGunu.tarih >= bugun().isoformat()) \
        .order_by(models.TatilGunu.tarih).all()
    izinler = db.query(models.BerberIzin).join(models.Berber).filter(
        models.Berber.salon_id == p.salon_id, models.BerberIzin.tarih >= bugun().isoformat()
    ).order_by(models.BerberIzin.tarih).all()
    return {
        "tatiller": [{"id": t.id, "tarih": t.tarih, "aciklama": t.aciklama} for t in tatiller],
        "izinler": [{"id": i.id, "tarih": i.tarih, "aciklama": i.aciklama, "berber_id": i.berber_id,
                     "berber": f"{i.berber.ad} {i.berber.soyad}".strip()} for i in izinler],
    }


@router.post("/tatil")
def tatil_ekle(veri: GunVerisi, p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    if db.query(models.TatilGunu).filter_by(salon_id=p.salon_id, tarih=veri.tarih).first():
        raise HTTPException(status_code=400, detail="Bu gün zaten kapalı olarak işaretli.")
    db.add(models.TatilGunu(salon_id=p.salon_id, tarih=veri.tarih, aciklama=veri.aciklama))
    db.commit()
    etkilenen = _etkilenen_randevular(db, p.salon_id, veri.tarih)
    return {"mesaj": "Kapalı gün eklendi.", "etkilenen_randevu": etkilenen,
            "uyari": f"Bu günde {etkilenen} aktif randevu var; müşterilerinize haber verip iptal etmeyi unutmayın."
            if etkilenen else None}


@router.delete("/tatil/{tatil_id}")
def tatil_sil(tatil_id: int, p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    t = db.get(models.TatilGunu, tatil_id)
    if not t or t.salon_id != p.salon_id:
        raise HTTPException(status_code=404, detail="Kayıt bulunamadı.")
    db.delete(t)
    db.commit()
    return {"mesaj": "Kapalı gün kaldırıldı."}


class IzinVerisi(GunVerisi):
    berber_id: int


@router.post("/izin")
def izin_ekle(veri: IzinVerisi, p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    b = db.get(models.Berber, veri.berber_id)
    if not b or b.salon_id != p.salon_id:
        raise HTTPException(status_code=404, detail="Personel bulunamadı.")
    if db.query(models.BerberIzin).filter_by(berber_id=b.id, tarih=veri.tarih).first():
        raise HTTPException(status_code=400, detail=f"{b.ad} zaten o gün izinli.")
    db.add(models.BerberIzin(berber_id=b.id, tarih=veri.tarih, aciklama=veri.aciklama))
    db.commit()
    etkilenen = _etkilenen_randevular(db, p.salon_id, veri.tarih, b.id)
    return {"mesaj": f"{b.ad} için izin eklendi.", "etkilenen_randevu": etkilenen}


@router.delete("/izin/{izin_id}")
def izin_sil(izin_id: int, p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    i = db.get(models.BerberIzin, izin_id)
    if not i or not i.berber or i.berber.salon_id != p.salon_id:
        raise HTTPException(status_code=404, detail="Kayıt bulunamadı.")
    db.delete(i)
    db.commit()
    return {"mesaj": "İzin kaldırıldı."}


# ─────────────────────────── Rapor ───────────────────────────

@router.get("/rapor")
def aylik_rapor(yil: int | None = None, ay: int | None = Query(default=None, ge=1, le=12),
                p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    an = simdi()
    yil, ay = yil or an.year, ay or an.month
    onek = f"{yil}-{ay:02d}"
    randevular = db.query(models.Randevu).filter(models.Randevu.salon_id == p.salon_id,
                                                 models.Randevu.tarih.like(f"{onek}%")).all()
    tamam = [r for r in randevular if r.durum == "tamamlandi"]
    ciro = sum(r.toplam_fiyat or 0 for r in tamam)
    berber_ciro: Counter = Counter()
    hizmet_sayac: Counter = Counter()
    for r in tamam:
        berber_ciro[f"{r.berber.ad} {r.berber.soyad}".strip()] += r.toplam_fiyat or 0
        for h in r.hizmetler:
            hizmet_sayac[h.ad] += 1
    gelmedi = sum(1 for r in randevular if r.durum == "gelmedi")
    sonuclanan = len(tamam) + gelmedi
    return {
        "donem": f"{yil}/{ay:02d}",
        "toplam_randevu": len(randevular),
        "tamamlanan": len(tamam),
        "iptal": sum(1 for r in randevular if r.durum == "iptal"),
        "gelmedi": gelmedi,
        "gelmeme_orani": round(gelmedi / sonuclanan * 100, 1) if sonuclanan else 0,
        "toplam_ciro": round(ciro, 2),
        "ortalama_sepet": round(ciro / len(tamam), 2) if tamam else 0,
        "berber_ciro": [{"ad": k, "ciro": round(v, 2)} for k, v in berber_ciro.most_common()],
        "populer_hizmetler": [{"ad": k, "adet": v} for k, v in hizmet_sayac.most_common(5)],
        "uygulamadan_gelen": sum(1 for r in randevular if r.kaynak == "uygulama"),
    }


# ─────────────────────────── Salon ayarları ───────────────────────────

class SalonVerisi(BaseModel):
    ad: str = Field(min_length=1, max_length=80)
    adres: str | None = None
    telefon: str | None = None
    whatsapp: str | None = None
    instagram_url: str | None = None
    acilis_saati: str
    kapanis_saati: str
    pazar_acilis_saati: str
    pazar_kapanis_saati: str
    kapali_gunler: str = ""

    @field_validator("acilis_saati", "kapanis_saati", "pazar_acilis_saati", "pazar_kapanis_saati")
    @classmethod
    def _saat(cls, v: str) -> str:
        try:
            saat_dk(v)
        except ValueError:
            raise ValueError("Saat HH:MM biçiminde olmalı") from None
        return v


def _salon_json(s: models.Salon) -> dict:
    return {k: getattr(s, k) for k in ("id", "ad", "adres", "telefon", "whatsapp", "instagram_url", "sehir", "ilce",
                                       "acilis_saati", "kapanis_saati", "pazar_acilis_saati", "pazar_kapanis_saati",
                                       "kapali_gunler", "puan")}


@router.get("/salon")
def salon_getir(p: PanelBaglami = Depends(panel_baglami), db: Session = Depends(get_db)):
    return _salon_json(_salon(db, p))


@router.put("/salon")
def salon_guncelle(veri: SalonVerisi, p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    s = _salon(db, p)
    for k, v in veri.model_dump().items():
        setattr(s, k, v)
    db.commit()
    return _salon_json(s)
