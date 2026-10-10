"""Slot, müsaitlik ve randevu oluşturma kuralları — tek doğruluk kaynağı.

Kurallar:
- Salonun o güne ait mesaisi (hafta içi / Pazar / haftalık kapalı gün) dışına taşan randevu alınamaz.
- Tatil günü (salona özel veya genel) ve berber izin günü kapalıdır.
- Geçmiş tarih/saat ve rezervasyon ufkunun ötesi alınamaz.
- Bir randevu, süresi SLOT_DK'ya yukarı yuvarlanmış aralığı kaplar (40 dk → 60 dk).
- Başlangıç saatleri açılıştan itibaren SLOT_DK adımlı ızgaradadır.
- İki randevu [bas, bit) aralıkları kesişiyorsa çakışır (bitiş anı ile başlangıç anı çakışma sayılmaz).
"""
import math
import threading
from dataclasses import dataclass
from datetime import date, timedelta

from fastapi import HTTPException
from sqlalchemy import or_
from sqlalchemy.orm import Session

import models
from config import ayarlar
from zaman import bugun, dk_saat, saat_dk, simdi, tarih_coz

# Aynı süreçteki eşzamanlı rezervasyonları sıraya sokar. PostgreSQL'de ek olarak
# berber satırı SELECT ... FOR UPDATE ile kilitlenir (çoklu worker/instance için).
_rezervasyon_kilidi = threading.Lock()


# ─────────────────────────── Saf fonksiyonlar ───────────────────────────

def blok_dk(sure_dk: int, slot: int | None = None) -> int:
    slot = slot or ayarlar().slot_dk
    return max(1, math.ceil(max(sure_dk, 1) / slot)) * slot


def cakisiyor(bas1: int, bit1: int, bas2: int, bit2: int) -> bool:
    return bas1 < bit2 and bas2 < bit1


def musait_baslangiclar(
    acilis_dk: int,
    kapanis_dk: int,
    sure_dk: int,
    dolu: list[tuple[int, int]],
    en_erken_dk: int | None = None,
    slot: int | None = None,
) -> list[int]:
    """Verilen gün için hizmetin başlayabileceği dakikaları döner."""
    slot = slot or ayarlar().slot_dk
    blok = blok_dk(sure_dk, slot)
    sonuc = []
    s = acilis_dk
    while s + blok <= kapanis_dk:
        if (en_erken_dk is None or s > en_erken_dk) and not any(cakisiyor(s, s + blok, b, e) for b, e in dolu):
            sonuc.append(s)
        s += slot
    return sonuc


def izgara(acilis_dk: int, kapanis_dk: int, slot: int | None = None) -> list[int]:
    slot = slot or ayarlar().slot_dk
    return list(range(acilis_dk, kapanis_dk, slot))


def gun_mesaisi(salon: models.Salon, gun: date) -> tuple[int, int] | None:
    """(açılış_dk, kapanış_dk) veya o gün haftalık kapalıysa None."""
    kapali = {int(x) for x in (salon.kapali_gunler or "").split(",") if x.strip().isdigit()}
    if gun.weekday() in kapali:
        return None
    if gun.weekday() == 6:
        acilis, kapanis = salon.pazar_acilis_saati or "10:00", salon.pazar_kapanis_saati or "17:00"
    else:
        acilis, kapanis = salon.acilis_saati or "09:00", salon.kapanis_saati or "20:00"
    a, k = saat_dk(acilis), saat_dk(kapanis)
    return (a, k) if k > a else None


# ─────────────────────────── Hatalar ───────────────────────────

def is_kurali_hatasi(mesaj: str, kod: int = 400, **ek) -> HTTPException:
    return HTTPException(status_code=kod, detail={"mesaj": mesaj, **ek})


# ─────────────────────────── DB katmanı ───────────────────────────

def tarih_dogrula(tarih_str: str) -> date:
    try:
        return tarih_coz(tarih_str)
    except (ValueError, TypeError):
        raise is_kurali_hatasi("Tarih formatı hatalı. Doğru format: YYYY-MM-DD") from None


def kapali_neden(db: Session, salon: models.Salon, berber_id: int | None, gun: date) -> str | None:
    """Gün randevuya kapalıysa kullanıcıya gösterilecek nedeni döner."""
    return kapali_nedenler(db, salon, berber_id, [gun])[gun]


def kapali_nedenler(db: Session, salon: models.Salon, berber_id: int | None,
                    gunler: list[date]) -> dict[date, str | None]:
    """Birden çok gün için kapalılık nedeni — tatil ve izinler tek sorguda (takvimde gün başına sorgu atılmasın)."""
    ufuk = ayarlar().rezervasyon_ufku_gun
    tarihler = [g.isoformat() for g in gunler]
    tatiller = {
        t.tarih: t for t in db.query(models.TatilGunu).filter(
            models.TatilGunu.tarih.in_(tarihler),
            or_(models.TatilGunu.salon_id == salon.id, models.TatilGunu.salon_id.is_(None)),
        )
    }
    izinler: set[str] = set()
    if berber_id is not None:
        izinler = {t for (t,) in db.query(models.BerberIzin.tarih).filter(
            models.BerberIzin.berber_id == berber_id, models.BerberIzin.tarih.in_(tarihler))}
    sonuc: dict[date, str | None] = {}
    for gun in gunler:
        tarih_str = gun.isoformat()
        tatil = tatiller.get(tarih_str)
        if gun < bugun():
            sonuc[gun] = "Geçmiş bir tarihe randevu alınamaz."
        elif gun > bugun() + timedelta(days=ufuk):
            sonuc[gun] = f"En fazla {ufuk} gün sonrasına randevu alınabilir."
        elif gun_mesaisi(salon, gun) is None:
            sonuc[gun] = "Salon bu gün kapalı."
        elif tatil:
            sonuc[gun] = f"Salon bu gün kapalı{f' ({tatil.aciklama})' if tatil.aciklama else ''}."
        elif tarih_str in izinler:
            sonuc[gun] = "Seçilen personel bu gün izinli."
        else:
            sonuc[gun] = None
    return sonuc


def dolu_araliklar(db: Session, berber_id: int, tarih_str: str) -> list[tuple[int, int]]:
    randevular = db.query(models.Randevu).filter(
        models.Randevu.berber_id == berber_id,
        models.Randevu.tarih == tarih_str,
        models.Randevu.durum.in_(models.AKTIF_DURUMLAR),
    ).all()
    araliklar = []
    for r in randevular:
        try:
            bas = saat_dk(r.saat)
        except (ValueError, TypeError):
            continue
        araliklar.append((bas, bas + blok_dk(r.sure_dk or 30)))
    return araliklar


def _en_erken(gun: date) -> int | None:
    if gun == bugun():
        s = simdi()
        return s.hour * 60 + s.minute
    return None


@dataclass
class GunMusaitligi:
    tarih: str
    kapali_neden: str | None
    musait: list[str]
    tum: list[str]  # ızgaradaki tüm saatler (UI'da dolu/boş göstermek için)


def gun_musaitligi(db: Session, salon: models.Salon, berber_id: int, tarih_str: str, sure_dk: int) -> GunMusaitligi:
    gun = tarih_dogrula(tarih_str)
    neden = kapali_neden(db, salon, berber_id, gun)
    mesai = gun_mesaisi(salon, gun)
    tum = [dk_saat(d) for d in izgara(*mesai)] if mesai else []
    if neden:
        return GunMusaitligi(tarih_str, neden, [], tum)
    bas = musait_baslangiclar(mesai[0], mesai[1], sure_dk, dolu_araliklar(db, berber_id, tarih_str), _en_erken(gun))
    return GunMusaitligi(tarih_str, None, [dk_saat(d) for d in bas], tum)


def en_yakin_slotlar(db: Session, salon: models.Salon, berber_id: int, sure_dk: int,
                     adet: int = 3, baslangic: date | None = None) -> list[dict]:
    """Bugünden (veya verilen günden) itibaren ilk boş slotlar."""
    gun = baslangic or bugun()
    son = bugun() + timedelta(days=ayarlar().rezervasyon_ufku_gun)
    sonuc: list[dict] = []
    while gun <= son and len(sonuc) < adet:
        m = gun_musaitligi(db, salon, berber_id, gun.isoformat(), sure_dk)
        for s in m.musait:
            sonuc.append({"tarih": m.tarih, "saat": s})
            if len(sonuc) >= adet:
                break
        gun += timedelta(days=1)
    return sonuc


def berber_ve_salon(db: Session, berber_id: int) -> tuple[models.Berber, models.Salon]:
    berber = db.query(models.Berber).filter(models.Berber.id == berber_id, models.Berber.aktif.is_(True)).first()
    if not berber or not berber.salon or not berber.salon.aktif:
        raise is_kurali_hatasi("Personel bulunamadı.", 404)
    return berber, berber.salon


def hizmetleri_coz(db: Session, salon_id: int, hizmet_ids: list[int]) -> list[models.Hizmet]:
    ids = list(dict.fromkeys(hizmet_ids))  # tekrarları at, sırayı koru
    if not ids:
        raise is_kurali_hatasi("En az bir hizmet seçmelisiniz.")
    hizmetler = db.query(models.Hizmet).filter(models.Hizmet.id.in_(ids), models.Hizmet.aktif.is_(True)).all()
    gecerli = [h for h in hizmetler if h.salon_id in (None, salon_id)]
    if len(gecerli) != len(ids):
        raise is_kurali_hatasi("Seçilen hizmetlerden biri bu salonda bulunmuyor.", 404)
    return gecerli


def randevu_olustur(
    db: Session,
    musteri: models.Musteri,
    berber_id: int,
    tarih_str: str,
    saat: str,
    hizmet_ids: list[int],
    kaynak: str = "uygulama",
    notlar: str | None = None,
) -> models.Randevu:
    """Tüm kuralları uygular, çakışmaya karşı kilitli şekilde randevuyu oluşturur ve commit eder."""
    try:
        saat_dk(saat)
    except (ValueError, TypeError):
        raise is_kurali_hatasi("Geçersiz saat formatı. Örnek: 14:30") from None

    berber, salon = berber_ve_salon(db, berber_id)
    hizmetler = hizmetleri_coz(db, salon.id, hizmet_ids)
    toplam_sure = sum(h.sure for h in hizmetler)
    toplam_fiyat = sum(h.fiyat for h in hizmetler)

    with _rezervasyon_kilidi:
        # PostgreSQL: aynı berbere eşzamanlı yazmaları sıraya sokar (SQLite'ta yok sayılır).
        db.query(models.Berber).filter(models.Berber.id == berber.id).with_for_update().first()
        m = gun_musaitligi(db, salon, berber.id, tarih_str, toplam_sure)
        if m.kapali_neden:
            raise is_kurali_hatasi(m.kapali_neden)
        if saat not in m.musait:
            oneriler = [s for s in m.musait][:5] or [
                f"{x['tarih']} {x['saat']}" for x in en_yakin_slotlar(db, salon, berber.id, toplam_sure, 3)
            ]
            raise is_kurali_hatasi(
                f"Seçtiğiniz saat ({saat}) artık uygun değil. Hizmet {toplam_sure} dk sürüyor.",
                409,
                oneriler=oneriler,
            )
        r = models.Randevu(
            musteri_id=musteri.id,
            berber_id=berber.id,
            salon_id=salon.id,
            tarih=tarih_str,
            saat=saat,
            sure_dk=toplam_sure,
            durum="onaylandi",
            hizmetler=hizmetler,
            toplam_fiyat=toplam_fiyat,
            olusturma=simdi().isoformat(timespec="seconds"),
            kaynak=kaynak,
            notlar=notlar,
        )
        db.add(r)
        db.commit()
    db.refresh(r)
    return r


def bitis_saati(r: models.Randevu) -> str:
    return dk_saat(saat_dk(r.saat) + (r.sure_dk or 30))


def randevu_baslangic(r: models.Randevu):
    from datetime import datetime
    return datetime.strptime(f"{r.tarih} {r.saat}", "%Y-%m-%d %H:%M")
