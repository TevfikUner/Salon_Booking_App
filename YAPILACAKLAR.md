# Yapılacaklar

Tek liste: biten iş buradan **silinir**. Ayrıntılı adımlar [BENDEN_GEREKENLER.md](BENDEN_GEREKENLER.md)'de (§ numaraları oraya bakar).
Neyin hazır olduğu: [YAYIN_KONTROL_LISTESI.md](YAYIN_KONTROL_LISTESI.md) · Son güncelleme: 12 Ekim 2026

Kodun güncel hali GitHub `main` dalında (Tur 4 ilham özellikleri dahil).

---

## ⚠️ HATIRLATMA — Uygulamayı kendiniz test edin (Tur 4'ten sonra ilk iş)

Otomatik testler geçti (backend 110, Flutter 50, emülatörde 2 uçtan uca akış), ama yeni özellikleri **siz elle
denemediniz**. Kurulum: [DEMO.md](DEMO.md) "Hazırlık" (yerel backend + seed) → iki cihaz/emülatör: biri müşteri,
biri işletme. Her maddeyi deneyip sorunluysa bana yazın:

- [ ] **Bildirim (işletme):** müşteri randevu alınca / iptal edince / erteleyince işletme cihazına push geliyor mu, dokununca panel o günle açılıyor mu (gerçek Firebase gerekir → önce A-1)
- [ ] **Erteleme:** Randevularım → Ertele → yeni saat; "İptal Et" diyaloğu ertelemeyi öneriyor mu; 2 ertelemeden sonra düğme kayboluyor mu
- [ ] **Yorumlar:** salon detayında puan özeti, dağılım, "Tümünü gör"; yorumsuz berber/salonda "Yeni" yazıyor mu
- [ ] **Öğle arası / saatlik kapatma / çalışma günleri:** Kapalı Günler'de mola ve saat kapatma, Ekip'te personele dokunup gün seçimi → müşteri tarafında o saatler/günler kapanıyor mu
- [ ] **Müşteri kartı:** akışta müşteri adına dokun → geçmiş, harcama, not kaydet → akışta 📝 çıkıyor mu
- [ ] **Takvim:** dolu gün kırmızı, az yer turuncu nokta; dolu güne dokununca bilgi satırı
- [ ] **Arama:** Keşfet'te "sakal" gibi hizmet adı ve salon adı araması, ★4.5+ filtresi, "Filtreleri temizle"
- [ ] **Takvime Ekle:** onay ekranında ve randevu kartında → Google Takvim ve .ics (Samsung Takvim vb.) gerçekten ekliyor mu
- [ ] **Bildirim izni kartı:** temiz kurulumda ilk randevu onayında "1 saat kala hatırlatalım mı?" çıkıyor mu; "Şimdi değil" sonrası bir daha çıkmıyor mu
- [ ] Eski akışlar bozulmadı mı: kayıt/giriş, Her Zamanki, walk-in randevu, bekleme listesi, hesap silme
- [ ] Büyük yazı boyutu (Ayarlar → Yazı tipi en büyük) ile yeni ekranlarda taşma var mı

## A. Sizin yapacaklarınız — önce bu 3'ü

1. **Firebase'e yeni Android uygulamasını ekleyin** — yayını bu engelliyor (§1)
   - Firebase Console → proje `berberapp-9859f` → Proje ayarları → Uygulama ekle → Android
   - Paket adı: `com.tevfikuner.premiumberber` · SHA-1: `C3:32:F3:DA:D6:34:7E:10:F4:9C:33:0F:59:A0:A9:95:71:6D:16:31`
   - İnen dosyayı yerleştirin: `python scripts/google_services_yukle.py ~/Downloads/google-services.json`
2. **Upload anahtarını yedekleyin** (§2)
   - `C:\Users\VICTUS\.premium-berber\` klasörünü iki ayrı yere kopyalayın (USB + bulut/parola yöneticisi)
   - Kaybolursa uygulamaya güncelleme yükleyemezsiniz
3. **Render'a yayın** (§3–4)
   - Firebase → Hizmet hesapları → yeni özel anahtar (JSON) indirin; E-posta/Şifre girişi açık olsun
   - render.com → New → Blueprint → `TevfikUner/pro_berber_full`, dal `main`
   - `FIREBASE_CREDENTIALS_JSON` (JSON'un tamamı) ve `DESTEK_EPOSTA` girin
   - Kontrol: `https://premium-berber-api.onrender.com/health` → `"durum":"ok"`
   - Render Shell: `python araclar.py admin-ekle sizin@eposta.com`
   - Not: yeni migration'lar (0003–0005) dağıtımda `preDeployCommand` ile kendiliğinden çalışır

## B. Sizin yapacaklarınız — sonra

4. Gerçek adresle AAB derleyin (§5) — Tur 4 özellikleri main'de olduğu için eski AAB'yi değil yenisini yükleyin:
   `cd App && flutter build appbundle --release --dart-define=API_URL=https://premium-berber-api.onrender.com`
5. Play Console: geliştirici hesabı (25 $), uygulama oluştur, mağaza girişi ve uygulama içeriği — metinler `MAGAZA/` klasöründe (§6)
6. Kapalı test: 12+ testçi, 14 gün — davet mesajı `MAGAZA/kapali_test_rehberi.md`
7. İnceleme hesabı (müşteri + onaylı işletme) → Play Console "Uygulama erişimi" (§7)
8. Gerçek telefonda giriş/kayıt/bildirim/hesap silme kontrolü (§8)
9. Yasal metinlere veri sorumlusu unvanı/adresi (hukukçu) → `python scripts/yasal_senkron.py` (§9)
10. Müşteri notu için gizlilik metnine bir cümle (hukukçu onayı; taslak hazır) → BENDEN_GEREKENLER §9
11. Eski admin şifresi `***KALDIRILDI***` başka bir yerde kullanıldıysa değiştirin

## C. Benim yapacaklarım

1. (İsteğe bağlı, siz isterseniz) Mağaza ekran görüntülerini yenileme: Keşfet'te arama kutusu, salon detayında
   yorumlar ve onay ekranında "Takvime Ekle" yeni. Komut: YAYIN_KONTROL_LISTESI Kapı 5 "Telefon ekran görüntüleri".
2. Sizin test sonuçlarınıza göre düzeltmeler (yukarıdaki HATIRLATMA listesi).

A-1 (Firebase) bitince B-4'ü (AAB derleme) ben de yapabilirim.
Emülatör hazır: `emulator -avd berber_test` (testlerden önce saat dilimi: `adb shell cmd alarm set-timezone Europe/Istanbul`).

## D. İlham raporundan yapılmayanlar (sonraya bırakıldı) — ayrıntı: [ILHAM_ANALIZI.md](ILHAM_ANALIZI.md) §3

Karar sizin; "yap" derseniz sırayla ele alırım. 💰 = ücretli servis/sözleşme gerekir.

| # | Özellik | Neden bekliyor | Ön koşul |
|---|---|---|---|
| 10 | Online kapora / ödeme | No-show'a karşı en güçlü araç ama ödeme kuruluşu şart | 💰 iyzico/PayTR sözleşmesi + hesap |
| 11 | Salon galerisi / berber portföyü + fotoğraflı yorum | Render diski kalıcı değil; fotoğraflı yorumda moderasyon gerekir | 💰 Obje depolama (Firebase Storage → Blaze planı veya Cloudinary ücretsiz katman) |
| 12 | Kampanya / paket fiyat (ör. Salı %20) | Fiyat mühürleme, rapor ve "uygulamadaki fiyat tutmuyor" riski → ürün kararı | Sizin kampanya kurallarınız |
| 13 | Berber ↔ hizmet eşleşmesi, berbere göre fiyat/süre | Randevu akışı sırası ve slot hesabı değişir | — (M efor) |
| 14 | Berber sütunlu gün/hafta takvimi + sürükle-bırak | Telefonda ızgara zor; ilk sürüm için Akış listesi yeterli | — (L efor) |
| 15 | Minimum önceden rezervasyon süresi (ör. en az 30 dk önce) | Berberler son dakika randevuyu genelde istiyor | Talep gelirse (S efor) |
| 16 | Sadakat kartı (ör. 10. tıraş indirimli) | Kampanya (#12) ile birlikte tasarlanmalı | #12 kararı |
| 17 | SMS / otomatik WhatsApp hatırlatma | Push + manuel WhatsApp şimdilik yeterli | 💰 SMS kontörü + İYS veya WhatsApp Business API |
| 18 | Çoklu dil | Hedef pazar TR; tüm metinlerin taşınması geniş iş | Yabancı müşteri talebi |
| 19 | Tekrarlayan randevu ("3 hafta sonra aynı saat") | "Her Zamanki" büyük kısmını karşılıyor | — |
| 20 | Kişisel verinin veritabanında şifrelenmesi | KVKK artısı ama arama/eşleşme ve veri taşıma etkisi var | Ayrı güvenlik turu |

Gerek görülmeyenler (karar, iş değil): uygulama içi sohbet, işletme onaylı (bekleyen) randevu, aydınlık tema,
e-posta bildirimleri, tanıtım slaytları/sepet/evde hizmet — gerekçeler ILHAM_ANALIZI §3 #21–#25.
