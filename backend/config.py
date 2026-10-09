"""Uygulama ayarları — tamamı ortam değişkenlerinden (.env) okunur.

Gizli bilgi (şifre, anahtar) bu dosyaya YAZILMAZ. Örnek değerler için .env.example.
"""
from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Ayarlar(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # development | production | test
    ortam: str = "development"

    database_url: str = "sqlite:///./berber_yeni.db"

    # firebase: ID token imzası Firebase ile doğrulanır (production için zorunlu)
    # dev: token imzası doğrulanmadan çözülür veya "dev:<uid>" kabul edilir (yalnızca yerel geliştirme/test)
    auth_mode: str = "firebase"

    # Virgülle ayrılmış Firebase UID listesi — bu kullanıcılar admin rolündedir
    admin_uids: str = ""
    # Eski X-Admin-Secret yolu. Boşsa tamamen kapalıdır (varsayılan değer YOK).
    admin_secret: str = ""

    # Servis hesabı: dosya yolu veya JSON içeriği (Render gibi ortamlarda env'e yapıştırmak için)
    firebase_credentials_path: str = "serviceAccountKey.json"
    firebase_credentials_json: str = ""

    # Virgülle ayrılmış izinli origin listesi. Mobil uygulama CORS'a tabi değildir;
    # bu ayar yalnızca web istemcileri (örn. ileride web paneli) içindir.
    cors_origins: str = "http://localhost:3000,http://localhost:8080"

    zaman_dilimi: str = "Europe/Istanbul"
    rezervasyon_ufku_gun: int = 30
    slot_dk: int = 30
    iptal_son_dk: int = 30

    scheduler_enabled: bool = True
    uploads_dir: str = "uploads"

    @property
    def admin_uid_listesi(self) -> set[str]:
        return {u.strip() for u in self.admin_uids.split(",") if u.strip()}

    @property
    def cors_listesi(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def uretim_mi(self) -> bool:
        return self.ortam == "production"


@lru_cache
def ayarlar() -> Ayarlar:
    a = Ayarlar()
    if a.uretim_mi and a.auth_mode != "firebase":
        raise RuntimeError("Production ortamında AUTH_MODE=firebase olmak zorunda.")
    return a
