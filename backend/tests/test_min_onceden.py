"""Salonun "en az önceden" randevu süresi: müşteri slotları, takvim, erteleme; panel muaf."""
from conftest import YARIN, auth, randevu_al

BUGUN = "2026-10-07"  # sabit an 12:10
ISL = auth("isletme-a")


def _ayarla(client, dk):
    s = client.get("/panel/salon", headers=ISL).json()
    govde = {k: s[k] for k in ("ad", "adres", "telefon", "whatsapp", "instagram_url", "acilis_saati", "kapanis_saati",
                               "pazar_acilis_saati", "pazar_kapanis_saati", "kapali_gunler")}
    return client.put("/panel/salon", headers=ISL, json=govde | {"min_onceden_dk": dk})


def _musait(client, veri, tarih=BUGUN):
    return client.get(f"/randevular/musait-saatler/{veri['ali']}",
                      params=[("tarih", tarih), ("hizmet_ids", veri["kesim"])]).json()


def test_varsayilan_sinir_yok(client, veri):
    m = _musait(client, veri)
    assert m["min_onceden_dk"] == 0 and m["musait_saatler"][0] == "12:30"


def test_bir_saat_once_musteri_icin_kapali_panel_icin_acik(client, veri):
    assert _ayarla(client, 60).json()["min_onceden_dk"] == 60
    m = _musait(client, veri)
    assert m["musait_saatler"][0] == "13:30" and m["min_onceden_dk"] == 60  # 12:10 + 60 = 13:10 → 13:30
    assert randevu_al(client, "musteri-1", veri["ali"], BUGUN, "13:00", [veri["kesim"]]).status_code == 409
    assert randevu_al(client, "musteri-1", veri["ali"], BUGUN, "13:30", [veri["kesim"]]).status_code == 200
    p = client.get("/panel/musait-saatler", headers=ISL,
                   params=[("berber_id", veri["ali"]), ("tarih", BUGUN), ("hizmet_ids", veri["kesim"])]).json()
    assert p["musait_saatler"][0] == "12:30"
    r = client.post("/panel/randevular", headers=ISL, json={"berber_id": veri["ali"], "tarih": BUGUN, "saat": "12:30",
                                                           "hizmet_ids": [veri["kesim"]], "musteri_ad": "Kapı"})
    assert r.status_code == 200


def test_bir_gun_once_bugun_takvimde_yok_yarin_ogleden_sonra(client, veri):
    _ayarla(client, 24 * 60)
    gunler = [g["tarih"] for g in client.get("/randevular/musait-takvim", params={"berber_id": veri["ali"]}).json()]
    assert BUGUN not in gunler and YARIN in gunler
    assert _musait(client, veri)["musait_saatler"] == []
    assert _musait(client, veri, YARIN)["musait_saatler"][0] == "12:30"
    en_yakin = client.get(f"/randevular/en-yakin/{veri['ali']}", params=[("hizmet_ids", veri["kesim"])]).json()
    assert en_yakin["slotlar"][0] == {"tarih": YARIN, "saat": "12:30"}


def test_erteleme_de_sinira_uyar(client, veri):
    rid = randevu_al(client, "musteri-1", veri["ali"], YARIN, "15:00", [veri["kesim"]]).json()["randevu_id"]
    _ayarla(client, 120)
    r = client.post(f"/randevular/{rid}/ertele", headers=auth("musteri-1"), json={"tarih": BUGUN, "saat": "13:00"})
    assert r.status_code == 409
    assert client.post(f"/randevular/{rid}/ertele", headers=auth("musteri-1"),
                       json={"tarih": BUGUN, "saat": "14:30"}).status_code == 200


def test_dogrulama(client, veri):
    assert _ayarla(client, 10081).status_code == 422
    assert _ayarla(client, -5).status_code == 422
    assert _ayarla(client, 30).status_code == 200
    s = client.get("/panel/salon", headers=ISL).json()
    govde = {k: s[k] for k in ("ad", "adres", "telefon", "whatsapp", "instagram_url", "acilis_saati", "kapanis_saati",
                               "pazar_acilis_saati", "pazar_kapanis_saati", "kapali_gunler")}
    assert client.put("/panel/salon", headers=ISL, json=govde).json()["min_onceden_dk"] == 30  # gönderilmezse korunur
