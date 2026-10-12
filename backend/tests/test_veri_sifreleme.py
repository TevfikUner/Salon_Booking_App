"""Kişisel verinin veritabanında şifrelenmesi: şifreli saklama, şeffaf okuma, telefon özeti, toplu şifreleme,
anahtar değişimi ve yanlış anahtar koruması."""
import pytest
from sqlalchemy import text

import models
import veri_sifreleme as vs
from conftest import YARIN, auth, randevu_al
from config import ayarlar


@pytest.fixture
def anahtar(monkeypatch):
    """Anahtarı değiştirip önbelleği temizleyen yardımcı. Testler şifreleme kapalı başlar (suit VERI_ANAHTARI ile
    çalıştırılsa da), bu yüzden test imzasında `veri`den ÖNCE istenmeli; sonunda ortamın ayarına döner."""
    def ayarla(yeni: str = "", eski: str = ""):
        monkeypatch.setattr(ayarlar(), "veri_anahtari", yeni)
        monkeypatch.setattr(ayarlar(), "veri_anahtari_eski", eski)
        vs.anahtarlari_yenile()
    ayarla()
    yield ayarla
    monkeypatch.undo()
    vs.anahtarlari_yenile()


def _ham(db, sql: str):
    return db.execute(text(sql)).scalar()


def test_anahtar_varken_veritabaninda_sifreli_api_de_duz(anahtar, client, veri, db):
    anahtar("test-anahtari-1")
    r = client.put("/musteriler/profil", headers=auth("musteri-1"),
                   json={"ad": "Ayşe", "soyad": "Kaya", "telefon": "05551234567"})
    assert r.status_code == 200, r.text
    ham = _ham(db, "SELECT telefon FROM musteriler WHERE firebase_uid = 'musteri-1'")
    assert ham.startswith("enc1:") and "0555" not in ham
    assert _ham(db, "SELECT ad FROM musteriler WHERE firebase_uid = 'musteri-1'").startswith("enc1:")
    p = client.get("/musteriler/profil", headers=auth("musteri-1")).json()
    assert (p["ad"], p["telefon"]) == ("Ayşe", "05551234567")


def test_panel_telefon_eslesmesi_sifreliyken_ve_bicimden_bagimsiz(anahtar, client, veri, db):
    anahtar("test-anahtari-1")
    isl = auth("isletme-a")

    def ekle(saat, tel):
        r = client.post("/panel/randevular", headers=isl, json={
            "berber_id": veri["ali"], "tarih": YARIN, "saat": saat, "hizmet_ids": [veri["kesim"]],
            "musteri_ad": "Kapı Müşterisi", "musteri_telefon": tel, "notlar": "Ense düz"})
        assert r.status_code == 200, r.text
        return r.json()["randevu"]["musteri"]["id"]

    assert ekle("10:00", "05301234567") == ekle("11:00", "5301234567")
    assert _ham(db, "SELECT notlar FROM randevular LIMIT 1").startswith("enc1:")
    akis = client.get("/panel/akis", params={"tarih": YARIN}, headers=isl).json()
    assert akis["randevular"][0]["notlar"] == "Ense düz"
    assert akis["randevular"][0]["musteri"]["telefon"] == "05301234567"


def test_toplu_sifreleme_mevcut_duz_veriyi_sifreler(anahtar, client, veri, db):
    randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["kesim"]])
    db.add(models.MusteriNotu(salon_id=veri["a"], musteri_id=1, metin="Üstü makas", guncelleme="2026-10-07T10:00"))
    db.commit()
    assert _ham(db, "SELECT telefon FROM musteriler WHERE id = 1") == "05321112233"  # anahtarsız: düz
    ozet_once = _ham(db, "SELECT telefon_ozet FROM musteriler WHERE id = 1")
    assert ozet_once  # özet anahtarsız da tutulur

    anahtar("test-anahtari-1")
    sayac = vs.tum_veriyi_yeniden_yaz(db)
    assert sayac["musteriler"] >= 4 and sayac["musteri_notlari"] == 1
    assert _ham(db, "SELECT telefon FROM musteriler WHERE id = 1").startswith("enc1:")
    assert _ham(db, "SELECT metin FROM musteri_notlari").startswith("enc1:")
    assert _ham(db, "SELECT telefon_ozet FROM musteriler WHERE id = 1") != ozet_once  # anahtarla yeniden hesaplandı
    db.expire_all()
    assert db.get(models.Musteri, 1).telefon == "05321112233"
    # Şifreliyken tekrar çalıştırmak güvenli
    vs.tum_veriyi_yeniden_yaz(db)
    db.expire_all()
    assert db.get(models.Musteri, 1).ad == "Ahmet"


def test_anahtar_degisimi_eski_anahtarla_okur_yenisiyle_yazar(anahtar, client, veri, db):
    anahtar("eski-anahtar")
    vs.tum_veriyi_yeniden_yaz(db)
    anahtar("yeni-anahtar", eski="eski-anahtar")
    db.expire_all()
    assert db.get(models.Musteri, 1).ad == "Ahmet"  # eski anahtarla çözülür
    vs.tum_veriyi_yeniden_yaz(db)
    anahtar("yeni-anahtar")  # eski anahtar artık verilmese de okunur
    db.expire_all()
    assert db.get(models.Musteri, 1).ad == "Ahmet"


def test_yanlis_anahtar_veriyi_ezmez(anahtar, client, veri, db):
    anahtar("dogru-anahtar")
    vs.tum_veriyi_yeniden_yaz(db)
    anahtar("yanlis-anahtar")
    db.expire_all()
    assert db.get(models.Musteri, 1).ad == vs.COZULEMEDI
    with pytest.raises(RuntimeError, match="çözülemedi"):
        vs.tum_veriyi_yeniden_yaz(db)
    anahtar("dogru-anahtar")
    db.expire_all()
    assert db.get(models.Musteri, 1).ad == "Ahmet"


def test_veri_coz_sifrelemeyi_geri_alir(anahtar, client, veri, db):
    anahtar("dogru-anahtar")
    vs.tum_veriyi_yeniden_yaz(db)
    vs.tum_veriyi_yeniden_yaz(db, duz=True)
    assert _ham(db, "SELECT ad FROM musteriler WHERE id = 1") == "Ahmet"
    anahtar("")
    with pytest.raises(RuntimeError, match="VERI_ANAHTARI"):
        vs.tum_veriyi_yeniden_yaz(db)


def test_yardimcilar():
    assert vs.telefon_ozeti("0532 111 22 33") == vs.telefon_ozeti("+90 532 111 2233")
    assert vs.telefon_ozeti("123") is None and vs.telefon_ozeti(None) is None
    assert vs.sifrele("") == "" and vs.coz(None) is None
    assert {m.__tablename__ for m in vs.sifreli_sutunlar()} >= {"musteriler", "isletmeler", "randevular",
                                                                "degerlendirmeler", "musteri_notlari"}
