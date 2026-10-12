"""Kişisel verinin veritabanında şifrelenmesi (KVKK m.12 — veri güvenliği için teknik tedbir).

- `VERI_ANAHTARI` verilirse `SifreliMetin` sütunları (ad, soyad, telefon, e-posta, notlar, yorumlar) yazılırken
  Fernet (AES-128-CBC + HMAC-SHA256) ile şifrelenir ve `enc1:` önekiyle saklanır. Anahtar herhangi bir gizli
  metin olabilir; Fernet anahtarı SHA-256 ile ondan türetilir (`python araclar.py anahtar-uret` güçlü bir tane üretir).
- Anahtar yoksa düz yazılır (yerel geliştirme/test). Okuma her iki biçimi de çözer → mevcut düz veri bozulmaz,
  `python araclar.py veri-sifrele` ile toplu şifrelenir (kademeli geçiş).
- Anahtar değişimi: yeni anahtar `VERI_ANAHTARI`, eskiler virgülle `VERI_ANAHTARI_ESKI`; ardından `veri-sifrele`
  bütün kayıtları yeni anahtarla yeniden yazar.
- Şifreli sütunda eşitlik araması yapılamaz. Telefonla eşleşme (panelden eklenen müşteri) için ayrı bir
  HMAC özeti tutulur: `Musteri.telefon_ozet`.

ANAHTAR KAYBOLURSA ŞİFRELİ VERİ GERİ GETİRİLEMEZ — parola yöneticisinde yedekleyin (BENDEN_GEREKENLER §10).
"""
import base64
import hashlib
import hmac
import logging
from functools import lru_cache

from cryptography.fernet import Fernet, InvalidToken, MultiFernet
from sqlalchemy import String, Text
from sqlalchemy.types import TypeDecorator

from config import ayarlar

log = logging.getLogger(__name__)

ONEK = "enc1:"
COZULEMEDI = "[şifreli]"  # anahtar yok/yanlışsa okunan değer (uygulama çökmesin, veri ezilmesin)


def _fernet_anahtari(gizli: str) -> bytes:
    return base64.urlsafe_b64encode(hashlib.sha256(gizli.encode()).digest())


@lru_cache
def _anahtarlar() -> tuple[MultiFernet | None, bytes]:
    a = ayarlar()
    gizliler = [x.strip() for x in [a.veri_anahtari, *a.veri_anahtari_eski.split(",")] if x.strip()]
    fernet = MultiFernet([Fernet(_fernet_anahtari(g)) for g in gizliler]) if gizliler else None
    # Telefon özeti için ayrı anahtar (şifreleme anahtarından türetilir; anahtar yoksa sabit geliştirme değeri)
    ozet = hashlib.sha256(b"telefon-ozet:" + (a.veri_anahtari or "gelistirme").encode()).digest()
    return fernet, ozet


def anahtarlari_yenile() -> None:
    """Testlerde/komutlarda ayar değişince önbelleği temizler."""
    _anahtarlar.cache_clear()


def sifreleme_acik() -> bool:
    return _anahtarlar()[0] is not None


_duz_yaz = False  # veri-coz komutu: şifrelemeyi kapatırken kayıtları düz yeniden yazmak için


def sifrele(deger: str | None) -> str | None:
    if not deger or deger.startswith(ONEK):
        return deger
    fernet = _anahtarlar()[0]
    if fernet is None or _duz_yaz:
        return deger
    return ONEK + fernet.encrypt(deger.encode()).decode()


def coz(deger: str | None) -> str | None:
    if not deger or not deger.startswith(ONEK):
        return deger
    fernet = _anahtarlar()[0]
    if fernet is None:
        log.error("Şifreli kişisel veri okunuyor ama VERI_ANAHTARI tanımlı değil.")
        return COZULEMEDI
    try:
        return fernet.decrypt(deger[len(ONEK):].encode()).decode()
    except InvalidToken:
        log.error("Şifreli kişisel veri çözülemedi: VERI_ANAHTARI / VERI_ANAHTARI_ESKI yanlış.")
        return COZULEMEDI


def telefon_ozeti(telefon: str | None) -> str | None:
    """Biçimden bağımsız (0532…, +90 532…, 532…) telefon özeti: son 10 rakamın HMAC-SHA256'sı."""
    rakam = "".join(c for c in (telefon or "") if c.isdigit())[-10:]
    if len(rakam) < 10:
        return None
    return hmac.new(_anahtarlar()[1], rakam.encode(), hashlib.sha256).hexdigest()


def sifreli_sutunlar() -> dict:
    """Model → şifreli sütun adları (toplu yeniden yazma için)."""
    import models

    sonuc = {}
    for mapper in models.Base.registry.mappers:
        adlar = [c.key for c in mapper.columns if isinstance(c.type, SifreliMetin)]
        if adlar:
            sonuc[mapper.class_] = adlar
    return sonuc


def tum_veriyi_yeniden_yaz(db, duz: bool = False, parti: int = 500) -> dict[str, int]:
    """Şifreli sütunlardaki tüm değerleri güncel anahtarla yeniden yazar (düz → şifreli, eski anahtar → yeni).
    `duz=True`: şifreyi çözüp düz yazar (şifrelemeyi kapatmadan önce). Çözülemeyen değer varsa hiçbir şey yazmaz.
    Müşterilerin telefon özetini de yeniden hesaplar (özet anahtarı VERI_ANAHTARI'ndan türetilir)."""
    global _duz_yaz
    from sqlalchemy.orm.attributes import flag_modified

    import models

    if not duz and not sifreleme_acik():
        raise RuntimeError("VERI_ANAHTARI tanımlı değil; şifrelenecek anahtar yok.")
    sayac: dict[str, int] = {}
    _duz_yaz = duz
    try:
        for model, sutunlar in sifreli_sutunlar().items():
            n = 0
            for nesne in db.query(model).yield_per(parti):
                for s in sutunlar:
                    deger = getattr(nesne, s)
                    if deger == COZULEMEDI:
                        db.rollback()
                        raise RuntimeError(f"{model.__tablename__}.{s} çözülemedi: anahtar yanlış. Hiçbir şey yazılmadı.")
                    if deger:
                        flag_modified(nesne, s)
                        n += 1
                if isinstance(nesne, models.Musteri):
                    nesne.telefon_ozet = telefon_ozeti(nesne.telefon)
            sayac[model.__tablename__] = n
        db.commit()
    finally:
        _duz_yaz = False
    return sayac


class SifreliMetin(TypeDecorator):
    """Yazarken şifreler, okurken çözer. Veritabanı tipi değişmez (VARCHAR), migration gerekmez."""
    impl = String
    cache_ok = True

    def process_bind_param(self, value, dialect):
        return sifrele(value)

    def process_result_value(self, value, dialect):
        return coz(value)


class SifreliUzunMetin(SifreliMetin):
    impl = Text
    cache_ok = True
