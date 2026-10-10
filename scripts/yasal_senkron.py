"""Yasal metinlerin tek kaynağı backend/yasal/*.md — uygulama içi kopyayı bundan üretir.

    python scripts/yasal_senkron.py            → App/lib/data/sabit/yasal_metinler.dart yazılır
    python scripts/yasal_senkron.py --kontrol  → Dart dosyası güncel değilse çıkış kodu 1 (CI için)

Web sayfası (/yasal/gizlilik …) ve uygulama aynı metni gösterir; Play Console'daki gizlilik politikası
bağlantısı ile uygulama içindeki metin birbirinden ayrışmaz. {DESTEK_EPOSTA} ve {..._URL} yer tutucuları
uygulamada çalışma anında AppConfig değerleriyle doldurulur.
"""
import re
import sys
from pathlib import Path

KOK = Path(__file__).resolve().parent.parent
KAYNAK = KOK / "backend" / "yasal"
HEDEF = KOK / "App" / "lib" / "data" / "sabit" / "yasal_metinler.dart"
BELGELER = [("gizlilik", "Gizlilik Politikası"), ("kvkk", "KVKK Aydınlatma Metni"), ("kullanim", "Kullanım Koşulları")]


def duz_metin(md: str) -> str:
    """Markdown → ekranda okunur düz metin (uygulama Text widget'ı ile gösterir)."""
    satirlar = []
    for s in md.strip().splitlines():
        if s.startswith("# "):
            continue  # belge başlığı AppBar'da
        if s.startswith("## "):
            s = s[3:].replace("i", "İ").replace("ı", "I").upper()  # Türkçe büyük harf (i→İ, ı→I)
        elif s.startswith("### "):
            s = s[4:]
        elif s.startswith("- "):
            s = "• " + s[2:]
        s = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r"\1 (\2)", s)
        s = s.replace("**", "")
        satirlar.append(s)
    return "\n".join(satirlar).strip() + "\n"


def uret() -> str:
    parcalar = [
        "// OTOMATİK ÜRETİLDİ — elle düzenlemeyin. Kaynak: backend/yasal/*.md",
        "// Güncellemek için: python scripts/yasal_senkron.py",
        "import 'package:berber_app_ui/core/config.dart';",
        "",
        "class YasalMetin {",
        "  final String baslik;",
        "  final String _ham;",
        "",
        "  /// Web'deki aynı belgenin adresi (Play Console ve tarayıcı için).",
        "  final String yol;",
        "  const YasalMetin(this.baslik, this._ham, this.yol);",
        "",
        "  String get icerik => _ham",
        "      .replaceAll('{DESTEK_EPOSTA}', AppConfig.destekEposta)",
        "      .replaceAll('{HESAP_SILME_URL}', AppConfig.hesapSilmeUrl)",
        "      .replaceAll('{KVKK_URL}', '${AppConfig.baseUrl}/yasal/kvkk');",
        "",
        "  String get webAdresi => '${AppConfig.baseUrl}/yasal/$yol';",
        "}",
        "",
        "class YasalMetinler {",
        "  YasalMetinler._();",
        "",
    ]
    for ad, baslik in BELGELER:
        parcalar.append(f"  static const {ad} = YasalMetin('{baslik}', _{ad}, '{ad}');")
    for ad, _ in BELGELER:
        metin = duz_metin((KAYNAK / f"{ad}.md").read_text(encoding="utf-8"))
        assert "'''" not in metin
        parcalar += ["", f"  static const String _{ad} = r'''", metin.rstrip("\n"), "''';"]
    parcalar.append("}")
    return "\n".join(parcalar) + "\n"


if __name__ == "__main__":
    yeni = uret()
    if "--kontrol" in sys.argv:
        # Windows'ta git CRLF'e çevirebilir; satır sonu farkı "güncel değil" sayılmaz
        guncel = HEDEF.exists() and HEDEF.read_text(encoding="utf-8").replace("\r\n", "\n") == yeni
        print("güncel" if guncel else "GÜNCEL DEĞİL: python scripts/yasal_senkron.py çalıştırın")
        sys.exit(0 if guncel else 1)
    HEDEF.write_text(yeni, encoding="utf-8", newline="\n")
    print(f"yazıldı: {HEDEF.relative_to(KOK)}")
