"""İşletme sahibine ve berbere giden anlık bildirimler (yeni randevu, müşteri iptali)."""
import pytest

import models
from bildirim import gonderilenler
from conftest import YARIN, auth, randevu_al


@pytest.fixture
def cihazlar(db, veri):
    """İşletme sahipleri ve Ali'nin personel hesabı cihaz kaydetmiş; Veli'nin hesabı yok."""
    db.get(models.Berber, veri["ali"]).firebase_uid = "ali-uid"
    db.add_all([
        models.Musteri(firebase_uid="isletme-a", fcm_token="tok-isletme-a"),
        models.Musteri(firebase_uid="isletme-b", fcm_token="tok-isletme-b"),
        models.Musteri(firebase_uid="ali-uid", fcm_token="tok-ali"),
    ])
    db.commit()
    return veri


def _panel_bildirimleri():
    return {b["token"]: b for b in gonderilenler if b["veri"].get("type") == "panel_randevu"}


def test_yeni_randevu_isletmeye_ve_berbere_bildirilir(client, cihazlar):
    r = randevu_al(client, "musteri-1", cihazlar["ali"], YARIN, "14:00", [cihazlar["kesim"]])
    assert r.status_code == 200
    giden = _panel_bildirimleri()
    assert set(giden) == {"tok-isletme-a", "tok-ali"}  # başka salonun işletmesi almaz
    b = giden["tok-isletme-a"]
    assert b["baslik"].startswith("Yeni randevu")
    assert "Ahmet Yıldız" in b["mesaj"] and "08.10.2026 14:00" in b["mesaj"] and "Kesim" in b["mesaj"]
    assert b["veri"] == {"type": "panel_randevu", "randevu_id": r.json()["randevu_id"], "tarih": YARIN}


def test_baska_berberin_randevusu_personele_gitmez(client, cihazlar):
    randevu_al(client, "musteri-1", cihazlar["veli"], YARIN, "14:00", [cihazlar["kesim"]])
    assert set(_panel_bildirimleri()) == {"tok-isletme-a"}


def test_musteri_iptali_isletmeye_bildirilir(client, cihazlar):
    rid = randevu_al(client, "musteri-1", cihazlar["ali"], YARIN, "14:00", [cihazlar["kesim"]]).json()["randevu_id"]
    gonderilenler.clear()
    assert client.post(f"/randevular/{rid}/iptal", headers=auth("musteri-1")).status_code == 200
    giden = _panel_bildirimleri()
    assert set(giden) == {"tok-isletme-a", "tok-ali"}
    assert giden["tok-isletme-a"]["baslik"] == "Randevu iptal edildi"


def test_panelden_eklenen_randevu_bildirim_uretmez(client, cihazlar):
    r = client.post("/panel/randevular", headers=auth("isletme-a"), json={
        "berber_id": cihazlar["ali"], "tarih": YARIN, "saat": "15:00", "hizmet_ids": [cihazlar["kesim"]],
        "musteri_ad": "Kapı Müşterisi", "musteri_telefon": "05329998877"})
    assert r.status_code == 200, r.text
    assert _panel_bildirimleri() == {}


def test_isletme_kendi_iptalinde_kendine_bildirim_almaz(client, cihazlar):
    rid = randevu_al(client, "musteri-1", cihazlar["ali"], YARIN, "14:00", [cihazlar["kesim"]]).json()["randevu_id"]
    gonderilenler.clear()
    client.patch(f"/panel/randevular/{rid}/durum", headers=auth("isletme-a"), json={"durum": "iptal"})
    assert _panel_bildirimleri() == {}
    assert any(b["token"] == "tok-1" for b in gonderilenler)  # müşteriye gider
