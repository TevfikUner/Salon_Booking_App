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
