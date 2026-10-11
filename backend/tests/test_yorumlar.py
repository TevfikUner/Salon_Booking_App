"""Salon yorumları (dağılım, sayfalama, sıralama) ve berber istatistikleri (tıraş sayısı)."""
from sqlalchemy import event

import models
from database import engine


def _tamamlanan(db, veri, musteri_uid, berber="ali", puan=None, yorum=None, gun=1):
    m = db.query(models.Musteri).filter_by(firebase_uid=musteri_uid).one()
    r = models.Randevu(musteri_id=m.id, berber_id=veri[berber], salon_id=veri["a"], tarih=f"2026-09-{gun:02d}",
                       saat="10:00", sure_dk=30, durum="tamamlandi", toplam_fiyat=300)
    db.add(r)
    db.flush()
    if puan is not None:
        db.add(models.Degerlendirme(musteri_id=m.id, berber_id=r.berber_id, salon_id=r.salon_id, randevu_id=r.id,
                                    puan=puan, yorum=yorum, tarih=r.tarih))
    db.commit()
    return r


def test_salon_yorumlari_dagilim_ve_siralama(client, veri, db):
    _tamamlanan(db, veri, "musteri-1", puan=5, yorum="Harika kesim", gun=1)
    _tamamlanan(db, veri, "musteri-2", berber="veli", puan=3, yorum=None, gun=2)
    _tamamlanan(db, veri, "musteri-2", puan=4, yorum="İyiydi", gun=3)
    v = client.get(f"/degerlendirmeler/salon/{veri['a']}").json()
    assert v["toplam"] == 3 and v["ortalama_puan"] == 4.0
    assert v["dagilim"] == {"5": 1, "4": 1, "3": 1, "2": 0, "1": 0}
    # yorumlu olanlar önce, yeniden eskiye; yorumsuz en sonda
    assert [y["yorum"] for y in v["yorumlar"]] == ["İyiydi", "Harika kesim", None]
    assert v["yorumlar"][0]["musteri"] == "Mehmet" and v["yorumlar"][1]["musteri"] == "Ahmet Y."
    assert v["yorumlar"][2]["berber"] == "Veli Kalfa"
    assert client.get(f"/degerlendirmeler/salon/{veri['b']}").json() == {
        "ortalama_puan": None, "toplam": 0, "dagilim": {"5": 0, "4": 0, "3": 0, "2": 0, "1": 0},
        "sayfa": 1, "sonraki_var": False, "yorumlar": []}


def test_salon_yorumlari_sayfalama_ve_silinmis_musteri(client, veri, db):
    for gun in range(1, 6):
        _tamamlanan(db, veri, "musteri-1", puan=5, yorum=f"Yorum {gun}", gun=gun)
    m = db.query(models.Musteri).filter_by(firebase_uid="musteri-1").one()
    m.silindi = True
    db.commit()
    s1 = client.get(f"/degerlendirmeler/salon/{veri['a']}", params={"adet": 2}).json()
    s3 = client.get(f"/degerlendirmeler/salon/{veri['a']}", params={"adet": 2, "sayfa": 3}).json()
    assert len(s1["yorumlar"]) == 2 and s1["sonraki_var"] is True
    assert len(s3["yorumlar"]) == 1 and s3["sonraki_var"] is False
    assert {y["musteri"] for y in s1["yorumlar"]} == {"Anonim"}


def test_salon_detayinda_berber_tiras_ve_degerlendirme_sayisi(client, veri, db):
    _tamamlanan(db, veri, "musteri-1", puan=5, gun=1)
    _tamamlanan(db, veri, "musteri-2", gun=2)
    berberler = {b["ad"]: b for b in client.get(f"/salonlar/{veri['a']}").json()["berberler"]}
    assert (berberler["Ali"]["tamamlanan"], berberler["Ali"]["degerlendirme_sayisi"]) == (2, 1)
    assert (berberler["Veli"]["tamamlanan"], berberler["Veli"]["degerlendirme_sayisi"]) == (0, 0)
    assert client.get(f"/degerlendirmeler/berber/{veri['ali']}").json()["tamamlanan"] == 2
    liste = {b["ad"]: b for b in client.get("/berberler/", params={"salon_id": veri["a"]}).json()}
    assert (liste["Ali"]["degerlendirme_sayisi"], liste["Veli"]["degerlendirme_sayisi"]) == (1, 0)


def test_salon_detayi_berber_sayisindan_bagimsiz_sorgu(client, veri, db):
    """Sayaçlar berber başına değil, gruplu tek sorguyla gelir (N+1 yok)."""
    def say():
        sayac = []
        dinle = lambda *a, **k: sayac.append(1)  # noqa: E731
        event.listen(engine, "before_cursor_execute", dinle)
        try:
            client.get(f"/salonlar/{veri['a']}")
        finally:
            event.remove(engine, "before_cursor_execute", dinle)
        return len(sayac)
    once = say()
    for i in range(5):
        db.add(models.Berber(ad=f"Ek{i}", salon_id=veri["a"]))
    db.commit()
    assert say() == once
