"""Randevuyu takvime ekleme (.ics): içerik, RFC 5545 kaçış ve satır katlama, yalnızca sahibine."""
from conftest import YARIN, auth, randevu_al

import models
from takvim_dosyasi import kacis, katla


def _ics(client, rid, uid="musteri-1"):
    return client.get(f"/randevular/{rid}/takvim.ics", headers=auth(uid))


def _acilmis(metin: str) -> str:
    """Katlanmış satırları birleştirir (RFC 5545 §3.1)."""
    return metin.replace("\r\n ", "")


def test_ics_icerik_ve_basliklar(client, veri, db):
    s = db.get(models.Salon, veri["a"])
    s.adres, s.telefon = "Bağdat Cad. No: 5, Kadıköy", "02161112233"
    db.commit()
    rid = randevu_al(client, "musteri-1", veri["ali"], YARIN, "14:00", [veri["sakal"]]).json()["randevu_id"]
    r = _ics(client, rid)
    assert r.status_code == 200
    assert r.headers["content-type"].startswith("text/calendar")
    assert f'filename="randevu-{rid}.ics"' in r.headers["content-disposition"]
    metin = r.text
    assert metin.startswith("BEGIN:VCALENDAR\r\n") and metin.endswith("END:VCALENDAR\r\n")
    assert all(len(sat.encode()) <= 75 for sat in metin.split("\r\n"))
    a = _acilmis(metin)
    assert f"UID:randevu-{rid}@premiumberber" in a
    assert "DTSTART;TZID=Europe/Istanbul:20261008T140000" in a
    assert "DTEND;TZID=Europe/Istanbul:20261008T144500" in a  # 45 dk hizmet
    assert "SUMMARY:Salon A — Sakal & Kesim" in a
    assert "LOCATION:Bağdat Cad. No: 5\\, Kadıköy" in a
    assert "Berber: Ali Usta\\nHizmetler: Sakal & Kesim\\nToplam: 450 TL\\nSalon telefonu: 02161112233" in a
    assert "TRIGGER:-PT60M" in a and "STATUS:CONFIRMED" in a and "SEQUENCE:0" in a


def test_erteleme_ve_iptal_takvime_yansir(client, veri):
    rid = randevu_al(client, "musteri-1", veri["ali"], YARIN, "14:00", [veri["kesim"]]).json()["randevu_id"]
    client.post(f"/randevular/{rid}/ertele", headers=auth("musteri-1"), json={"tarih": YARIN, "saat": "16:00"})
    a = _acilmis(_ics(client, rid).text)
    assert "DTSTART;TZID=Europe/Istanbul:20261008T160000" in a and "SEQUENCE:1" in a
    client.post(f"/randevular/{rid}/iptal", headers=auth("musteri-1"))
    assert "STATUS:CANCELLED" in _ics(client, rid).text


def test_ics_yalnizca_sahibine(client, veri):
    rid = randevu_al(client, "musteri-1", veri["ali"], YARIN, "14:00", [veri["kesim"]]).json()["randevu_id"]
    assert _ics(client, rid, uid="musteri-2").status_code == 403
    assert client.get(f"/randevular/{rid}/takvim.ics").status_code == 401
    assert _ics(client, 99999).status_code == 404


def test_kacis_ve_katlama_utf8_bolmez():
    assert kacis("a;b,c\\d\ne") == "a\\;b\\,c\\\\d\\ne"
    uzun = "DESCRIPTION:" + "ğ" * 100  # her ğ 2 bayt
    parcalar = katla(uzun)
    assert all(len(p.encode()) <= 75 for p in parcalar)
    assert all(p.startswith(" ") for p in parcalar[1:])
    assert "".join(p.removeprefix(" ") if i else p for i, p in enumerate(parcalar)) == uzun
