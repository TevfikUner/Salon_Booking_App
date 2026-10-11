"""Keşfet: harf duyarsız filtre, konuma göre sıralama, favori işareti."""
import models
from conftest import auth
from routers.salonlar import mesafe_km, normalize


def test_normalize_turkce():
    assert normalize("İstanbul") == normalize("ISTANBUL") == normalize("istanbul") == normalize("Istanbul")
    assert normalize("Selçuklu") == normalize("SELCUKLU")
    assert normalize("Çankaya ") == "cankaya"


def test_mesafe_km():
    # Konya merkez ↔ Ankara Kızılay ≈ 230 km kuş uçuşu
    assert 220 < mesafe_km(37.8746, 32.4932, 39.9208, 32.8541) < 240
    assert mesafe_km(37.0, 32.0, 37.0, 32.0) == 0


def test_filtre_harf_duyarsiz_ve_konum_siralamasi(client, db):
    db.add_all([
        models.Salon(ad="Uzak", sehir="İstanbul", ilce="Kadıköy", konum_lat=40.99, konum_long=29.02, puan=5),
        models.Salon(ad="Yakın", sehir="İstanbul", ilce="Beşiktaş", konum_lat=41.04, konum_long=29.00, puan=4),
        models.Salon(ad="Konumsuz", sehir="İstanbul", ilce="Şişli"),
        models.Salon(ad="Pasif", sehir="İstanbul", aktif=False),
    ])
    db.commit()
    adlar = [s["ad"] for s in client.get("/salonlar", params={"sehir": "ISTANBUL"}).json()]
    assert set(adlar) == {"Uzak", "Yakın", "Konumsuz"}
    assert [s["ad"] for s in client.get("/salonlar", params={"sehir": "istanbul", "ilce": "besiktas"}).json()] == ["Yakın"]
    v = client.get("/salonlar", params={"lat": 41.043, "lng": 29.005}).json()
    assert [s["ad"] for s in v] == ["Yakın", "Uzak", "Konumsuz"]
    assert v[0]["mesafe_km"] < 1 and v[2]["mesafe_km"] is None
    # eski yol hâlâ çalışır
    assert len(client.get("/dukkan/salonlar").json()) == 3


def test_salon_detay_favori_isareti(client, veri):
    d = client.get(f"/salonlar/{veri['a']}").json()
    assert d["pazar_kapanis_saati"] == "17:00" and all(b["favori"] is False for b in d["berberler"])
    client.post("/musteriler/favori-toggle", params={"berber_id": veri["ali"]}, headers=auth("musteri-1"))
    d = client.get(f"/salonlar/{veri['a']}", headers=auth("musteri-1")).json()
    assert {b["id"]: b["favori"] for b in d["berberler"]}[veri["ali"]] is True
    fav = client.get("/musteriler/favoriler", headers=auth("musteri-1")).json()
    assert fav[0]["ad"] == "Ali" and fav[0]["soyad"] == "Usta"
    assert client.get("/salonlar/9999").status_code == 404


def test_arama_salon_adi_ilce_ve_hizmet(client, db):
    a = models.Salon(ad="Makas Kuaför", sehir="İstanbul", ilce="Kadıköy", puan=4.8)
    b = models.Salon(ad="Usta Berber", sehir="Ankara", ilce="Çankaya", puan=4.1)
    c = models.Salon(ad="Pasif Salon", sehir="İstanbul", aktif=False)
    db.add_all([a, b, c])
    db.flush()
    m = models.Musteri(firebase_uid="yorumcu")
    db.add(m)
    db.flush()
    db.add_all([models.Degerlendirme(musteri_id=m.id, salon_id=a.id, puan=5),
                models.Degerlendirme(musteri_id=m.id, salon_id=b.id, puan=4)])
    db.add_all([models.Hizmet(salon_id=b.id, ad="Sakal Tıraşı", fiyat=200, sure=30),
                models.Hizmet(salon_id=b.id, ad="Sakal Şekillendirme", fiyat=250, sure=30),
                models.Hizmet(salon_id=a.id, ad="Eski Sakal", fiyat=1, sure=30, aktif=False)])
    db.commit()
    ara = lambda **p: [(s["ad"], s["eslesen_hizmetler"]) for s in client.get("/salonlar", params=p).json()]  # noqa: E731
    assert ara(q="MAKAS") == [("Makas Kuaför", [])]
    assert ara(q="kuafor") == [("Makas Kuaför", [])]  # aksan duyarsız
    assert ara(q="kadikoy") == [("Makas Kuaför", [])]  # ilçe
    assert ara(q="ŞEKİL") == [("Usta Berber", ["Sakal Şekillendirme"])]
    assert ara(q="sakal") == [("Usta Berber", ["Sakal Tıraşı", "Sakal Şekillendirme"])]  # pasif hizmet sayılmaz
    assert ara(q="istanbul", min_puan=4.5) == [("Makas Kuaför", [])]  # pasif salon dönmez
    assert ara(min_puan=4.5) == [("Makas Kuaför", [])]
    assert ara(q="  ") == [("Makas Kuaför", []), ("Usta Berber", [])]
    assert ara(q="yok-boyle-bir-sey") == []
    assert client.get("/salonlar", params={"min_puan": 6}).status_code == 422


def test_degerlendirmesiz_salon_yeni_sayilir_puan_filtresine_girmez(client, db):
    eski = models.Salon(ad="Eski Salon", puan=4.6)
    yeni = models.Salon(ad="Yeni Salon")  # varsayılan puan 5.0, hiç değerlendirme yok
    db.add_all([eski, yeni])
    db.flush()
    m = models.Musteri(firebase_uid="yorumcu")
    db.add(m)
    db.flush()
    db.add(models.Degerlendirme(musteri_id=m.id, salon_id=eski.id, puan=5))
    db.commit()
    liste = client.get("/salonlar").json()
    assert [(s["ad"], s["degerlendirme_sayisi"]) for s in liste] == [("Eski Salon", 1), ("Yeni Salon", 0)]
    assert [s["ad"] for s in client.get("/salonlar", params={"min_puan": 4.5}).json()] == ["Eski Salon"]
    assert client.get(f"/salonlar/{yeni.id}").json()["degerlendirme_sayisi"] == 0
