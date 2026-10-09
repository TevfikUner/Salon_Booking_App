"""Kimlik doğrulama ve rol yetkilendirmesi.

İstemci her istekte `Authorization: Bearer <Firebase ID token>` gönderir.
- AUTH_MODE=firebase → token Firebase Admin SDK ile doğrulanır (production).
- AUTH_MODE=dev      → imza doğrulanmadan çözülür; ayrıca "dev:<uid>" biçimi kabul edilir (yerel geliştirme/test).

Roller: admin > isletme > personel > musteri
- admin    : UID, ADMIN_UIDS listesinde
- isletme  : `isletmeler` tablosunda kaydı var (panel için durum=onaylandi ve salona bağlı olmalı)
- personel : `berberler.firebase_uid` ile eşleşen berber
- musteri  : diğer herkes (ilk randevu/profil işleminde müşteri kaydı oluşur)
"""
import base64
import hmac
import json
from dataclasses import dataclass

from fastapi import Depends, Header, HTTPException
from sqlalchemy.orm import Session

import models
from config import ayarlar
from database import get_db
from zaman import simdi


@dataclass
class Kimlik:
    uid: str
    email: str | None = None
    email_dogrulandi: bool = False


@dataclass
class Kullanici:
    kimlik: Kimlik
    rol: str
    musteri: models.Musteri | None = None
    isletme: models.Isletme | None = None
    berber: models.Berber | None = None

    @property
    def salon_id(self) -> int | None:
        if self.isletme and self.isletme.durum == "onaylandi":
            return self.isletme.salon_id
        if self.berber:
            return self.berber.salon_id
        return None


def _jwt_coz_imzasiz(token: str) -> dict:
    try:
        govde = token.split(".")[1]
        govde += "=" * (-len(govde) % 4)
        return json.loads(base64.urlsafe_b64decode(govde))
    except Exception as e:
        raise HTTPException(status_code=401, detail="Geçersiz oturum anahtarı.") from e


def token_coz(token: str) -> Kimlik:
    a = ayarlar()
    if a.auth_mode == "dev":
        if token.startswith("dev:"):
            return Kimlik(uid=token[4:])
        veri = _jwt_coz_imzasiz(token)
        uid = veri.get("user_id") or veri.get("sub")
        if not uid:
            raise HTTPException(status_code=401, detail="Geçersiz oturum anahtarı.")
        return Kimlik(uid=uid, email=veri.get("email"), email_dogrulandi=bool(veri.get("email_verified")))

    from firebase_admin import auth as fb_auth

    from firebase_app import firebase_hazir

    if not firebase_hazir():
        raise HTTPException(status_code=503, detail="Kimlik doğrulama servisi yapılandırılmamış.")
    try:
        veri = fb_auth.verify_id_token(token, check_revoked=False)
    except Exception as e:
        raise HTTPException(status_code=401, detail="Oturum süresi doldu veya geçersiz. Lütfen tekrar giriş yapın.") from e
    return Kimlik(uid=veri["uid"], email=veri.get("email"), email_dogrulandi=bool(veri.get("email_verified")))


def kimlik_gerekli(authorization: str | None = Header(default=None)) -> Kimlik:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="Giriş yapmanız gerekiyor.")
    return token_coz(authorization.split(" ", 1)[1].strip())


def kimlik_istege_bagli(authorization: str | None = Header(default=None)) -> Kimlik | None:
    if not authorization:
        return None
    return kimlik_gerekli(authorization)


def kullanici_cozumle(db: Session, kimlik: Kimlik) -> Kullanici:
    musteri = db.query(models.Musteri).filter(models.Musteri.firebase_uid == kimlik.uid).first()
    isletme = db.query(models.Isletme).filter(models.Isletme.firebase_uid == kimlik.uid).first()
    berber = db.query(models.Berber).filter(models.Berber.firebase_uid == kimlik.uid, models.Berber.aktif.is_(True)).first()
    if kimlik.uid in ayarlar().admin_uid_listesi:
        rol = "admin"
    elif isletme:
        rol = "isletme"
    elif berber:
        rol = "personel"
    else:
        rol = "musteri"
    return Kullanici(kimlik=kimlik, rol=rol, musteri=musteri, isletme=isletme, berber=berber)


def aktif_kullanici(kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)) -> Kullanici:
    return kullanici_cozumle(db, kimlik)


def musteri_getir_veya_olustur(db: Session, kimlik: Kimlik, ad: str = "", soyad: str = "", telefon: str = "") -> models.Musteri:
    m = db.query(models.Musteri).filter(models.Musteri.firebase_uid == kimlik.uid).first()
    if m:
        return m
    m = models.Musteri(firebase_uid=kimlik.uid, ad=ad or "Misafir", soyad=soyad, telefon=telefon,
                       olusturma=simdi().isoformat(timespec="seconds"))
    db.add(m)
    db.flush()
    return m


def musteri_gerekli(kimlik: Kimlik = Depends(kimlik_gerekli), db: Session = Depends(get_db)) -> models.Musteri:
    m = db.query(models.Musteri).filter(models.Musteri.firebase_uid == kimlik.uid).first()
    if not m:
        raise HTTPException(status_code=404, detail="Müşteri kaydı bulunamadı.")
    return m


# ── Admin ────────────────────────────────────────────────────

def _admin_secret_gecerli(x_admin_secret: str | None) -> bool:
    gizli = ayarlar().admin_secret
    return bool(gizli) and bool(x_admin_secret) and hmac.compare_digest(gizli, x_admin_secret)


def admin_dogrula(
    authorization: str | None = Header(default=None),
    x_admin_secret: str | None = Header(default=None),
) -> None:
    """Admin: ADMIN_UIDS'deki Firebase kullanıcısı veya (yapılandırılmışsa) X-Admin-Secret."""
    if _admin_secret_gecerli(x_admin_secret):
        return
    if authorization and authorization.lower().startswith("bearer "):
        kimlik = token_coz(authorization.split(" ", 1)[1].strip())
        if kimlik.uid in ayarlar().admin_uid_listesi:
            return
    raise HTTPException(status_code=403, detail="Bu işlem için yönetici yetkisi gerekiyor.")


# ── İşletme paneli ───────────────────────────────────────────

@dataclass
class PanelBaglami:
    salon_id: int
    rol: str
    berber_id: int | None = None  # personel ise yalnızca kendi randevuları

    @property
    def yonetici(self) -> bool:
        return self.rol in ("isletme", "admin")


def panel_yetkisi(salon_id: int | None, k: Kullanici) -> PanelBaglami:
    if k.rol == "admin":
        if salon_id is None:
            raise HTTPException(status_code=400, detail="Admin için salon_id parametresi gerekli.")
        return PanelBaglami(salon_id=salon_id, rol="admin")
    if k.rol == "isletme":
        if k.isletme.durum != "onaylandi":
            raise HTTPException(status_code=403, detail="İşletme başvurunuz henüz onaylanmadı.")
        if not k.isletme.salon_id:
            raise HTTPException(status_code=403, detail="İşletmenize henüz bir salon bağlanmadı.")
        if salon_id is not None and salon_id != k.isletme.salon_id:
            raise HTTPException(status_code=403, detail="Bu salona erişim yetkiniz yok.")
        return PanelBaglami(salon_id=k.isletme.salon_id, rol="isletme")
    if k.rol == "personel":
        if salon_id is not None and salon_id != k.berber.salon_id:
            raise HTTPException(status_code=403, detail="Bu salona erişim yetkiniz yok.")
        return PanelBaglami(salon_id=k.berber.salon_id, rol="personel", berber_id=k.berber.id)
    raise HTTPException(status_code=403, detail="Bu ekran yalnızca işletmeler içindir.")


def panel_baglami(salon_id: int | None = None, k: Kullanici = Depends(aktif_kullanici)) -> PanelBaglami:
    return panel_yetkisi(salon_id, k)


def panel_yonetici(p: PanelBaglami = Depends(panel_baglami)) -> PanelBaglami:
    if not p.yonetici:
        raise HTTPException(status_code=403, detail="Bu işlem için işletme sahibi yetkisi gerekiyor.")
    return p
