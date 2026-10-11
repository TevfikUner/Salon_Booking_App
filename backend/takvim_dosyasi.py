"""Randevu için iCalendar (.ics, RFC 5545) dosyası — müşterinin kendi takvimine eklemesi için.

Bağımlılık yok: metin kaçışı (ters bölü, noktalı virgül, virgül, satır sonu) ve 75 baytlık satır katlama
elle yapılır. Saatler salonun yerel saatidir; Türkiye 2016'dan beri yaz saati uygulamadığı için VTIMEZONE
sabit +03:00.
"""
from datetime import datetime, timedelta

import models

TZID = "Europe/Istanbul"
_VTIMEZONE = [
    "BEGIN:VTIMEZONE", f"TZID:{TZID}",
    "BEGIN:STANDARD", "DTSTART:19700101T000000", "TZOFFSETFROM:+0300", "TZOFFSETTO:+0300", "TZNAME:+03",
    "END:STANDARD", "END:VTIMEZONE",
]


def kacis(metin: str | None) -> str:
    r"""RFC 5545 TEXT kaçışı: \ → \\, ; → \;, , → \,, satır sonu → \n"""
    return ((metin or "").replace("\\", "\\\\").replace(";", "\\;").replace(",", "\\,")
            .replace("\r\n", "\\n").replace("\n", "\\n"))


def katla(satir: str) -> list[str]:
    """75 oktetten uzun satırı, UTF-8 karakterini bölmeden devam satırlarına (başı boşluk) ayırır."""
    parcalar, mevcut, boyut = [], "", 0
    for ch in satir:
        b = len(ch.encode("utf-8"))
        sinir = 75 if not parcalar else 74  # devam satırının baştaki boşluğu da sayılır
        if boyut + b > sinir:
            parcalar.append(mevcut)
            mevcut, boyut = "", 0
        mevcut += ch
        boyut += b
    parcalar.append(mevcut)
    return [parcalar[0]] + [" " + p for p in parcalar[1:]]


def _yerel(dt: datetime) -> str:
    return dt.strftime("%Y%m%dT%H%M%S")


def randevu_ics(r: models.Randevu, damga_utc: datetime) -> str:
    bas = datetime.strptime(f"{r.tarih} {r.saat}", "%Y-%m-%d %H:%M")
    bit = bas + timedelta(minutes=r.sure_dk or 30)
    salon = r.salon.ad if r.salon else "Salon"
    hizmetler = ", ".join(h.ad for h in r.hizmetler)
    berber = f"{r.berber.ad} {r.berber.soyad}".strip() if r.berber else ""
    aciklama = "\n".join(x for x in [
        f"Berber: {berber}" if berber else "",
        f"Hizmetler: {hizmetler}" if hizmetler else "",
        f"Toplam: {r.toplam_fiyat:.0f} TL" if r.toplam_fiyat is not None else "",
        f"Salon telefonu: {r.salon.telefon}" if r.salon and r.salon.telefon else "",
        "Premium Berber uygulamasından değiştirebilir veya iptal edebilirsiniz.",
    ] if x)
    satirlar = [
        "BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//Premium Berber//Randevu//TR", "CALSCALE:GREGORIAN",
        "METHOD:PUBLISH", *_VTIMEZONE,
        "BEGIN:VEVENT",
        f"UID:randevu-{r.id}@premiumberber",
        f"DTSTAMP:{damga_utc.strftime('%Y%m%dT%H%M%SZ')}",
        f"DTSTART;TZID={TZID}:{_yerel(bas)}",
        f"DTEND;TZID={TZID}:{_yerel(bit)}",
        f"SUMMARY:{kacis(f'{salon} — {hizmetler}' if hizmetler else salon)}",
        f"LOCATION:{kacis((r.salon.adres if r.salon else None) or salon)}",
        f"DESCRIPTION:{kacis(aciklama)}",
        f"STATUS:{'CANCELLED' if r.durum == 'iptal' else 'CONFIRMED'}",
        f"SEQUENCE:{r.erteleme_sayisi or 0}",  # ertelenince takvim uygulaması eski kaydı günceller
        "BEGIN:VALARM", "ACTION:DISPLAY", "TRIGGER:-PT60M", f"DESCRIPTION:{kacis('Randevunuza 1 saat kaldı')}",
        "END:VALARM",
        "END:VEVENT", "END:VCALENDAR",
    ]
    return "\r\n".join(k for s in satirlar for k in katla(s)) + "\r\n"
