"""Kapı 2: sağlık kontrolü, hata yanıtları, hız/boyut sınırı, idempotency, DB son savunma hattı, görev kilidi,
yasal sayfalar, fotoğraf içerik denetimi."""
import threading
import time

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.exc import IntegrityError, OperationalError

import gorev_kilidi as gk
import models
from conftest import YARIN, auth, randevu_al
from database import SessionLocal
from koruma import limiter
from main import app


# ── Sağlık ve hata yanıtları ─────────────────────────────────

def test_health_db_ile(client):
    v = client.get("/health").json()
    assert v["durum"] == "ok" and v["veritabani"] == "ok"
    assert client.get("/saglik").status_code == 200


def test_health_db_yokken_503(client, monkeypatch):
    import main

    class Bozuk:
        def execute(self, *_):
            raise OperationalError("SELECT 1", {}, Exception("bağlantı reddedildi"))

        def close(self):
            pass

    monkeypatch.setattr(main, "SessionLocal", lambda: Bozuk())
    r = client.get("/health")
    assert r.status_code == 503 and r.json()["veritabani"] == "erişilemiyor"


def test_db_kesintisinde_turkce_503(client, veri, monkeypatch):
    import slot_servisi as ss

    def kopuk(*_a, **_k):
        raise OperationalError("SELECT", {}, Exception("server closed the connection unexpectedly"))

    monkeypatch.setattr(ss, "gun_musaitligi", kopuk)
    r = client.get(f"/randevular/musait-saatler/{veri['ali']}", params=[("tarih", YARIN), ("hizmet_ids", veri["kesim"])])
    assert r.status_code == 503
    assert "geçici olarak kullanılamıyor" in r.json()["detail"]
    assert r.headers["retry-after"] == "5"


def test_beklenmeyen_hata_ham_istisna_sizdirmaz(veri, monkeypatch):
    import slot_servisi as ss
    monkeypatch.setattr(ss, "gun_musaitligi", lambda *a, **k: 1 / 0)
    c = TestClient(app, raise_server_exceptions=False)
    r = c.get(f"/randevular/musait-saatler/{veri['ali']}", params=[("tarih", YARIN), ("hizmet_ids", veri["kesim"])])
    assert r.status_code == 500
    assert "Beklenmeyen bir hata" in r.json()["detail"]
    assert "ZeroDivision" not in r.text and "Traceback" not in r.text
    assert r.headers.get("x-request-id")


def test_dogrulama_hatasi_turkce(client):
    r = client.get("/randevular/musait-saatler/abc", params={"tarih": YARIN})
    assert r.status_code == 422 and r.json()["detail"] == "Girilen bilgileri kontrol edin."


# ── Hız ve boyut sınırı ──────────────────────────────────────

@pytest.fixture
def hiz_siniri():
    limiter.enabled = True
    limiter.reset()
    yield
    limiter.enabled = False
    limiter.reset()


def test_hiz_siniri_ben_ucu(client, veri, hiz_siniri):
    kodlar = [client.get("/ben", headers=auth("musteri-1")).status_code for _ in range(32)]
    assert kodlar[:30] == [200] * 30
    assert kodlar[30] == 429
    r = client.get("/ben", headers=auth("musteri-1"))
    assert "Çok fazla istek" in r.json()["detail"]
    # başka kullanıcı etkilenmez (kullanıcı başına sınır)
    assert client.get("/ben", headers=auth("musteri-2")).status_code == 200


def test_hiz_siniri_randevu_olusturma(client, veri, hiz_siniri):
    kodlar = [randevu_al(client, "musteri-1", veri["ali"], YARIN, f"{9 + i}:00".zfill(5), [veri["kesim"]]).status_code
              for i in range(11)]
    assert kodlar.count(429) == 1 and kodlar[-1] == 429


def test_istek_boyutu_siniri(client):
    r = client.post("/musteriler/kayit", content=b"x" * 1_100_000,
                    headers={**auth("musteri-1"), "content-type": "application/json"})
    assert r.status_code == 413


# ── Idempotency ve çift randevu ──────────────────────────────

def test_ayni_idempotency_anahtari_tek_randevu(client, veri, db):
    params = [("berber_id", veri["ali"]), ("tarih", YARIN), ("saat", "10:00"), ("hizmet_ids", veri["kesim"])]
    h = {**auth("musteri-1"), "Idempotency-Key": "onay-123"}
    r1 = client.post("/randevular/olustur", params=params, headers=h)
    r2 = client.post("/randevular/olustur", params=params, headers=h)
    assert r1.status_code == r2.status_code == 200
    assert r1.json()["randevu_id"] == r2.json()["randevu_id"]
    assert db.query(models.Randevu).filter_by(berber_id=veri["ali"], tarih=YARIN).count() == 1
    # farklı anahtar = yeni istek → slot dolu
    h2 = {**auth("musteri-1"), "Idempotency-Key": "onay-456"}
    assert client.post("/randevular/olustur", params=params, headers=h2).status_code == 409


def test_basarisiz_istek_anahtari_serbest_birakir(client, veri):
    h = {**auth("musteri-1"), "Idempotency-Key": "tekrar-dene"}
    kotu = [("berber_id", veri["ali"]), ("tarih", YARIN), ("saat", "08:00"), ("hizmet_ids", veri["kesim"])]
    assert client.post("/randevular/olustur", params=kotu, headers=h).status_code == 409
    iyi = [("berber_id", veri["ali"]), ("tarih", YARIN), ("saat", "10:00"), ("hizmet_ids", veri["kesim"])]
    assert client.post("/randevular/olustur", params=iyi, headers=h).status_code == 200


def test_eszamanli_ayni_anahtar_tek_kayit(veri):
    """Çift tıklama: aynı anahtarla eşzamanlı 6 istek → tek randevu."""
    params = [("berber_id", veri["ali"]), ("tarih", YARIN), ("saat", "11:00"), ("hizmet_ids", veri["kesim"])]
    sonuc = []

    def gonder():
        c = TestClient(app)
        sonuc.append(c.post("/randevular/olustur", params=params,
                            headers={**auth("musteri-1"), "Idempotency-Key": "cift-tik"}).status_code)

    t = [threading.Thread(target=gonder) for _ in range(6)]
    [x.start() for x in t]
    [x.join() for x in t]
    with SessionLocal() as db:
        assert db.query(models.Randevu).filter_by(berber_id=veri["ali"], tarih=YARIN, saat="11:00").count() == 1
    assert set(sonuc) <= {200, 409} and 200 in sonuc


def test_db_ayni_slota_iki_aktif_randevuyu_reddeder(db, veri):
    """Kilit atlansa bile (ör. elle INSERT) kısmi tekil indeks çift kaydı engeller; iptal edilen serbest bırakır."""
    m = db.query(models.Musteri).first()
    ortak = dict(musteri_id=m.id, berber_id=veri["ali"], salon_id=veri["a"], tarih=YARIN, saat="15:00", sure_dk=30,
                 toplam_fiyat=300)
    db.add(models.Randevu(durum="iptal", **ortak))
    db.add(models.Randevu(durum="onaylandi", **ortak))
    db.commit()
    db.add(models.Randevu(durum="onaylandi", **ortak))
    with pytest.raises(IntegrityError):
        db.commit()
    db.rollback()


# ── Görev kilidi ─────────────────────────────────────────────

def test_gorev_kilidi_tek_sahip_ve_sure_dolunca_duser(veri):
    assert gk.kilit_al("deneme", 60, sahip="A") is True
    assert gk.kilit_al("deneme", 60, sahip="B") is False
    gk.kilit_birak("deneme", sahip="A")
    assert gk.kilit_al("deneme", 1, sahip="B") is True
    time.sleep(1.1)  # süre doldu → çökmüş sürecin kilidi devralınabilir
    assert gk.kilit_al("deneme", 60, sahip="C") is True


def test_gorev_eszamanli_iki_surecte_tek_kez_calisir(veri):
    sayac = []

    def gorev():
        sayac.append(1)
        time.sleep(0.3)

    t = [threading.Thread(target=gk.kilitli_calistir, args=("hatirlatma_test", gorev, 60, f"surec-{i}"))
         for i in range(5)]
    [x.start() for x in t]
    [x.join() for x in t]
    assert len(sayac) == 1


def test_zamanlayici_gorevleri_kilitli_tanimli():
    from apscheduler.schedulers.background import BackgroundScheduler

    from zamanlayici import gorevleri_ekle
    z = BackgroundScheduler()
    gorevleri_ekle(z)
    isler = {j.id: j for j in z.get_jobs()}
    assert set(isler) == {"hatirlatma", "tamamlama", "idempotency_temizlik"}
    assert all(j.func is gk.kilitli_calistir for j in isler.values())


# ── Yasal sayfalar ve web silme talebi ───────────────────────

def test_yasal_sayfalar_herkese_acik(client):
    for ad, baslik in (("gizlilik", "Gizlilik Politikası"), ("kvkk", "KVKK"), ("kullanim", "Kullanım Koşulları")):
        r = client.get(f"/yasal/{ad}")
        assert r.status_code == 200 and baslik in r.text and "text/html" in r.headers["content-type"]
        assert "{DESTEK_EPOSTA}" not in r.text and "{HESAP_SILME_URL}" not in r.text
    assert "Hesabımı Sil" in client.get("/yasal/hesap-silme").text


def test_web_hesap_silme_talebi(client, db):
    r = client.post("/yasal/hesap-silme", data={"email": " Ali@Ornek.com ", "aciklama": "Uygulamaya giremiyorum"})
    assert r.status_code == 200 and "Talebiniz alındı" in r.text
    t = db.query(models.HesapSilmeTalebi).one()
    assert t.email == "ali@ornek.com" and t.durum == "bekliyor"
    assert "Geçersiz" in client.post("/yasal/hesap-silme", data={"email": "gecersiz"}).text


def test_hesap_silme_yorum_kopyasini_da_temizler(client, veri, db):
    rid = randevu_al(client, "musteri-2", veri["ali"], YARIN, "10:00", [veri["kesim"]]).json()["randevu_id"]
    db.get(models.Randevu, rid).durum = "tamamlandi"
    db.commit()
    client.post("/degerlendirmeler/ekle", params={"randevu_id": rid, "puan": 5, "yorum": "Kişisel yorum"},
                headers=auth("musteri-2"))
    client.delete("/musteriler/hesabim", headers=auth("musteri-2"))
    db.expire_all()
    assert db.get(models.Randevu, rid).yorum is None


# ── Yönetici tablosu ─────────────────────────────────────────

def test_db_yoneticisi_admin_rolunde(client, db):
    assert client.get("/ben", headers=auth("yeni-admin")).json()["rol"] == "musteri"
    db.add(models.Yonetici(firebase_uid="yeni-admin"))
    db.commit()
    assert client.get("/ben", headers=auth("yeni-admin")).json()["rol"] == "admin"
    assert client.get("/isletmeler/", headers=auth("yeni-admin")).status_code == 200


# ── Fotoğraf içerik denetimi ─────────────────────────────────

def test_foto_yukleme_icerik_turunu_denetler(client, veri):
    h = auth("admin-uid")
    sahte = client.post(f"/berberler/foto-yukle/{veri['ali']}", headers=h,
                        files={"foto": ("resim.jpg", b"<?php echo 1; ?>", "image/jpeg")})
    assert sahte.status_code == 400
    png = bytes.fromhex("89504e470d0a1a0a") + b"\x00" * 64
    r = client.post(f"/berberler/foto-yukle/{veri['ali']}", headers=h, files={"foto": ("a.bin", png, "text/plain")})
    assert r.status_code == 200 and r.json()["foto_url"].endswith(".png")


def test_production_dokumanlari_kapali():
    from config import Ayarlar
    assert Ayarlar(ortam="production", auth_mode="firebase").dokumanlar_acik is False
    assert Ayarlar(ortam="development").dokumanlar_acik is True
    assert Ayarlar(ortam="production", docs_enabled=True).dokumanlar_acik is True
