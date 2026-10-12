"""Randevu yaşam döngüsü: iptal, durum değişikliği, bekleme listesi, güven skoru, "her zamanki"."""
from collections import Counter
from datetime import date, timedelta
from itertools import pairwise

from fastapi import HTTPException
from sqlalchemy.orm import Session

import models
import slot_servisi as ss
from bildirim import bildirim_gonder
from config import ayarlar
from zaman import simdi


def _tarih_tr(tarih: str) -> str:
    y, a, g = tarih.split("-")
    return f"{g}.{a}.{y}"


# ─────────────────────────── İşletmeye bildirim ───────────────────────────

def salon_bildirim_tokenlari(db: Session, r: models.Randevu) -> list[str]:
    """Randevudan haberdar olması gerekenlerin cihazları: salonun onaylı işletme sahibi ve randevunun berberi.
    İşletme/personel token'ları da `musteriler` tablosunda tutulur (bkz. /musteriler/fcm-token-guncelle)."""
    uidler = {uid for (uid,) in db.query(models.Isletme.firebase_uid).filter(
        models.Isletme.salon_id == r.salon_id, models.Isletme.durum == "onaylandi")}
    if r.berber and r.berber.firebase_uid:
        uidler.add(r.berber.firebase_uid)
    if r.musteri and r.musteri.firebase_uid:
        uidler.discard(r.musteri.firebase_uid)  # kendi işlemini yapan kişiye bildirim gitmesin
    uidler.discard(None)
    if not uidler:
        return []
    return [t for (t,) in db.query(models.Musteri.fcm_token).filter(
        models.Musteri.firebase_uid.in_(uidler), models.Musteri.fcm_token.isnot(None))]


def salona_bildir(db: Session, r: models.Randevu, baslik: str, olay: str, arka_plan=None) -> int:
    """İşletme sahibine ve berbere push gönderir. `arka_plan` (BackgroundTasks) verilirse yanıtı bekletmez."""
    musteri = f"{r.musteri.ad} {r.musteri.soyad}".strip() if r.musteri else "Müşteri"
    berber = f"{r.berber.ad} {r.berber.soyad}".strip() if r.berber else ""
    mesaj = f"{musteri} · {_tarih_tr(r.tarih)} {r.saat} · {berber} — {olay}"
    veri = {"type": "panel_randevu", "randevu_id": r.id, "tarih": r.tarih}
    tokenlar = salon_bildirim_tokenlari(db, r)
    for t in tokenlar:
        if arka_plan is not None:
            arka_plan.add_task(bildirim_gonder, t, baslik, mesaj, veri)
        else:
            bildirim_gonder(t, baslik, mesaj, veri)
    return len(tokenlar)


# ─────────────────────────── İptal, erteleme & durum ───────────────────────────

def _musteri_degistirebilir(r: models.Randevu, eylem: str) -> None:
    """Müşteri iptali ve ertelemesi için ortak kural: aktif, geçmemiş ve son N dakikaya girmemiş randevu."""
    if r.durum != "onaylandi":
        raise HTTPException(status_code=400, detail="Bu randevu zaten aktif değil.")
    kalan_dk = (ss.randevu_baslangic(r) - simdi()).total_seconds() / 60
    if kalan_dk <= 0:
        raise HTTPException(status_code=400, detail=f"Geçmiş bir randevu {eylem}.")
    if kalan_dk < ayarlar().iptal_son_dk:
        raise HTTPException(
            status_code=400,
            detail=f"Randevuya {ayarlar().iptal_son_dk} dakikadan az kaldığı için {eylem}. Lütfen salonu arayın.",
        )


def erteleme_hakki(r: models.Randevu) -> int:
    return max(0, ayarlar().erteleme_limiti - (r.erteleme_sayisi or 0))


def musteri_iptal(db: Session, r: models.Randevu) -> None:
    _musteri_degistirebilir(r, "iptal edilemez")
    _iptal_et(db, r, "musteri")
    salona_bildir(db, r, "Randevu iptal edildi", "müşteri iptal etti, saat artık boş.")


def musteri_ertele(db: Session, r: models.Randevu, tarih: str, saat: str) -> None:
    """Aynı berber, aynı hizmetler ve mühürlü süreyle yeni güne/saate taşır. Eski gün bekleme listesine açılır."""
    _musteri_degistirebilir(r, "ertelenemez")
    if erteleme_hakki(r) <= 0:
        raise HTTPException(status_code=400, detail=f"Bir randevu en fazla {ayarlar().erteleme_limiti} kez "
                                                    "ertelenebilir. İptal edip yeni randevu alabilirsiniz.")
    if (r.tarih, r.saat) == (tarih, saat):
        raise HTTPException(status_code=400, detail="Randevunuz zaten bu gün ve saatte.")
    eski_tarih, eski_saat = r.tarih, r.saat
    ss.randevu_tasi(db, r, tarih, saat)
    bekleme_listesine_haber_ver(db, r.berber_id, eski_tarih)
    salona_bildir(db, r, "Randevu ertelendi", f"önceki: {_tarih_tr(eski_tarih)} {eski_saat}")


def isletme_tasi(db: Session, r: models.Randevu, berber_id: int, tarih: str, saat: str) -> None:
    """İşletmenin randevuyu takvimde taşıması (başka saat/gün/berber). Fiyat ve süre aynı kalır; müşteriye
    bildirim gider, eski günün bekleme listesi açılır. Müşterinin erteleme hakkından düşmez."""
    if r.durum != "onaylandi":
        raise HTTPException(status_code=400, detail="Yalnızca aktif randevular taşınabilir.")
    if ss.randevu_baslangic(r) <= simdi():
        raise HTTPException(status_code=400, detail="Başlamış veya geçmiş bir randevu taşınamaz.")
    if (r.berber_id, r.tarih, r.saat) == (berber_id, tarih, saat):
        raise HTTPException(status_code=400, detail="Randevu zaten bu saatte.")
    eski_berber, eski_tarih, eski_saat = r.berber_id, r.tarih, r.saat
    ss.randevu_tasi(db, r, tarih, saat, berber_id=berber_id, musteri_ertelemesi=False)
    db.refresh(r)
    bekleme_listesine_haber_ver(db, eski_berber, eski_tarih)
    if r.musteri and r.musteri.fcm_token:
        berber = f"{r.berber.ad} {r.berber.soyad}".strip() if r.berber else ""
        bildirim_gonder(r.musteri.fcm_token, "Randevunuz güncellendi",
                        f"{r.salon.ad if r.salon else 'Salon'}: {_tarih_tr(eski_tarih)} {eski_saat} randevunuz "
                        f"{_tarih_tr(r.tarih)} {r.saat}{f' ({berber})' if berber else ''} olarak değiştirildi.",
                        {"type": "randevu", "randevu_id": r.id})


def isletme_iptal(db: Session, r: models.Randevu) -> None:
    if r.durum != "onaylandi":
        raise HTTPException(status_code=400, detail="Bu randevu zaten aktif değil.")
    _iptal_et(db, r, "isletme")
    if r.musteri and r.musteri.fcm_token:
        bildirim_gonder(r.musteri.fcm_token, "Randevunuz iptal edildi",
                        f"{r.salon.ad if r.salon else 'Salon'} {_tarih_tr(r.tarih)} {r.saat} randevunuzu iptal etti. "
                        "Uygulamadan yeni bir saat seçebilirsiniz.", {"type": "randevu", "randevu_id": r.id})


def _iptal_et(db: Session, r: models.Randevu, eden: str) -> None:
    r.durum = "iptal"
    r.iptal_eden = eden
    r.iptal_zamani = simdi().isoformat(timespec="seconds")
    db.commit()
    bekleme_listesine_haber_ver(db, r.berber_id, r.tarih)


def durum_guncelle(db: Session, r: models.Randevu, yeni: str) -> None:
    if yeni not in models.RANDEVU_DURUMLARI:
        raise HTTPException(status_code=400, detail="Geçersiz durum.")
    if yeni == "iptal":
        return isletme_iptal(db, r)
    if yeni in ("tamamlandi", "gelmedi") and ss.randevu_baslangic(r) > simdi():
        raise HTTPException(status_code=400, detail="Henüz başlamamış bir randevu bu şekilde işaretlenemez.")
    r.durum = yeni
    db.commit()
    if yeni == "tamamlandi":
        degerlendirme_iste(db, r)


def degerlendirme_iste(db: Session, r: models.Randevu) -> None:
    if r.degerlendirme_bildirimi_gonderildi or r.puan is not None:
        return
    berber_adi = f"{r.berber.ad} {r.berber.soyad}".strip() if r.berber else "Berberiniz"
    if r.musteri and r.musteri.fcm_token:
        bildirim_gonder(r.musteri.fcm_token, "Sıhhatler olsun! 💈",
                        f"{berber_adi} ile randevunuzu puanlamak ister misiniz?",
                        {"type": "degerlendirme", "randevu_id": r.id, "berber_adi": berber_adi})
    r.degerlendirme_bildirimi_gonderildi = True
    db.commit()


OTOMATIK_TAMAMLAMA_PAYI_DK = 60


def gecmisleri_tamamla(db: Session) -> list[models.Randevu]:
    """Bitişinin üzerinden 1 saat geçmiş ve işletmenin işaretlemediği 'onaylandi' randevuları
    'tamamlandi' yapar. (İşletme bu süre içinde 'gelmedi' işaretleyebilir.)"""
    sinir = simdi()
    adaylar = db.query(models.Randevu).filter(
        models.Randevu.durum == "onaylandi", models.Randevu.tarih <= sinir.date().isoformat()
    ).all()
    tamamlananlar = []
    for r in adaylar:
        try:
            if ss.randevu_baslangic(r) + timedelta(minutes=(r.sure_dk or 30) + OTOMATIK_TAMAMLAMA_PAYI_DK) < sinir:
                r.durum = "tamamlandi"
                tamamlananlar.append(r)
        except ValueError:
            continue
    if tamamlananlar:
        db.commit()
    return tamamlananlar


# ─────────────────────────── Bekleme listesi ───────────────────────────

def bekleme_listesine_haber_ver(db: Session, berber_id: int, tarih: str) -> int:
    """Boşalan gün için bekleyen müşterilerden, süresi artık sığanlara bildirim gönderir."""
    kayitlar = db.query(models.BeklemeListesi).filter(
        models.BeklemeListesi.berber_id == berber_id,
        models.BeklemeListesi.tarih == tarih,
        models.BeklemeListesi.bildirildi.is_(False),
    ).order_by(models.BeklemeListesi.id).all()
    if not kayitlar:
        return 0
    berber = db.get(models.Berber, berber_id)
    if not berber or not berber.salon:
        return 0
    sayi = 0
    for k in kayitlar:
        m = ss.gun_musaitligi(db, berber.salon, berber_id, tarih, k.sure_dk)
        if not m.musait:
            continue
        if k.musteri and k.musteri.fcm_token:
            bildirim_gonder(k.musteri.fcm_token, "Beklediğiniz gün boşaldı! ⏰",
                            f"{berber.ad} {berber.soyad} için {_tarih_tr(tarih)} tarihinde {m.musait[0]} müsait. "
                            "Hemen randevu alın, ilk gelen alır.",
                            {"type": "bekleme", "berber_id": berber_id, "tarih": tarih, "salon_id": berber.salon_id})
        k.bildirildi = True
        sayi += 1
    db.commit()
    return sayi


# ─────────────────────────── Güven skoru (imza özellik) ───────────────────────────

def guven_skoru(db: Session, musteri_id: int) -> dict:
    """Müşterinin geçmiş davranışına göre 0-100 skor.

    - Her 'gelmedi' −30, randevuya 2 saatten az kala müşteri iptali −10, her tamamlanan +5 (tavan 100).
    - Geçmişi olmayan müşteri 'Yeni' etiketi alır.
    """
    gecmis = db.query(models.Randevu).filter(
        models.Randevu.musteri_id == musteri_id,
        models.Randevu.durum.in_(("tamamlandi", "gelmedi", "iptal")),
    ).all()
    tamam = sum(1 for r in gecmis if r.durum == "tamamlandi")
    gelmedi = sum(1 for r in gecmis if r.durum == "gelmedi")
    gec_iptal = 0
    for r in gecmis:
        if r.durum == "iptal" and r.iptal_eden == "musteri" and r.iptal_zamani:
            try:
                from datetime import datetime
                fark = ss.randevu_baslangic(r) - datetime.fromisoformat(r.iptal_zamani)
                if fark < timedelta(hours=2):
                    gec_iptal += 1
            except ValueError:
                pass
    if tamam + gelmedi + gec_iptal == 0:
        return {"skor": None, "etiket": "Yeni", "tamamlanan": 0, "gelmedi": 0, "gec_iptal": 0}
    skor = max(0, min(100, 80 + tamam * 5 - gelmedi * 30 - gec_iptal * 10))
    etiket = "Güvenilir" if skor >= 80 else ("Dikkat" if skor >= 50 else "Riskli")
    return {"skor": skor, "etiket": etiket, "tamamlanan": tamam, "gelmedi": gelmedi, "gec_iptal": gec_iptal}


# ─────────────────────────── Tekrar randevu ───────────────────────────

def olagan_aralik_hafta(db: Session, r: models.Randevu) -> int:
    """Müşterinin bu berbere gelme sıklığı (hafta, 1–8): tamamlanan ziyaretler arası günlerin medyanı.
    Yeterli geçmiş yoksa 3 hafta (berberde en yaygın aralık)."""
    tarihler = sorted({x for (x,) in db.query(models.Randevu.tarih).filter(
        models.Randevu.musteri_id == r.musteri_id, models.Randevu.berber_id == r.berber_id,
        models.Randevu.durum == "tamamlandi")})
    if len(tarihler) < 2:
        return 3
    gunler = sorted((date.fromisoformat(b) - date.fromisoformat(a)).days for a, b in pairwise(tarihler))
    medyan = gunler[len(gunler) // 2]
    return max(1, min(8, round(medyan / 7)))


def tekrar_onerisi(db: Session, r: models.Randevu, hafta: int | None) -> dict:
    """Aynı berber ve hizmetlerle N hafta sonrası için öneri: aynı saat boşsa o; değilse o günün en yakın saatleri,
    gün kapalı/doluysa sonraki en yakın boş saatler. Hedef geçmişte kalırsa aynı haftanın gününe ileri alınır."""
    if r.durum not in ("tamamlandi", "onaylandi"):
        raise HTTPException(status_code=400, detail="Yalnızca alınmış veya tamamlanmış bir randevu tekrarlanabilir.")
    berber = db.query(models.Berber).filter(models.Berber.id == r.berber_id, models.Berber.aktif.is_(True)).first()
    if not berber or not berber.salon or not berber.salon.aktif:
        raise HTTPException(status_code=400, detail="Bu personel artık randevu almıyor.")
    kalemler = ss.hizmet_kalemleri(db, berber.salon_id, [h.id for h in r.hizmetler], berber.id)
    sure = sum(k.sure for k in kalemler)
    varsayilan = olagan_aralik_hafta(db, r)
    hafta = hafta or varsayilan
    hedef = date.fromisoformat(r.tarih) + timedelta(weeks=hafta)
    while hedef <= ss.bugun():
        hedef += timedelta(weeks=1)
    m = ss.gun_musaitligi(db, berber.salon, berber.id, hedef.isoformat(), sure)
    ayni = r.saat in m.musait
    if ayni:
        oneriler = [{"tarih": m.tarih, "saat": r.saat}]
    elif m.musait:
        hedef_dk = ss.saat_dk(r.saat)
        yakin = sorted(m.musait, key=lambda s: abs(ss.saat_dk(s) - hedef_dk))[:3]
        oneriler = [{"tarih": m.tarih, "saat": s} for s in sorted(yakin)]
    else:
        oneriler = ss.en_yakin_slotlar(db, berber.salon, berber.id, sure, 3, baslangic=hedef)
    return {
        "hafta": hafta,
        "olagan_hafta": varsayilan,
        "hedef_tarih": hedef.isoformat(),
        "ayni_saat_bos": ayni,
        "kapali_neden": m.kapali_neden,
        "oneriler": oneriler,
        "berber_id": berber.id,
        "berber": f"{berber.ad} {berber.soyad}".strip(),
        "salon_ad": berber.salon.ad,
        "hizmet_ids": [k.hizmet.id for k in kalemler],
        "hizmetler": [k.hizmet.ad for k in kalemler],
        "toplam_sure_dk": sure,
        "liste_fiyati": sum(k.fiyat for k in kalemler),
    }


# ─────────────────────────── "Her Zamanki" (imza özellik) ───────────────────────────

def her_zamanki(db: Session, musteri: models.Musteri) -> dict | None:
    """Müşterinin en sık aldığı berber + hizmet kombinasyonu ve en yakın boş slotlar."""
    gecmis = db.query(models.Randevu).filter(
        models.Randevu.musteri_id == musteri.id,
        models.Randevu.durum.in_(("tamamlandi", "onaylandi")),
    ).order_by(models.Randevu.tarih.desc(), models.Randevu.saat.desc()).limit(20).all()
    if not gecmis:
        return None
    sayac = Counter((r.berber_id, tuple(sorted(h.id for h in r.hizmetler))) for r in gecmis if r.hizmetler)
    if not sayac:
        return None
    (berber_id, hizmet_ids), kac_kez = sayac.most_common(1)[0]
    berber = db.query(models.Berber).filter(models.Berber.id == berber_id, models.Berber.aktif.is_(True)).first()
    if not berber or not berber.salon or not berber.salon.aktif:
        return None
    try:  # hizmet menüden kalktıysa ya da berber artık bu hizmeti vermiyorsa öneri yok
        kalemler = ss.hizmet_kalemleri(db, berber.salon_id, list(hizmet_ids), berber.id)
    except HTTPException:
        return None
    sure = sum(k.sure for k in kalemler)
    return {
        "berber": {"id": berber.id, "ad": berber.ad, "soyad": berber.soyad, "uzmanlik": berber.uzmanlik,
                   "puan": berber.puan, "foto_url": berber.foto_url},
        "salon": {"id": berber.salon.id, "ad": berber.salon.ad},
        "hizmetler": [{"id": k.hizmet.id, "ad": k.hizmet.ad, "fiyat": k.fiyat, "sure": k.sure} for k in kalemler],
        "toplam_sure_dk": sure,
        "toplam_fiyat": sum(k.fiyat for k in kalemler),
        "kac_kez": kac_kez,
        "en_yakin_slotlar": ss.en_yakin_slotlar(db, berber.salon, berber.id, sure, 3),
    }
