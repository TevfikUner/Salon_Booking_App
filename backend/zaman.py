"""Tek zaman kaynağı.

Sunucu UTC'de çalışsa bile (Render/Docker) tüm iş kuralları salonun yerel saatine
(Europe/Istanbul) göre işler. Testler `sabit_an` ile zamanı dondurabilir.
"""
from datetime import date, datetime
from zoneinfo import ZoneInfo

from config import ayarlar

TZ = ZoneInfo(ayarlar().zaman_dilimi)

# Testlerde zamanı dondurmak için: zaman.sabit_an = datetime(2026, 10, 7, 12, 10)
sabit_an: datetime | None = None


def simdi() -> datetime:
    """Yerel saat (tz bilgisi olmadan, DB'deki tarih/saat string'leriyle karşılaştırmak için)."""
    if sabit_an is not None:
        return sabit_an
    return datetime.now(TZ).replace(tzinfo=None)


def bugun() -> date:
    return simdi().date()


def tarih_coz(tarih_str: str) -> date:
    return datetime.strptime(tarih_str, "%Y-%m-%d").date()


def saat_dk(saat_str: str) -> int:
    """"HH:MM" → gün başından itibaren dakika. Geçersizse ValueError."""
    t = datetime.strptime(saat_str, "%H:%M")
    return t.hour * 60 + t.minute


def dk_saat(dk: int) -> str:
    return f"{dk // 60:02d}:{dk % 60:02d}"
