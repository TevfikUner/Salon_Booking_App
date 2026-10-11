"""DEMO verisi yükler (kurgusal salonlar, müşteriler, randevular). ÖNCE: `alembic upgrade head`.

PRODUCTION VERİTABANINA ÇALIŞTIRMAYIN: tüm tabloları siler. Production ortamında (ORTAM=production) çalışmayı reddeder.

    python seed_demo.py

Tüm tabloları temizler ve yeniden doldurur (yalnızca geliştirme/demo için!).
Kendi Firebase hesaplarınızla demo yapmak için UID'leri ortam değişkeniyle verin:
    SEED_ISLETME_UID=<işletme hesabının uid'si>  SEED_MUSTERI_UID=<müşteri hesabının uid'si>
Verilmezse "demo-isletme" / "demo-musteri" kullanılır (AUTH_MODE=dev'de `Bearer dev:demo-isletme`).
"""
import os
import sys
from datetime import timedelta

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

import models
from config import ayarlar
from database import SessionLocal
from zaman import bugun, simdi

if ayarlar().uretim_mi and os.getenv("SEED_ZORLA") != "1":
    sys.exit("Production ortamında seed çalıştırılmaz (SEED_ZORLA=1 ile zorlanabilir).")

ISLETME_UID = os.getenv("SEED_ISLETME_UID", "demo-isletme")
MUSTERI_UID = os.getenv("SEED_MUSTERI_UID", "demo-musteri")

db = SessionLocal()

# Temizlik (FK sırasıyla)
for tablo in (models.randevu_hizmetleri, models.favori_berberler):
    db.execute(tablo.delete())
for model in (models.Degerlendirme, models.BeklemeListesi, models.MusteriNotu, models.Randevu, models.BerberIzin,
              models.SaatBloke, models.TatilGunu, models.Isletme, models.Musteri, models.SalonFotograf, models.Hizmet,
              models.Berber, models.Salon, models.Dukkan):
    db.query(model).delete()
db.commit()

# ── 1. Salonlar ──────────────────────────────────────────────
salonlar_data = [
    dict(ad="Premium Berber Center", adres="Akademi Mah. İsmetpaşa Sk. No:1, Karatay/Konya", telefon="0332 000 00 01",
         foto_url="https://images.unsplash.com/photo-1585747860715-2ba37e788b70", whatsapp="903320000001",
         instagram_url="https://instagram.com/premiumberber", sehir="Konya", ilce="Karatay",
         acilis_saati="09:00", kapanis_saati="21:00", pazar_acilis_saati="10:00", pazar_kapanis_saati="17:00",
         konum_lat=37.8762, konum_long=32.4850),
    dict(ad="Elit Kuaför Salonu", adres="Mevlana Mah. Ankara Cad. No:45, Selçuklu/Konya", telefon="0332 000 00 02",
         foto_url="https://images.unsplash.com/photo-1503951914875-452162b0f3f1", whatsapp="903320000002",
         sehir="Konya", ilce="Selçuklu", acilis_saati="09:00", kapanis_saati="21:00", kapali_gunler="6",
         konum_lat=37.8746, konum_long=32.4932),
    dict(ad="İstanbul Style Barber", adres="Bağdat Cad. No:120, Kadıköy/İstanbul", telefon="0216 000 00 03",
         foto_url="https://images.unsplash.com/photo-1621605815971-fbc98d665033", whatsapp="902160000003",
         sehir="İstanbul", ilce="Kadıköy", acilis_saati="10:00", kapanis_saati="22:00",
         konum_lat=40.9906, konum_long=29.0230),
    dict(ad="Ankara Premium Erkek Kuaförü", adres="Kızılay Mah. Atatürk Blv. No:78, Çankaya/Ankara",
         telefon="0312 000 00 04", foto_url="https://images.unsplash.com/photo-1599351431202-1e0f0137899a",
         whatsapp="903120000004", sehir="Ankara", ilce="Çankaya", acilis_saati="09:00", kapanis_saati="21:00",
         konum_lat=39.9208, konum_long=32.8541),
    dict(ad="Ege Barber Shop", adres="Alsancak Mah. Kordon Boyu No:55, Konak/İzmir", telefon="0232 000 00 05",
         foto_url="https://images.unsplash.com/photo-1622286342621-4bd786c2447c", whatsapp="902320000005",
         sehir="İzmir", ilce="Konak", acilis_saati="10:00", kapanis_saati="22:00",
         konum_lat=38.4192, konum_long=27.1287),
    dict(ad="Antalya Beach Barber", adres="Lara Mah. Güllük Cad. No:12, Muratpaşa/Antalya", telefon="0242 000 00 06",
         foto_url="https://images.unsplash.com/photo-1605497788044-5a32c7078486", whatsapp="902420000006",
         sehir="Antalya", ilce="Muratpaşa", acilis_saati="09:00", kapanis_saati="23:00",
         konum_lat=36.8869, konum_long=30.7025),
]
salonlar = []
for d in salonlar_data:
    s = models.Salon(puan=5.0, **d)
    db.add(s)
    salonlar.append(s)
db.flush()

# ── 2. Hizmetler (her salonun kendi menüsü) ─────────────────
menu = [
    ("Saç Kesimi", 300, 30, "Klasik veya modern saç kesimi."),
    ("Sakal Tıraşı", 150, 15, "Makine veya ustura ile sakal şekillendirme."),
    ("Saç & Sakal (Yıkama Dahil)", 450, 45, "Saç kesimi + sakal + yıkama."),
    ("Çocuk Tıraşı (13 Yaş Altı)", 200, 20, None),
    ("Yıkama & Fön", 100, 15, None),
    ("Cilt Bakımı (Siyah Maske + Peeling)", 200, 20, None),
    ("Ağda (Kulak / Yanak / Burun)", 100, 15, None),
    ("Keratin Bakımı", 500, 60, None),
    ("Saç Boyama / Beyaz Kapatma", 500, 60, None),
    ("Damat Tıraşı (VIP Paket)", 1500, 120, "Saç + sakal + cilt bakımı + ağda + fön."),
]
hizmet = {}  # (salon_index, ad) → Hizmet
for i, s in enumerate(salonlar):
    carpan = 1.0 if i < 2 else 1.2  # büyükşehir fiyatı
    for ad, fiyat, sure, aciklama in menu:
        h = models.Hizmet(salon_id=s.id, ad=ad, fiyat=round(fiyat * carpan), sure=sure, aciklama=aciklama)
        db.add(h)
        hizmet[(i, ad)] = h
db.flush()

# ── 3. Berberler ─────────────────────────────────────────────
berber_adlari = [("Ali", "Uysal", "Usta"), ("Mehmet", "Kaya", "Kalfa"), ("Eren", "Altınsoy", "Kalfa"),
                 ("Baran", "Demir", "Çırak"), ("Hasan", "Yılmaz", "Usta"), ("Emre", "Çelik", "Kalfa"),
                 ("Can", "Özdemir", "Usta"), ("Burak", "Arslan", "Kalfa"), ("Oğuz", "Koç", "Usta"),
                 ("Serkan", "Aydın", "Kalfa"), ("Murat", "Şahin", "Usta"), ("Kemal", "Tuncer", "Çırak")]
berberler = []
for i, (ad, soyad, uzmanlik) in enumerate(berber_adlari):
    b = models.Berber(ad=ad, soyad=soyad, uzmanlik=uzmanlik, puan=5.0, salon_id=salonlar[i // 2].id)
    db.add(b)
    berberler.append(b)
berberler[2].salon_id = salonlar[0].id  # Premium Berber Center'da 3 personel
db.flush()

# ── 4. İşletme sahibi (onaylı, salon 1'e bağlı) + bekleyen başvuru ──
db.add(models.Isletme(firebase_uid=ISLETME_UID, ad="Demo", soyad="İşletmeci", telefon="05320000000",
                      email="isletme@demo.local", isletme_adi=salonlar[0].ad, durum="onaylandi",
                      salon_id=salonlar[0].id, olusturma=simdi().isoformat(timespec="seconds")))
db.add(models.Isletme(firebase_uid="demo-bekleyen", ad="Yeni", soyad="Başvuru", telefon="05320000009",
                      email="basvuru@demo.local", isletme_adi="Kuzey Berber", durum="beklemede",
                      olusturma=simdi().isoformat(timespec="seconds")))

# ── 5. Müşteriler ────────────────────────────────────────────
onay = simdi().isoformat(timespec="seconds")
musteri = models.Musteri(firebase_uid=MUSTERI_UID, ad="Ahmet", soyad="Yıldız", telefon="05321112233",
                         kvkk_onay_tarihi=onay, olusturma=onay)
diger = [
    models.Musteri(firebase_uid="demo-m2", ad="Kerem", soyad="Aksoy", telefon="05324445566", kvkk_onay_tarihi=onay),
    models.Musteri(firebase_uid="demo-m3", ad="Tolga", soyad="Ekinci", telefon="05327778899", kvkk_onay_tarihi=onay),
    models.Musteri(ad="Selim", soyad="Kara", telefon="05301234567"),  # telefonla gelen (uygulaması yok)
]
db.add(musteri)
db.add_all(diger)
db.flush()
musteri.favori_berberler.append(berberler[0])


def randevu(m, b, gun, saat, hizmet_adlari, durum="onaylandi", kaynak="uygulama", iptal_zamani=None):
    salon_i = salonlar.index(next(s for s in salonlar if s.id == b.salon_id))
    hs = [hizmet[(salon_i, a)] for a in hizmet_adlari]
    r = models.Randevu(musteri_id=m.id, berber_id=b.id, salon_id=b.salon_id, tarih=gun.isoformat(), saat=saat,
                       sure_dk=sum(h.sure for h in hs), toplam_fiyat=sum(h.fiyat for h in hs), hizmetler=hs,
                       durum=durum, kaynak=kaynak, olusturma=onay, hatirlatma_gonderildi=durum != "onaylandi",
                       degerlendirme_bildirimi_gonderildi=durum != "onaylandi",
                       iptal_eden="musteri" if durum == "iptal" else None, iptal_zamani=iptal_zamani)
    db.add(r)
    return r


g = bugun()
ali, mehmet, eren = berberler[0], berberler[1], berberler[2]

# Ahmet'in geçmişi → "Her zamanki": Ali Usta + Saç & Sakal
for hafta in (6, 4, 2):
    r = randevu(musteri, ali, g - timedelta(weeks=hafta), "18:00", ["Saç & Sakal (Yıkama Dahil)"], "tamamlandi")
randevu(musteri, mehmet, g - timedelta(weeks=5), "12:00", ["Saç Kesimi"], "tamamlandi")

# Tolga: iki kez gelmedi → "Riskli"
randevu(diger[1], mehmet, g - timedelta(days=20), "15:00", ["Saç Kesimi"], "gelmedi")
randevu(diger[1], ali, g - timedelta(days=9), "16:00", ["Saç Kesimi"], "gelmedi")
randevu(diger[1], eren, g - timedelta(days=3), "11:00", ["Sakal Tıraşı"], "tamamlandi")
# Kerem: düzenli müşteri
for gun in (30, 16):
    randevu(diger[0], eren, g - timedelta(days=gun), "13:00", ["Saç Kesimi", "Sakal Tıraşı"], "tamamlandi")

# Bugünün akışı (Premium Berber Center)
randevu(diger[0], ali, g, "10:00", ["Saç Kesimi"])
randevu(diger[1], mehmet, g, "11:30", ["Saç & Sakal (Yıkama Dahil)"])
randevu(diger[2], ali, g, "13:00", ["Saç Kesimi", "Cilt Bakımı (Siyah Maske + Peeling)"], kaynak="panel")
randevu(diger[0], eren, g, "15:00", ["Damat Tıraşı (VIP Paket)"])
randevu(diger[2], mehmet, g, "17:30", ["Sakal Tıraşı"], kaynak="panel")
randevu(diger[1], ali, g, "19:00", ["Keratin Bakımı"])
# Ahmet'in yaklaşan randevusu
randevu(musteri, ali, g + timedelta(days=3), "18:00", ["Saç & Sakal (Yıkama Dahil)"])

# Değerlendirmeler
db.flush()
for r in db.query(models.Randevu).filter(models.Randevu.durum == "tamamlandi", models.Randevu.musteri_id == musteri.id):
    r.puan, r.yorum = 5, "Her zamanki gibi harika."
    db.add(models.Degerlendirme(musteri_id=r.musteri_id, berber_id=r.berber_id, salon_id=r.salon_id,
                                randevu_id=r.id, puan=5, yorum=r.yorum, tarih=r.tarih))
diger_yorumlar = {diger[0].id: (5, "Ense düz, yanlar tam istediğim gibi. Randevu saatinde alındım."),
                  diger[1].id: (3, None)}
for r in db.query(models.Randevu).filter(models.Randevu.durum == "tamamlandi",
                                         models.Randevu.musteri_id.in_(diger_yorumlar)):
    r.puan, r.yorum = diger_yorumlar[r.musteri_id]
    db.add(models.Degerlendirme(musteri_id=r.musteri_id, berber_id=r.berber_id, salon_id=r.salon_id,
                                randevu_id=r.id, puan=r.puan, yorum=r.yorum, tarih=r.tarih))
db.flush()
for b in berberler:
    puanlar = [d.puan for d in db.query(models.Degerlendirme).filter_by(berber_id=b.id)]
    b.puan = round(sum(puanlar) / len(puanlar), 2) if puanlar else 5.0
for s in salonlar:
    puanlar = [d.puan for d in db.query(models.Degerlendirme).filter_by(salon_id=s.id)]
    if puanlar:
        s.puan = round(sum(puanlar) / len(puanlar), 2)

# Müşteri kartı: Kerem için işletmenin kalıcı notu (akışta 📝 görünür)
db.add(models.MusteriNotu(salon_id=salonlar[0].id, musteri_id=diger[0].id, metin="Yanlar 1 numara, üstü makas. Ense düz.",
                          guncelleme=f"{g.isoformat()}T09:00", guncelleyen="İşletme"))

# Kapalı gün örneği: 10 gün sonrası salon 1'de tadilat
db.add(models.TatilGunu(salon_id=salonlar[0].id, tarih=(g + timedelta(days=10)).isoformat(), aciklama="Tadilat"))
db.add(models.BerberIzin(berber_id=mehmet.id, tarih=(g + timedelta(days=2)).isoformat(), aciklama="Yıllık izin"))

db.commit()
print(f"[TAMAM] {len(salonlar)} salon, {len(berberler)} berber, {len(hizmet)} hizmet, "
      f"{db.query(models.Randevu).count()} randevu yüklendi.")
print(f"  İşletme UID: {ISLETME_UID}  (salon: {salonlar[0].ad})")
print(f"  Müşteri UID: {MUSTERI_UID}")
db.close()
