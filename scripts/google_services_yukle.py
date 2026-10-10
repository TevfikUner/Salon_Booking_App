"""Firebase'den indirilen google-services.json'u doğrulayıp uygulamaya yerleştirir.

    python scripts/google_services_yukle.py ~/Downloads/google-services.json

Dosya `com.tevfikuner.premiumberber` paket adlı bir Android istemcisi içermiyorsa hiçbir şey değiştirmez
(yanlış dosyayla uygulama açılışta Firebase'e bağlanamaz).
"""
import json
import shutil
import sys
from pathlib import Path

PAKET = "com.tevfikuner.premiumberber"
HEDEF = Path(__file__).resolve().parent.parent / "App" / "android" / "app" / "google-services.json"

for akis in (sys.stdout, sys.stderr):
    if hasattr(akis, "reconfigure"):
        akis.reconfigure(encoding="utf-8")

if len(sys.argv) != 2:
    sys.exit(__doc__)
kaynak = Path(sys.argv[1]).expanduser()
try:
    veri = json.loads(kaynak.read_text(encoding="utf-8"))
except (OSError, json.JSONDecodeError) as e:
    sys.exit(f"❌ Okunamadı: {e}")

istemciler = [c for c in veri.get("client", [])
              if c.get("client_info", {}).get("android_client_info", {}).get("package_name") == PAKET]
if not istemciler:
    paketler = [c.get("client_info", {}).get("android_client_info", {}).get("package_name") for c in veri.get("client", [])]
    sys.exit(f"❌ Bu dosyada {PAKET} yok (bulunanlar: {paketler}). Firebase'de bu paket adıyla Android uygulaması ekleyin.")

uygulama_id = istemciler[0]["client_info"]["mobilesdk_app_id"]
proje = veri.get("project_info", {}).get("project_id")
if kaynak.resolve() != HEDEF.resolve():
    shutil.copyfile(kaynak, HEDEF)
print(f"✅ Yerleştirildi: {HEDEF}\n   proje={proje}  mobilesdk_app_id={uygulama_id}")
print("Sonra: cd App && flutter build appbundle --release --dart-define=API_URL=https://<API_ADRESİ>")
