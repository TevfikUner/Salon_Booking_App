"""İşletme takviminde randevu taşıma (sürükle-bırak) ve gün takvimi verisi."""
import models
from bildirim import gonderilenler
from conftest import YARIN, auth, randevu_al

ISL = auth("isletme-a")


def _al(client, veri, saat="10:00", berber="ali", hizmet="kesim", uid="musteri-1"):
    r = randevu_al(client, uid, veri[berber], YARIN, saat, [veri[hizmet]])
    assert r.status_code == 200, r.text
    return r.json()["randevu_id"]


def _tasi(client, rid, berber_id, saat, tarih=YARIN, uid="isletme-a"):
    return client.post(f"/panel/randevular/{rid}/tasi", headers=auth(uid),
                       json={"berber_id": berber_id, "tarih": tarih, "saat": saat})


def test_baska_berbere_ve_saate_tasir_fiyat_ayni_bildirim_gider(client, veri, db):
    rid = _al(client, veri)
    gonderilenler.clear()
    r = _tasi(client, rid, veri["veli"], "15:00")
    assert r.status_code == 200, r.text
    j = r.json()["randevu"]
    assert (j["berber"]["id"], j["saat"], j["toplam_fiyat"]) == (veri["veli"], "15:00", 300)
    rnd = db.get(models.Randevu, rid)
    db.refresh(rnd)
    assert (rnd.erteleme_sayisi, rnd.hatirlatma_gonderildi) == (0, False)  # müşterinin hakkından düşmez
    b = [g for g in gonderilenler if g["token"] == "tok-1"]
    assert b and b[0]["baslik"] == "Randevunuz güncellendi" and "08.10.2026 15:00 (Veli Kalfa)" in b[0]["mesaj"]
    # Ali'nin 10:00'ı artık boş
    m = client.get(f"/randevular/musait-saatler/{veri['ali']}",
                   params=[("tarih", YARIN), ("hizmet_ids", veri["kesim"])]).json()
    assert "10:00" in m["musait_saatler"]


def test_ayni_berberde_kendi_araligiyla_cakismaz(client, veri):
    rid = _al(client, veri, hizmet="sakal")  # 45 dk → 10:00–11:00 bloğu
    assert _tasi(client, rid, veri["ali"], "10:30").status_code == 200


def test_cakisma_409_ve_kurallar(client, veri, db):
    rid = _al(client, veri)
    _al(client, veri, saat="14:00", berber="veli", uid="musteri-2")
    r = _tasi(client, rid, veri["veli"], "14:00")
    assert r.status_code == 409 and r.json()["detail"]["oneriler"]
    assert _tasi(client, rid, veri["ali"], "10:00").status_code == 400  # aynı yer
    assert _tasi(client, rid, veri["zeki"], "11:00").status_code == 403  # başka salonun personeli
    assert _tasi(client, rid, veri["ali"], "11:00", uid="isletme-b").status_code == 404
    # Vermediği hizmete taşınamaz
    client.put(f"/panel/personel/{veri['veli']}/hizmetler", headers=ISL,
               json=[{"hizmet_id": veri["kesim"], "veriyor": False}])
    r = _tasi(client, rid, veri["veli"], "11:00")
    assert r.status_code == 400 and "Kesim" in r.json()["detail"]["mesaj"]
    # İptal edilmiş randevu taşınamaz
    db.get(models.Randevu, rid).durum = "iptal"
    db.commit()
    assert _tasi(client, rid, veri["ali"], "11:00").status_code == 400


def test_personel_yalnizca_kendi_takviminde(client, veri, db):
    rid = _al(client, veri)
    db.get(models.Berber, veri["ali"]).firebase_uid = "personel-ali"
    db.commit()
    assert _tasi(client, rid, veri["veli"], "11:00", uid="personel-ali").status_code == 403
    assert _tasi(client, rid, veri["ali"], "11:00", uid="personel-ali").status_code == 200
    rid2 = _al(client, veri, berber="veli", uid="musteri-2")
    assert _tasi(client, rid2, veri["veli"], "12:00", uid="personel-ali").status_code == 403


def test_gecmis_randevu_tasinamaz(client, veri, db):
    m = db.query(models.Musteri).filter_by(firebase_uid="musteri-1").first()
    r = models.Randevu(musteri_id=m.id, berber_id=veri["ali"], salon_id=veri["a"], tarih="2026-10-07", saat="09:00",
                       sure_dk=30, durum="onaylandi", toplam_fiyat=300)
    db.add(r)
    db.commit()
    assert _tasi(client, r.id, veri["ali"], "15:00").status_code == 400


def test_eski_gunun_bekleme_listesi_haber_alir(client, veri, db):
    # Ali o gün tamamen dolu değil ama test için: başka günden taşınınca eski gün için bekleyen haberdar olur
    rid = _al(client, veri)
    m2 = db.query(models.Musteri).filter_by(firebase_uid="musteri-2").first()
    db.add(models.BeklemeListesi(musteri_id=m2.id, berber_id=veri["ali"], salon_id=veri["a"], tarih=YARIN, sure_dk=30))
    db.commit()
    assert _tasi(client, rid, veri["ali"], "10:00", tarih="2026-10-09").status_code == 200
    assert db.query(models.BeklemeListesi).one().bildirildi


def test_akis_gun_takvimi_verisi(client, veri):
    s = client.get("/panel/salon", headers=ISL).json()
    govde = {k: s[k] for k in ("ad", "adres", "telefon", "whatsapp", "instagram_url", "acilis_saati", "kapanis_saati",
                               "pazar_acilis_saati", "pazar_kapanis_saati", "kapali_gunler")}
    client.put("/panel/salon", headers=ISL, json=govde | {"mola_baslangic": "13:00", "mola_bitis": "14:00"})
    client.post("/panel/bloke", headers=ISL, json={"berber_id": veri["veli"], "tarih": YARIN, "bas_saat": "16:00",
                                                    "bit_saat": "17:00", "aciklama": "Doktor"})
    v = client.get("/panel/akis", params={"tarih": YARIN}, headers=ISL).json()
    assert v["mesai"] == {"acilis": "09:00", "kapanis": "21:00"}
    assert v["mola"] == {"bas": "13:00", "bit": "14:00"}
    assert [(b["berber_id"], b["bas_saat"], b["aciklama"]) for b in v["blokeler"]] == [(veri["veli"], "16:00", "Doktor")]
    pazar_b = client.get("/panel/akis", params={"tarih": "2026-10-11"}, headers=auth("isletme-b")).json()
    assert pazar_b["mesai"] is None  # salon B Pazar kapalı
