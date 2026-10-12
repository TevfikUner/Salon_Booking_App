from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, BackgroundTasks, Depends, Header, HTTPException, Query, Request, Response
from pydantic import BaseModel
from sqlalchemy.orm import Session, joinedload, selectinload

import models
import fiyat_servisi as fs
import randevu_servisi as rs
import slot_servisi as ss
from auth import (Kimlik, Kullanici, admin_dogrula, aktif_kullanici, kimlik_gerekli, kimlik_istege_bagli,
                  musteri_gerekli, musteri_getir_veya_olustur, panel_yetkisi)
from bildirim import bildirim_gonder
from config import ayarlar
from database import get_db
from idempotency import idempotent
from koruma import SINIR_RANDEVU, limiter
from routers import musteriler
from takvim_dosyasi import randevu_ics
from zaman import bugun, saat_dk, simdi

router = APIRouter(prefix="/randevular", tags=["Randevu İşlemleri"])

GUN_ADLARI = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]


def randevu_json(r: models.Randevu) -> dict:
    return {
        "id": r.id,
        "berber_id": r.berber_id,
        "berber": f"{r.berber.ad} {r.berber.soyad}".strip() if r.berber else "",
        "salon_id": r.salon_id,
        "salon_ad": r.salon.ad if r.salon else "",
        "salon_telefon": r.salon.telefon if r.salon else None,
        "hizmetler": [h.ad for h in r.hizmetler],
        "hizmet_ids": [h.id for h in r.hizmetler],
        "tarih": r.tarih,
        "saat": r.saat,
        "bitis": ss.bitis_saati(r),
        "sure_dk": r.sure_dk,
        "durum": r.durum,
        "toplam_fiyat": r.toplam_fiyat,
        "liste_fiyati": r.liste_fiyati if r.liste_fiyati is not None else r.toplam_fiyat,
        "indirim_tutari": r.indirim_tutari or 0,
        "indirim_aciklama": r.indirim_aciklama,
        "kampanyali": r.kampanya_id is not None,
        "puan": r.puan,
        "yorum": r.yorum,
        "iptal_eden": r.iptal_eden,
        "erteleme_hakki": rs.erteleme_hakki(r),
    }


def _salon_bul(db: Session, berber_id: int | None, salon_id: int | None) -> models.Salon:
    if berber_id is not None:
        return ss.berber_ve_salon(db, berber_id)[1]
    if salon_id is not None:
        salon = db.query(models.Salon).filter(models.Salon.id == salon_id, models.Salon.aktif.is_(True)).first()
        if salon:
            return salon
    raise HTTPException(status_code=400, detail="berber_id veya salon_id gerekli.")


def _sure_hesapla(db: Session, salon_id: int, hizmet_ids: list[int], berber_id: int | None) -> int:
    """Seçilen hizmetlerin toplam süresi; berber verilmişse o berbere özel süreler."""
    return ss.toplam_sure(db, salon_id, hizmet_ids, berber_id)


# ── 1. Müsait takvim ─────────────────────────────────────────
@router.get("/musait-takvim")
def musait_takvim_getir(berber_id: int | None = None, salon_id: int | None = None,
                        hizmet_ids: list[int] | None = Query(default=None), db: Session = Depends(get_db)):
    """Rezervasyon ufku içindeki açık günler. Tatil, kapalı gün ve (berber verilmişse) izin günleri hariç.
    Berber ve hizmetler verilirse her güne `bos_slot` (hizmetin sığdığı başlangıç sayısı) ve `dolu` eklenir."""
    salon = _salon_bul(db, berber_id, salon_id)
    gunler = []
    aday = [bugun() + timedelta(days=i) for i in range(ayarlar().rezervasyon_ufku_gun + 1)]
    nedenler = ss.kapali_nedenler(db, salon, berber_id, aday)
    acik = []
    for gun in aday:
        if nedenler[gun]:
            continue
        acilis, kapanis = ss.gun_mesaisi(salon, gun)
        if gun == bugun() and simdi().hour * 60 + simdi().minute >= kapanis - ss.blok_dk(1):
            continue
        acik.append(gun)
        gunler.append({
            "tarih": gun.isoformat(),
            "acilis": ss.dk_saat(acilis),
            "kapanis": ss.dk_saat(kapanis),
            "gun_adi": GUN_ADLARI[gun.weekday()],
            "tatil": False,
            "berber_izin": False,
        })
    if berber_id is not None and hizmet_ids:
        kalemler = ss.hizmet_kalemleri(db, salon.id, hizmet_ids, berber_id)
        sayilar = ss.gunluk_bos_sayilari(db, salon, berber_id, acik, sum(k.sure for k in kalemler))
        kampanyalar = fs.aktif_kampanyalar(db, salon.id)
        liste = sum(k.fiyat for k in kalemler)
        for g, kayit in zip(acik, gunler, strict=True):
            kayit["bos_slot"] = sayilar[g]
            kayit["dolu"] = sayilar[g] == 0
            # O günün herhangi bir saatinde geçerli en yüksek kampanya indirimi (takvimde "%" işareti için)
            tutar, _ = fs.kampanya_indirimi(kampanyalar, kalemler, g, None)
            kayit["indirim_yuzde"] = round(tutar / liste * 100) if liste and tutar else 0
    return gunler


# ── 1b. Salon istatistiği (keşfet/detay) ─────────────────────
@router.get("/istatistik")
def istatistik_getir(salon_id: int | None = None, db: Session = Depends(get_db)):
    berber_sorgu = db.query(models.Berber).filter(models.Berber.aktif.is_(True))
    if salon_id:
        berber_sorgu = berber_sorgu.filter(models.Berber.salon_id == salon_id)
    berberler = berber_sorgu.all()
    bos = {"bugunku_randevu": 0, "musait_slot_sayisi": 0, "toplam_slot": 0, "aktif_berber": len(berberler)}
    if not berberler:
        return bos
    toplam = musait = randevu = 0
    for b in berberler:
        if not b.salon:
            continue
        m = ss.gun_musaitligi(db, b.salon, b.id, bugun().isoformat(), ayarlar().slot_dk)
        toplam += len(m.tum)
        musait += len(m.musait)
    randevu = db.query(models.Randevu).filter(
        models.Randevu.tarih == bugun().isoformat(),
        models.Randevu.durum == "onaylandi",
        models.Randevu.berber_id.in_([b.id for b in berberler]),
    ).count()
    return {"bugunku_randevu": randevu, "musait_slot_sayisi": musait, "toplam_slot": toplam,
            "aktif_berber": len(berberler)}


# ── 2. Müsait saatler (tek doğruluk kaynağı) ─────────────────
@router.get("/musait-saatler/{berber_id}")
def musait_saatleri_getir(
    berber_id: int, tarih: str, hizmet_ids: list[int] = Query(...), ertelenen_id: int | None = None,
    kimlik: Kimlik | None = Depends(kimlik_istege_bagli), db: Session = Depends(get_db),
):
    """`ertelenen_id`: müşterinin ertelediği kendi randevusu; onun eski yeri dolu sayılmaz (yalnızca sahibine)."""
    _, salon = ss.berber_ve_salon(db, berber_id)
    haric = None
    if ertelenen_id is not None:
        if kimlik is None:
            raise HTTPException(status_code=401, detail="Oturum gerekli.")
        r = _musteri_randevusu(db, ertelenen_id, kimlik)
        if r.berber_id != berber_id:
            raise HTTPException(status_code=400, detail="Randevu bu personele ait değil.")
        # Süre randevuda mühürlü: hizmet sonradan menüden kaldırılmış olsa da erteleme engellenmesin
        haric, sure = r.id, r.sure_dk or ayarlar().slot_dk
    else:
        sure = _sure_hesapla(db, salon.id, hizmet_ids, berber_id)
    m = ss.gun_musaitligi(db, salon, berber_id, tarih, sure, haric_id=haric)
    musait = set(m.musait)
    indirimler: dict[str, int] = {}
    korunan: list[str] | None = None
    if haric:
        # Ertelemede yeni indirim kazanılmaz; kampanyalı randevunun indirimi yalnızca bu saatlerde korunur
        if r.kampanya_id:
            gun = ss.tarih_dogrula(tarih)
            korunan = [s for s in m.musait if fs.ertelemede_kampanya_korunur(db, r, gun, s)]
    elif m.musait:
        kalemler = ss.hizmet_kalemleri(db, salon.id, hizmet_ids, berber_id)
        indirimler = fs.slot_yuzdeleri(fs.aktif_kampanyalar(db, salon.id), kalemler, ss.tarih_dogrula(tarih),
                                       m.musait)
    return {
        "tarih": tarih,
        "berber_id": berber_id,
        "toplam_sure_dk": sure,
        "gerekli_slot": ss.blok_dk(sure) // ayarlar().slot_dk,
        "kapali_neden": m.kapali_neden,
        "musait_saatler": m.musait,
        "tum_saatler": m.tum,
        "dolu_slotlar": [s for s in m.tum if s not in musait],
        "indirimler": indirimler,  # saat → kampanya indirim yüzdesi (yalnızca indirimli müsait saatler)
        "kampanya_korunan_saatler": korunan,  # yalnızca kampanyalı randevu ertelenirken
    }


@router.get("/dolu-saatler/{berber_id}", deprecated=True)
def dolu_saatleri_getir(berber_id: int, tarih: str, db: Session = Depends(get_db)):
    """Eski istemciler için: 30 dk'lık hizmete göre müsait olmayan saatler."""
    _, salon = ss.berber_ve_salon(db, berber_id)
    m = ss.gun_musaitligi(db, salon, berber_id, tarih, ayarlar().slot_dk)
    return [s for s in m.tum if s not in set(m.musait)]


@router.get("/en-yakin/{berber_id}")
def en_yakin_bos(berber_id: int, hizmet_ids: list[int] = Query(...), adet: int = Query(3, ge=1, le=10),
                 db: Session = Depends(get_db)):
    """Akıllı en yakın boş slot önerisi."""
    _, salon = ss.berber_ve_salon(db, berber_id)
    sure = _sure_hesapla(db, salon.id, hizmet_ids, berber_id)
    return {"toplam_sure_dk": sure, "slotlar": ss.en_yakin_slotlar(db, salon, berber_id, sure, adet)}


# ── 3. Randevu oluşturma ─────────────────────────────────────
@router.post("/olustur")
@limiter.limit(SINIR_RANDEVU)
def randevu_olustur(
    request: Request,
    arka_plan: BackgroundTasks,
    berber_id: int,
    saat: str,
    tarih: str,
    hizmet_ids: list[int] = Query(...),
    ad: str = Query(default="", max_length=60),
    soyad: str = Query(default="", max_length=60),
    telefon: str = Query(default="", max_length=20),
    idempotency_key: str | None = Header(default=None),
    kimlik: Kimlik = Depends(kimlik_gerekli),
    db: Session = Depends(get_db),
):
    """Randevu oluşturur. `Idempotency-Key` başlığıyla tekrarlanan istek ikinci randevu oluşturmaz."""
    return idempotent(idempotency_key, kimlik.uid, lambda: _randevu_olustur(
        arka_plan, berber_id, saat, tarih, hizmet_ids, ad, soyad, telefon, kimlik, db))


def _randevu_olustur(arka_plan: BackgroundTasks, berber_id: int, saat: str, tarih: str, hizmet_ids: list[int],
                     ad: str, soyad: str, telefon: str, kimlik: Kimlik, db: Session) -> dict:
    musteri = musteri_getir_veya_olustur(db, kimlik, ad.strip(), soyad.strip(), telefon.strip())
    if musteri.silindi:
        raise HTTPException(status_code=403, detail="Bu hesap silinmiş.")
    # İlk randevuda girilen iletişim bilgileri boş alanları tamamlar
    if ad.strip() and musteri.ad in ("", "Misafir"):
        musteri.ad = ad.strip()
    if soyad.strip() and not musteri.soyad:
        musteri.soyad = soyad.strip()
    if telefon.strip() and not musteri.telefon:
        musteri.telefon = telefon.strip()

    r = ss.randevu_olustur(db, musteri, berber_id, tarih, saat, hizmet_ids)
    db.query(models.BeklemeListesi).filter(
        models.BeklemeListesi.musteri_id == musteri.id,
        models.BeklemeListesi.berber_id == berber_id,
        models.BeklemeListesi.tarih == tarih,
    ).delete()
    db.commit()

    if musteri.fcm_token:  # bildirim (ağ çağrısı) yanıtı bekletmesin
        arka_plan.add_task(bildirim_gonder, musteri.fcm_token, "Randevunuz onaylandı 💈",
                           f"{r.salon.ad} — {tarih} {saat}, {r.berber.ad} {r.berber.soyad}. "
                           f"Toplam: {r.toplam_fiyat:.0f} ₺", {"type": "randevu", "randevu_id": r.id})
    rs.salona_bildir(db, r, "Yeni randevu 💈", ", ".join(h.ad for h in r.hizmetler), arka_plan)
    return {
        "mesaj": "Randevu başarıyla alındı!",
        "randevu_id": r.id,
        "saat": r.saat,
        "bitis": ss.bitis_saati(r),
        "tarih": r.tarih,
        "salon_ad": r.salon.ad,
        "toplam_sure_dk": r.sure_dk,
        "toplam_fiyat": r.toplam_fiyat,
        "liste_fiyati": r.liste_fiyati,
        "indirim_tutari": r.indirim_tutari,
        "indirim_aciklama": r.indirim_aciklama,
        "detay": f"Toplam {len(r.hizmetler)} hizmet, {r.sure_dk} dakika, {r.toplam_fiyat:.0f} TL",
    }


@router.get("/fiyat")
def fiyat_teklifi(berber_id: int, tarih: str, saat: str, hizmet_ids: list[int] = Query(...),
                  kimlik: Kimlik | None = Depends(kimlik_istege_bagli), db: Session = Depends(get_db)):
    """Onay öncesi özet: liste fiyatı, uygulanacak indirim (kampanya veya oturum varsa sadakat) ve toplam.
    Randevu oluşturulurken aynı hesap kilit altında tekrarlanır."""
    _, salon = ss.berber_ve_salon(db, berber_id)
    kalemler = ss.hizmet_kalemleri(db, salon.id, hizmet_ids, berber_id)
    musteri_id = None
    if kimlik:
        m = db.query(models.Musteri).filter(models.Musteri.firebase_uid == kimlik.uid).first()
        musteri_id = m.id if m else None
    try:
        saat_dk(saat)
    except (ValueError, TypeError):
        raise HTTPException(status_code=400, detail="Geçersiz saat formatı. Örnek: 14:30") from None
    return fs.fiyat_hesapla(db, salon, kalemler, ss.tarih_dogrula(tarih), saat, musteri_id).json()


# ── 4. Müşterinin randevuları ────────────────────────────────
@router.get("/benim-randevularim")
def benim_randevularim(musteri: models.Musteri = Depends(musteri_gerekli), db: Session = Depends(get_db)):
    randevular = db.query(models.Randevu).filter(models.Randevu.musteri_id == musteri.id) \
        .options(selectinload(models.Randevu.hizmetler), joinedload(models.Randevu.berber),
                 joinedload(models.Randevu.salon)) \
        .order_by(models.Randevu.tarih.desc(), models.Randevu.saat.desc()).limit(200).all()
    return [randevu_json(r) for r in randevular]


@router.get("/her-zamanki")
def her_zamanki(musteri: models.Musteri = Depends(musteri_gerekli), db: Session = Depends(get_db)):
    """İmza özellik: en sık alınan berber+hizmet ve en yakın boş slotlar. Geçmiş yoksa null."""
    return rs.her_zamanki(db, musteri)


# ── 5. İptal ─────────────────────────────────────────────────
def _musteri_randevusu(db: Session, randevu_id: int, kimlik: Kimlik) -> models.Randevu:
    r = db.get(models.Randevu, randevu_id)
    if not r:
        raise HTTPException(status_code=404, detail="Randevu bulunamadı.")
    if not r.musteri or r.musteri.firebase_uid != kimlik.uid:
        raise HTTPException(status_code=403, detail="Bu randevu size ait değil.")
    return r


@router.post("/{randevu_id}/iptal")
def randevu_iptal(randevu_id: int, kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)):
    r = _musteri_randevusu(db, randevu_id, kimlik)
    rs.musteri_iptal(db, r)
    return {"mesaj": "Randevunuz iptal edildi.", "randevu": randevu_json(r)}


class ErtelemeIstegi(BaseModel):
    tarih: str
    saat: str


@router.post("/{randevu_id}/ertele")
@limiter.limit(SINIR_RANDEVU)
def randevu_ertele(request: Request, randevu_id: int, veri: ErtelemeIstegi,
                   idempotency_key: str | None = Header(default=None),
                   kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)):
    """Müşterinin kendi randevusunu aynı berberde başka güne/saate taşıması. Çakışmada 409 + öneriler."""
    def _ertele() -> dict:
        r = _musteri_randevusu(db, randevu_id, kimlik)
        rs.musteri_ertele(db, r, veri.tarih, veri.saat)
        return {"mesaj": "Randevunuz ertelendi.", "randevu": randevu_json(r)}
    return idempotent(idempotency_key, kimlik.uid, _ertele)


@router.get("/{randevu_id}/takvim.ics", response_class=Response)
def randevu_takvim_dosyasi(randevu_id: int, kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)):
    """Randevunun .ics dosyası (Google/Samsung/Apple takvimine eklemek için). Yalnızca randevunun sahibine."""
    r = _musteri_randevusu(db, randevu_id, kimlik)
    return Response(content=randevu_ics(r, datetime.now(UTC)), media_type="text/calendar; charset=utf-8",
                    headers={"Content-Disposition": f'attachment; filename="randevu-{r.id}.ics"'})


@router.delete("/sil/{randevu_id}", deprecated=True)
def randevu_sil(randevu_id: int, kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)):
    """Eski istemciler için. Artık kalıcı silmez; randevuyu iptal eder."""
    return randevu_iptal(randevu_id, kimlik, db)


# ── 6. Bekleme listesi ───────────────────────────────────────
class BeklemeIstegi(BaseModel):
    berber_id: int
    tarih: str
    hizmet_ids: list[int]


@router.post("/bekleme-listesi")
def bekleme_listesine_ekle(veri: BeklemeIstegi, kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)):
    """Dolu bir gün için 'boşalırsa haber ver'."""
    musteri = musteri_getir_veya_olustur(db, kimlik)
    _, salon = ss.berber_ve_salon(db, veri.berber_id)
    sure = _sure_hesapla(db, salon.id, veri.hizmet_ids, veri.berber_id)
    gun = ss.tarih_dogrula(veri.tarih)
    neden = ss.kapali_neden(db, salon, veri.berber_id, gun)
    if neden:
        raise HTTPException(status_code=400, detail=neden)
    mevcut = db.query(models.BeklemeListesi).filter_by(musteri_id=musteri.id, berber_id=veri.berber_id,
                                                       tarih=veri.tarih).first()
    if mevcut:
        mevcut.sure_dk, mevcut.bildirildi = sure, False
    else:
        db.add(models.BeklemeListesi(musteri_id=musteri.id, berber_id=veri.berber_id, salon_id=salon.id,
                                     tarih=veri.tarih, sure_dk=sure, olusturma=simdi().isoformat(timespec="seconds")))
    db.commit()
    return {"mesaj": "Bu günde yer açılırsa size hemen bildirim göndereceğiz."}


# ── 7. Admin / işletme uyumluluk uçları ──────────────────────
@router.patch("/durum-guncelle/{randevu_id}", deprecated=True)
def durum_guncelle(randevu_id: int, yeni_durum: str, db: Session = Depends(get_db), _: None = Depends(admin_dogrula)):
    r = db.get(models.Randevu, randevu_id)
    if not r:
        raise HTTPException(status_code=404, detail="Randevu bulunamadı.")
    rs.durum_guncelle(db, r, yeni_durum)
    return {"mesaj": f"Durum '{r.durum}' olarak güncellendi."}


@router.get("/berber-plani/{berber_id}")
def berber_plani(berber_id: int, k: Kullanici = Depends(aktif_kullanici), db: Session = Depends(get_db)):
    """Berberin aktif randevuları — yalnızca o salonun işletmesi/personeli/admin."""
    berber = db.get(models.Berber, berber_id)
    if not berber:
        raise HTTPException(status_code=404, detail="Berber bulunamadı.")
    p = panel_yetkisi(berber.salon_id, k)
    if p.berber_id is not None and p.berber_id != berber_id:
        raise HTTPException(status_code=403, detail="Yalnızca kendi takviminizi görebilirsiniz.")
    randevular = db.query(models.Randevu).filter(
        models.Randevu.berber_id == berber_id, models.Randevu.durum == "onaylandi",
        models.Randevu.tarih >= bugun().isoformat(),
    ).order_by(models.Randevu.tarih, models.Randevu.saat).all()
    return [{**randevu_json(r), "musteri": f"{r.musteri.ad} {r.musteri.soyad}".strip()} for r in randevular]


# ── 8. Profil & favoriler (eski yollar; mantık musteriler.py'de) ──
router.add_api_route("/profil", musteriler.profil_getir, methods=["GET"])
router.add_api_route("/profil/guncelle", musteriler.profil_guncelle_json, methods=["POST"])
router.add_api_route("/profil/favori-toggle", musteriler.favori_toggle, methods=["POST"])
router.add_api_route("/profil/favoriler", musteriler.favori_listele, methods=["GET"])
