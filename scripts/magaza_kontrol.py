"""Play mağaza metinlerinin karakter sınırlarını ve görsel ölçülerini doğrular.

    python scripts/magaza_kontrol.py
"""
import re
import sys
from pathlib import Path

KOK = Path(__file__).resolve().parent.parent
MD = (KOK / "MAGAZA" / "magaza_metinleri.md").read_text(encoding="utf-8")
SINIRLAR = {"Uygulama adı": 30, "Kısa açıklama": 80, "Uzun açıklama": 4000}


def blok(baslik: str) -> str:
    m = re.search(rf"## {baslik}[^\n]*\n+```\n(.*?)\n```", MD, re.S)
    if not m:
        sys.exit(f"Bulunamadı: {baslik}")
    return m.group(1)


hata = False
for baslik, sinir in SINIRLAR.items():
    n = len(blok(baslik))
    durum = "✅" if n <= sinir else "❌"
    hata |= n > sinir
    print(f"{durum} {baslik}: {n}/{sinir}")

try:
    from PIL import Image

    for dosya, olcu in [("ikon_512.png", (512, 512)), ("one_cikan_1024x500.png", (1024, 500))]:
        with Image.open(KOK / "MAGAZA" / "gorseller" / dosya) as im:
            ok = im.size == olcu
            hata |= not ok
            print(f"{'✅' if ok else '❌'} {dosya}: {im.size[0]}x{im.size[1]} {im.mode}")
except ImportError:
    print("(Pillow yok, görsel ölçüsü atlandı)")

sys.exit(1 if hata else 0)
