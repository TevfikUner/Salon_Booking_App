"""Roller, işletme paneli, güven skoru, admin ve hesap silme."""
import models
import randevu_servisi as rs
from conftest import YARIN, auth, randevu_al


def test_ben_rolleri(client, veri):
    assert client.get("/ben", headers=auth("musteri-1")).json()["rol"] == "musteri"
    v = client.get("/ben", headers=auth("isletme-a")).json()
    assert v["rol"] == "isletme" and v["salon"]["ad"] == "Salon A"
    assert client.get("/ben", headers=auth("isletme-bekleyen")).json()["isletme"]["durum"] == "beklemede"
    assert client.get("/ben", headers=auth("admin-uid")).json()["rol"] == "admin"
    assert client.get("/ben").status_code == 401


def test_personel_davet_eposta_ile_baglanir(client, veri, db, monkeypatch):
    import auth as auth_mod
    # Doğrulanmamış e-postayla personel rolü ele geçirilemez
    monkeypatch.setattr(auth_mod, "token_coz", lambda t: auth_mod.Kimlik(uid="sahte", email="ali@salon.test"))
    assert client.get("/ben", headers={"Authorization": "Bearer x"}).json()["rol"] == "musteri"
    assert db.get(models.Berber, veri["ali"]).firebase_uid is None
    monkeypatch.setattr(auth_mod, "token_coz", lambda t: auth_mod.Kimlik(uid="ali-uid", email="ALI@salon.test",
                                                                        email_dogrulandi=True))
    v = client.get("/ben", headers={"Authorization": "Bearer x"}).json()
    assert v["rol"] == "personel" and v["berber"]["id"] == veri["ali"]
    assert db.get(models.Berber, veri["ali"]).firebase_uid == "ali-uid"


def test_panel_yetkileri(client, veri):
    assert client.get("/panel/akis", headers=auth("musteri-1")).status_code == 403
    assert client.get("/panel/akis", headers=auth("isletme-bekleyen")).status_code == 403
    assert client.get("/panel/akis", params={"salon_id": veri["b"]}, headers=auth("isletme-a")).status_code == 403
    assert client.get("/panel/akis", headers=auth("admin-uid")).status_code == 400
    assert client.get("/panel/akis", params={"salon_id": veri["b"]}, headers=auth("admin-uid")).status_code == 200
    # berber planı artık herkese açık değil
    assert client.get(f"/randevular/berber-plani/{veri['ali']}").status_code == 401
    assert client.get(f"/randevular/berber-plani/{veri['ali']}", headers=auth("musteri-1")).status_code == 403
    assert client.get(f"/randevular/berber-plani/{veri['ali']}", headers=auth("isletme-a")).status_code == 200


def test_gunun_akisi_ozet_ve_izolasyon(client, veri):
    randevu_al(client, "musteri-1", veri["ali"], "2026-10-07", "13:00", [veri["kesim"], veri["sakal"]])
    randevu_al(client, "musteri-2", veri["veli"], "2026-10-07", "14:00", [veri["kesim"]])
    randevu_al(client, "musteri-2", veri["zeki"], "2026-10-07", "14:00", [veri["b_kesim"]])  # salon B
    v = client.get("/panel/akis", headers=auth("isletme-a")).json()
    assert v["ozet"]["randevu_sayisi"] == 2
    assert v["ozet"]["beklenen_ciro"] == 1050
    assert v["ozet"]["toplam_sure_dk"] == 105
    ilk = v["randevular"][0]
    assert ilk["saat"] == "13:00" and ilk["bitis"] == "14:15" and ilk["musteri"]["ad"] == "Ahmet Yıldız"
    assert [h["ad"] for h in ilk["hizmetler"]] == ["Kesim", "Sakal & Kesim"]
    assert ilk["whatsapp_link"].startswith("https://wa.me/905321112233?text=")
    assert v["siradaki"]["saat"] == "13:00"
    # B salonunun randevusu A'nın panelinde görünmez ve yönetilemez
    b_id = client.get("/panel/akis", headers=auth("isletme-b")).json()["randevular"][0]["id"]
    assert client.patch(f"/panel/randevular/{b_id}/durum", json={"durum": "iptal"},
                        headers=auth("isletme-a")).status_code == 404


def test_durum_isaretleme_ve_degerlendirme_bildirimi(client, veri, db):
    from bildirim import gonderilenler
    rid = randevu_al(client, "musteri-1", veri["ali"], "2026-10-07", "13:00", [veri["kesim"]]).json()["randevu_id"]
    # başlamamış randevu "gelmedi" yapılamaz
    r = client.patch(f"/panel/randevular/{rid}/durum", json={"durum": "gelmedi"}, headers=auth("isletme-a"))
    assert r.status_code == 400
    import zaman
    from datetime import datetime
    zaman.sabit_an = datetime(2026, 10, 7, 13, 40)
    gonderilenler.clear()
    r = client.patch(f"/panel/randevular/{rid}/durum", json={"durum": "tamamlandi"}, headers=auth("isletme-a"))
    assert r.status_code == 200
    assert any(b["veri"].get("type") == "degerlendirme" for b in gonderilenler)
    # işletme iptali müşteriye bildirilir ve slot boşalır
    rid2 = randevu_al(client, "musteri-2", veri["ali"], YARIN, "10:00", [veri["kesim"]]).json()["randevu_id"]
    gonderilenler.clear()
    client.patch(f"/panel/randevular/{rid2}/durum", json={"durum": "iptal"}, headers=auth("isletme-a"))
    assert db.get(models.Randevu, rid2).iptal_eden == "isletme"
    assert any(b["token"] == "tok-2" for b in gonderilenler)


def test_guven_skoru(db, veri):
    m = db.query(models.Musteri).filter_by(firebase_uid="musteri-2").one()
    assert rs.guven_skoru(db, m.id)["etiket"] == "Yeni"
    for t in ("2026-09-01", "2026-09-10"):
        db.add(models.Randevu(musteri_id=m.id, berber_id=veri["ali"], salon_id=veri["a"], tarih=t, saat="10:00",
                              sure_dk=30, toplam_fiyat=300, durum="gelmedi"))
    db.commit()
    s = rs.guven_skoru(db, m.id)
    assert s["etiket"] == "Riskli" and s["gelmedi"] == 2
    db.add(models.Randevu(musteri_id=m.id, berber_id=veri["ali"], salon_id=veri["a"], tarih="2026-09-05",
                          saat="10:00", sure_dk=30, toplam_fiyat=300, durum="iptal", iptal_eden="musteri",
                          iptal_zamani="2026-09-05T09:30:00"))
    db.commit()
    assert rs.guven_skoru(db, m.id)["gec_iptal"] == 1


def test_panelden_walkin_randevu(client, veri):
    r = client.post("/panel/randevular", headers=auth("isletme-a"), json={
        "berber_id": veri["veli"], "tarih": YARIN, "saat": "11:00", "hizmet_ids": [veri["kesim"]],
        "musteri_ad": "Selim Kara", "musteri_telefon": "05301234567", "notlar": "Telefonla aradı"})
    assert r.status_code == 200, r.text
    assert r.json()["randevu"]["musteri"]["ad"] == "Selim Kara"
    # kayıtlı kullanıcının telefonu girilse bile onun hesabına bağlanmaz
    r = client.post("/panel/randevular", headers=auth("isletme-a"), json={
        "berber_id": veri["veli"], "tarih": YARIN, "saat": "12:00", "hizmet_ids": [veri["kesim"]],
        "musteri_ad": "Başka Biri", "musteri_telefon": "05321112233"})
    assert r.status_code == 200
    assert client.get("/randevular/benim-randevularim", headers=auth("musteri-1")).json() == []
    # aynı slot uygulamadan alınamaz
    assert randevu_al(client, "musteri-1", veri["veli"], YARIN, "11:00", [veri["kesim"]]).status_code == 409
    # başka salonun personeline eklenemez
    r = client.post("/panel/randevular", headers=auth("isletme-a"), json={
        "berber_id": veri["zeki"], "tarih": YARIN, "saat": "11:00", "hizmet_ids": [veri["b_kesim"]],
        "musteri_ad": "X"})
    assert r.status_code == 403


def test_panel_hizmet_personel_tatil_yonetimi(client, veri, db):
    h = client.post("/panel/hizmetler", headers=auth("isletme-a"),
                    json={"ad": "Fön", "fiyat": 120, "sure": 15}).json()
    assert h["salon_id"] == veri["a"]
    assert any(x["ad"] == "Fön" for x in client.get("/hizmetler/", params={"salon_id": veri["a"]}).json())
    assert not any(x["ad"] == "Fön" for x in client.get("/hizmetler/", params={"salon_id": veri["b"]}).json())
    assert client.delete(f"/panel/hizmetler/{h['id']}", headers=auth("isletme-b")).status_code == 404
    assert client.delete(f"/panel/hizmetler/{h['id']}", headers=auth("isletme-a")).status_code == 200

    p = client.post("/panel/personel", headers=auth("isletme-a"), json={"ad": "Yeni", "soyad": "Berber"}).json()
    randevu_al(client, "musteri-1", p["id"], YARIN, "10:00", [veri["kesim"]])
    r = client.delete(f"/panel/personel/{p['id']}", headers=auth("isletme-a"))
    assert r.status_code == 400  # aktif randevusu var

    r = client.post("/panel/tatil", headers=auth("isletme-a"), json={"tarih": YARIN, "aciklama": "Bayram"})
    assert r.status_code == 200 and r.json()["etkilenen_randevu"] == 1
    assert client.post("/panel/tatil", headers=auth("isletme-a"), json={"tarih": "09-10-2026"}).status_code in (400, 422)


def test_admin_secret_varsayilani_yok(client, veri):
    assert client.post("/tatil/ekle", params={"tarih": YARIN}, headers={"x-admin-secret": "***KALDIRILDI***"}).status_code == 403
    assert client.post("/tatil/ekle", params={"tarih": YARIN}, headers=auth("isletme-a")).status_code == 403
    assert client.post("/tatil/ekle", params={"tarih": YARIN}, headers=auth("admin-uid")).status_code == 200
    # işletme listesi (iletişim bilgileri) herkese açık değil
    assert client.get("/isletmeler/").status_code == 403


def test_isletme_basvuru_ve_onay(client, veri):
    params = {"ad": "A", "soyad": "B", "telefon": "05301112233", "email": "a@b.co", "isletme_adi": "Yeni Salon"}
    assert client.post("/isletmeler/kayit", params=params).status_code == 401
    assert client.post("/isletmeler/kayit", params=params, headers=auth("yeni-isletme")).status_code == 200
    assert client.post("/isletmeler/kayit", params=params, headers=auth("yeni-isletme")).status_code == 400
    iid = client.get("/isletmeler/durum", headers=auth("yeni-isletme")).json()["id"]
    assert client.post(f"/isletmeler/{iid}/onayla", headers=auth("musteri-1")).status_code == 403
    r = client.post(f"/isletmeler/{iid}/onayla", params={"sehir": "Konya"}, headers=auth("admin-uid"))
    assert r.status_code == 200 and r.json()["salon_id"]
    assert client.get("/panel/akis", headers=auth("yeni-isletme")).status_code == 200


def test_hesap_silme_anonimlestirir(client, veri, db):
    rid = randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["kesim"]]).json()["randevu_id"]
    mid = db.query(models.Musteri).filter_by(firebase_uid="musteri-1").one().id
    assert client.delete("/musteriler/hesabim", headers=auth("musteri-1")).status_code == 200
    db.expire_all()
    m = db.get(models.Musteri, mid)  # ad/telefon şifreli olabilir: eşitlik aramasıyla değil kimlikle
    assert (m.ad, m.telefon, m.telefon_ozet) == ("Silinmiş", "", None)
    assert m.firebase_uid is None and m.silindi and m.fcm_token is None
    assert db.get(models.Randevu, rid).durum == "iptal"


def test_kvkk_onayi_olmadan_kayit_olmaz(client):
    assert client.post("/musteriler/kayit", headers=auth("yeni"), json={"ad": "A"}).status_code == 400
    r = client.post("/musteriler/kayit", headers=auth("yeni"), json={"ad": "A", "kvkk_onay": True})
    assert r.status_code == 200
    assert client.get("/ben", headers=auth("yeni")).json()["kvkk_onay"] is True


def test_fcm_token_cihaz_devri(client, veri, db):
    client.patch("/musteriler/fcm-token-guncelle", params={"fcm_token": "tok-1"}, headers=auth("musteri-2"))
    db.expire_all()
    assert db.query(models.Musteri).filter_by(firebase_uid="musteri-1").one().fcm_token is None
    assert db.query(models.Musteri).filter_by(firebase_uid="musteri-2").one().fcm_token == "tok-1"


def test_otomatik_tamamlama_ve_hatirlatma(db, veri, client):
    import gorevler
    import zaman
    from datetime import datetime
    from bildirim import gonderilenler
    randevu_al(client, "musteri-1", veri["ali"], "2026-10-07", "13:00", [veri["kesim"]])
    zaman.sabit_an = datetime(2026, 10, 7, 12, 5)
    gonderilenler.clear()
    assert gorevler.hatirlatma_gorevi() == 1
    assert gorevler.hatirlatma_gorevi() == 0  # ikinci kez gönderilmez
    zaman.sabit_an = datetime(2026, 10, 7, 14, 0)  # bitiş + 30 dk: henüz değil
    assert gorevler.tamamlama_ve_degerlendirme_gorevi() == 0
    zaman.sabit_an = datetime(2026, 10, 7, 14, 31)
    assert gorevler.tamamlama_ve_degerlendirme_gorevi() == 1
    assert any(b["veri"].get("type") == "degerlendirme" for b in gonderilenler)
