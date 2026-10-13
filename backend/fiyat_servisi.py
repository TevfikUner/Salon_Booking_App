"""Fiyatlandırma — kampanya ve sadakat indirimi. Tek doğruluk kaynağı.

Kurallar:
- Hizmet fiyatı berbere göre çözülür (slot_servisi.Kalem); indirim bu fiyatların üzerine hesaplanır.
- Kampanya hizmet kalemi bazında uygulanır: bir kaleme birden çok kampanya uyuyorsa yüzdesi en büyük olan.
- Sadakat kartı: müşterinin bu salondaki (tamamlanan + aktif) randevu sayısı + 1, eşiğin katıysa tüm tutara.
- Kampanya ve sadakat üst üste binmez; müşteri için hangisi daha fazla indirimse o uygulanır.
- İndirim tam liraya yuvarlanır ve randevuda mühürlenir (sonradan kampanya değişse de tutar değişmez).
"""
from dataclasses import dataclass
from datetime import date

from sqlalchemy.orm import Session

import ceviri
import models
from slot_servisi import Kalem, gun_listesi
from zaman import bugun, saat_dk

GUN_ADLARI = ("Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar")
GUN_ADLARI_EN = ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
_BIRLER = ("", "'e", "'ye", "'e", "'e", "'e", "'ya", "'ye", "'e", "'a")
_ONLAR = ("", "'a", "'ye", "'a", "'a", "'ye", "'a", "'e", "'e", "'a")


def yonelme_eki(n: int) -> str:
    """Sayının okunuşuna göre yönelme eki: 2026 → 'ya, 2030 → 'a, 10 → 'a, 20 → 'ye."""
    n = abs(n)
    if n % 10:
        return _BIRLER[n % 10]
    if n % 100:
        return _ONLAR[n // 10 % 10]
    return "'e" if n else "'a"


@dataclass(frozen=True)
class Fiyat:
    liste: float
    indirim: float = 0
    aciklama: str | None = None
    kampanya_id: int | None = None

    @property
    def toplam(self) -> float:
        return self.liste - self.indirim

    def json(self) -> dict:
        return {"liste_fiyati": self.liste, "indirim_tutari": self.indirim, "indirim_aciklama": self.aciklama,
                "toplam_fiyat": self.toplam}


def id_listesi(metin: str | None) -> set[int]:
    return {int(x) for x in (metin or "").split(",") if x.strip().isdigit()}


# ─────────────────────────── Kampanya ───────────────────────────

def aktif_kampanyalar(db: Session, salon_id: int) -> list[models.Kampanya]:
    """Aktif ve süresi dolmamış kampanyalar."""
    bugun_str = bugun().isoformat()
    return [k for k in db.query(models.Kampanya).filter(models.Kampanya.salon_id == salon_id,
                                                        models.Kampanya.aktif.is_(True))
            if not k.bit_tarih or k.bit_tarih >= bugun_str]


def gune_uyar(k: models.Kampanya, gun: date) -> bool:
    t = gun.isoformat()
    if k.bas_tarih and t < k.bas_tarih or k.bit_tarih and t > k.bit_tarih:
        return False
    gunler = gun_listesi(k.gunler)
    return not gunler or gun.weekday() in gunler


def saate_uyar(k: models.Kampanya, saat: str) -> bool:
    if not k.bas_saat or not k.bit_saat:
        return True
    return saat_dk(k.bas_saat) <= saat_dk(saat) < saat_dk(k.bit_saat)


def hizmete_uyar(k: models.Kampanya, hizmet_id: int) -> bool:
    idler = id_listesi(k.hizmet_idler)
    return not idler or hizmet_id in idler


def kampanya_indirimi(kampanyalar: list[models.Kampanya], kalemler: list[Kalem], gun: date,
                      saat: str | None) -> tuple[float, models.Kampanya | None]:
    """(indirim tutarı, en çok indirimi sağlayan kampanya). `saat` None → yalnızca gün kontrolü."""
    uyan = [k for k in kampanyalar if gune_uyar(k, gun) and (saat is None or saate_uyar(k, saat))]
    toplam, katki = 0.0, {}
    for kalem in kalemler:
        adaylar = [k for k in uyan if hizmete_uyar(k, kalem.hizmet.id)]
        if not adaylar:
            continue
        en_iyi = max(adaylar, key=lambda k: k.yuzde)
        tutar = kalem.fiyat * en_iyi.yuzde / 100
        toplam += tutar
        katki[en_iyi.id] = katki.get(en_iyi.id, 0) + tutar
    if not katki:
        return 0, None
    kampanya_id = max(katki, key=katki.get)
    return round(toplam), next(k for k in uyan if k.id == kampanya_id)


def slot_yuzdeleri(kampanyalar: list[models.Kampanya], kalemler: list[Kalem], gun: date,
                   saatler: list[str]) -> dict[str, int]:
    """Müşteriye gösterim: saat → toplam tutara göre indirim yüzdesi (yalnızca indirimli saatler)."""
    liste = sum(k.fiyat for k in kalemler)
    if not liste or not kampanyalar:
        return {}
    sonuc = {}
    for s in saatler:
        tutar, _ = kampanya_indirimi(kampanyalar, kalemler, gun, s)
        if tutar:
            sonuc[s] = round(tutar / liste * 100)
    return sonuc


def kampanya_ozeti(k: models.Kampanya, hizmet_adlari: dict[int, str]) -> str:
    """"Salı · 10:00–14:00 · Saç Kesimi" gibi kısa koşul metni (İngilizce istekte İngilizce)."""
    en = ceviri.ingilizce()
    parca = []
    gunler = sorted(gun_listesi(k.gunler))
    if gunler == [0, 1, 2, 3, 4]:
        parca.append("Weekdays" if en else "Hafta içi")
    elif gunler == [5, 6]:
        parca.append("Weekends" if en else "Hafta sonu")
    elif gunler and len(gunler) < 7:
        parca.append(", ".join((GUN_ADLARI_EN if en else GUN_ADLARI)[g] for g in gunler))
    if k.bas_saat and k.bit_saat:
        parca.append(f"{k.bas_saat}–{k.bit_saat}")
    idler = id_listesi(k.hizmet_idler)
    if idler:
        parca.append(", ".join(hizmet_adlari[i] for i in sorted(idler) if i in hizmet_adlari))
    if k.bit_tarih:
        y, a, g = k.bit_tarih.split("-")
        parca.append(f"until {g}.{a}.{y}" if en else f"{g}.{a}.{y}{yonelme_eki(int(y))} kadar")
    return " · ".join(parca) or ("All services, every day" if en else "Tüm hizmetlerde, her gün")


# ─────────────────────────── Sadakat ───────────────────────────

def ziyaret_sayisi(db: Session, salon_id: int, musteri_id: int) -> int:
    """Sadakatte sayılan randevular: tamamlanan + henüz gerçekleşmemiş aktif olanlar."""
    return db.query(models.Randevu).filter(models.Randevu.salon_id == salon_id,
                                           models.Randevu.musteri_id == musteri_id,
                                           models.Randevu.durum.in_(("tamamlandi", "onaylandi"))).count()


def sadakat_acik(salon: models.Salon) -> bool:
    return bool(salon.sadakat_esik and salon.sadakat_yuzde)


def sadakat_durumu(db: Session, salon: models.Salon, musteri_id: int | None) -> dict | None:
    """Salon detayındaki kart: eşik, yüzde ve (oturum varsa) müşterinin sayacı."""
    if not sadakat_acik(salon):
        return None
    sonuc = {"esik": salon.sadakat_esik, "yuzde": salon.sadakat_yuzde, "ziyaret": None, "siradaki_indirimli": False}
    if musteri_id is not None:
        n = ziyaret_sayisi(db, salon.id, musteri_id)
        sonuc["ziyaret"] = n % salon.sadakat_esik
        sonuc["siradaki_indirimli"] = (n + 1) % salon.sadakat_esik == 0
    return sonuc


# ─────────────────────────── Toplam ───────────────────────────

def fiyat_hesapla(db: Session, salon: models.Salon, kalemler: list[Kalem], gun: date, saat: str,
                  musteri_id: int | None) -> Fiyat:
    liste = float(sum(k.fiyat for k in kalemler))
    k_tutar, kampanya = kampanya_indirimi(aktif_kampanyalar(db, salon.id), kalemler, gun, saat)
    s_tutar = 0
    if musteri_id is not None and sadakat_acik(salon):
        sira = ziyaret_sayisi(db, salon.id, musteri_id) + 1
        if sira % salon.sadakat_esik == 0:
            s_tutar = round(liste * salon.sadakat_yuzde / 100)
    if s_tutar and s_tutar >= k_tutar:
        return Fiyat(liste, float(s_tutar), f"Sadakat kartı: {sira}. ziyaret %{salon.sadakat_yuzde}")
    if k_tutar:
        return Fiyat(liste, float(k_tutar), f"{kampanya.ad} %{kampanya.yuzde}", kampanya.id)
    return Fiyat(liste)


def ertelemede_kampanya_korunur(db: Session, r: models.Randevu, gun: date, saat: str) -> bool:
    """Kampanyalı randevu yeni gün/saatte de aynı kampanyaya uyuyor mu? (Uymuyorsa indirim kalkar.)"""
    k = db.get(models.Kampanya, r.kampanya_id) if r.kampanya_id else None
    if not k or not k.aktif:
        return False
    return gune_uyar(k, gun) and saate_uyar(k, saat) and any(hizmete_uyar(k, h.id) for h in r.hizmetler)
