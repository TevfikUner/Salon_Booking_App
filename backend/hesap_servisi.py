"""Hesap silme (KVKK / Google Play). Uygulama içi silme ve web talebi aynı işlevi kullanır."""
import logging

from sqlalchemy.orm import Session

import models
import randevu_servisi as rs
from config import ayarlar
from zaman import simdi

log = logging.getLogger("premium_berber.hesap")


def hesabi_anonimlestir(db: Session, uid: str) -> bool:
    """Kişisel verileri siler, gelecek randevuları iptal eder. Geçmiş randevular salonun muhasebesi için
    kimliksiz kalır. Firebase kullanıcısının kendisi istemcide (veya araclar.py ile) silinir.
    Bir şey bulunup anonimleştirildiyse True döner."""
    bulundu = False
    m = db.query(models.Musteri).filter(models.Musteri.firebase_uid == uid).first()
    if m:
        bulundu = True
        an = simdi()
        for r in db.query(models.Randevu).filter(models.Randevu.musteri_id == m.id,
                                                 models.Randevu.durum == "onaylandi").all():
            if (r.tarih, r.saat) >= (an.date().isoformat(), an.strftime("%H:%M")):
                rs._iptal_et(db, r, "musteri")
        m.ad, m.soyad, m.telefon = "Silinmiş", "Kullanıcı", ""
        m.firebase_uid = None
        m.fcm_token = None
        m.ticari_ileti_izni = False
        if m.foto_url:
            from depolama import depolama
            depolama().sil(m.foto_url)
            m.foto_url = None
        m.silindi = True
        m.favori_berberler.clear()
        db.query(models.BeklemeListesi).filter(models.BeklemeListesi.musteri_id == m.id).delete()
        db.query(models.MusteriNotu).filter(models.MusteriNotu.musteri_id == m.id).delete()
        db.query(models.Degerlendirme).filter(models.Degerlendirme.musteri_id == m.id).update({"yorum": None})
        # Yorumun randevu kaydındaki kopyası ve müşterinin randevuya bıraktığı notlar
        db.query(models.Randevu).filter(models.Randevu.musteri_id == m.id).update({"yorum": None, "notlar": None})

    isletme = db.query(models.Isletme).filter(models.Isletme.firebase_uid == uid).first()
    if isletme:
        bulundu = True
        isletme.firebase_uid = None
        isletme.ad, isletme.soyad, isletme.telefon, isletme.email = "Silinmiş", "Kullanıcı", "", ""
        isletme.durum = "reddedildi"

    for b in db.query(models.Berber).filter(models.Berber.firebase_uid == uid).all():
        bulundu = True
        b.firebase_uid = None
        b.email = None
    if db.query(models.Yonetici).filter(models.Yonetici.firebase_uid == uid).delete():
        bulundu = True
    db.commit()
    return bulundu


def silme_talebini_tamamla(db: Session, talep: models.HesapSilmeTalebi) -> None:
    talep.durum = "tamamlandi"
    talep.aciklama = ((talep.aciklama or "") + f" [tamamlandı {simdi().isoformat(timespec='minutes')}]").strip()
    db.commit()


def firebase_kullanicisini_sil(uid: str) -> bool:
    """Firebase kullanıcısını sunucuda siler (AUTH_MODE=firebase ve servis hesabı varsa). İstemcideki
    `currentUser.delete()` son giriş eskiyse (requires-recent-login) başarısız olur; sunucu tarafı bu kısıtlamaya
    tabi değildir ve silinen hesabın yenileme token'ı da geçersizleşir. Silindiyse veya zaten yoksa True."""
    if ayarlar().auth_mode != "firebase":
        return False
    from firebase_admin import auth as fb_auth

    from firebase_app import firebase_hazir

    if not firebase_hazir():
        return False
    try:
        fb_auth.delete_user(uid)
    except fb_auth.UserNotFoundError:
        pass
    except Exception as e:  # kişisel veri zaten silindi; istemci kendi tarafında silmeyi dener
        log.warning("Firebase kullanıcısı sunucuda silinemedi", exc_info=e)
        return False
    return True
