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

    # Zamanlanmış görevler. Production'da web süreçlerinde KAPALI, ayrı worker sürecinde açıktır
    # (worker.py). Yanlışlıkla iki yerde açılsa bile DB kilidi (gorev_kilitleri) işi tek örnekte çalıştırır.
    scheduler_enabled: bool = True
    uploads_dir: str = "uploads"

    # Veritabanı bağlantı havuzu (PostgreSQL). Toplam bağlantı ≈ worker × (pool_size + max_overflow)
    db_pool_size: int = 5
    db_max_overflow: int = 10
    db_pool_timeout: int = 10
    db_pool_recycle: int = 1800

    # /docs ve /openapi.json. Boşsa: production'da kapalı, diğer ortamlarda açık.
    docs_enabled: bool | None = None

    # Hız sınırı (slowapi). Depo: memory:// (worker başına) veya redis://… (tüm worker'larda ortak)
    rate_limit_enabled: bool = True
    rate_limit_storage_uri: str = "memory://"
    rate_limit_varsayilan: str = "300/minute"

    # İstek gövdesi üst sınırı (bayt). Fotoğraf yükleme ucu kendi sınırını uygular.
    maks_istek_boyutu: int = 1_000_000

    # Gözlemlenebilirlik
    log_format: str = "json"  # json | metin
    log_level: str = "INFO"
    sentry_dsn: str = ""
    sentry_traces_sample_rate: float = 0.1
    surum: str = "1.0.0"

    # Yasal sayfalarda ve destek iletişiminde görünen e-posta (gerçek adres env ile verilmeli)
    destek_eposta: str = "destek@premiumberber.app"

    @property
    def admin_uid_listesi(self) -> set[str]:
        return {u.strip() for u in self.admin_uids.split(",") if u.strip()}

    @property
    def cors_listesi(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def uretim_mi(self) -> bool:
        return self.ortam == "production"

    @property
    def dokumanlar_acik(self) -> bool:
        return (not self.uretim_mi) if self.docs_enabled is None else self.docs_enabled


@lru_cache
def ayarlar() -> Ayarlar:
    a = Ayarlar()
    if a.uretim_mi and a.auth_mode != "firebase":
        raise RuntimeError("Production ortamında AUTH_MODE=firebase olmak zorunda.")
    return a
