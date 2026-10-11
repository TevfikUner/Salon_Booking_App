"""Takvimde gün başına boş slot sayısı ve dolu gün işareti (N+1 olmadan)."""
from sqlalchemy import event

import models
from conftest import YARIN, auth
from database import engine


def _takvim(client, veri, hizmet="kesim", berber="ali"):
    params = [("berber_id", veri[berber])] + ([("hizmet_ids", veri[hizmet])] if hizmet else [])
    return {g["tarih"]: g for g in client.get("/randevular/musait-takvim", params=params).json()}


def _gunu_doldur(db, veri, tarih, berber="ali"):
    m = db.query(models.Musteri).filter_by(firebase_uid="musteri-2").one()
    for dk in range(9 * 60, 21 * 60, 30):  # Salon A 09:00–21:00
        db.add(models.Randevu(musteri_id=m.id, berber_id=veri[berber], salon_id=veri["a"], tarih=tarih,
                              saat=f"{dk // 60:02d}:{dk % 60:02d}", sure_dk=30, durum="onaylandi", toplam_fiyat=300))
    db.commit()


def test_dolu_gun_isaretlenir_bos_sayisi_doner(client, veri, db):
    _gunu_doldur(db, veri, YARIN)
    t = _takvim(client, veri)
    assert t[YARIN]["dolu"] is True and t[YARIN]["bos_slot"] == 0
    assert t["2026-10-09"]["bos_slot"] == 24 and t["2026-10-09"]["dolu"] is False  # 09:00–21:00, 30 dk
    assert t["2026-10-07"]["bos_slot"] == 17  # bugün 12:10'dan sonrası: 12:30 … 20:30
    assert _takvim(client, veri, berber="veli")[YARIN]["dolu"] is False


def test_sure_ve_mola_hesaba_katilir(client, veri, db):
    db.get(models.Salon, veri["a"]).mola_baslangic, db.get(models.Salon, veri["a"]).mola_bitis = "13:00", "14:00"
    db.commit()
    client.post("/panel/bloke", headers=auth("isletme-a"), json={
        "berber_id": veri["ali"], "tarih": "2026-10-09", "bas_saat": "09:00", "bit_saat": "12:00"})
    t = _takvim(client, veri, hizmet="damat")  # 120 dk
    # Mola 13–14: sabah 09:00–11:00 arası 5 başlangıç (bitiş ≤ 13:00), öğleden sonra 14:00–19:00 arası 11
    assert t[YARIN]["bos_slot"] == 5 + 11
    # Ayrıca 09:00–12:00 kapalı: sabah 12:00'de başlayan 120 dk molaya taşar → yalnızca öğleden sonra
    assert t["2026-10-09"]["bos_slot"] == 11


def test_hizmet_verilmezse_alanlar_yok_eski_istemci_uyumlu(client, veri):
    t = _takvim(client, veri, hizmet=None)
    assert "bos_slot" not in t[YARIN] and "dolu" not in t[YARIN]


def test_sorgu_sayisi_gun_sayisindan_bagimsiz(client, veri, db):
    sayac = []
    dinle = lambda *a, **k: sayac.append(1)  # noqa: E731
    event.listen(engine, "before_cursor_execute", dinle)
    try:
        _takvim(client, veri)
    finally:
        event.remove(engine, "before_cursor_execute", dinle)
    assert len(sayac) < 15  # 31 gün için gün başına sorgu atılsaydı 60+ olurdu
