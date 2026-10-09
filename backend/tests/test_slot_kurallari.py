"""Saf slot/çakışma fonksiyonları (DB'siz)."""
import pytest

import slot_servisi as ss


@pytest.mark.parametrize("sure,beklenen", [(15, 30), (30, 30), (40, 60), (45, 60), (60, 60), (90, 90), (120, 120)])
def test_blok_dk_yukari_yuvarlar(sure, beklenen):
    assert ss.blok_dk(sure, 30) == beklenen


def test_bitisik_araliklar_cakismaz():
    assert not ss.cakisiyor(600, 630, 630, 660)
    assert ss.cakisiyor(600, 660, 630, 690)
    assert ss.cakisiyor(600, 700, 620, 640)  # içerilen


def test_kapanisa_sigmayan_baslangic_onerilmez():
    # 09:00-21:00, 60 dk hizmet → son başlangıç 20:00
    bas = ss.musait_baslangiclar(9 * 60, 21 * 60, 60, [], slot=30)
    assert bas[0] == 9 * 60
    assert bas[-1] == 20 * 60
    # 30 dk hizmet → 20:30 da olur
    assert ss.musait_baslangiclar(9 * 60, 21 * 60, 30, [], slot=30)[-1] == 20 * 60 + 30


def test_yetersiz_ardisik_bosluk_onerilmez():
    # 14:00-15:00 arası boş (2 slot), geri kalan dolu; 180 dk hizmet hiçbir yere sığmaz
    dolu = [(9 * 60, 14 * 60), (15 * 60, 21 * 60)]
    assert ss.musait_baslangiclar(9 * 60, 21 * 60, 180, dolu, slot=30) == []
    assert ss.musait_baslangiclar(9 * 60, 21 * 60, 60, dolu, slot=30) == [14 * 60]


def test_mevcut_randevuyla_cakisan_baslangic_elenir():
    dolu = [(16 * 60 + 30, 17 * 60 + 30)]  # 16:30-17:30
    bas = ss.musait_baslangiclar(9 * 60, 21 * 60, 60, dolu, slot=30)
    assert 16 * 60 not in bas          # 16:00-17:00 çakışır
    assert 16 * 60 + 30 not in bas
    assert 17 * 60 not in bas
    assert 17 * 60 + 30 in bas         # hemen bitişte başlayabilir
    assert 15 * 60 + 30 in bas         # 15:30-16:30 bitişik, çakışmaz


def test_gecmis_saatler_elenir():
    bas = ss.musait_baslangiclar(9 * 60, 21 * 60, 30, [], en_erken_dk=12 * 60 + 10, slot=30)
    assert bas[0] == 12 * 60 + 30
    # tam şu an başlayan slot da geçmiş sayılır
    bas = ss.musait_baslangiclar(9 * 60, 21 * 60, 30, [], en_erken_dk=12 * 60 + 30, slot=30)
    assert bas[0] == 13 * 60
