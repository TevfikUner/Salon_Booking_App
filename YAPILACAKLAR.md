# Yapılacaklar

Tek liste: biten iş buradan **silinir**. Ayrıntılı adımlar [BENDEN_GEREKENLER.md](BENDEN_GEREKENLER.md)'de (§ numaraları oraya bakar).
Neyin hazır olduğu: [YAYIN_KONTROL_LISTESI.md](YAYIN_KONTROL_LISTESI.md) · Son güncelleme: 12 Ekim 2026 (Tur 5)

Kodun güncel hali GitHub `main` dalında (Tur 4 + Tur 5 dahil). Tur 5'te eklenenler: berbere özel hizmet/fiyat,
kampanya ve sadakat kartı, işletme gün takvimi (sürükle-bırak), kişisel veri şifreleme (isteğe bağlı), en az önceden
randevu süresi, "Aynısını Tekrar Al" — ayrıntı [KARARLAR.md](KARARLAR.md) "Tur 5", demo [DEMO.md](DEMO.md).

---

## ⚠️ HATIRLATMA — Uygulamayı kendiniz deneyin

Emülatörde benim doğruladıklarım (listeden çıkarıldı): erteleme ve iptal diyaloğu, müşteri kartı notu, takvimde
dolu/az yer işaretleri, kampanya indirimi akışı, vermeyen personelin seçilemeyişi, tekrar al, takvimde sürükle-bırak,
kampanya formu, personel hizmetleri; 15 ekranın cihaz görüntüsü (backend 155, Flutter 64, uçtan uca 5 test).

Sizin denemeniz gerekenler (gerçek telefon / gerçek Firebase / sizin gözünüz). Kurulum: [DEMO.md](DEMO.md) "Hazırlık".
Sorunluysa bana yazın:

- [ ] **Bildirimler (gerçek Firebase gerekir → önce A-1):** müşteri randevu alınca / iptal edince / erteleyince işletmeye push; işletme takvimde taşıyınca müşteriye "Randevunuz güncellendi"; dokununca doğru ekran
- [ ] **Bildirim izni kartı:** temiz kurulumda ilk randevu onayında "1 saat kala hatırlatalım mı?"; "Şimdi değil" sonrası bir daha çıkmıyor mu
- [ ] **Takvime Ekle:** onay ekranında ve randevu kartında → Google Takvim ve .ics (Samsung Takvim vb.) gerçekten ekliyor mu
- [ ] **Takvimde sürükle-bırak (yeni):** gerçek telefonda basılı tutup sürüklemek rahat mı, kenara gelince kayıyor mu
- [ ] **Kampanya ve sadakat (yeni):** kendi salonunuzun kurallarıyla bir kampanya tanımlayın; müşteri tarafında doğru gün/saatte indirim görünüyor mu, özet ve randevu kartındaki tutar beklediğiniz gibi mi
- [ ] **Berbere özel fiyat (yeni):** bir personele farklı fiyat/süre verin, bir hizmeti kapatın → müşteri akışında doğru mu
- [ ] **Yorumlar ve arama:** salon detayında puan özeti, "Tümünü gör"; Keşfet'te "sakal" araması, ★4.5+ filtresi
- [ ] **Öğle arası / saatlik kapatma / çalışma günleri / en az önceden (yeni):** panelde ayarlayın → müşteri tarafında o saatler/günler kapanıyor mu
- [ ] Eski akışlar: kayıt/giriş, şifremi unuttum, Her Zamanki, walk-in randevu, bekleme listesi, hesap silme
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
   - `FIREBASE_CREDENTIALS_JSON` (JSON'un tamamı) ve `DESTEK_EPOSTA` girin; `VERI_ANAHTARI`'nı şimdilik boş bırakın
   - Kontrol: `https://premium-berber-api.onrender.com/health` → `"durum":"ok"`
   - Render Shell: `python araclar.py admin-ekle sizin@eposta.com`
   - Not: migration'lar (0003–0009) dağıtımda `preDeployCommand` ile kendiliğinden çalışır

## B. Sizin yapacaklarınız — sonra

4. Gerçek adresle AAB derleyin (§5) — Tur 4–5 özellikleri main'de olduğu için eski AAB'yi değil yenisini yükleyin:
   `cd App && flutter build appbundle --release --dart-define=API_URL=https://premium-berber-api.onrender.com`
5. Play Console: geliştirici hesabı (25 $), uygulama oluştur, mağaza girişi ve uygulama içeriği — metinler `MAGAZA/` klasöründe,
   ekran görüntüleri yenilendi: `MAGAZA/ekran_goruntuleri/` (8 adet) (§6)
6. Kapalı test: 12+ testçi, 14 gün — davet mesajı `MAGAZA/kapali_test_rehberi.md`
7. İnceleme hesabı (müşteri + onaylı işletme) → Play Console "Uygulama erişimi" (§7)
8. Gerçek telefonda giriş/kayıt/bildirim/hesap silme kontrolü (§8)
9. Yasal metinlere veri sorumlusu unvanı/adresi (hukukçu) → `python scripts/yasal_senkron.py` (§9)
10. Müşteri notu için gizlilik metnine bir cümle (hukukçu onayı; taslak hazır) → BENDEN_GEREKENLER §9
11. **Yeni:** Kampanyada üstü çizili fiyat gösterimi için indirimli satış kurallarını hukukçuya sorun → BENDEN_GEREKENLER §9
12. **Yeni, isteğe bağlı:** Kişisel veri şifrelemesini açın — anahtarı üretip **yedekledikten sonra** (§4.8)
13. Eski admin şifresi `***KALDIRILDI***` başka bir yerde kullanıldıysa değiştirin

## C. Benim yapacaklarım

1. **#18 Çoklu dil** (sırada): müşteri ekranları için Türkçe + İngilizce, cihaz diline göre ve Profil'den seçilebilir.
2. Sizin test sonuçlarınıza göre düzeltmeler (yukarıdaki HATIRLATMA listesi).

A-1 (Firebase) bitince B-4'ü (AAB derleme) ben de yapabilirim.
Emülatör hazır: `emulator -avd berber_test` (testlerden önce saat dilimi: `adb shell cmd alarm set-timezone Europe/Istanbul`).

## D. İlham raporundan bekleyenler — ayrıntı: [ILHAM_ANALIZI.md](ILHAM_ANALIZI.md) §3

Üçü de ücretli bir servis/sözleşme olmadan yapılamaz ya da doğrulanamaz. Hesabı açtığınızda "yap" deyin, sırayla ele alırım.

| # | Özellik | Neden bekliyor | Ön koşul |
|---|---|---|---|
| 10 | Online kapora / ödeme | No-show'a karşı en güçlü araç ama ödeme kuruluşu şart | 💰 iyzico/PayTR sözleşmesi + test hesabı (API anahtarları) |
| 11 | Salon galerisi / berber portföyü + fotoğraflı yorum | Render diski kalıcı değil; fotoğraflı yorumda moderasyon gerekir | 💰 Obje depolama (Firebase Storage → Blaze planı veya Cloudinary ücretsiz katman) hesabı |
| 17 | SMS / otomatik WhatsApp hatırlatma | Push + manuel WhatsApp şimdilik yeterli | 💰 SMS kontörü (Netgsm/İleti Merkezi) + İYS veya WhatsApp Business API |

Gerek görülmeyenler (karar, iş değil): uygulama içi sohbet, işletme onaylı (bekleyen) randevu, aydınlık tema,
e-posta bildirimleri, tanıtım slaytları/sepet/evde hizmet — gerekçeler ILHAM_ANALIZI §3 #21–#25.
