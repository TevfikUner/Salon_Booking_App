"""Logo'dan ikon, splash ve mağaza görsellerini üretir (Pillow gerekir: pip install pillow).

    python scripts/gorsel_uret.py

Üretilenler:
  App/assets/images/ikon_on_plan.png   adaptive icon ön planı (şeffaf, güvenli alanda)
  App/assets/images/splash_logo.png    splash ekranı logosu (şeffaf)
  MAGAZA/gorseller/ikon_512.png        Play Store uygulama ikonu (512x512, 32-bit PNG)
  MAGAZA/gorseller/one_cikan_1024x500.png   Play Store öne çıkan görsel
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

KOK = Path(__file__).resolve().parent.parent
LOGO = KOK / "App/assets/images/logo.png"
ZEMIN = (20, 20, 20)
ALTIN = (212, 165, 116)


def seffaf_logo() -> Image.Image:
    """Koyu zemini alfa kanalına çevirir; içeriği kırpar."""
    im = Image.open(LOGO).convert("RGB")
    piks = im.load()
    w, h = im.size
    alfa = Image.new("L", im.size, 0)
    ap = alfa.load()
    for y in range(h):
        for x in range(w):
            r, g, b = piks[x, y]
            fark = max(abs(r - ZEMIN[0]), abs(g - ZEMIN[1]), abs(b - ZEMIN[2]))
            ap[x, y] = 0 if fark < 12 else min(255, (fark - 12) * 6)
    rgba = im.convert("RGBA")
    rgba.putalpha(alfa)
    return rgba.crop(alfa.getbbox())


def ortala(icerik: Image.Image, boyut: int, oran: float) -> Image.Image:
    tuval = Image.new("RGBA", (boyut, boyut), (0, 0, 0, 0))
    olcek = boyut * oran / max(icerik.size)
    k = icerik.resize((round(icerik.width * olcek), round(icerik.height * olcek)), Image.LANCZOS)
    tuval.alpha_composite(k, ((boyut - k.width) // 2, (boyut - k.height) // 2))
    return tuval


def font(boyut: int) -> ImageFont.FreeTypeFont:
    for aday in ("C:/Windows/Fonts/georgiab.ttf", "C:/Windows/Fonts/timesbd.ttf",
                 "/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf"):
        if Path(aday).exists():
            return ImageFont.truetype(aday, boyut)
    return ImageFont.load_default()


def main() -> None:
    logo = seffaf_logo()
    (KOK / "MAGAZA/gorseller").mkdir(parents=True, exist_ok=True)

    # Adaptive icon: flutter_launcher_icons %16 iç boşluk ekler → etkin oran ~%58 (güvenli alan %61)
    ortala(logo, 1024, 0.86).save(KOK / "App/assets/images/ikon_on_plan.png")
    ortala(logo, 1024, 0.80).save(KOK / "App/assets/images/splash_logo.png")

    # Play ikonu: 512x512, köşesiz (Play kendisi yuvarlar), opak
    ikon = Image.new("RGBA", (512, 512), ZEMIN + (255,))
    ikon.alpha_composite(ortala(logo, 512, 0.78))
    ikon.convert("RGBA").save(KOK / "MAGAZA/gorseller/ikon_512.png")  # Play: 32-bit PNG

    # Öne çıkan görsel 1024x500
    fg = Image.new("RGB", (1024, 500), (10, 10, 10))
    parilti = Image.new("L", (1024, 500), 0)
    ImageDraw.Draw(parilti).ellipse((40, 60, 460, 440), fill=90)
    parilti = parilti.filter(ImageFilter.GaussianBlur(80))
    fg.paste(Image.new("RGB", (1024, 500), ALTIN), (0, 0), parilti)
    kucuk = ortala(logo, 380, 0.92)
    fg.paste(kucuk, (60, 60), kucuk)
    d = ImageDraw.Draw(fg)
    sol, genislik = 470, 1024 - 470 - 36

    def sigdir(metin: str, boyut: int) -> ImageFont.FreeTypeFont:
        while boyut > 12 and d.textlength(metin, font=font(boyut)) > genislik:
            boyut -= 2
        return font(boyut)

    d.text((sol, 150), "Premium Berber", font=sigdir("Premium Berber", 64), fill=ALTIN)
    d.text((sol + 2, 240), "3 saniyede berber randevusu", font=sigdir("3 saniyede berber randevusu", 30),
           fill=(235, 235, 235))
    alt = "Komisyonsuz · WhatsApp onaylı · Anında"
    d.text((sol + 2, 290), alt, font=sigdir(alt, 24), fill=(160, 160, 160))
    fg.save(KOK / "MAGAZA/gorseller/one_cikan_1024x500.png")
    print("Görseller üretildi.")


if __name__ == "__main__":
    main()
