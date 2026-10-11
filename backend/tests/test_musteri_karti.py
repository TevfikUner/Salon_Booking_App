"""İşletmenin müşteri kartı (geçmiş, harcama, en sık berber/hizmet) ve kalıcı müşteri notu."""
import models
from conftest import YARIN, auth, randevu_al


def _gecmis(db, veri, uid="musteri-1", berber="ali", durum="tamamlandi", gun=1, hizmet="kesim", salon="a"):
    m = db.query(models.Musteri).filter_by(firebase_uid=uid).one()
    h = db.get(models.Hizmet, veri[hizmet])
    r = models.Randevu(musteri_id=m.id, berber_id=veri[berber], salon_id=veri[salon], tarih=f"2026-09-{gun:02d}",
                       saat="10:00", sure_dk=h.sure, durum=durum, toplam_fiyat=h.fiyat, hizmetler=[h])
    db.add(r)
    db.commit()
    return m.id


def test_musteri_karti_ozet_ve_gecmis(client, veri, db):
    mid = _gecmis(db, veri, gun=1)
    _gecmis(db, veri, gun=5, hizmet="sakal")
    _gecmis(db, veri, gun=9, berber="veli")
    _gecmis(db, veri, gun=12, durum="gelmedi")
    v = client.get(f"/panel/musteriler/{mid}", headers=auth("isletme-a")).json()
    assert v["musteri"]["ad"] == "Ahmet Yıldız" and v["musteri"]["uygulama_kullanicisi"] is True
    o = v["ozet"]
    assert (o["ziyaret"], o["son_ziyaret"], o["toplam_harcama"], o["gelmedi"]) == (3, "2026-09-09", 1050, 1)
    assert o["en_sik_berber"] == "Ali Usta" and o["en_sik_hizmetler"][0] == "Kesim"
    assert v["guven"]["gelmedi"] == 1 and v["not"] is None
    assert [r["tarih"] for r in v["son_randevular"]] == ["2026-09-12", "2026-09-09", "2026-09-05", "2026-09-01"]


def test_baska_salonun_musterisi_gorulemez(client, veri, db):
    mid = _gecmis(db, veri)
    assert client.get(f"/panel/musteriler/{mid}", headers=auth("isletme-b")).status_code == 404
    assert client.put(f"/panel/musteriler/{mid}/not", headers=auth("isletme-b"),
                      json={"metin": "x"}).status_code == 404
    assert client.get(f"/panel/musteriler/{mid}", headers=auth("musteri-2")).status_code == 403


def test_personel_yalnizca_kendi_musterisini_gorur(client, veri, db):
    db.get(models.Berber, veri["ali"]).firebase_uid = "ali-uid"
    db.commit()
    m1 = _gecmis(db, veri, berber="ali", gun=1)
    _gecmis(db, veri, berber="veli", gun=2)
    m2 = _gecmis(db, veri, uid="musteri-2", berber="veli", gun=3)
    v = client.get(f"/panel/musteriler/{m1}", headers=auth("ali-uid")).json()
    assert v["ozet"]["ziyaret"] == 1  # Veli'deki ziyaret personel Ali'ye gösterilmez
    assert client.get(f"/panel/musteriler/{m2}", headers=auth("ali-uid")).status_code == 404
    r = client.put(f"/panel/musteriler/{m1}/not", headers=auth("ali-uid"), json={"metin": "Yanlar 1 numara"})
    assert r.status_code == 200 and r.json()["not"]["guncelleyen"] == "Ali Usta"


def test_not_yaz_guncelle_sil_ve_akista_isaret(client, veri, db):
    rid = randevu_al(client, "musteri-1", veri["ali"], YARIN, "14:00", [veri["kesim"]]).json()["randevu_id"]
    mid = db.get(models.Randevu, rid).musteri_id
    akis = lambda: client.get("/panel/akis", params={"tarih": YARIN}, headers=auth("isletme-a")).json()  # noqa: E731
    assert akis()["randevular"][0]["not_var"] is False
    yol = f"/panel/musteriler/{mid}/not"
    assert client.put(yol, headers=auth("isletme-a"), json={"metin": "  Üstü makas  "}).json()["not"]["metin"] == "Üstü makas"
    client.put(yol, headers=auth("isletme-a"), json={"metin": "Üstü makas, ense düz"})
    assert db.query(models.MusteriNotu).count() == 1
    kart = client.get(f"/panel/musteriler/{mid}", headers=auth("isletme-a")).json()
    assert kart["not"]["metin"] == "Üstü makas, ense düz" and kart["not"]["guncelleyen"] == "İşletme"
    assert akis()["randevular"][0]["not_var"] is True
    assert client.put(yol, headers=auth("isletme-a"), json={"metin": "x" * 501}).status_code == 422
    assert client.put(yol, headers=auth("isletme-a"), json={"metin": "  "}).json()["not"] is None
    assert akis()["randevular"][0]["not_var"] is False


def test_hesap_silmede_musteri_notu_silinir(client, veri, db):
    mid = _gecmis(db, veri)
    client.put(f"/panel/musteriler/{mid}/not", headers=auth("isletme-a"), json={"metin": "Alerjisi var"})
    assert client.delete("/musteriler/hesabim", headers=auth("musteri-1")).status_code == 200
    assert db.query(models.MusteriNotu).count() == 0
    v = client.get(f"/panel/musteriler/{mid}", headers=auth("isletme-a")).json()
    assert v["musteri"]["telefon"] == "" and v["musteri"]["uygulama_kullanicisi"] is False
