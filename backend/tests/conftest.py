"""Test ortamı: geçici SQLite dosyası, AUTH_MODE=dev, zamanlayıcı kapalı, sabit zaman.

Sabit an: 7 Ekim 2026 Çarşamba 12:10 (İstanbul).
"""
import os
import sys
import tempfile
from datetime import datetime

# Varsayılan: geçici SQLite. PostgreSQL ile çalıştırmak için:
#   TEST_DATABASE_URL=postgresql://berber:berber_yerel@127.0.0.1:55432/berber_test pytest
_DB = os.environ.get("TEST_DATABASE_URL") or "sqlite:///" + os.path.join(tempfile.mkdtemp(prefix="berber_test_"), "test.db")
os.environ.update({
    "ORTAM": "test",
    "DATABASE_URL": _DB,
    "AUTH_MODE": "dev",
    "SCHEDULER_ENABLED": "false",
    "ADMIN_UIDS": "admin-uid",
    "ADMIN_SECRET": "",
    "REZERVASYON_UFKU_GUN": "30",
    "RATE_LIMIT_ENABLED": "false",  # hız sınırı ayrı testte açılarak denenir
    "LOG_FORMAT": "metin",
})
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402

import bildirim  # noqa: E402
import models  # noqa: E402
import zaman  # noqa: E402
from database import Base, SessionLocal, engine  # noqa: E402
from main import app  # noqa: E402

SABIT_AN = datetime(2026, 10, 7, 12, 10)  # Çarşamba
YARIN = "2026-10-08"  # Perşembe
PAZAR = "2026-10-11"


def auth(uid: str) -> dict:
    return {"Authorization": f"Bearer dev:{uid}"}


@pytest.fixture(autouse=True)
def temiz_ortam():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    zaman.sabit_an = SABIT_AN
    bildirim.gonderilenler.clear()
    yield
    zaman.sabit_an = None


@pytest.fixture
def db():
    s = SessionLocal()
    yield s
    s.close()


@pytest.fixture
def client():
    return TestClient(app)


@pytest.fixture
def veri(db):
    """İki salon; salon A: 09:00-21:00, Pazar 10:00-17:00, 2 berber; salon B: Pazar kapalı."""
    a = models.Salon(ad="Salon A", acilis_saati="09:00", kapanis_saati="21:00",
                     pazar_acilis_saati="10:00", pazar_kapanis_saati="17:00")
    b = models.Salon(ad="Salon B", acilis_saati="10:00", kapanis_saati="20:00", kapali_gunler="6")
    db.add_all([a, b])
    db.flush()
    ali = models.Berber(ad="Ali", soyad="Usta", salon_id=a.id, email="ali@salon.test")
    veli = models.Berber(ad="Veli", soyad="Kalfa", salon_id=a.id)
    zeki = models.Berber(ad="Zeki", soyad="", salon_id=b.id)
    db.add_all([ali, veli, zeki])
    kesim = models.Hizmet(salon_id=a.id, ad="Kesim", fiyat=300, sure=30)
    sakal = models.Hizmet(salon_id=a.id, ad="Sakal & Kesim", fiyat=450, sure=45)
    damat = models.Hizmet(salon_id=a.id, ad="Damat", fiyat=1500, sure=120)
    b_kesim = models.Hizmet(salon_id=b.id, ad="B Kesim", fiyat=250, sure=30)
    db.add_all([kesim, sakal, damat, b_kesim])
    db.add(models.Isletme(firebase_uid="isletme-a", ad="İ", soyad="A", isletme_adi="Salon A",
                          durum="onaylandi", salon_id=a.id))
    db.add(models.Isletme(firebase_uid="isletme-b", ad="İ", soyad="B", isletme_adi="Salon B",
                          durum="onaylandi", salon_id=b.id))
    db.add(models.Isletme(firebase_uid="isletme-bekleyen", ad="İ", soyad="C", isletme_adi="C", durum="beklemede"))
    db.add(models.Musteri(firebase_uid="musteri-1", ad="Ahmet", soyad="Yıldız", telefon="05321112233",
                          fcm_token="tok-1"))
    db.add(models.Musteri(firebase_uid="musteri-2", ad="Mehmet", soyad="", telefon="05324445566",
                          fcm_token="tok-2"))
    db.commit()
    return {"a": a.id, "b": b.id, "ali": ali.id, "veli": veli.id, "zeki": zeki.id, "kesim": kesim.id,
            "sakal": sakal.id, "damat": damat.id, "b_kesim": b_kesim.id}


def randevu_al(client, uid, berber_id, tarih, saat, hizmet_ids):
    params = [("berber_id", berber_id), ("tarih", tarih), ("saat", saat)] + [("hizmet_ids", h) for h in hizmet_ids]
    return client.post("/randevular/olustur", params=params, headers=auth(uid))
