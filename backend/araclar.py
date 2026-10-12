"""Yönetim komutları.

    python araclar.py uid <e-posta>              Firebase kullanıcısının UID'sini yazar
    python araclar.py admin-ekle <e-posta>       İlk/yeni admin: Firebase hesabını yoneticiler tablosuna ekler
    python araclar.py admin-ekle --uid <uid>     (Firebase anahtarı yoksa UID ile)
    python araclar.py admin-listele
    python araclar.py silme-talepleri             Web formundan gelen bekleyen hesap silme talepleri
    python araclar.py silme-uygula <talep_id>     Talebi uygular: verileri anonimleştirir, Firebase hesabını siler
    python araclar.py basvurular                  Bekleyen işletme başvurularını listeler
    python araclar.py onayla <isletme_id> [--salon <id>] [--sehir Konya --ilce Selçuklu]
    python araclar.py reddet <isletme_id>
    python araclar.py gizli                       ADMIN_SECRET için güçlü rastgele değer üretir
    python araclar.py saglik                      DB ve Firebase yapılandırmasını kontrol eder
    python araclar.py anahtar-uret                VERI_ANAHTARI için güçlü rastgele değer üretir (YEDEKLEYİN)
    python araclar.py veri-sifrele                Kişisel veriyi güncel VERI_ANAHTARI ile (yeniden) şifreler
    python araclar.py veri-coz                    Şifrelemeyi kapatmadan önce: veriyi çözüp düz yazar

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


def _firebase_kullanici(eposta: str):
    from firebase_admin import auth

    from firebase_app import firebase_hazir

    if not firebase_hazir():
        raise SystemExit("Firebase servis hesabı yapılandırılmamış (FIREBASE_CREDENTIALS_JSON / serviceAccountKey.json).")
    try:
        return auth.get_user_by_email(eposta)
    except auth.UserNotFoundError:
        raise SystemExit(f"{eposta} ile kayıtlı Firebase kullanıcısı yok. Önce uygulamadan hesap açın.") from None


def admin_ekle(eposta: str | None, uid_: str | None) -> int:
    """Admin yetkisi DB'de tutulur: yeniden deploy veya env değişikliği gerektirmez.
    E-postayla eklemek, kimin admin olduğunu Firebase'den doğrular (UID yazım hatasına karşı)."""
    import models
    from database import SessionLocal
    from zaman import simdi

    if eposta:
        k = _firebase_kullanici(eposta)
        uid_, eposta = k.uid, k.email
    with SessionLocal() as db:
        if db.get(models.Yonetici, uid_):
            print(f"Zaten admin: {uid_}")
            return 0
        db.add(models.Yonetici(firebase_uid=uid_, email=eposta, olusturma=simdi().isoformat(timespec="seconds")))
        db.commit()
    print(f"Admin eklendi: {eposta or ''} ({uid_})")
    return 0


def admin_listele() -> int:
    import models
    from config import ayarlar
    from database import SessionLocal

    with SessionLocal() as db:
        for y in db.query(models.Yonetici).all():
            print(f"DB   {y.firebase_uid}  {y.email or ''}  ({y.olusturma})")
    for u in ayarlar().admin_uid_listesi:
        print(f"ENV  {u}")
    return 0


def silme_talepleri() -> int:
    import models
    from database import SessionLocal

    with SessionLocal() as db:
        liste = db.query(models.HesapSilmeTalebi).filter_by(durum="bekliyor").order_by(models.HesapSilmeTalebi.id).all()
        if not liste:
            print("Bekleyen silme talebi yok.")
        for t in liste:
            print(f"#{t.id:<4} {t.email:<35} {t.olusturma}  {t.aciklama or ''}")
    return 0


def silme_uygula(talep_id: int) -> int:
    import models
    from database import SessionLocal
    from hesap_servisi import hesabi_anonimlestir, silme_talebini_tamamla

    with SessionLocal() as db:
        talep = db.get(models.HesapSilmeTalebi, talep_id)
        if not talep or talep.durum != "bekliyor":
            print("Bekleyen böyle bir talep yok.")
            return 1
        k = _firebase_kullanici(talep.email)
        bulundu = hesabi_anonimlestir(db, k.uid)
        from firebase_admin import auth
        auth.delete_user(k.uid)
        silme_talebini_tamamla(db, talep)
    print(f"Tamamlandı: {talep.email} (sunucu verisi: {'anonimleştirildi' if bulundu else 'yoktu'}, Firebase hesabı silindi)."
          f" Kullanıcıya e-postayla bilgi verin.")
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
    with SessionLocal() as db:
        import models
        db_admin = db.query(models.Yonetici).count()
    print(f"Admin         : {len(a.admin_uid_listesi)} (env) + {db_admin} (DB)")
    print(f"ADMIN_SECRET  : {'tanımlı' if a.admin_secret else 'kapalı'}")
    from veri_sifreleme import sifreleme_acik
    print(f"Veri şifreleme: {'açık' if sifreleme_acik() else 'kapalı (VERI_ANAHTARI yok)'}")
    if a.uretim_mi and not firebase_hazir():
        print("\nUYARI: Production'da Firebase olmadan kimse giriş yapamaz.")
        return 1
    return 0


def veri_sifrele(duz: bool) -> int:
    from database import SessionLocal
    from veri_sifreleme import tum_veriyi_yeniden_yaz

    try:
        with SessionLocal() as db:
            sayac = tum_veriyi_yeniden_yaz(db, duz=duz)
    except RuntimeError as e:
        print(f"HATA: {e}")
        return 1
    for tablo, n in sayac.items():
        print(f"{tablo:<24} {n} değer {'düz yazıldı' if duz else 'şifrelendi'}")
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
    ae = alt.add_parser("admin-ekle")
    ae.add_argument("eposta", nargs="?")
    ae.add_argument("--uid")
    alt.add_parser("admin-listele")
    alt.add_parser("silme-talepleri")
    alt.add_parser("silme-uygula").add_argument("talep_id", type=int)
    alt.add_parser("gizli")
    alt.add_parser("saglik")
    alt.add_parser("anahtar-uret")
    alt.add_parser("veri-sifrele")
    alt.add_parser("veri-coz")
    a = p.parse_args()
    if a.komut == "uid":
        return uid(a.eposta)
    if a.komut == "admin-ekle":
        if not (a.eposta or a.uid):
            p.error("admin-ekle için e-posta veya --uid gerekli")
        return admin_ekle(a.eposta, a.uid)
    if a.komut == "admin-listele":
        return admin_listele()
    if a.komut == "silme-talepleri":
        return silme_talepleri()
    if a.komut == "silme-uygula":
        return silme_uygula(a.talep_id)
    if a.komut == "basvurular":
        return basvurular()
    if a.komut == "onayla":
        return onayla(a.isletme_id, a.salon, a.sehir, a.ilce)
    if a.komut == "reddet":
        return reddet(a.isletme_id)
    if a.komut in ("gizli", "anahtar-uret"):
        print(secrets.token_urlsafe(32))
        return 0
    if a.komut in ("veri-sifrele", "veri-coz"):
        return veri_sifrele(duz=a.komut == "veri-coz")
    return saglik()


if __name__ == "__main__":
    sys.exit(main())
