"""İşletme paneli: Bugünün Akışı, randevu durumları, personel, hizmet, tatil/izin, rapor, salon ayarları.

Yetki: onaylı işletme sahibi (kendi salonu), admin (?salon_id=), personel (yalnızca okuma + kendi randevuları).
"""
from collections import Counter
from urllib.parse import quote

from fastapi import APIRouter, Depends, Header, HTTPException, Query, Request
from pydantic import BaseModel, Field, field_validator, model_validator
from sqlalchemy.orm import Session

import models
import randevu_servisi as rs
import slot_servisi as ss
from auth import PanelBaglami, panel_baglami, panel_yonetici
from database import get_db
from idempotency import idempotent
from koruma import SINIR_PANEL_YAZMA, limiter
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

    notlu = {mid for (mid,) in db.query(models.MusteriNotu.musteri_id).filter(
        models.MusteriNotu.salon_id == salon.id,
        models.MusteriNotu.musteri_id.in_({r.musteri_id for r in randevular}))}
    for x in liste:
        x["not_var"] = x["musteri"]["id"] in notlu

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
@limiter.limit(SINIR_PANEL_YAZMA)
def panel_randevu_ekle(request: Request, veri: PanelRandevuIstegi, p: PanelBaglami = Depends(panel_baglami),
                       idempotency_key: str | None = Header(default=None), db: Session = Depends(get_db)):
    """Telefonla/kapıdan gelen müşteri için randevu (takvim tek kaynak kalsın). Idempotency-Key destekler."""
    return idempotent(idempotency_key, f"panel:{p.salon_id}", lambda: _panel_randevu_ekle(veri, p, db))


def _panel_randevu_ekle(veri: PanelRandevuIstegi, p: PanelBaglami, db: Session) -> dict:
    berber, _ = ss.berber_ve_salon(db, veri.berber_id)
    if berber.salon_id != p.salon_id or (p.berber_id is not None and p.berber_id != berber.id):
        raise HTTPException(status_code=403, detail="Bu personel için randevu ekleyemezsiniz.")
    tel = veri.musteri_telefon.strip()
    musteri = None
    if tel:
        # Yalnızca uygulaması olmayan (panelden eklenmiş) müşteri kaydıyla eşleşir; kayıtlı bir kullanıcının
        # hesabına onun haberi olmadan randevu eklenmesin.
        musteri = db.query(models.Musteri).filter(models.Musteri.telefon == tel,
                                                  models.Musteri.firebase_uid.is_(None),
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
    sure = ss.toplam_sure(db, salon.id, hizmet_ids, berber.id)
    m = ss.gun_musaitligi(db, salon, berber.id, tarih, sure)
    return {"musait_saatler": m.musait, "kapali_neden": m.kapali_neden, "toplam_sure_dk": sure}


# ─────────────────────────── Müşteri kartı (mini CRM) ───────────────────────────

def _musteri_randevulari(db: Session, musteri_id: int, p: PanelBaglami) -> list[models.Randevu]:
    """Müşterinin bu salondaki randevuları (personel yalnızca kendisininkileri görür). Hiç yoksa 404:
    işletme, salonuna hiç gelmemiş bir müşterinin bilgisine erişemez."""
    q = db.query(models.Randevu).filter(models.Randevu.musteri_id == musteri_id,
                                        models.Randevu.salon_id == p.salon_id)
    if p.berber_id is not None:
        q = q.filter(models.Randevu.berber_id == p.berber_id)
    randevular = q.order_by(models.Randevu.tarih.desc(), models.Randevu.saat.desc()).all()
    if not randevular:
        raise HTTPException(status_code=404, detail="Müşteri bulunamadı.")
    return randevular


@router.get("/musteriler/{musteri_id}")
def musteri_karti(musteri_id: int, p: PanelBaglami = Depends(panel_baglami), db: Session = Depends(get_db)):
    """Müşterinin bu salondaki geçmişi, harcaması, en sık berber/hizmeti, güven skoru ve işletme notu."""
    randevular = _musteri_randevulari(db, musteri_id, p)
    m = db.get(models.Musteri, musteri_id)
    tamam = [r for r in randevular if r.durum == "tamamlandi"]
    berberler = Counter(f"{r.berber.ad} {r.berber.soyad}".strip() for r in tamam if r.berber)
    hizmetler = Counter(h.ad for r in tamam for h in r.hizmetler)
    notu = db.query(models.MusteriNotu).filter_by(salon_id=p.salon_id, musteri_id=musteri_id).first()
    return {
        "musteri": {"id": m.id, "ad": f"{m.ad} {m.soyad}".strip(), "telefon": "" if m.silindi else m.telefon,
                    "uygulama_kullanicisi": bool(m.firebase_uid)},
        "ozet": {
            "ziyaret": len(tamam),
            "son_ziyaret": tamam[0].tarih if tamam else None,
            "toplam_harcama": round(sum(r.toplam_fiyat or 0 for r in tamam), 2),
            "gelmedi": sum(1 for r in randevular if r.durum == "gelmedi"),
            "iptal": sum(1 for r in randevular if r.durum == "iptal"),
            "en_sik_berber": berberler.most_common(1)[0][0] if berberler else None,
            "en_sik_hizmetler": [ad for ad, _ in hizmetler.most_common(3)],
        },
        "guven": rs.guven_skoru(db, musteri_id),
        "not": {"metin": notu.metin, "guncelleme": notu.guncelleme, "guncelleyen": notu.guncelleyen} if notu else None,
        "son_randevular": [{"id": r.id, "tarih": r.tarih, "saat": r.saat, "durum": r.durum,
                            "berber": f"{r.berber.ad} {r.berber.soyad}".strip() if r.berber else "",
                            "hizmetler": [h.ad for h in r.hizmetler], "toplam_fiyat": r.toplam_fiyat}
                           for r in randevular[:10]],
    }


class NotVerisi(BaseModel):
    metin: str = Field(max_length=500)


@router.put("/musteriler/{musteri_id}/not")
def musteri_notu_kaydet(musteri_id: int, veri: NotVerisi, p: PanelBaglami = Depends(panel_baglami),
                        db: Session = Depends(get_db)):
    """Salonun müşteri notunu yazar; boş metin notu siler. İşletme ve personel (kendi müşterisi için) yazabilir."""
    _musteri_randevulari(db, musteri_id, p)
    notu = db.query(models.MusteriNotu).filter_by(salon_id=p.salon_id, musteri_id=musteri_id).first()
    metin = veri.metin.strip()
    if not metin:
        if notu:
            db.delete(notu)
            db.commit()
        return {"mesaj": "Not silindi.", "not": None}
    yazan = "İşletme"
    if p.berber_id is not None:
        b = db.get(models.Berber, p.berber_id)
        yazan = f"{b.ad} {b.soyad}".strip() if b else "Personel"
    if not notu:
        notu = models.MusteriNotu(salon_id=p.salon_id, musteri_id=musteri_id, metin=metin)
        db.add(notu)
    notu.metin, notu.guncelleme, notu.guncelleyen = metin, simdi().isoformat(timespec="minutes"), yazan
    db.commit()
    return {"mesaj": "Not kaydedildi.",
            "not": {"metin": notu.metin, "guncelleme": notu.guncelleme, "guncelleyen": notu.guncelleyen}}


# ─────────────────────────── Personel ───────────────────────────

def gun_listesi_dogrula(v: str | None) -> str | None:
    """Haftalık gün listesi: "0,6" (0=Pzt … 6=Paz). Sıralı ve tekrarsız saklanır."""
    if v is None:
        return None
    parcalar = [x.strip() for x in v.split(",") if x.strip()]
    if any(not x.isdigit() or not 0 <= int(x) <= 6 for x in parcalar):
        raise ValueError("Günler 0 (Pazartesi) ile 6 (Pazar) arasında olmalı")
    return ",".join(str(g) for g in sorted({int(x) for x in parcalar}))


class PersonelVerisi(BaseModel):
    ad: str = Field(min_length=1, max_length=60)
    soyad: str = Field(default="", max_length=60)
    uzmanlik: str = Field(default="Berber", max_length=40)
    email: str | None = Field(default=None, max_length=120)
    whatsapp_no: str | None = None
    # Haftalık izin günleri; gönderilmezse (None) mevcut değer korunur
    kapali_gunler: str | None = Field(default=None, max_length=20)

    @field_validator("kapali_gunler")
    @classmethod
    def _gunler(cls, v: str | None) -> str | None:
        return gun_listesi_dogrula(v)


def _personel_json(b: models.Berber) -> dict:
    return {"id": b.id, "ad": b.ad, "soyad": b.soyad, "uzmanlik": b.uzmanlik, "puan": b.puan,
            "foto_url": b.foto_url, "email": b.email, "hesap_bagli": bool(b.firebase_uid), "aktif": b.aktif,
            "kapali_gunler": b.kapali_gunler or ""}


@router.get("/personel")
def personel_listele(p: PanelBaglami = Depends(panel_baglami), db: Session = Depends(get_db)):
    q = db.query(models.Berber).filter(models.Berber.salon_id == p.salon_id, models.Berber.aktif.is_(True))
    berberler = q.order_by(models.Berber.id).all()
    ayarlar_ = ss.berber_ayarlari(db, [b.id for b in berberler])
    aktif_hizmet = {i for (i,) in db.query(models.Hizmet.id).filter(models.Hizmet.salon_id == p.salon_id,
                                                                     models.Hizmet.aktif.is_(True))}
    sonuc = []
    for b in berberler:
        ayar = [a for hid, a in ayarlar_[b.id].items() if hid in aktif_hizmet]
        sonuc.append({**_personel_json(b),
                      "vermedigi_hizmet_sayisi": sum(1 for a in ayar if not a.veriyor),
                      "ozel_fiyatli_hizmet_sayisi": sum(1 for a in ayar if a.veriyor)})
    return sonuc


@router.post("/personel")
def personel_ekle(veri: PersonelVerisi, p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    b = models.Berber(salon_id=p.salon_id, ad=veri.ad.strip(), soyad=veri.soyad.strip(), uzmanlik=veri.uzmanlik,
                      email=(veri.email or "").strip().lower() or None, whatsapp_no=veri.whatsapp_no, puan=5.0,
                      kapali_gunler=veri.kapali_gunler or "")
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
    if veri.kapali_gunler is not None:
        b.kapali_gunler = veri.kapali_gunler
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


class PersonelHizmetAyari(BaseModel):
    hizmet_id: int
    veriyor: bool = True
    # Boş (null) → menüdeki fiyat/süre geçerli
    fiyat: float | None = Field(default=None, ge=0, le=100000)
    sure: int | None = Field(default=None, ge=5, le=480)


def _personel(db: Session, p: PanelBaglami, berber_id: int) -> models.Berber:
    b = db.get(models.Berber, berber_id)
    if not b or b.salon_id != p.salon_id or not b.aktif:
        raise HTTPException(status_code=404, detail="Personel bulunamadı.")
    return b


def _personel_hizmetleri_json(db: Session, salon_id: int, berber_id: int) -> list[dict]:
    ayar = ss.berber_ayarlari(db, [berber_id])[berber_id]
    sonuc = []
    for h in db.query(models.Hizmet).filter(models.Hizmet.salon_id == salon_id, models.Hizmet.aktif.is_(True))             .order_by(models.Hizmet.id):
        a = ayar.get(h.id)
        sonuc.append({"hizmet_id": h.id, "ad": h.ad, "menu_fiyat": h.fiyat, "menu_sure": h.sure,
                      "veriyor": a.veriyor if a else True,
                      "fiyat": a.fiyat if a else None, "sure": a.sure if a else None})
    return sonuc


@router.get("/personel/{berber_id}/hizmetler")
def personel_hizmetleri(berber_id: int, p: PanelBaglami = Depends(panel_baglami), db: Session = Depends(get_db)):
    """Menüdeki her hizmet için bu personelin verip vermediği ve (varsa) kendine özel fiyatı/süresi."""
    _personel(db, p, berber_id)
    return _personel_hizmetleri_json(db, p.salon_id, berber_id)


@router.put("/personel/{berber_id}/hizmetler")
def personel_hizmetleri_kaydet(berber_id: int, veri: list[PersonelHizmetAyari],
                               p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    """Gönderilen hizmetlerin ayarını yazar. Menüyle aynı olan (veriyor, özel fiyat/süre yok) kayıt tutulmaz.
    Mevcut randevular etkilenmez (fiyat ve süre randevuda mühürlü)."""
    b = _personel(db, p, berber_id)
    menu = {h.id: h for h in db.query(models.Hizmet).filter(models.Hizmet.salon_id == p.salon_id,
                                                              models.Hizmet.aktif.is_(True))}
    mevcut = ss.berber_ayarlari(db, [b.id])[b.id]
    for a in veri:
        if a.hizmet_id not in menu:
            raise HTTPException(status_code=404, detail="Hizmet bu salonun menüsünde yok.")
        h = menu[a.hizmet_id]
        fiyat = None if a.fiyat is None or a.fiyat == h.fiyat else a.fiyat
        sure = None if a.sure is None or a.sure == h.sure else a.sure
        kayit = mevcut.get(h.id)
        if a.veriyor and fiyat is None and sure is None:
            if kayit:
                db.delete(kayit)
            continue
        if not kayit:
            kayit = models.BerberHizmet(berber_id=b.id, hizmet_id=h.id)
            db.add(kayit)
        kayit.veriyor, kayit.fiyat, kayit.sure = a.veriyor, fiyat, sure
    db.flush()
    yeni = ss.berber_ayarlari(db, [b.id])[b.id]
    if menu and all(ss.kalem(h, yeni.get(h.id)) is None for h in menu.values()):
        db.rollback()
        raise HTTPException(status_code=400, detail="Personel en az bir hizmet vermeli.")
    db.commit()
    return _personel_hizmetleri_json(db, p.salon_id, b.id)


# ─────────────────────────── Hizmetler ───────────────────────────

class HizmetVerisi(BaseModel):
    ad: str = Field(min_length=1, max_length=80)
    fiyat: float = Field(ge=0, le=100000)
    sure: int = Field(ge=5, le=480)
    aciklama: str | None = Field(default=None, max_length=300)


def _hizmet_json(h: models.Hizmet) -> dict:
    return {"id": h.id, "ad": h.ad, "fiyat": h.fiyat, "sure": h.sure, "aciklama": h.aciklama, "salon_id": h.salon_id}


@router.get("/hizmetler")
def hizmet_listele(berber_id: int | None = None, p: PanelBaglami = Depends(panel_baglami),
                   db: Session = Depends(get_db)):
    """Salonun menüsü. `berber_id` ile: yalnızca o personelin verdikleri, fiyat/süre ona göre."""
    q = db.query(models.Hizmet).filter(models.Hizmet.salon_id == p.salon_id, models.Hizmet.aktif.is_(True))
    hizmetler = q.order_by(models.Hizmet.id).all()
    if berber_id is None:
        return [_hizmet_json(h) for h in hizmetler]
    _personel(db, p, berber_id)
    ayar = ss.berber_ayarlari(db, [berber_id])[berber_id]
    return [{**_hizmet_json(h), "fiyat": k.fiyat, "sure": k.sure}
            for h in hizmetler if (k := ss.kalem(h, ayar.get(h.id)))]


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
    blokeler = db.query(models.SaatBloke).join(models.Berber).filter(
        models.Berber.salon_id == p.salon_id, models.SaatBloke.tarih >= bugun().isoformat()
    ).order_by(models.SaatBloke.tarih, models.SaatBloke.bas_saat).all()
    return {
        "tatiller": [{"id": t.id, "tarih": t.tarih, "aciklama": t.aciklama} for t in tatiller],
        "izinler": [{"id": i.id, "tarih": i.tarih, "aciklama": i.aciklama, "berber_id": i.berber_id,
                     "berber": f"{i.berber.ad} {i.berber.soyad}".strip()} for i in izinler],
        "blokeler": [{"id": b.id, "tarih": b.tarih, "bas_saat": b.bas_saat, "bit_saat": b.bit_saat,
                      "aciklama": b.aciklama, "berber_id": b.berber_id,
                      "berber": f"{b.berber.ad} {b.berber.soyad}".strip()} for b in blokeler],
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


class BlokeVerisi(GunVerisi):
    berber_id: int
    bas_saat: str
    bit_saat: str

    @field_validator("bas_saat", "bit_saat")
    @classmethod
    def _saat(cls, v: str) -> str:
        try:
            saat_dk(v)
        except (ValueError, TypeError):
            raise ValueError("Saat HH:MM biçiminde olmalı") from None
        return v


@router.post("/bloke")
def bloke_ekle(veri: BlokeVerisi, p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    """Berberi belirli bir günün belirli saatlerinde randevuya kapatır. Mevcut randevular silinmez, sayısı döner."""
    b = db.get(models.Berber, veri.berber_id)
    if not b or b.salon_id != p.salon_id or not b.aktif:
        raise HTTPException(status_code=404, detail="Personel bulunamadı.")
    bas, bit = saat_dk(veri.bas_saat), saat_dk(veri.bit_saat)
    if bit <= bas:
        raise HTTPException(status_code=400, detail="Bitiş saati başlangıçtan sonra olmalı.")
    if veri.tarih < bugun().isoformat():
        raise HTTPException(status_code=400, detail="Geçmiş bir güne bloke eklenemez.")
    db.add(models.SaatBloke(berber_id=b.id, tarih=veri.tarih, bas_saat=veri.bas_saat, bit_saat=veri.bit_saat,
                            aciklama=veri.aciklama))
    db.commit()
    randevular = db.query(models.Randevu).filter(models.Randevu.berber_id == b.id, models.Randevu.tarih == veri.tarih,
                                                 models.Randevu.durum == "onaylandi").all()
    etkilenen = sum(1 for r in randevular if ss.cakisiyor(bas, bit, saat_dk(r.saat), saat_dk(r.saat) + (r.sure_dk or 30)))
    return {"mesaj": f"{b.ad} için {veri.bas_saat}–{veri.bit_saat} kapatıldı.", "etkilenen_randevu": etkilenen}


@router.delete("/bloke/{bloke_id}")
def bloke_sil(bloke_id: int, p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    k = db.get(models.SaatBloke, bloke_id)
    if not k or not k.berber or k.berber.salon_id != p.salon_id:
        raise HTTPException(status_code=404, detail="Kayıt bulunamadı.")
    tarih, berber_id = k.tarih, k.berber_id
    db.delete(k)
    db.commit()
    rs.bekleme_listesine_haber_ver(db, berber_id, tarih)
    return {"mesaj": "Bloke kaldırıldı."}


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
    # Öğle arası: ikisi birlikte verilir; ikisi de null → mola yok. Gönderilmezse mevcut değer korunur.
    mola_baslangic: str | None = None
    mola_bitis: str | None = None

    @field_validator("acilis_saati", "kapanis_saati", "pazar_acilis_saati", "pazar_kapanis_saati",
                     "mola_baslangic", "mola_bitis")
    @classmethod
    def _saat(cls, v: str | None) -> str | None:
        if v is None:
            return v
        try:
            saat_dk(v)
        except ValueError:
            raise ValueError("Saat HH:MM biçiminde olmalı") from None
        return v

    @field_validator("kapali_gunler")
    @classmethod
    def _gunler(cls, v: str) -> str:
        return gun_listesi_dogrula(v)

    @model_validator(mode="after")
    def _mola(self):
        a, b = self.mola_baslangic, self.mola_bitis
        if (a is None) != (b is None):
            raise ValueError("Öğle arasının başlangıç ve bitişi birlikte girilmeli")
        if a is not None and saat_dk(b) <= saat_dk(a):
            raise ValueError("Öğle arası bitişi başlangıçtan sonra olmalı")
        return self


def _salon_json(s: models.Salon) -> dict:
    return {k: getattr(s, k) for k in ("id", "ad", "adres", "telefon", "whatsapp", "instagram_url", "sehir", "ilce",
                                       "acilis_saati", "kapanis_saati", "pazar_acilis_saati", "pazar_kapanis_saati",
                                       "kapali_gunler", "puan", "mola_baslangic", "mola_bitis")}


@router.get("/salon")
def salon_getir(p: PanelBaglami = Depends(panel_baglami), db: Session = Depends(get_db)):
    return _salon_json(_salon(db, p))


@router.put("/salon")
def salon_guncelle(veri: SalonVerisi, p: PanelBaglami = Depends(panel_yonetici), db: Session = Depends(get_db)):
    s = _salon(db, p)
    for k, v in veri.model_dump(exclude_unset=True).items():  # eski istemci mola alanlarını göndermezse korunur
        setattr(s, k, v)
    db.commit()
    return _salon_json(s)
