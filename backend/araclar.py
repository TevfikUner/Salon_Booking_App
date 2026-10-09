"""Yönetim komutları.

    python araclar.py uid <e-posta>              Firebase kullanıcısının UID'sini yazar (ADMIN_UIDS için)
    python araclar.py basvurular                  Bekleyen işletme başvurularını listeler
    python araclar.py onayla <isletme_id> [--salon <id>] [--sehir Konya --ilce Selçuklu]
    python araclar.py reddet <isletme_id>
    python araclar.py gizli                       ADMIN_SECRET için güçlü rastgele değer üretir
    python araclar.py saglik                      DB ve Firebase yapılandırmasını kontrol eder

Render'da: Dashboard → servis → Shell → `python araclar.py ...`
"""
import argparse
import secrets
import sys

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")


def uid(eposta: str) -> int:
    from firebase_admin import auth

    from firebase_app import firebase_hazir

    if not firebase_hazir():
        print("Firebase servis hesabı yapılandırılmamış (FIREBASE_CREDENTIALS_JSON / serviceAccountKey.json).")
        return 1
    try:
        k = auth.get_user_by_email(eposta)
    except auth.UserNotFoundError:
        print(f"{eposta} ile kayıtlı Firebase kullanıcısı yok.")
        return 1
    print(k.uid)
    print(f"\nAdmin yapmak için ortam değişkenine ekleyin:  ADMIN_UIDS={k.uid}", file=sys.stderr)
    return 0


def basvurular() -> int:
    import models
    from database import SessionLocal

    with SessionLocal() as db:
        liste = db.query(models.Isletme).filter(models.Isletme.durum == "beklemede").order_by(models.Isletme.id).all()
        if not liste:
            print("Bekleyen başvuru yok.")
        for i in liste:
            print(f"#{i.id:<4} {i.isletme_adi:<30} {i.ad} {i.soyad}  {i.telefon}  {i.email}  ({i.olusturma})")
    return 0


def onayla(isletme_id: int, salon_id: int | None, sehir: str | None, ilce: str | None) -> int:
    from routers.isletmeler import isletme_onayla

    from database import SessionLocal

    with SessionLocal() as db:
        print(isletme_onayla(isletme_id, salon_id=salon_id, sehir=sehir, ilce=ilce, db=db)["mesaj"])
    return 0


def reddet(isletme_id: int) -> int:
    from routers.isletmeler import isletme_reddet

    from database import SessionLocal

    with SessionLocal() as db:
        print(isletme_reddet(isletme_id, db=db)["mesaj"])
    return 0


def saglik() -> int:
    from sqlalchemy import text

    from config import ayarlar
    from database import SessionLocal
    from firebase_app import firebase_hazir

    a = ayarlar()
    with SessionLocal() as db:
        db.execute(text("SELECT 1"))
    print(f"DB            : OK ({a.database_url.split('@')[-1]})")
    print(f"AUTH_MODE     : {a.auth_mode}")
    print(f"Firebase      : {'OK' if firebase_hazir() else 'YAPILANDIRILMAMIŞ'}")
    print(f"ADMIN_UIDS    : {len(a.admin_uid_listesi)} kullanıcı")
    print(f"ADMIN_SECRET  : {'tanımlı' if a.admin_secret else 'kapalı'}")
    if a.uretim_mi and not firebase_hazir():
        print("\nUYARI: Production'da Firebase olmadan kimse giriş yapamaz.")
        return 1
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    alt = p.add_subparsers(dest="komut", required=True)
    alt.add_parser("uid").add_argument("eposta")
    alt.add_parser("basvurular")
    o = alt.add_parser("onayla")
    o.add_argument("isletme_id", type=int)
    o.add_argument("--salon", type=int)
    o.add_argument("--sehir")
    o.add_argument("--ilce")
    alt.add_parser("reddet").add_argument("isletme_id", type=int)
    alt.add_parser("gizli")
    alt.add_parser("saglik")
    a = p.parse_args()
    if a.komut == "uid":
        return uid(a.eposta)
    if a.komut == "basvurular":
        return basvurular()
    if a.komut == "onayla":
        return onayla(a.isletme_id, a.salon, a.sehir, a.ilce)
    if a.komut == "reddet":
        return reddet(a.isletme_id)
    if a.komut == "gizli":
        print(secrets.token_urlsafe(32))
        return 0
    return saglik()


if __name__ == "__main__":
    sys.exit(main())
