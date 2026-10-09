"""Android/iOS paket adını değiştirir (Google Play `com.example` kabul etmez).

Kullanım (repo kökünden):
    python scripts/paket_adi_degistir.py com.premiumberber.app indirilen/google-services.json

Önce Firebase Console → Proje ayarları → "Uygulama ekle" → Android → paket adı: com.premiumberber.app
ile yeni uygulamayı kaydedip google-services.json'u indirin. Betik, dosyanın bu paket adını içerdiğini doğrular;
içermiyorsa hiçbir şeyi değiştirmez (aksi halde uygulama açılışta Firebase'e bağlanamaz).

--dene: değişiklikleri yazmadan gösterir.
"""
import argparse
import json
import re
import shutil
import sys
from pathlib import Path

KOK = Path(__file__).resolve().parent.parent
APP = KOK / "App"

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
ESKI = "com.example.berber_app_ui"


def kontrol_et(paket: str, gs_json: Path) -> None:
    if not re.fullmatch(r"[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*){1,}", paket) or paket.startswith("com.example"):
        sys.exit(f"Geçersiz paket adı: {paket} (örn. com.premiumberber.app; com.example olamaz)")
    veri = json.loads(gs_json.read_text(encoding="utf-8"))
    paketler = [c["client_info"]["android_client_info"]["package_name"] for c in veri.get("client", [])]
    if paket not in paketler:
        sys.exit(f"{gs_json} içinde '{paket}' yok (bulunan: {paketler}). Firebase'de doğru paket adıyla kaydedin.")


def degistir(paket: str, gs_json: Path, dene: bool) -> list[str]:
    islemler: list[str] = []

    def yaz(yol: Path, eski: str, yeni: str) -> None:
        if eski == yeni:
            return
        islemler.append(f"güncellendi: {yol.relative_to(KOK)}")
        if not dene:
            yol.write_text(yeni, encoding="utf-8")

    gradle = APP / "android/app/build.gradle.kts"
    s = gradle.read_text(encoding="utf-8")
    yaz(gradle, s, s.replace(f'namespace = "{ESKI}"', f'namespace = "{paket}"')
        .replace(f'applicationId = "{ESKI}"', f'applicationId = "{paket}"'))

    manifest = APP / "android/app/src/main/AndroidManifest.xml"
    s = manifest.read_text(encoding="utf-8")
    yaz(manifest, s, s.replace(f'\n    package="{ESKI}"', ""))  # namespace gradle'da; package niteliği gereksiz

    kotlin_kok = APP / "android/app/src/main/kotlin"
    eski_activity = kotlin_kok / Path(*ESKI.split(".")) / "MainActivity.kt"
    yeni_activity = kotlin_kok / Path(*paket.split(".")) / "MainActivity.kt"
    if eski_activity.exists():
        s = eski_activity.read_text(encoding="utf-8").replace(f"package {ESKI}", f"package {paket}")
        islemler.append(f"taşındı: {eski_activity.relative_to(KOK)} → {yeni_activity.relative_to(KOK)}")
        if not dene:
            yeni_activity.parent.mkdir(parents=True, exist_ok=True)
            yeni_activity.write_text(s, encoding="utf-8")
            eski_activity.unlink()
            for d in list(eski_activity.parents)[: len(ESKI.split("."))]:
                if d.is_dir() and not any(d.iterdir()):
                    d.rmdir()

    pbx = APP / "ios/Runner.xcodeproj/project.pbxproj"
    if pbx.exists():
        s = pbx.read_text(encoding="utf-8")
        yaz(pbx, s, re.sub(r"PRODUCT_BUNDLE_IDENTIFIER = com\.example\.berberAppUi(\.RunnerTests)?;",
                           lambda m: f"PRODUCT_BUNDLE_IDENTIFIER = {paket}{m.group(1) or ''};", s))

    config = APP / "lib/core/config.dart"
    s = config.read_text(encoding="utf-8")
    yaz(config, s, re.sub(r"details\?id=[\w.]+'", f"details?id={paket}'", s))

    hedef = APP / "android/app/google-services.json"
    islemler.append(f"kopyalandı: {gs_json} → {hedef.relative_to(KOK)}")
    if not dene:
        shutil.copyfile(gs_json, hedef)
    return islemler


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("paket")
    p.add_argument("google_services_json", type=Path)
    p.add_argument("--dene", action="store_true")
    p.add_argument("--kok", type=Path, help="(test için) repo kökü")
    a = p.parse_args()
    if a.kok:
        global KOK, APP
        KOK, APP = a.kok.resolve(), a.kok.resolve() / "App"
    kontrol_et(a.paket, a.google_services_json)
    for satir in degistir(a.paket, a.google_services_json, a.dene):
        print(("[deneme] " if a.dene else "") + satir)
    if not a.dene:
        print("\nSonra: cd App && flutter clean && flutter build appbundle --release --dart-define=API_BASE_URL=https://...")


if __name__ == "__main__":
    main()
