"""Berber ↔ hizmet eşleşmesi: verdiği hizmetler, berbere özel fiyat ve süre (slot, randevu, listeler)."""
from conftest import YARIN, auth, randevu_al

import models

ISL = auth("isletme-a")


def _ayarla(client, veri, berber, ayarlar, uid="isletme-a"):
    return client.put(f"/panel/personel/{veri[berber]}/hizmetler", headers=auth(uid), json=ayarlar)


def test_ayar_yokken_davranis_ayni(client, veri):
    h = client.get("/hizmetler/", params={"salon_id": veri["a"]}).json()
    kesim = next(x for x in h if x["id"] == veri["kesim"])
    assert kesim["fiyat_min"] == kesim["fiyat_max"] == 300 and kesim["sure_min"] == kesim["sure_max"] == 30
    b = client.get("/berberler/", params=[("salon_id", veri["a"]), ("hizmet_ids", veri["sakal"])]).json()
    assert all(x["uygun"] and x["toplam_fiyat"] == 450 and x["toplam_sure_dk"] == 45 for x in b)


def test_ozel_fiyat_ve_sure_randevuya_muhurlenir(client, veri, db):
    r = _ayarla(client, veri, "ali", [{"hizmet_id": veri["kesim"], "fiyat": 400, "sure": 60}])
    assert r.status_code == 200
    k = next(x for x in r.json() if x["hizmet_id"] == veri["kesim"])
    assert (k["veriyor"], k["fiyat"], k["sure"], k["menu_fiyat"]) == (True, 400, 60, 300)

    # Müşteri listeleri
    h = next(x for x in client.get("/hizmetler/", params={"salon_id": veri["a"]}).json() if x["id"] == veri["kesim"])
    assert (h["fiyat_min"], h["fiyat_max"], h["sure_min"], h["sure_max"]) == (300, 400, 30, 60)
    ali_menu = client.get("/hizmetler/", params={"salon_id": veri["a"], "berber_id": veri["ali"]}).json()
    assert next(x for x in ali_menu if x["id"] == veri["kesim"])["fiyat"] == 400

    # 60 dk süre slotu etkiler: 20:30 kapanışa (21:00) sığmaz
    m = client.get(f"/randevular/musait-saatler/{veri['ali']}",
                   params=[("tarih", YARIN), ("hizmet_ids", veri["kesim"])]).json()
    assert m["toplam_sure_dk"] == 60 and "20:00" in m["musait_saatler"] and "20:30" not in m["musait_saatler"]

    rid = randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["kesim"]]).json()["randevu_id"]
    rnd = db.get(models.Randevu, rid)
    assert (rnd.toplam_fiyat, rnd.sure_dk) == (400, 60)
    # Veli menü fiyatıyla
    rid2 = randevu_al(client, "musteri-2", veri["veli"], YARIN, "10:00", [veri["kesim"]]).json()["randevu_id"]
    assert db.get(models.Randevu, rid2).toplam_fiyat == 300

    # Sonradan değişiklik mevcut randevuyu etkilemez
    _ayarla(client, veri, "ali", [{"hizmet_id": veri["kesim"], "fiyat": 500}])
    db.expire_all()
    assert db.get(models.Randevu, rid).toplam_fiyat == 400


def test_vermedigi_hizmet_icin_randevu_alinmaz(client, veri):
    assert _ayarla(client, veri, "ali", [{"hizmet_id": veri["damat"], "veriyor": False}]).status_code == 200
    b = client.get("/berberler/", params=[("salon_id", veri["a"]), ("hizmet_ids", veri["kesim"]),
                                          ("hizmet_ids", veri["damat"])]).json()
    assert b[0]["id"] == veri["veli"] and b[0]["uygun"]  # uygunlar önce
    ali = next(x for x in b if x["id"] == veri["ali"])
    assert not ali["uygun"] and ali["vermedigi_hizmetler"] == ["Damat"] and ali["toplam_fiyat"] is None

    r = randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["damat"]])
    assert r.status_code == 400 and "Damat" in r.json()["detail"]["mesaj"]
    m = client.get(f"/randevular/musait-saatler/{veri['ali']}", params=[("tarih", YARIN), ("hizmet_ids", veri["damat"])])
    assert m.status_code == 400
    ali_menu = client.get("/hizmetler/", params={"salon_id": veri["a"], "berber_id": veri["ali"]}).json()
    assert veri["damat"] not in [x["id"] for x in ali_menu]
    # Panelden de alınamaz
    p = client.post("/panel/randevular", headers=ISL, json={"berber_id": veri["ali"], "tarih": YARIN, "saat": "10:00",
                                                           "hizmet_ids": [veri["damat"]], "musteri_ad": "Kapı"})
    assert p.status_code == 400
    panel_menu = client.get("/panel/hizmetler", params={"berber_id": veri["ali"]}, headers=ISL).json()
    assert veri["damat"] not in [x["id"] for x in panel_menu]
    per = next(x for x in client.get("/panel/personel", headers=ISL).json() if x["id"] == veri["ali"])
    assert per["vermedigi_hizmet_sayisi"] == 1


def test_hicbir_personelin_vermedigi_hizmet_menude_gorunmez(client, veri):
    for b in ("ali", "veli"):
        _ayarla(client, veri, b, [{"hizmet_id": veri["damat"], "veriyor": False}])
    h = client.get("/hizmetler/", params={"salon_id": veri["a"]}).json()
    assert veri["damat"] not in [x["id"] for x in h]


def test_menuyle_ayni_ayar_kayit_tutmaz_ve_en_az_bir_hizmet(client, veri, db):
    _ayarla(client, veri, "ali", [{"hizmet_id": veri["kesim"], "fiyat": 400}])
    _ayarla(client, veri, "ali", [{"hizmet_id": veri["kesim"], "fiyat": 300, "sure": 30}])  # menüye dönüş
    assert db.query(models.BerberHizmet).count() == 0
    hepsi = [{"hizmet_id": veri[h], "veriyor": False} for h in ("kesim", "sakal", "damat")]
    r = _ayarla(client, veri, "ali", hepsi)
    assert r.status_code == 400 and db.query(models.BerberHizmet).count() == 0


def test_yetki_ve_salon_izolasyonu(client, veri, db):
    assert _ayarla(client, veri, "ali", [{"hizmet_id": veri["kesim"], "veriyor": False}], uid="isletme-b").status_code == 404
    assert _ayarla(client, veri, "ali", [{"hizmet_id": veri["b_kesim"], "veriyor": False}]).status_code == 404
    db.get(models.Berber, veri["ali"]).firebase_uid = "personel-ali"
    db.commit()
    assert client.get(f"/panel/personel/{veri['ali']}/hizmetler", headers=auth("personel-ali")).status_code == 200
    assert _ayarla(client, veri, "ali", [{"hizmet_id": veri["kesim"], "veriyor": False}],
                   uid="personel-ali").status_code == 403
    assert _ayarla(client, veri, "ali", [{"hizmet_id": veri["kesim"], "sure": 2}]).status_code == 422


def test_her_zamanki_ve_bekleme_berber_suresiyle(client, veri, db):
    _ayarla(client, veri, "ali", [{"hizmet_id": veri["kesim"], "fiyat": 350, "sure": 45}])
    m = db.query(models.Musteri).filter_by(firebase_uid="musteri-1").first()
    db.add(models.Randevu(musteri_id=m.id, berber_id=veri["ali"], salon_id=veri["a"], tarih="2026-10-01", saat="10:00",
                          sure_dk=30, durum="tamamlandi", toplam_fiyat=300,
                          hizmetler=[db.get(models.Hizmet, veri["kesim"])]))
    db.commit()
    hz = client.get("/randevular/her-zamanki", headers=auth("musteri-1")).json()
    assert hz["toplam_fiyat"] == 350 and hz["toplam_sure_dk"] == 45
    b = client.post("/randevular/bekleme-listesi", headers=auth("musteri-1"),
                    json={"berber_id": veri["ali"], "tarih": YARIN, "hizmet_ids": [veri["kesim"]]})
    assert b.status_code == 200
    assert db.query(models.BeklemeListesi).one().sure_dk == 45
    # Berber hizmeti bırakırsa "Her Zamanki" önerilmez
    _ayarla(client, veri, "ali", [{"hizmet_id": veri["kesim"], "veriyor": False}])
    assert client.get("/randevular/her-zamanki", headers=auth("musteri-1")).json() is None
