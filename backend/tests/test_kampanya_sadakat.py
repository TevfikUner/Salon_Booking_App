"""Kampanya (gün/saat/tarih/hizmet koşullu yüzde indirim) ve sadakat kartı: hesap, mühür, erteleme, panel."""
import models
from conftest import YARIN, auth, randevu_al

ISL = auth("isletme-a")
CUMA = "2026-10-09"  # YARIN Perşembe (weekday 3)


def _kampanya(client, **ek):
    govde = {"ad": "Perşembe İndirimi", "yuzde": 20, "gunler": "3"} | ek
    r = client.post("/panel/kampanyalar", headers=ISL, json=govde)
    assert r.status_code == 200, r.text
    return r.json()


def _al(client, veri, saat="10:00", tarih=YARIN, hizmetler=("kesim",), uid="musteri-1"):
    r = randevu_al(client, uid, veri["ali"], tarih, saat, [veri[h] for h in hizmetler])
    assert r.status_code == 200, r.text
    return r.json()


def test_gun_kampanyasi_uygulanir_ve_muhurlenir(client, veri, db):
    k = _kampanya(client)
    assert k["kosul"] == "Perşembe"
    r = _al(client, veri)
    assert (r["liste_fiyati"], r["indirim_tutari"], r["toplam_fiyat"]) == (300, 60, 240)
    assert r["indirim_aciklama"] == "Perşembe İndirimi %20"
    assert _al(client, veri, tarih=CUMA)["toplam_fiyat"] == 300
    # Kampanya sonradan değişse de mühürlü tutar aynı
    client.put(f"/panel/kampanyalar/{k['id']}", headers=ISL, json={"ad": "X", "yuzde": 50, "gunler": "3"})
    db.expire_all()
    assert db.get(models.Randevu, r["randevu_id"]).toplam_fiyat == 240
    benim = client.get("/randevular/benim-randevularim", headers=auth("musteri-1")).json()
    kayit = next(x for x in benim if x["id"] == r["randevu_id"])
    assert kayit["kampanyali"] and kayit["liste_fiyati"] == 300 and kayit["indirim_tutari"] == 60


def test_saat_araligi_ve_slot_yuzdeleri(client, veri):
    _kampanya(client, bas_saat="10:00", bit_saat="12:00")
    m = client.get(f"/randevular/musait-saatler/{veri['ali']}",
                   params=[("tarih", YARIN), ("hizmet_ids", veri["kesim"])]).json()
    assert m["indirimler"]["10:00"] == 20 and m["indirimler"]["11:30"] == 20
    assert "12:00" not in m["indirimler"] and "09:30" not in m["indirimler"]
    assert _al(client, veri, saat="12:00")["indirim_tutari"] == 0
    assert _al(client, veri, saat="11:30", uid="musteri-2")["indirim_tutari"] == 60


def test_hizmete_ozel_ve_en_yuksek_kampanya(client, veri):
    _kampanya(client, ad="Sakal", yuzde=20, hizmet_idler=[veri["sakal"]])
    _kampanya(client, ad="Sakal Süper", yuzde=40, hizmet_idler=[veri["sakal"]])
    _kampanya(client, ad="Genel", yuzde=10)
    # kesim 300 → %10 = 30; sakal 450 → %40 = 180 (kampanyalar üst üste binmez, kalem başına en yükseği)
    r = _al(client, veri, hizmetler=("kesim", "sakal"))
    assert (r["liste_fiyati"], r["indirim_tutari"]) == (750, 210)
    assert r["indirim_aciklama"] == "Sakal Süper %40"  # en çok katkıyı yapan
    h = {x["id"]: x for x in client.get("/hizmetler/", params={"salon_id": veri["a"]}).json()}
    assert h[veri["sakal"]]["kampanya_yuzde"] == 40 and h[veri["kesim"]]["kampanya_yuzde"] == 10


def test_tarih_araligi_disi_ve_pasif_kampanya_uygulanmaz(client, veri):
    _kampanya(client, ad="Eski", bit_tarih="2026-10-06")  # dün bitti
    _kampanya(client, ad="Gelecek", bas_tarih="2026-10-15")
    _kampanya(client, ad="Pasif", aktif=False)
    assert _al(client, veri)["indirim_tutari"] == 0
    s = client.get("/salonlar").json()
    assert next(x for x in s if x["id"] == veri["a"])["kampanya_yuzde"] == 20  # "Gelecek" hâlâ geçerli
    d = client.get(f"/salonlar/{veri['a']}").json()
    assert [k["ad"] for k in d["kampanyalar"]] == ["Gelecek"]
    lst = client.get("/panel/kampanyalar", headers=ISL).json()
    assert next(x for x in lst if x["ad"] == "Eski")["suresi_doldu"]


def test_takvimde_kampanyali_gun(client, veri):
    _kampanya(client)
    g = client.get("/randevular/musait-takvim",
                   params=[("berber_id", veri["ali"]), ("hizmet_ids", veri["kesim"])]).json()
    gunler = {x["tarih"]: x for x in g}
    assert gunler[YARIN]["indirim_yuzde"] == 20 and gunler[CUMA]["indirim_yuzde"] == 0


def test_fiyat_teklifi_olusturmayla_ayni(client, veri):
    _kampanya(client)
    params = [("berber_id", veri["ali"]), ("tarih", YARIN), ("saat", "10:00"), ("hizmet_ids", veri["kesim"])]
    t = client.get("/randevular/fiyat", params=params).json()
    assert t == {"liste_fiyati": 300, "indirim_tutari": 60, "indirim_aciklama": "Perşembe İndirimi %20",
                 "toplam_fiyat": 240}
    assert _al(client, veri)["toplam_fiyat"] == t["toplam_fiyat"]


def test_ertelemede_kampanya_disina_cikinca_indirim_kalkar(client, veri):
    _kampanya(client, bas_saat="10:00", bit_saat="12:00")
    rid = _al(client, veri)["randevu_id"]
    m = client.get(f"/randevular/musait-saatler/{veri['ali']}", headers=auth("musteri-1"),
                   params=[("tarih", YARIN), ("hizmet_ids", veri["kesim"]), ("ertelenen_id", rid)]).json()
    assert "11:00" in m["kampanya_korunan_saatler"] and "14:00" not in m["kampanya_korunan_saatler"]
    assert m["indirimler"] == {}  # ertelemede yeni indirim kazanılmaz
    r = client.post(f"/randevular/{rid}/ertele", headers=auth("musteri-1"), json={"tarih": YARIN, "saat": "11:00"})
    assert r.json()["randevu"]["toplam_fiyat"] == 240
    r = client.post(f"/randevular/{rid}/ertele", headers=auth("musteri-1"), json={"tarih": CUMA, "saat": "10:00"})
    j = r.json()["randevu"]
    assert (j["toplam_fiyat"], j["indirim_tutari"], j["kampanyali"]) == (300, 0, False)


def test_ertelemede_kampanyasiz_randevu_indirim_kazanmaz(client, veri):
    rid = _al(client, veri, tarih=CUMA)["randevu_id"]
    _kampanya(client)
    r = client.post(f"/randevular/{rid}/ertele", headers=auth("musteri-1"), json={"tarih": YARIN, "saat": "10:00"})
    assert r.json()["randevu"]["toplam_fiyat"] == 300


def _gecmis(db, veri, adet, uid="musteri-1"):
    m = db.query(models.Musteri).filter_by(firebase_uid=uid).first()
    for i in range(adet):
        db.add(models.Randevu(musteri_id=m.id, berber_id=veri["ali"], salon_id=veri["a"], tarih=f"2026-09-0{i + 1}",
                              saat="10:00", sure_dk=30, durum="tamamlandi", toplam_fiyat=300))
    db.add(models.Randevu(musteri_id=m.id, berber_id=veri["ali"], salon_id=veri["a"], tarih="2026-09-09",
                          saat="10:00", sure_dk=30, durum="gelmedi", toplam_fiyat=300))  # sayılmaz
    db.commit()


def test_sadakat_karti_esikte_indirim(client, veri, db):
    assert client.put("/panel/sadakat", headers=ISL, json={"esik": 3, "yuzde": 50}).json() == {"esik": 3, "yuzde": 50}
    _gecmis(db, veri, 2)
    kart = client.get(f"/salonlar/{veri['a']}", headers=auth("musteri-1")).json()["sadakat_karti"]
    assert kart == {"esik": 3, "yuzde": 50, "ziyaret": 2, "siradaki_indirimli": True}
    assert client.get(f"/salonlar/{veri['a']}").json()["sadakat_karti"]["ziyaret"] is None
    _kampanya(client)  # %20 < %50 → sadakat uygulanır (üst üste binmez)
    r = _al(client, veri)
    assert (r["indirim_tutari"], r["toplam_fiyat"]) == (150, 150)
    assert r["indirim_aciklama"] == "Sadakat kartı: 3. ziyaret %50"
    # Sonraki (4.) randevu sadakatte değil → kampanya
    assert _al(client, veri, saat="11:00")["indirim_tutari"] == 60
    assert next(x for x in client.get("/salonlar").json() if x["id"] == veri["a"])["sadakat"] is True


def test_sadakat_baska_musteri_ve_kapatma(client, veri, db):
    client.put("/panel/sadakat", headers=ISL, json={"esik": 3, "yuzde": 50})
    _gecmis(db, veri, 2)
    assert _al(client, veri, uid="musteri-2")["indirim_tutari"] == 0
    assert client.put("/panel/sadakat", headers=ISL, json={"esik": None, "yuzde": None}).status_code == 200
    assert _al(client, veri, saat="11:00")["indirim_tutari"] == 0
    assert client.put("/panel/sadakat", headers=ISL, json={"esik": 3}).status_code == 422


def test_panel_kampanya_dogrulama_ve_yetki(client, veri, db):
    def post(uid="isletme-a", **ek):
        return client.post("/panel/kampanyalar", headers=auth(uid), json={"ad": "K", "yuzde": 20} | ek)
    assert post(yuzde=95).status_code == 422
    assert post(bas_saat="12:00").status_code == 422
    assert post(bas_saat="12:00", bit_saat="11:00").status_code == 422
    assert post(bas_tarih="2026-10-10", bit_tarih="2026-10-09").status_code == 422
    assert post(gunler="8").status_code == 422
    assert post(hizmet_idler=[veri["b_kesim"]]).status_code == 404
    k = post().json()
    assert client.put(f"/panel/kampanyalar/{k['id']}", headers=auth("isletme-b"),
                      json={"ad": "K", "yuzde": 20}).status_code == 404
    db.get(models.Berber, veri["ali"]).firebase_uid = "personel-ali"
    db.commit()
    assert post(uid="personel-ali").status_code == 403
    assert client.get("/panel/kampanyalar", headers=auth("personel-ali")).status_code == 200


def test_kampanya_silinince_indirim_korunur_ve_rapor(client, veri, db):
    k = _kampanya(client)
    rid = _al(client, veri)["randevu_id"]
    assert client.get("/panel/kampanyalar", headers=ISL).json()[0]["randevu_sayisi"] == 1
    assert client.delete(f"/panel/kampanyalar/{k['id']}", headers=ISL).status_code == 200
    db.expire_all()
    r = db.get(models.Randevu, rid)
    assert (r.toplam_fiyat, r.kampanya_id) == (240, None)
    r.durum = "tamamlandi"
    db.commit()
    rapor = client.get("/panel/rapor", params={"yil": 2026, "ay": 10}, headers=ISL).json()
    assert rapor["toplam_indirim"] == 60 and rapor["indirimli_randevu"] == 1 and rapor["toplam_ciro"] == 240
    akis = client.get("/panel/akis", params={"tarih": YARIN}, headers=ISL).json()
    assert akis["randevular"][0]["indirim_tutari"] == 60


def test_takvim_isareti_yalnizca_alinabilir_indirimli_saat_varsa(client, veri):
    # Sabit an Çarşamba 12:10: bugünün 10:00–12:00 kampanyası geçti, yarınki geçerli
    _kampanya(client, gunler="", bas_saat="10:00", bit_saat="12:00")
    g = {x["tarih"]: x for x in client.get("/randevular/musait-takvim",
                                            params=[("berber_id", veri["ali"]), ("hizmet_ids", veri["kesim"])]).json()}
    assert g["2026-10-07"]["indirim_yuzde"] == 0 and g[YARIN]["indirim_yuzde"] == 20
    # Yarının indirimli saatleri dolarsa işaret kalkar
    for i, s in enumerate(("10:00", "10:30", "11:00", "11:30")):
        randevu_al(client, f"dolu-{i}", veri["ali"], YARIN, s, [veri["kesim"]])
    g = {x["tarih"]: x for x in client.get("/randevular/musait-takvim",
                                            params=[("berber_id", veri["ali"]), ("hizmet_ids", veri["kesim"])]).json()}
    assert g[YARIN]["indirim_yuzde"] == 0


def test_kosul_metni_hafta_ici_ve_sonu(client, veri):
    assert _kampanya(client, gunler="0,1,2,3,4")["kosul"] == "Hafta içi"
    assert _kampanya(client, gunler="5,6", bit_tarih="2026-11-06")["kosul"] == "Hafta sonu · 06.11.2026'ya kadar"
