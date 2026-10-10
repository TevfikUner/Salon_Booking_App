"""Uygulamada kullanılan Google Fonts varyantlarını assets/google_fonts/ altına indirir.

google_fonts paketi, bu klasörde doğru adlandırılmış dosya bulursa ağdan indirmez
(çevrimdışı ilk açılış + Google'a istek yok + testler ağsız çalışır).

    python scripts/yazi_tipi_indir.py
"""
import re
import sys
import urllib.request
from pathlib import Path

KOK = Path(__file__).resolve().parent.parent
HEDEF = KOK / "App/assets/google_fonts"
ISTENEN = {"Inter": [400, 500, 600, 700], "PlayfairDisplay": [400, 600, 700]}
AD = {400: "Regular", 500: "Medium", 600: "SemiBold", 700: "Bold"}


def paket_klasoru() -> Path:
    onbellek = Path.home() / "AppData/Local/Pub/Cache/hosted/pub.dev"
    if not onbellek.exists():
        onbellek = Path.home() / ".pub-cache/hosted/pub.dev"
    adaylar = sorted(onbellek.glob("google_fonts-*"))
    if not adaylar:
        sys.exit("google_fonts paketi pub önbelleğinde bulunamadı (önce flutter pub get).")
    return adaylar[-1]


def dosyalar(aile: str) -> dict[int, str]:
    for parca in (paket_klasoru() / "lib/src/google_fonts_parts").glob("*.dart"):
        metin = parca.read_text(encoding="utf-8")
        i = metin.find(f"fontFamily: '{aile}'")
        if i < 0:
            continue
        blok = metin[metin.rfind("static TextStyle", 0, i):i]
        sonuc = {}
        for m in re.finditer(r"fontWeight: FontWeight\.w(\d+),\s*fontStyle: FontStyle\.normal,\s*\): GoogleFontsFile\(\s*'([0-9a-f]+)'",
                             blok):
            sonuc[int(m.group(1))] = m.group(2)
        return sonuc
    sys.exit(f"{aile} bulunamadı")


def main() -> None:
    HEDEF.mkdir(parents=True, exist_ok=True)
    for aile, agirliklar in ISTENEN.items():
        harita = dosyalar(aile)
        for w in agirliklar:
            hedef = HEDEF / f"{aile.replace(' ', '')}-{AD[w]}.ttf"
            if hedef.exists():
                continue
            url = f"https://fonts.gstatic.com/s/a/{harita[w]}.ttf"
            urllib.request.urlretrieve(url, hedef)
            print(f"indirildi: {hedef.name} ({hedef.stat().st_size // 1024} KB)")
    print("Tamam.")


if __name__ == "__main__":
    main()
