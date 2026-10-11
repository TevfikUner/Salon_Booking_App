"""Müşterinin randevu ertelemesi: kurallar, çakışma, kendi aralığı, limit, bildirimler."""
import models
import randevu_servisi as rs
from bildirim import gonderilenler
from conftest import YARIN, auth, randevu_al

SONRAKI = "2026-10-09"  # Cuma


def _al(client, veri, saat="14:00", hizmet="kesim", uid="musteri-1", tarih=YARIN, berber="ali"):
    r = randevu_al(client, uid, veri[berber], tarih, saat, [veri[hizmet]])
    assert r.status_code == 200, r.text
    return r.json()["randevu_id"]


def _ertele(client, rid, tarih, saat, uid="musteri-1", anahtar=None):
    h = auth(uid) | ({"Idempotency-Key": anahtar} if anahtar else {})
    return client.post(f"/randevular/{rid}/ertele", headers=h, json={"tarih": tarih, "saat": saat})


def test_erteleme_tasir_sayaci_ve_hatirlatmayi_gunceller(client, veri, db):
    rid = _al(client, veri)
    db.get(models.Randevu, rid).hatirlatma_gonderildi = True
    db.commit()
    r = _ertele(client, rid, SONRAKI, "16:30")
    assert r.status_code == 200, r.text
    assert r.json()["randevu"]["tarih"] == SONRAKI and r.json()["randevu"]["erteleme_hakki"] == 1
    db.expire_all()
    k = db.get(models.Randevu, rid)
    assert (k.tarih, k.saat, k.erteleme_sayisi, k.hatirlatma_gonderildi) == (SONRAKI, "16:30", 1, False)
    assert k.sure_dk == 30 and k.toplam_fiyat == 300  # süre ve fiyat mühürlü kalır
    # eski saat başkasına açıldı
    assert randevu_al(client, "musteri-2", veri["ali"], YARIN, "14:00", [veri["kesim"]]).status_code == 200


def test_dolu_saate_erteleme_409_ve_oneri(client, veri):
    rid = _al(client, veri)
    _al(client, veri, saat="16:00", uid="musteri-2", tarih=SONRAKI)
    r = _ertele(client, rid, SONRAKI, "16:00")
    assert r.status_code == 409
    assert r.json()["detail"]["oneriler"]


def test_kendi_araligiyla_cakisan_kaydirma_yapilabilir(client, veri):
    """120 dk'lık randevu 30 dk ileri kaydırılınca kendi eski aralığıyla çakışma sayılmamalı."""
    rid = _al(client, veri, hizmet="damat")
    assert _ertele(client, rid, YARIN, "14:30").status_code == 200


def test_erteleme_limiti(client, veri):
    rid = _al(client, veri)
    assert _ertele(client, rid, YARIN, "15:00").status_code == 200
    assert _ertele(client, rid, YARIN, "16:00").status_code == 200
    r = _ertele(client, rid, YARIN, "17:00")
    assert r.status_code == 400 and "en fazla 2" in r.json()["detail"]


def test_son_30_dk_ve_aktif_olmayan_randevu_ertelenemez(client, veri):
    bugun = _al(client, veri, saat="12:30", tarih="2026-10-07")  # sabit an 12:10
    r = _ertele(client, bugun, YARIN, "15:00")
    assert r.status_code == 400 and "ertelenemez" in r.json()["detail"]
    rid = _al(client, veri, saat="18:00")
    client.post(f"/randevular/{rid}/iptal", headers=auth("musteri-1"))
    assert _ertele(client, rid, YARIN, "19:00").status_code == 400
    assert _ertele(client, _al(client, veri, saat="10:00"), YARIN, "10:00").status_code == 400  # aynı saat


def test_baskasinin_randevusu_ertelenemez(client, veri):
    rid = _al(client, veri)
    assert _ertele(client, rid, YARIN, "15:00", uid="musteri-2").status_code == 403


def test_ayni_anahtarla_tekrar_tek_erteleme(client, veri, db):
    rid = _al(client, veri)
    a = _ertele(client, rid, YARIN, "15:00", anahtar="ertele-1")
    b = _ertele(client, rid, YARIN, "15:00", anahtar="ertele-1")
    assert a.status_code == b.status_code == 200
    db.expire_all()
    assert db.get(models.Randevu, rid).erteleme_sayisi == 1


def test_erteleme_eski_gunu_bekleme_listesine_acar_ve_isletmeye_bildirir(client, veri, db, monkeypatch):
    db.add(models.Musteri(firebase_uid="isletme-a", fcm_token="tok-isletme-a"))
    db.commit()
    rid = _al(client, veri)
    acilan = []
    monkeypatch.setattr(rs, "bekleme_listesine_haber_ver", lambda _db, berber_id, tarih: acilan.append(tarih))
    gonderilenler.clear()
    assert _ertele(client, rid, SONRAKI, "11:00").status_code == 200
    assert acilan == [YARIN]
    b = [g for g in gonderilenler if g["token"] == "tok-isletme-a"]
    assert b and b[0]["baslik"] == "Randevu ertelendi" and "09.10.2026 11:00" in b[0]["mesaj"]
    assert "önceki: 08.10.2026 14:00" in b[0]["mesaj"]


def test_musait_saatler_ertelenen_randevunun_yerini_bos_gosterir(client, veri):
    rid = _al(client, veri)
    params = [("tarih", YARIN), ("hizmet_ids", veri["kesim"])]
    yol = f"/randevular/musait-saatler/{veri['ali']}"
    assert "14:00" not in client.get(yol, params=params).json()["musait_saatler"]
    v = client.get(yol, params=params + [("ertelenen_id", rid)], headers=auth("musteri-1")).json()
    assert "14:00" in v["musait_saatler"]
    assert client.get(yol, params=params + [("ertelenen_id", rid)], headers=auth("musteri-2")).status_code == 403
    assert client.get(yol, params=params + [("ertelenen_id", rid)]).status_code == 401


def test_menuden_kaldirilan_hizmetli_randevu_ertelenebilir(client, veri, db):
    """Randevudaki hizmet sonradan menüden kaldırılsa da müşteri saatleri görüp erteleyebilmeli (süre mühürlü)."""
    rid = _al(client, veri, hizmet="sakal")
    db.get(models.Hizmet, veri["sakal"]).aktif = False
    db.commit()
    v = client.get(f"/randevular/musait-saatler/{veri['ali']}", headers=auth("musteri-1"),
                   params=[("tarih", YARIN), ("hizmet_ids", veri["sakal"]), ("ertelenen_id", rid)])
    assert v.status_code == 200, v.text
    assert v.json()["toplam_sure_dk"] == 45 and "14:00" in v.json()["musait_saatler"]
    assert _ertele(client, rid, YARIN, "16:00").status_code == 200
