"""Randevu çekirdek akışı: müsaitlik, oluşturma, çakışma, kapalı günler, iptal, bekleme listesi, değerlendirme."""
import threading

import models
import slot_servisi as ss
from bildirim import gonderilenler
from conftest import PAZAR, YARIN, auth, randevu_al
from database import SessionLocal


def test_kimliksiz_randevu_alinamaz(client, veri):
    params = [("berber_id", veri["ali"]), ("tarih", YARIN), ("saat", "10:00"), ("hizmet_ids", veri["kesim"])]
    assert client.post("/randevular/olustur", params=params).status_code == 401
    # eski x-firebase-uid header'ı artık kimlik sayılmaz
    assert client.post("/randevular/olustur", params=params, headers={"x-firebase-uid": "musteri-1"}).status_code == 401


def test_randevu_olusur_salon_sure_fiyat_muhurlenir(client, veri, db):
    r = randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["kesim"], veri["sakal"]])
    assert r.status_code == 200, r.text
    v = r.json()
    assert v["toplam_sure_dk"] == 75 and v["toplam_fiyat"] == 750 and v["bitis"] == "11:15"
    kayit = db.get(models.Randevu, v["randevu_id"])
    assert kayit.salon_id == veri["a"] and kayit.sure_dk == 75
    # hizmet süresi sonradan değişse de mühürlü süre değişmez
    db.get(models.Hizmet, veri["kesim"]).sure = 90
    db.commit()
    db.refresh(kayit)
    assert kayit.sure_dk == 75
    assert any(b["token"] == "tok-1" for b in gonderilenler)


def test_ayni_slota_ikinci_randevu_409_ve_oneri(client, veri):
    assert randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["kesim"]]).status_code == 200
    r = randevu_al(client, "musteri-2", veri["ali"], YARIN, "10:00", [veri["kesim"]])
    assert r.status_code == 409
    assert "10:30" in r.json()["detail"]["oneriler"]
    # başka berber aynı saatte müsait
    assert randevu_al(client, "musteri-2", veri["veli"], YARIN, "10:00", [veri["kesim"]]).status_code == 200


def test_uzun_hizmet_sonraki_slotu_da_kaplar(client, veri):
    # 45 dk → 60 dk blok: 10:00-11:00
    assert randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["sakal"]]).status_code == 200
    assert randevu_al(client, "musteri-2", veri["ali"], YARIN, "10:30", [veri["kesim"]]).status_code == 409
    assert randevu_al(client, "musteri-2", veri["ali"], YARIN, "11:00", [veri["kesim"]]).status_code == 200
    # 09:00'da 120 dk'lık hizmet 10:00'daki randevuyla çakışır
    assert randevu_al(client, "musteri-2", veri["ali"], YARIN, "09:00", [veri["damat"]]).status_code == 409


def test_kapanisa_sigmayan_hizmet_reddedilir(client, veri):
    assert randevu_al(client, "musteri-1", veri["ali"], YARIN, "20:00", [veri["damat"]]).status_code == 409
    assert randevu_al(client, "musteri-1", veri["ali"], YARIN, "20:30", [veri["kesim"]]).status_code == 200
    assert randevu_al(client, "musteri-1", veri["veli"], YARIN, "08:30", [veri["kesim"]]).status_code == 409


def test_gecmis_tarih_ve_saat_reddedilir(client, veri):
    r = randevu_al(client, "musteri-1", veri["ali"], "2026-10-06", "15:00", [veri["kesim"]])
    assert r.status_code == 400 and "Geçmiş" in r.json()["detail"]["mesaj"]
    # bugün 12:10 → 12:00 geçmiş, 12:30 alınabilir
    assert randevu_al(client, "musteri-1", veri["ali"], "2026-10-07", "12:00", [veri["kesim"]]).status_code == 409
    assert randevu_al(client, "musteri-1", veri["ali"], "2026-10-07", "12:30", [veri["kesim"]]).status_code == 200


def test_rezervasyon_ufku_disi_reddedilir(client, veri):
    r = randevu_al(client, "musteri-1", veri["ali"], "2026-11-20", "10:00", [veri["kesim"]])
    assert r.status_code == 400


def test_pazar_mesaisi_ve_kapali_gun(client, veri):
    # Salon A Pazar 10-17
    assert randevu_al(client, "musteri-1", veri["ali"], PAZAR, "09:30", [veri["kesim"]]).status_code == 409
    assert randevu_al(client, "musteri-1", veri["ali"], PAZAR, "16:30", [veri["kesim"]]).status_code == 200
    # Salon B Pazar kapalı
    r = randevu_al(client, "musteri-1", veri["zeki"], PAZAR, "12:00", [veri["b_kesim"]])
    assert r.status_code == 400 and "kapalı" in r.json()["detail"]["mesaj"]


def test_tatil_ve_izin_gunleri_kapali(client, veri, db):
    db.add(models.TatilGunu(salon_id=veri["a"], tarih=YARIN, aciklama="Bayram"))
    db.add(models.BerberIzin(berber_id=veri["zeki"], tarih="2026-10-09"))
    db.commit()
    r = randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["kesim"]])
    assert r.status_code == 400 and "Bayram" in r.json()["detail"]["mesaj"]
    r = randevu_al(client, "musteri-1", veri["zeki"], "2026-10-09", "12:00", [veri["b_kesim"]])
    assert r.status_code == 400 and "izinli" in r.json()["detail"]["mesaj"]
    takvim = client.get("/randevular/musait-takvim", params={"berber_id": veri["ali"]}).json()
    assert YARIN not in [g["tarih"] for g in takvim]
    assert "2026-10-07" in [g["tarih"] for g in takvim]


def test_baska_salonun_hizmeti_kullanilamaz(client, veri):
    r = randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["b_kesim"]])
    assert r.status_code == 404


def test_musait_saatler_ucu_tek_dogruluk_kaynagi(client, veri):
    randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["sakal"]])
    v = client.get(f"/randevular/musait-saatler/{veri['ali']}",
                   params=[("tarih", YARIN), ("hizmet_ids", veri["kesim"])]).json()
    assert v["tum_saatler"][0] == "09:00" and v["tum_saatler"][-1] == "20:30"
    assert "10:00" in v["dolu_slotlar"] and "10:30" in v["dolu_slotlar"]
    assert "11:00" in v["musait_saatler"] and "09:30" in v["musait_saatler"]


def test_eszamanli_rezervasyonda_tek_kazanan(veri):
    sonuc = []

    def dene(uid):
        db = SessionLocal()
        try:
            m = db.query(models.Musteri).filter_by(firebase_uid=uid).one()
            ss.randevu_olustur(db, m, veri["ali"], YARIN, "15:00", [veri["kesim"]])
            sonuc.append("ok")
        except Exception as e:  # HTTPException 409
            sonuc.append(getattr(e, "status_code", str(e)))
        finally:
            db.close()

    threadler = [threading.Thread(target=dene, args=(u,)) for u in ["musteri-1", "musteri-2"] * 4]
    for t in threadler:
        t.start()
    for t in threadler:
        t.join()
    assert sonuc.count("ok") == 1
    assert sonuc.count(409) == 7


def test_iptal_kurallari(client, veri, db):
    rid = randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["kesim"]]).json()["randevu_id"]
    assert client.post(f"/randevular/{rid}/iptal", headers=auth("musteri-2")).status_code == 403
    r = client.post(f"/randevular/{rid}/iptal", headers=auth("musteri-1"))
    assert r.status_code == 200 and r.json()["randevu"]["durum"] == "iptal"
    # iptal edilen slot yeniden alınabilir ve kayıt silinmemiştir
    assert db.get(models.Randevu, rid) is not None
    assert randevu_al(client, "musteri-2", veri["ali"], YARIN, "10:00", [veri["kesim"]]).status_code == 200
    # son 30 dk kuralı: bugün 12:30'daki randevu 12:10'da iptal edilemez
    rid2 = randevu_al(client, "musteri-1", veri["ali"], "2026-10-07", "12:30", [veri["kesim"]]).json()["randevu_id"]
    r = client.post(f"/randevular/{rid2}/iptal", headers=auth("musteri-1"))
    assert r.status_code == 400 and "30" in r.json()["detail"]
    # eski DELETE yolu da soft iptal yapar
    rid3 = randevu_al(client, "musteri-1", veri["veli"], YARIN, "14:00", [veri["kesim"]]).json()["randevu_id"]
    assert client.delete(f"/randevular/sil/{rid3}", headers=auth("musteri-1")).status_code == 200
    assert db.get(models.Randevu, rid3).durum == "iptal"


def test_bekleme_listesi_iptalde_bildirim_alir(client, veri, db):
    # Ali'nin yarınki tüm gününü doldur
    for s in ss.gun_musaitligi(db, db.get(models.Salon, veri["a"]), veri["ali"], YARIN, 30).musait:
        assert randevu_al(client, "musteri-1", veri["ali"], YARIN, s, [veri["kesim"]]).status_code == 200
    v = client.get(f"/randevular/musait-saatler/{veri['ali']}",
                   params=[("tarih", YARIN), ("hizmet_ids", veri["kesim"])]).json()
    assert v["musait_saatler"] == []
    r = client.post("/randevular/bekleme-listesi", headers=auth("musteri-2"),
                    json={"berber_id": veri["ali"], "tarih": YARIN, "hizmet_ids": [veri["kesim"]]})
    assert r.status_code == 200
    gonderilenler.clear()
    rid = db.query(models.Randevu).filter_by(berber_id=veri["ali"], tarih=YARIN, saat="15:00").one().id
    client.post(f"/randevular/{rid}/iptal", headers=auth("musteri-1"))
    bekleme = [b for b in gonderilenler if b["token"] == "tok-2"]
    assert bekleme and "15:00" in bekleme[0]["mesaj"]
    # ikinci iptal aynı kişiye tekrar bildirim göndermez
    gonderilenler.clear()
    rid = db.query(models.Randevu).filter_by(berber_id=veri["ali"], tarih=YARIN, saat="16:00").one().id
    client.post(f"/randevular/{rid}/iptal", headers=auth("musteri-1"))
    assert not [b for b in gonderilenler if b["token"] == "tok-2"]


def test_degerlendirme_kurallari(client, veri, db):
    rid = randevu_al(client, "musteri-2", veri["ali"], YARIN, "10:00", [veri["kesim"]]).json()["randevu_id"]
    params = {"randevu_id": rid, "puan": 4, "yorum": "İyi"}
    assert client.post("/degerlendirmeler/ekle", params=params, headers=auth("musteri-2")).status_code == 400
    db.get(models.Randevu, rid).durum = "tamamlandi"
    db.commit()
    assert client.post("/degerlendirmeler/ekle", params=params, headers=auth("musteri-1")).status_code == 403
    assert client.post("/degerlendirmeler/ekle", params={**params, "puan": 6},
                       headers=auth("musteri-2")).status_code == 400
    assert client.post("/degerlendirmeler/ekle", params=params, headers=auth("musteri-2")).status_code == 200
    assert client.post("/degerlendirmeler/ekle", params=params, headers=auth("musteri-2")).status_code == 400
    db.expire_all()
    assert db.get(models.Randevu, rid).puan == 4
    assert db.get(models.Berber, veri["ali"]).puan == 4.0
    assert db.get(models.Salon, veri["a"]).puan == 4.0
    # soyadı boş müşteri listede hata vermez
    v = client.get(f"/degerlendirmeler/berber/{veri['ali']}").json()
    assert v["yorumlar"][0]["musteri"] == "Mehmet"


def test_benim_randevularim_salon_adi_ve_bitis(client, veri):
    randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["sakal"]])
    v = client.get("/randevular/benim-randevularim", headers=auth("musteri-1")).json()
    assert v[0]["salon_ad"] == "Salon A" and v[0]["bitis"] == "10:45" and v[0]["salon_id"] == veri["a"]


def test_her_zamanki_en_sik_kombinasyon_ve_en_yakin_slot(client, veri, db):
    m = db.query(models.Musteri).filter_by(firebase_uid="musteri-1").one()
    kesim, sakal = db.get(models.Hizmet, veri["kesim"]), db.get(models.Hizmet, veri["sakal"])
    for tarih in ("2026-09-01", "2026-09-15", "2026-09-29"):
        db.add(models.Randevu(musteri_id=m.id, berber_id=veri["ali"], salon_id=veri["a"], tarih=tarih, saat="18:00",
                              sure_dk=45, toplam_fiyat=450, durum="tamamlandi", hizmetler=[sakal]))
    db.add(models.Randevu(musteri_id=m.id, berber_id=veri["veli"], salon_id=veri["a"], tarih="2026-09-20",
                          saat="10:00", sure_dk=30, toplam_fiyat=300, durum="tamamlandi", hizmetler=[kesim]))
    db.commit()
    v = client.get("/randevular/her-zamanki", headers=auth("musteri-1")).json()
    assert v["berber"]["id"] == veri["ali"] and [h["id"] for h in v["hizmetler"]] == [veri["sakal"]]
    assert v["kac_kez"] == 3
    assert v["en_yakin_slotlar"][0] == {"tarih": "2026-10-07", "saat": "12:30"}
    # geçmişi olmayan müşteri
    assert client.get("/randevular/her-zamanki", headers=auth("musteri-2")).json() is None


def test_en_yakin_bos_slot_ucu(client, veri):
    v = client.get(f"/randevular/en-yakin/{veri['ali']}", params=[("hizmet_ids", veri["damat"])]).json()
    assert v["slotlar"][0] == {"tarih": "2026-10-07", "saat": "12:30"}
