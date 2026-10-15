"""Yüklenen dosyaların (berber fotoğrafı) saklanması: yerel disk veya S3 uyumlu nesne depolama.

DEPOLAMA=yerel → UPLOADS_DIR altına yazar, /uploads/... olarak sunulur (geliştirme, Docker volume).
DEPOLAMA=s3    → S3 uyumlu bucket'a yazar (Cloudflare R2, AWS S3, MinIO); URL S3_GENEL_URL ile kurulur.
Render'ın diski kalıcı olmadığından production'da s3 kullanılır (yerel dosyalar her deploy'da silinirdi).

Anahtar içerik özetini taşır (berberler/berber_7_3fa2c1d9e0b4.jpg): fotoğraf değişince URL de değişir, böylece
istemci/CDN önbelleği eski resmi göstermez; aynı dosya tekrar yüklenirse aynı anahtar oluşur.
"""
import contextlib
import hashlib
import logging
import os
from functools import lru_cache

from fastapi import HTTPException, UploadFile

from config import ayarlar

log = logging.getLogger("premium_berber.depolama")

ICERIK_TURLERI = {"jpg": "image/jpeg", "png": "image/png", "webp": "image/webp"}


MAKS_FOTO_BOYUTU = 5 * 1024 * 1024


def dosya_anahtari(klasor: str, onek: str, icerik: bytes, uzanti: str) -> str:
    return f"{klasor}/{onek}_{hashlib.sha256(icerik).hexdigest()[:12]}.{uzanti}"


def resim_turu(bas: bytes) -> str | None:
    """Dosyanın gerçek türü (istemcinin bildirdiği content-type'a güvenilmez)."""
    if bas.startswith(bytes.fromhex("ffd8ff")):
        return "jpg"
    if bas.startswith(bytes.fromhex("89504e470d0a1a0a")):
        return "png"
    if bas[:4] == b"RIFF" and bas[8:12] == b"WEBP":
        return "webp"
    return None


def resmi_oku(foto: UploadFile) -> tuple[bytes, str]:
    """Yüklenen fotoğrafı okur ve denetler (JPG/PNG/WebP, en fazla 5 MB). (içerik, uzantı) döner."""
    icerik = foto.file.read(MAKS_FOTO_BOYUTU + 1)
    if len(icerik) > MAKS_FOTO_BOYUTU:
        raise HTTPException(status_code=413, detail="Fotoğraf en fazla 5 MB olabilir.")
    uzanti = resim_turu(icerik[:16])
    if not uzanti:
        raise HTTPException(status_code=400, detail="Sadece JPG, PNG ve WebP formatı kabul edilir.")
    return icerik, uzanti


class YerelDepolama:
    URL_ONEKI = "/uploads/"

    def __init__(self, kok: str):
        self.kok = kok

    def kaydet(self, anahtar: str, icerik: bytes, uzanti: str) -> str:
        yol = os.path.join(self.kok, *anahtar.split("/"))
        os.makedirs(os.path.dirname(yol), exist_ok=True)
        with open(yol, "wb") as f:
            f.write(icerik)
        return self.URL_ONEKI + anahtar

    def sil(self, url: str | None) -> None:
        """Yalnızca bu depolamanın ürettiği URL'leri siler (elle girilmiş dış adreslere dokunmaz)."""
        if not url or not url.startswith(self.URL_ONEKI):
            return
        anahtar = url[len(self.URL_ONEKI):]
        if ".." in anahtar.split("/"):
            return
        with contextlib.suppress(FileNotFoundError):
            os.remove(os.path.join(self.kok, *anahtar.split("/")))


class S3Depolama:
    def __init__(self, bucket: str, genel_url: str, istemci=None):
        self.bucket = bucket
        self.genel_url = genel_url.rstrip("/")
        self._istemci = istemci

    @property
    def istemci(self):
        if self._istemci is None:
            import boto3

            a = ayarlar()
            self._istemci = boto3.client(
                "s3", endpoint_url=a.s3_endpoint_url or None, region_name=a.s3_bolge or None,
                aws_access_key_id=a.s3_erisim_anahtari or None, aws_secret_access_key=a.s3_gizli_anahtar or None)
        return self._istemci

    def kaydet(self, anahtar: str, icerik: bytes, uzanti: str) -> str:
        try:
            self.istemci.put_object(Bucket=self.bucket, Key=anahtar, Body=icerik,
                                    ContentType=ICERIK_TURLERI.get(uzanti, "application/octet-stream"),
                                    # içerik özetli anahtar asla değişmez → uzun süre önbelleğe alınabilir
                                    CacheControl="public, max-age=31536000, immutable")
        except Exception as e:
            log.error("Dosya depolamaya yazılamadı", exc_info=e)
            raise HTTPException(status_code=503, detail="Dosya şu anda kaydedilemiyor. Lütfen birazdan tekrar deneyin.") from e
        return f"{self.genel_url}/{anahtar}"

    def sil(self, url: str | None) -> None:
        if not url or not url.startswith(self.genel_url + "/"):
            return
        try:
            self.istemci.delete_object(Bucket=self.bucket, Key=url[len(self.genel_url) + 1:])
        except Exception as e:  # eski dosya kalırsa yalnızca yer kaplar; yüklemeyi bozmasın
            log.warning("Eski dosya silinemedi", exc_info=e)


@lru_cache
def depolama() -> YerelDepolama | S3Depolama:
    a = ayarlar()
    if a.depolama == "s3":
        if not (a.s3_bucket and a.s3_genel_url):
            raise HTTPException(status_code=503, detail="Dosya depolama yapılandırılmamış.")
        return S3Depolama(a.s3_bucket, a.s3_genel_url)
    return YerelDepolama(a.uploads_dir)
