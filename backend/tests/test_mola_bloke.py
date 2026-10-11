"""Öğle arası, berber haftalık izin günü ve saatlik bloke: müşteri slotlarını ve panel kaydını kapatır."""
from conftest import YARIN, auth, randevu_al

import models


def _musait(client, veri, berber="ali", tarih=YARIN, hizmet="kesim"):
    v = client.get(f"/randevular/musait-saatler/{veri[berber]}",
                   params=[("tarih", tarih), ("hizmet_ids", veri[hizmet])]).json()
    return v["kapali_neden"], v["musait_saatler"]


def _salon_ayari(client, **ek):
    s = client.get("/panel/salon", headers=auth("isletme-a")).json()
    govde = {k: s[k] for k in ("ad", "adres", "telefon", "whatsapp", "instagram_url", "acilis_saati", "kapanis_saati",
                               "pazar_acilis_saati", "pazar_kapanis_saati", "kapali_gunler")} | ek
    return client.put("/panel/salon", headers=auth("isletme-a"), json=govde)


def test_ogle_arasi_slotlari_kapatir_ve_tasan_hizmeti_reddeder(client, veri):
    r = _salon_ayari(client, mola_baslangic="13:00", mola_bitis="14:00")
    assert r.status_code == 200 and r.json()["mola_baslangic"] == "13:00"
    _, musait = _musait(client, veri)
    assert "12:30" in musait and "13:00" not in musait and "13:30" not in musait and "14:00" in musait
    _, sakal = _musait(client, veri, hizmet="sakal")  # 45 dk → 60 dk blok: 12:30 molaya taşar
    assert "12:00" in sakal and "12:30" not in sakal
    assert randevu_al(client, "musteri-1", veri["ali"], YARIN, "13:00", [veri["kesim"]]).status_code == 409


def test_mola_eski_istemci_gondermezse_korunur_null_ile_kaldirilir(client, veri):
    _salon_ayari(client, mola_baslangic="13:00", mola_bitis="14:00")
    assert _salon_ayari(client).json()["mola_baslangic"] == "13:00"  # alan gönderilmedi
    assert _salon_ayari(client, mola_baslangic=None, mola_bitis=None).json()["mola_baslangic"] is None
    assert "13:00" in _musait(client, veri)[1]


def test_mola_dogrulama(client, veri):
    assert _salon_ayari(client, mola_baslangic="13:00").status_code == 422
    assert _salon_ayari(client, mola_baslangic="14:00", mola_bitis="13:00").status_code == 422
    assert _salon_ayari(client, kapali_gunler="7").status_code == 422


def test_berber_haftalik_izin_gunu(client, veri):
    p = client.get("/panel/personel", headers=auth("isletme-a")).json()[0]
    r = client.put(f"/panel/personel/{p['id']}", headers=auth("isletme-a"),
                   json={"ad": p["ad"], "soyad": p["soyad"], "uzmanlik": p["uzmanlik"], "kapali_gunler": "3,3,0"})
    assert r.status_code == 200 and r.json()["kapali_gunler"] == "0,3"
    neden, musait = _musait(client, veri)
    assert neden == "Seçilen personel bu gün çalışmıyor." and musait == []
    takvim = client.get("/randevular/musait-takvim", params={"berber_id": veri["ali"]}).json()
    assert YARIN not in {g["tarih"] for g in takvim}
    assert _musait(client, veri, berber="veli")[0] is None  # diğer berber çalışıyor
    # alan gönderilmeyen güncelleme haftalık izni silmez
    client.put(f"/panel/personel/{p['id']}", headers=auth("isletme-a"), json={"ad": "Ali", "soyad": "Usta"})
    assert client.get("/panel/personel", headers=auth("isletme-a")).json()[0]["kapali_gunler"] == "0,3"
    assert client.put(f"/panel/personel/{p['id']}", headers=auth("isletme-a"),
                      json={"ad": "Ali", "kapali_gunler": "x"}).status_code == 422


def test_saatlik_bloke_ekle_listele_sil(client, veri, db):
    randevu_al(client, "musteri-1", veri["ali"], YARIN, "15:00", [veri["kesim"]])
    r = client.post("/panel/bloke", headers=auth("isletme-a"), json={
        "berber_id": veri["ali"], "tarih": YARIN, "bas_saat": "14:00", "bit_saat": "16:00", "aciklama": "Doktor"})
    assert r.status_code == 200 and r.json()["etkilenen_randevu"] == 1
    _, musait = _musait(client, veri)
    assert "13:30" in musait and not {"14:00", "14:30", "15:30"} & set(musait) and "16:00" in musait
    assert "14:00" in _musait(client, veri, berber="veli")[1]
    # panelden de o saate randevu girilemez
    walkin = client.post("/panel/randevular", headers=auth("isletme-a"), json={
        "berber_id": veri["ali"], "tarih": YARIN, "saat": "14:00", "hizmet_ids": [veri["kesim"]],
        "musteri_ad": "Kapı Müşterisi"})
    assert walkin.status_code == 409
    liste = client.get("/panel/tatil", headers=auth("isletme-a")).json()["blokeler"]
    assert [(b["bas_saat"], b["bit_saat"], b["berber"]) for b in liste] == [("14:00", "16:00", "Ali Usta")]
    assert client.delete(f"/panel/bloke/{liste[0]['id']}", headers=auth("isletme-b")).status_code == 404
    assert client.delete(f"/panel/bloke/{liste[0]['id']}", headers=auth("isletme-a")).status_code == 200
    assert "14:00" in _musait(client, veri)[1]


def test_bloke_dogrulama_ve_yetki(client, veri, db):
    govde = {"berber_id": veri["ali"], "tarih": YARIN, "bas_saat": "16:00", "bit_saat": "14:00"}
    assert client.post("/panel/bloke", headers=auth("isletme-a"), json=govde).status_code == 400
    assert client.post("/panel/bloke", headers=auth("isletme-a"),
                       json=govde | {"tarih": "2026-10-01", "bit_saat": "17:00"}).status_code == 400
    assert client.post("/panel/bloke", headers=auth("isletme-b"),
                       json=govde | {"bit_saat": "17:00"}).status_code == 404  # başka salonun personeli
    db.get(models.Berber, veri["ali"]).firebase_uid = "ali-uid"
    db.commit()
    assert client.post("/panel/bloke", headers=auth("ali-uid"),
                       json=govde | {"bit_saat": "17:00"}).status_code == 403  # personel yönetici değil
