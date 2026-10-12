"""Tekrar randevu önerisi: N hafta sonra aynı saat, olağan aralık, dolu saatte yakın saatler, yetki."""
import models
from conftest import auth, randevu_al


def _gecmis(db, veri, tarihler, saat="10:00", uid="musteri-1", hizmet="kesim"):
    m = db.query(models.Musteri).filter_by(firebase_uid=uid).first()
    rler = []
    for t in tarihler:
        r = models.Randevu(musteri_id=m.id, berber_id=veri["ali"], salon_id=veri["a"], tarih=t, saat=saat, sure_dk=30,
                           durum="tamamlandi", toplam_fiyat=300, hizmetler=[db.get(models.Hizmet, veri[hizmet])])
        db.add(r)
        rler.append(r)
    db.commit()
    return rler[-1].id


def _oneri(client, rid, uid="musteri-1", **params):
    return client.get(f"/randevular/{rid}/tekrar-onerisi", headers=auth(uid), params=params)


def test_ayni_saat_bossa_onerilir(client, veri, db):
    rid = _gecmis(db, veri, ["2026-10-01"])  # Çarşamba
    v = _oneri(client, rid, hafta=3).json()
    assert v["hedef_tarih"] == "2026-10-22" and v["ayni_saat_bos"]
    assert v["oneriler"] == [{"tarih": "2026-10-22", "saat": "10:00"}]
    assert v["hizmetler"] == ["Kesim"] and v["liste_fiyati"] == 300 and v["berber_id"] == veri["ali"]
    # Önerilen saatle randevu alınabilir
    assert randevu_al(client, "musteri-1", v["berber_id"], v["oneriler"][0]["tarih"], v["oneriler"][0]["saat"],
                      v["hizmet_ids"]).status_code == 200


def test_olagan_aralik_varsayilan(client, veri, db):
    rid = _gecmis(db, veri, ["2026-08-19", "2026-09-02", "2026-09-16", "2026-09-30"])  # 2 haftada bir
    v = _oneri(client, rid).json()
    assert (v["hafta"], v["olagan_hafta"], v["hedef_tarih"]) == (2, 2, "2026-10-14")
    rid1 = _gecmis(db, veri, ["2026-09-30"], uid="musteri-2")
    assert _oneri(client, rid1, uid="musteri-2").json()["olagan_hafta"] == 3  # geçmiş yetersiz


def test_dolu_saatte_en_yakin_saatler_ve_gecmis_hedef_ileri_alinir(client, veri, db):
    rid = _gecmis(db, veri, ["2026-09-01"])  # 1 hafta sonrası geçmişte → bugünden sonraki Salı
    randevu_al(client, "musteri-2", veri["ali"], "2026-10-13", "10:00", [veri["kesim"]])
    v = _oneri(client, rid, hafta=1).json()
    assert v["hedef_tarih"] == "2026-10-13" and not v["ayni_saat_bos"]
    assert [o["saat"] for o in v["oneriler"]] == ["09:00", "09:30", "10:30"]  # 10:00'a en yakın üç saat
    assert all(o["tarih"] == "2026-10-13" for o in v["oneriler"])


def test_kapali_gunde_sonraki_bos_saatler(client, veri, db):
    rid = _gecmis(db, veri, ["2026-10-04"])  # Pazar
    db.add(models.TatilGunu(salon_id=veri["a"], tarih="2026-10-25", aciklama="Bayram"))
    db.commit()
    v = _oneri(client, rid, hafta=3).json()
    assert v["kapali_neden"] and v["oneriler"][0]["tarih"] == "2026-10-26"


def test_yetki_ve_verilmeyen_hizmet(client, veri, db):
    rid = _gecmis(db, veri, ["2026-10-01"])
    assert _oneri(client, rid, uid="musteri-2").status_code == 403
    assert _oneri(client, rid, hafta=13).status_code == 422
    client.put(f"/panel/personel/{veri['ali']}/hizmetler", headers=auth("isletme-a"),
               json=[{"hizmet_id": veri["kesim"], "veriyor": False}])
    assert _oneri(client, rid).status_code == 400
    db.get(models.Randevu, rid).durum = "iptal"
    db.commit()
    assert _oneri(client, rid).status_code == 400
