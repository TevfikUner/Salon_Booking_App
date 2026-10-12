"""Keşfet: salon listesi (filtre + konuma göre sıralama), salon detayı, filtre seçenekleri."""
import math

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, or_
from sqlalchemy.orm import Session

import fiyat_servisi as fs
import models
from auth import Kimlik, kimlik_istege_bagli
from database import get_db
from routers.degerlendirmeler import degerlendirme_sayilari, tamamlanan_sayilari
from zaman import bugun

router = APIRouter(prefix="/salonlar", tags=["Keşfet"])

_TR_KUCUK = str.maketrans({"I": "ı", "İ": "i"})
_ASCII = str.maketrans("ıiğüşöçâîû", "iiguso caiu".replace(" ", ""))


def normalize(metin: str | None) -> str:
    """Türkçe büyük/küçük harf ve aksan farkını yok sayan karşılaştırma anahtarı.
    "İstanbul", "ISTANBUL", "istanbul" → "istanbul"; "Selçuklu" ↔ "Selcuklu"."""
    return (metin or "").strip().translate(_TR_KUCUK).lower().translate(_ASCII)


def mesafe_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """Haversine — iki koordinat arasındaki kuş uçuşu mesafe."""
    r = 6371.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp, dl = math.radians(lat2 - lat1), math.radians(lng2 - lng1)
    a = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * r * math.asin(math.sqrt(a))


def _salon_degerlendirme_sayilari(db: Session, salon_idler: list[int]) -> dict[int, int]:
    """Salon başına değerlendirme sayısı — tek gruplu sorgu. Hiç değerlendirmesi olmayan salonun `puan`ı
    varsayılan 5.0'dır; istemci bunu "Yeni" gösterir, puan filtresi ve sıralama bu salonları öne almaz."""
    if not salon_idler:
        return {}
    return dict(db.query(models.Degerlendirme.salon_id, func.count(models.Degerlendirme.id)).filter(
        models.Degerlendirme.salon_id.in_(salon_idler)).group_by(models.Degerlendirme.salon_id).all())


def _kampanya_yuzdeleri(db: Session, salon_idler: list[int]) -> dict[int, int]:
    """Salon başına aktif kampanyaların en yüksek indirim yüzdesi (kartta "%20'ye varan indirim"). Tek sorgu."""
    if not salon_idler:
        return {}
    sonuc: dict[int, int] = {}
    bugun_str = bugun().isoformat()
    for k in db.query(models.Kampanya).filter(models.Kampanya.salon_id.in_(salon_idler),
                                              models.Kampanya.aktif.is_(True)):
        if not k.bit_tarih or k.bit_tarih >= bugun_str:
            sonuc[k.salon_id] = max(sonuc.get(k.salon_id, 0), k.yuzde)
    return sonuc


def _salon_ozet(s: models.Salon, mesafe: float | None = None, eslesen: list[str] | None = None,
                degerlendirme: int = 0, kampanya: int = 0) -> dict:
    return {
        "id": s.id,
        "ad": s.ad,
        "adres": s.adres,
        "telefon": s.telefon,
        "foto_url": s.foto_url,
        "sehir": s.sehir,
        "ilce": s.ilce,
        "puan": s.puan,
        "degerlendirme_sayisi": degerlendirme,
        "acilis_saati": s.acilis_saati,
        "kapanis_saati": s.kapanis_saati,
        "pazar_acilis_saati": s.pazar_acilis_saati,
        "pazar_kapanis_saati": s.pazar_kapanis_saati,
        "kapali_gunler": s.kapali_gunler,
        "mesafe_km": round(mesafe, 1) if mesafe is not None else None,
        "eslesen_hizmetler": eslesen or [],
        "kampanya_yuzde": kampanya,
        "sadakat": bool(s.sadakat_esik and s.sadakat_yuzde),
    }


@router.get("")
def salonlari_listele(
    sehir: str | None = None,
    ilce: str | None = None,
    lat: float | None = Query(default=None, ge=-90, le=90),
    lng: float | None = Query(default=None, ge=-180, le=180),
    q: str | None = Query(default=None, max_length=60),
    min_puan: float | None = Query(default=None, ge=0, le=5),
    db: Session = Depends(get_db),
):
    """Aktif salonlar. Şehir/ilçe filtresi harf duyarsızdır. Konum verilirse yakından uzağa sıralanır.
    `q`: salon adı, şehir/ilçe veya hizmet adında arar (Türkçe harf ve aksan duyarsız); hizmetten eşleşen
    salonlarda eşleşen hizmetler `eslesen_hizmetler` alanında döner."""
    salonlar = db.query(models.Salon).filter(models.Salon.aktif.is_(True)).all()
    if sehir:
        salonlar = [s for s in salonlar if normalize(s.sehir) == normalize(sehir)]
    if ilce:
        salonlar = [s for s in salonlar if normalize(s.ilce) == normalize(ilce)]
    sayilar = _salon_degerlendirme_sayilari(db, [s.id for s in salonlar])
    if min_puan is not None:  # değerlendirmesi olmayan salonun varsayılan 5.0 puanı sayılmaz
        salonlar = [s for s in salonlar if sayilar.get(s.id) and (s.puan or 0) >= min_puan]
    eslesen: dict[int, list[str]] = {}
    if q and (aranan := normalize(q)):
        eslesen = _hizmet_eslesmeleri(db, [s.id for s in salonlar], aranan)
        salonlar = [s for s in salonlar
                    if s.id in eslesen or any(aranan in normalize(x) for x in (s.ad, s.ilce, s.sehir))]
    kampanya = _kampanya_yuzdeleri(db, [s.id for s in salonlar])

    def ozet(s: models.Salon, mesafe: float | None = None) -> dict:
        return _salon_ozet(s, mesafe, eslesen.get(s.id), sayilar.get(s.id, 0), kampanya.get(s.id, 0))

    if lat is not None and lng is not None:
        konumlu = [(s, mesafe_km(lat, lng, s.konum_lat, s.konum_long))
                   for s in salonlar if s.konum_lat is not None and s.konum_long is not None]
        konumsuz = [s for s in salonlar if s.konum_lat is None or s.konum_long is None]
        konumlu.sort(key=lambda x: x[1])
        return [ozet(s, m) for s, m in konumlu] + [ozet(s) for s in konumsuz]
    # Değerlendirilmiş salonlar puana göre önde; henüz değerlendirmesi olmayanlar ("Yeni") sonra
    salonlar.sort(key=lambda s: (0 if sayilar.get(s.id) else 1, -(s.puan or 0), s.ad))
    return [ozet(s) for s in salonlar]


def _hizmet_eslesmeleri(db: Session, salon_idler: list[int], aranan: str) -> dict[int, list[str]]:
    """Adında aranan geçen aktif hizmetler, salon başına (en fazla 3). Tüm salonların ortak hizmetleri
    (salon_id NULL) her salona sayılır. Tek sorgu."""
    if not salon_idler:
        return {}
    sonuc: dict[int, list[str]] = {}
    ortak: list[str] = []
    for h in db.query(models.Hizmet).filter(models.Hizmet.aktif.is_(True),
                                            or_(models.Hizmet.salon_id.in_(salon_idler),
                                                models.Hizmet.salon_id.is_(None))):
        if aranan in normalize(h.ad):
            (ortak if h.salon_id is None else sonuc.setdefault(h.salon_id, [])).append(h.ad)
    if ortak:
        for sid in salon_idler:
            sonuc.setdefault(sid, []).extend(ortak)
    return {sid: list(dict.fromkeys(adlar))[:3] for sid, adlar in sonuc.items()}


@router.get("/filtreler")
def filtre_secenekleri(db: Session = Depends(get_db)):
    """Salonu olan şehir ve ilçeler."""
    salonlar = db.query(models.Salon).filter(models.Salon.aktif.is_(True)).all()
    ilceler: dict[str, set] = {}
    for s in salonlar:
        if s.sehir:
            ilceler.setdefault(s.sehir, set())
            if s.ilce:
                ilceler[s.sehir].add(s.ilce)
    return {"sehirler": sorted(ilceler), "ilceler": {k: sorted(v) for k, v in ilceler.items()}}


@router.get("/{salon_id}")
def salon_detay(salon_id: int, kimlik: Kimlik | None = Depends(kimlik_istege_bagli), db: Session = Depends(get_db)):
    """Salon detayı: iletişim, konum, çalışma saatleri, ekip (oturum varsa favori bilgisiyle)."""
    salon = db.query(models.Salon).filter(models.Salon.id == salon_id, models.Salon.aktif.is_(True)).first()
    if not salon:
        raise HTTPException(status_code=404, detail="Salon bulunamadı.")
    fotograflar = db.query(models.SalonFotograf).filter(models.SalonFotograf.salon_id == salon_id) \
        .order_by(models.SalonFotograf.sira).all()
    berberler = db.query(models.Berber).filter(models.Berber.salon_id == salon_id, models.Berber.aktif.is_(True)) \
        .order_by(models.Berber.id).all()
    idler = [b.id for b in berberler]
    tamamlanan = tamamlanan_sayilari(db, idler)
    degerlendirme = degerlendirme_sayilari(db, idler)
    favori_idler: set[int] = set()
    musteri_id = None
    if kimlik:
        m = db.query(models.Musteri).filter(models.Musteri.firebase_uid == kimlik.uid).first()
        if m:
            favori_idler = {b.id for b in m.favori_berberler}
            musteri_id = m.id
    kampanyalar = fs.aktif_kampanyalar(db, salon.id)
    hizmet_adlari = {h.id: h.ad for h in db.query(models.Hizmet).filter(models.Hizmet.salon_id == salon.id)}
    return {
        **_salon_ozet(salon, degerlendirme=_salon_degerlendirme_sayilari(db, [salon.id]).get(salon.id, 0),
                      kampanya=max((k.yuzde for k in kampanyalar), default=0)),
        "kampanyalar": [{"id": k.id, "ad": k.ad, "yuzde": k.yuzde, "kosul": fs.kampanya_ozeti(k, hizmet_adlari)}
                        for k in sorted(kampanyalar, key=lambda k: -k.yuzde)],
        "sadakat_karti": fs.sadakat_durumu(db, salon, musteri_id),
        "instagram": salon.instagram_url,
        "whatsapp": salon.whatsapp,
        "konum": {"lat": salon.konum_lat, "lng": salon.konum_long},
        "fotograflar": [{"id": f.id, "foto_url": f.foto_url, "sira": f.sira} for f in fotograflar],
        "berberler": [{"id": b.id, "ad": b.ad, "soyad": b.soyad, "uzmanlik": b.uzmanlik, "puan": b.puan,
                       "foto_url": b.foto_url, "favori": b.id in favori_idler,
                       "tamamlanan": tamamlanan.get(b.id, 0), "degerlendirme_sayisi": degerlendirme.get(b.id, 0)}
                      for b in berberler],
    }
