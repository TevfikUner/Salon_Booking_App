"""İngilizce arayüz: Accept-Language: en ile sunucu mesajları İngilizce; başlıksız Türkçe."""
import os
import re

import ceviri
from conftest import YARIN, auth, randevu_al

EN = {"Accept-Language": "en-US,en;q=0.9"}


def test_hata_mesaji_ingilizce_turkce_degismez(client, veri):
    assert client.get("/salonlar/9999", headers=EN).json()["detail"] == "Salon not found."
    assert client.get("/salonlar/9999").json()["detail"] == "Salon bulunamadı."
    assert client.get("/salonlar/9999", headers={"Accept-Language": "tr-TR"}).json()["detail"] == "Salon bulunamadı."


def test_cakisma_409_mesaji_ve_oneriler(client, veri):
    randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["kesim"]])
    params = [("berber_id", veri["ali"]), ("tarih", YARIN), ("saat", "10:00"), ("hizmet_ids", veri["kesim"])]
    r = client.post("/randevular/olustur", params=params, headers=auth("musteri-2") | EN)
    assert r.status_code == 409
    d = r.json()["detail"]
    assert d["mesaj"] == "The selected time (10:00) is no longer available. The service takes 30 min."
    assert d["oneriler"]  # dokunulmaz


def test_kapali_neden_kampanya_kosulu_indirim_aciklamasi(client, veri):
    m = client.get(f"/randevular/musait-saatler/{veri['ali']}", headers=EN,
                   params=[("tarih", "2026-10-01"), ("hizmet_ids", veri["kesim"])]).json()
    assert m["kapali_neden"] == "You can't book a past date."
    client.post("/panel/kampanyalar", headers=auth("isletme-a"),
                json={"ad": "Thursday Deal", "yuzde": 20, "gunler": "3", "bas_saat": "10:00", "bit_saat": "12:00"})
    d = client.get(f"/salonlar/{veri['a']}", headers=EN).json()
    assert d["kampanyalar"][0]["kosul"] == "Thursday · 10:00–12:00"
    assert client.get(f"/salonlar/{veri['a']}").json()["kampanyalar"][0]["kosul"] == "Perşembe · 10:00–12:00"
    params = [("berber_id", veri["ali"]), ("tarih", YARIN), ("saat", "10:00"), ("hizmet_ids", veri["kesim"])]
    r = client.post("/randevular/olustur", params=params, headers=auth("musteri-1") | EN).json()
    assert r["mesaj"] == "Appointment booked!" and r["indirim_aciklama"] == "Thursday Deal 20% off"


def test_json_disi_yanit_ve_dogrulama_hatasi(client, veri):
    rid = randevu_al(client, "musteri-1", veri["ali"], YARIN, "10:00", [veri["kesim"]]).json()["randevu_id"]
    ics = client.get(f"/randevular/{rid}/takvim.ics", headers=auth("musteri-1") | EN)
    assert ics.headers["content-type"].startswith("text/calendar") and "BEGIN:VCALENDAR" in ics.text
    r = client.post("/panel/kampanyalar", headers=auth("isletme-a") | EN, json={"ad": "K", "yuzde": 99})
    assert r.status_code == 422 and r.json()["detail"] == "Please check the information you entered."


def test_desenler():
    assert ceviri.cevir("Sadakat kartı: 6. ziyaret %50") == "Loyalty card: visit 6, 50% off"
    assert ceviri.cevir("Salon bu gün kapalı (Tadilat).") == "The salon is closed on this day (Tadilat)."
    assert ceviri.cevir("Ali şu hizmeti vermiyor: Damat.") == "Ali doesn't offer: Damat."
    assert ceviri.cevir("Bilinmeyen mesaj") == "Bilinmeyen mesaj"


def test_kaynaktaki_sabit_mesajlarin_hepsi_cevrilmis():
    """Yeni bir kullanıcı mesajı eklenip kataloğa yazılmazsa İngilizce arayüzde Türkçe kalır → test düşer."""
    kok = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    eski_uclar = {"dukkan.py", "kurumsal.py", "tatil.py", "berberler.py", "hizmetler.py", "isletmeler.py"}
    desen = re.compile(r'(?:detail=|is_kurali_hatasi\(|"mesaj": |"uyari": |sonuc\[gun\] = )"([^"{}]+)"')
    eksik = []
    for klasor in (kok, os.path.join(kok, "routers")):
        for ad in os.listdir(klasor):
            if not ad.endswith(".py") or ad in eski_uclar:
                continue
            with open(os.path.join(klasor, ad), encoding="utf-8") as f:
                kaynak = f.read()
            for metin in desen.findall(kaynak):
                if ceviri.cevir(metin) == metin:
                    eksik.append(f"{ad}: {metin}")
    assert not eksik, eksik
