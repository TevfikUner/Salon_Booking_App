"""Slot, müsaitlik ve randevu oluşturma kuralları — tek doğruluk kaynağı.

Kurallar:
- Salonun o güne ait mesaisi (hafta içi / Pazar / haftalık kapalı gün) dışına taşan randevu alınamaz.
- Tatil günü (salona özel veya genel), berber izin günü ve berberin haftalık izin günü kapalıdır.
- Salonun öğle arası ve berberin saatlik blokeleri, randevu gibi dolu aralık sayılır.
- Geçmiş tarih/saat ve rezervasyon ufkunun ötesi alınamaz.
- Müşteri, salonun "en az önceden" süresinden (min_onceden_dk) daha yakın bir saate randevu alamaz/erteleyemez;
  işletme panelinden eklenen ve taşınan randevular bu sınırdan muaftır.
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


def gun_listesi(metin: str | None) -> set[int]:
    """"0,6" → {0, 6} (0=Pazartesi … 6=Pazar); bozuk parçalar yok sayılır."""
    return {int(x) for x in (metin or "").split(",") if x.strip().isdigit() and 0 <= int(x) <= 6}


def mola_araligi(salon: models.Salon) -> tuple[int, int] | None:
    try:
        a, b = saat_dk(salon.mola_baslangic), saat_dk(salon.mola_bitis)
    except (ValueError, TypeError, AttributeError):
        return None
    return (a, b) if b > a else None


def gun_mesaisi(salon: models.Salon, gun: date) -> tuple[int, int] | None:
    """(açılış_dk, kapanış_dk) veya o gün haftalık kapalıysa None."""
    kapali = gun_listesi(salon.kapali_gunler)
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
    berber_haftalik: set[int] = set()
    if berber_id is not None:
        izinler = {t for (t,) in db.query(models.BerberIzin.tarih).filter(
            models.BerberIzin.berber_id == berber_id, models.BerberIzin.tarih.in_(tarihler))}
        berber = db.get(models.Berber, berber_id)
        berber_haftalik = gun_listesi(berber.kapali_gunler if berber else "")
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
        elif gun.weekday() in berber_haftalik:
            sonuc[gun] = "Seçilen personel bu gün çalışmıyor."
        else:
            sonuc[gun] = None
    return sonuc


def dolu_araliklar(db: Session, berber_id: int, tarih_str: str, haric_id: int | None = None) -> list[tuple[int, int]]:
    """Berberin o günkü dolu aralıkları. `haric_id`: ertelenen randevu kendi yerini dolu saymasın."""
    q = db.query(models.Randevu).filter(
        models.Randevu.berber_id == berber_id,
        models.Randevu.tarih == tarih_str,
        models.Randevu.durum.in_(models.AKTIF_DURUMLAR),
    )
    if haric_id is not None:
        q = q.filter(models.Randevu.id != haric_id)
    return [a for r in q.all() if (a := _randevu_araligi(r))]


def _randevu_araligi(r: models.Randevu) -> tuple[int, int] | None:
    try:
        bas = saat_dk(r.saat)
    except (ValueError, TypeError):
        return None
    return bas, bas + blok_dk(r.sure_dk or 30)


def bloke_araliklari(db: Session, salon: models.Salon, berber_id: int, tarih_str: str) -> list[tuple[int, int]]:
    """Randevu alınamayan ama randevu olmayan aralıklar: salonun öğle arası + berberin saatlik blokeleri."""
    araliklar = []
    mola = mola_araligi(salon)
    if mola:
        araliklar.append(mola)
    for b in db.query(models.SaatBloke).filter(models.SaatBloke.berber_id == berber_id,
                                               models.SaatBloke.tarih == tarih_str):
        try:
            araliklar.append((saat_dk(b.bas_saat), saat_dk(b.bit_saat)))
        except (ValueError, TypeError):
            continue
    return araliklar


def gunluk_bos_sayilari(db: Session, salon: models.Salon, berber_id: int, gunler: list[date],
                        sure_dk: int) -> dict[date, int]:
    """Takvim için: her gün bu süredeki hizmetin kaç başlangıç saati boş. Gün sayısından bağımsız 2 sorgu."""
    tarihler = [g.isoformat() for g in gunler]
    dolu: dict[str, list[tuple[int, int]]] = {t: [] for t in tarihler}
    for r in db.query(models.Randevu).filter(models.Randevu.berber_id == berber_id,
                                             models.Randevu.tarih.in_(tarihler),
                                             models.Randevu.durum.in_(models.AKTIF_DURUMLAR)):
        if a := _randevu_araligi(r):
            dolu[r.tarih].append(a)
    for b in db.query(models.SaatBloke).filter(models.SaatBloke.berber_id == berber_id,
                                               models.SaatBloke.tarih.in_(tarihler)):
        try:
            dolu[b.tarih].append((saat_dk(b.bas_saat), saat_dk(b.bit_saat)))
        except (ValueError, TypeError):
            continue
    mola = mola_araligi(salon)
    sonuc = {}
    for gun in gunler:
        mesai = gun_mesaisi(salon, gun)
        if not mesai:
            sonuc[gun] = 0
            continue
        araliklar = dolu[gun.isoformat()] + ([mola] if mola else [])
        sonuc[gun] = len(musait_baslangiclar(mesai[0], mesai[1], sure_dk, araliklar,
                                             _en_erken(gun, onceden_dk(salon))))
    return sonuc


def onceden_dk(salon: models.Salon, uygula: bool = True) -> int:
    return (salon.min_onceden_dk or 0) if uygula else 0


def en_erken_an(onceden: int = 0):
    """Randevunun başlayabileceği en erken an: şimdi + salonun önceden alma süresi."""
    return simdi() + timedelta(minutes=onceden)


def _en_erken(gun: date, onceden: int = 0) -> int | None:
    """Bu günde bu dakikadan sonra başlayan saatler alınabilir; kısıt yoksa None. Önceden alma süresi ertesi
    güne taşıyorsa (ör. 24 saat) o gün tamamen kapanır."""
    sinir = en_erken_an(onceden)
    if gun < sinir.date():
        return 24 * 60
    if gun == sinir.date():
        return sinir.hour * 60 + sinir.minute
    return None


@dataclass
class GunMusaitligi:
    tarih: str
    kapali_neden: str | None
    musait: list[str]
    tum: list[str]  # ızgaradaki tüm saatler (UI'da dolu/boş göstermek için)


def gun_musaitligi(db: Session, salon: models.Salon, berber_id: int, tarih_str: str, sure_dk: int,
                   haric_id: int | None = None, onceden: bool = True) -> GunMusaitligi:
    """onceden=False: salonun "en az önceden" sınırı uygulanmaz (işletme paneli)."""
    gun = tarih_dogrula(tarih_str)
    neden = kapali_neden(db, salon, berber_id, gun)
    mesai = gun_mesaisi(salon, gun)
    tum = [dk_saat(d) for d in izgara(*mesai)] if mesai else []
    if neden:
        return GunMusaitligi(tarih_str, neden, [], tum)
    dolu = dolu_araliklar(db, berber_id, tarih_str, haric_id) + bloke_araliklari(db, salon, berber_id, tarih_str)
    bas = musait_baslangiclar(mesai[0], mesai[1], sure_dk, dolu, _en_erken(gun, onceden_dk(salon, onceden)))
    return GunMusaitligi(tarih_str, None, [dk_saat(d) for d in bas], tum)


def en_yakin_slotlar(db: Session, salon: models.Salon, berber_id: int, sure_dk: int,
                     adet: int = 3, baslangic: date | None = None, onceden: bool = True) -> list[dict]:
    """Bugünden (veya verilen günden) itibaren ilk boş slotlar."""
    gun = baslangic or bugun()
    son = bugun() + timedelta(days=ayarlar().rezervasyon_ufku_gun)
    sonuc: list[dict] = []
    while gun <= son and len(sonuc) < adet:
        m = gun_musaitligi(db, salon, berber_id, gun.isoformat(), sure_dk, onceden=onceden)
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


@dataclass(frozen=True)
class Kalem:
    """Bir hizmetin seçilen berberdeki fiyatı ve süresi (berbere özel ayar yoksa menüdeki değerler)."""
    hizmet: models.Hizmet
    fiyat: float
    sure: int


def berber_ayarlari(db: Session, berber_idler: list[int]) -> dict[int, dict[int, models.BerberHizmet]]:
    """berber_id → {hizmet_id → berbere özel ayar}. Tek sorgu."""
    sonuc: dict[int, dict[int, models.BerberHizmet]] = {b: {} for b in berber_idler}
    if berber_idler:
        for k in db.query(models.BerberHizmet).filter(models.BerberHizmet.berber_id.in_(berber_idler)):
            sonuc[k.berber_id][k.hizmet_id] = k
    return sonuc


def kalem(h: models.Hizmet, ayar: models.BerberHizmet | None) -> Kalem | None:
    """Berber bu hizmeti vermiyorsa None."""
    if ayar is None:
        return Kalem(h, h.fiyat, h.sure)
    if not ayar.veriyor:
        return None
    return Kalem(h, h.fiyat if ayar.fiyat is None else ayar.fiyat, h.sure if ayar.sure is None else ayar.sure)


def hizmet_kalemleri(db: Session, salon_id: int, hizmet_ids: list[int], berber_id: int | None) -> list[Kalem]:
    """Seçilen hizmetlerin bu berberdeki fiyat/süresi. Berber verilmezse menü değerleri.
    Berber hizmetlerden birini vermiyorsa 400."""
    hizmetler = hizmetleri_coz(db, salon_id, hizmet_ids)
    if berber_id is None:
        return [Kalem(h, h.fiyat, h.sure) for h in hizmetler]
    ayarlar_ = berber_ayarlari(db, [berber_id])[berber_id]
    kalemler = [(h, kalem(h, ayarlar_.get(h.id))) for h in hizmetler]
    vermedigi = [h.ad for h, k in kalemler if k is None]
    if vermedigi:
        raise is_kurali_hatasi(f"Seçilen personel şu hizmeti vermiyor: {', '.join(vermedigi)}.",
                               vermedigi_hizmetler=vermedigi)
    return [k for _, k in kalemler]


def toplam_sure(db: Session, salon_id: int, hizmet_ids: list[int], berber_id: int | None) -> int:
    return sum(k.sure for k in hizmet_kalemleri(db, salon_id, hizmet_ids, berber_id))


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

    import fiyat_servisi as fs  # fiyat_servisi bu modülü içe aktarır (Kalem)

    berber, salon = berber_ve_salon(db, berber_id)
    kalemler = hizmet_kalemleri(db, salon.id, hizmet_ids, berber.id)
    hizmetler = [k.hizmet for k in kalemler]
    sure = sum(k.sure for k in kalemler)

    with _rezervasyon_kilidi:
        # PostgreSQL: aynı berbere eşzamanlı yazmaları sıraya sokar (SQLite'ta yok sayılır).
        db.query(models.Berber).filter(models.Berber.id == berber.id).with_for_update().first()
        onceden = kaynak != "panel"
        m = gun_musaitligi(db, salon, berber.id, tarih_str, sure, onceden=onceden)
        if m.kapali_neden:
            raise is_kurali_hatasi(m.kapali_neden)
        if saat not in m.musait:
            oneriler = [s for s in m.musait][:5] or [
                f"{x['tarih']} {x['saat']}" for x in en_yakin_slotlar(db, salon, berber.id, sure, 3, onceden=onceden)
            ]
            raise is_kurali_hatasi(
                f"Seçtiğiniz saat ({saat}) artık uygun değil. Hizmet {sure} dk sürüyor.",
                409,
                oneriler=oneriler,
            )
        fiyat = fs.fiyat_hesapla(db, salon, kalemler, tarih_dogrula(tarih_str), saat, musteri.id)
        r = models.Randevu(
            musteri_id=musteri.id,
            berber_id=berber.id,
            salon_id=salon.id,
            tarih=tarih_str,
            saat=saat,
            sure_dk=sure,
            durum="onaylandi",
            hizmetler=hizmetler,
            toplam_fiyat=fiyat.toplam,
            liste_fiyati=fiyat.liste,
            indirim_tutari=fiyat.indirim,
            indirim_aciklama=fiyat.aciklama,
            kampanya_id=fiyat.kampanya_id,
            olusturma=simdi().isoformat(timespec="seconds"),
            kaynak=kaynak,
            notlar=notlar,
        )
        db.add(r)
        db.commit()
    db.refresh(r)
    return r


def randevu_tasi(db: Session, r: models.Randevu, tarih_str: str, saat: str, berber_id: int | None = None,
                 musteri_ertelemesi: bool = True) -> None:
    """Randevuyu yeni güne/saate (işletme taşımasında başka berbere de) taşır; süre ve fiyat mühürlü kalır.
    Kilit altında, randevunun kendi eski aralığı dolu sayılmadan yeniden müsaitlik hesaplanır; çakışmada 409 +
    öneriler. Müşteri ertelemesinde: erteleme sayacı artar ve kampanya indirimi yalnızca yeni gün/saat de aynı
    kampanyaya uyuyorsa korunur (sadakat indirimi korunur). İşletme taşımasında fiyat olduğu gibi kalır."""
    import fiyat_servisi as fs

    try:
        saat_dk(saat)
    except (ValueError, TypeError):
        raise is_kurali_hatasi("Geçersiz saat formatı. Örnek: 14:30") from None
    berber, salon = berber_ve_salon(db, berber_id or r.berber_id)
    if berber.salon_id != r.salon_id:
        raise is_kurali_hatasi("Randevu yalnızca aynı salondaki personele taşınabilir.", 403)
    if berber.id != r.berber_id:
        ayar = berber_ayarlari(db, [berber.id])[berber.id]
        vermedigi = [h.ad for h in r.hizmetler if kalem(h, ayar.get(h.id)) is None]
        if vermedigi:
            raise is_kurali_hatasi(f"{berber.ad} şu hizmeti vermiyor: {', '.join(vermedigi)}.")
    sure = r.sure_dk or 30
    with _rezervasyon_kilidi:
        db.query(models.Berber).filter(models.Berber.id == berber.id).with_for_update().first()
        m = gun_musaitligi(db, salon, berber.id, tarih_str, sure, haric_id=r.id if berber.id == r.berber_id else None,
                           onceden=musteri_ertelemesi)
        if m.kapali_neden:
            raise is_kurali_hatasi(m.kapali_neden)
        if saat not in m.musait:
            oneriler = m.musait[:5] or [
                f"{x['tarih']} {x['saat']}"
                for x in en_yakin_slotlar(db, salon, berber.id, sure, 3, onceden=musteri_ertelemesi)
            ]
            raise is_kurali_hatasi(f"Seçtiğiniz saat ({saat}) uygun değil. Hizmet {sure} dk sürüyor.", 409,
                                   oneriler=oneriler)
        if musteri_ertelemesi:
            if r.kampanya_id and not fs.ertelemede_kampanya_korunur(db, r, tarih_dogrula(tarih_str), saat):
                r.toplam_fiyat = r.liste_fiyati if r.liste_fiyati is not None else r.toplam_fiyat
                r.indirim_tutari, r.indirim_aciklama, r.kampanya_id = 0, None, None
            r.erteleme_sayisi = (r.erteleme_sayisi or 0) + 1
        r.berber_id = berber.id
        r.tarih, r.saat = tarih_str, saat
        r.hatirlatma_gonderildi = False
        db.commit()


def bitis_saati(r: models.Randevu) -> str:
    return dk_saat(saat_dk(r.saat) + (r.sure_dk or 30))


def randevu_baslangic(r: models.Randevu):
    from datetime import datetime
    return datetime.strptime(f"{r.tarih} {r.saat}", "%Y-%m-%d %H:%M")
