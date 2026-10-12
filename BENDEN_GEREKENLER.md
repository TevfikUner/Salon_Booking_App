# Benden Gerekenler

Yalnızca **sizin hesabınızla** yapılabilecek işler, yapılma sırasıyla. Kod tarafı hazır; komutlar kopyala-çalıştır.
Ayrıntılı dağıtım rehberi: [CANLIYA_ALMA.md](CANLIYA_ALMA.md) · Durum: [YAYIN_KONTROL_LISTESI.md](YAYIN_KONTROL_LISTESI.md)

---

## 1. ⛔ Firebase'e yeni Android uygulamasını kaydedin (YAYINI BLOKE EDİYOR, ~5 dk)

Paket adı `com.tevfikuner.premiumberber` oldu. Firebase hesabınıza erişimim olmadığı için şu anki
`App/android/app/google-services.json` **geçici**: eski uygulamanın kaydı yeni paket adına kopyalandı. Derleme çalışıyor
ama bu dosyayla bildirim, Crashlytics ve Analytics doğru uygulamaya bağlanmaz. Bu düzeltilmeden Play'e yüklemeyin.

1. https://console.firebase.google.com → proje **berberapp-9859f** → ⚙ **Proje ayarları** → **Genel** → **Uygulama ekle** → Android simgesi.
2. **Android paket adı:** `com.tevfikuner.premiumberber` · **Takma ad:** Premium Berber
3. **SHA-1** (upload anahtarı): `C3:32:F3:DA:D6:34:7E:10:F4:9C:33:0F:59:A0:A9:95:71:6D:16:31` → **Uygulamayı kaydet**
4. `google-services.json`'u indirin, repo kökünde:
   ```bash
   python scripts/google_services_yukle.py ~/Downloads/google-services.json
   ```
   ✅ görürseniz tamam. (Yanlış dosyada hiçbir şeyi değiştirmez.)
5. Aynı sayfada eski `com.example.berber_app_ui` uygulamasını silebilirsiniz (artık kullanılmıyor).
6. Play'e ilk yüklemeden sonra (adım 6.4) Play Console → **Uygulama bütünlüğü → Uygulama imzalama** sayfasındaki
   **uygulama imzalama anahtarı** SHA-1 ve SHA-256'yı da Firebase'deki bu uygulamaya ekleyin.

## 2. 🔐 Upload anahtarını yedekleyin (bugün, ~3 dk)

| Ne | Nerede |
|---|---|
| Anahtar deposu | `C:\Users\VICTUS\.premium-berber\upload-keystore.jks` (repo dışında, git'e girmez) |
| Takma ad (alias) | `upload` |
| Şifre | `App\android\key.properties` içinde (`storePassword` = `keyPassword`) · yedeği: `C:\Users\VICTUS\.premium-berber\key.properties.yedek` |
| SHA-256 | `53:3F:BC:5E:6C:4A:AA:93:EA:A4:FA:53:A4:A7:45:1D:82:3E:4C:57:1C:F3:1F:4A:3E:3F:D0:DA:1B:27:84:9F` |

> ⚠️ **Bu anahtarı ve şifresini kaybederseniz uygulamaya güncelleme yükleyemezsiniz.** (Play App Signing açık olduğu
> için Google'a başvurup yeni upload anahtarı tanımlatmak mümkün ama günler sürer ve kimlik doğrulama ister.)

Yapılacak: `.premium-berber` klasörünü **iki ayrı yere** kopyalayın (ör. şifreli USB + parola yöneticisi / Google Drive'da
şifreli arşiv). Şifreyi parola yöneticinize kaydedin. Bilgisayar değişirse klasörü aynı yola koymanız yeterli.

## 3. Firebase ayarları (~10 dk)

1. **Authentication → Sign-in method → E-posta/Şifre:** açık olmalı. **Templates** → dili **Türkçe** yapın.
2. **Servis hesabı anahtarı:** ⚙ Proje ayarları → **Hizmet hesapları** → **Yeni özel anahtar oluştur** → JSON iner.
   Bu dosyayı kimseyle paylaşmayın; içeriği adım 4'te Render'a yapıştırılacak.
3. **Crashlytics:** sol menü → Crashlytics → **Etkinleştir** (ilk çökme raporu gelene kadar "bekleniyor" görünür, normal).
4. **Analytics:** Proje ayarları → **Entegrasyonlar → Google Analytics** bağlı olmalı (yoksa bağlayın).
5. **Cloud Messaging:** ek işlem yok (V1 API varsayılan).
6. (Önerilir) Google Cloud Console → **API'ler ve Hizmetler → Kimlik bilgileri** → "Android key (auto created by Firebase)"
   → **Android uygulamaları** kısıtı: paket `com.tevfikuner.premiumberber` + SHA-1 (adım 1.3). Repo herkese açıksa önemli.
7. **Eski admin şifresi:** `***KALDIRILDI***` git geçmişinde açık. Kod kullanmıyor; başka bir yerde kullandıysanız değiştirin.

## 4. Render'a yayın (~15 dk + derleme)

Kodun güncel hali GitHub `main` dalında (Tur 5 dahil). Yeni migration'lar (0003–0009) dağıtımda `preDeployCommand`
ile kendiliğinden çalışır; mevcut veriye dokunmaz.

1. https://render.com → hesap açın (GitHub ile) → **Billing**'e kart ekleyin (Starter planlar ücretli; free plan neden olmaz: KARARLAR.md "Render planı").
2. **New → Blueprint** → repo `TevfikUner/pro_berber_full` → dal `main` → Render `render.yaml`'ı okur: 1 web, 1 worker, 1 PostgreSQL.
3. Sorulan gizli değerler (**premium-berber-ortak** grubu):

   | Değişken | Değer | Zorunlu |
   |---|---|---|
   | `FIREBASE_CREDENTIALS_JSON` | Adım 3.2'deki JSON dosyasının **tüm içeriği** | ✅ |
   | `DESTEK_EPOSTA` | Gerçek destek adresiniz (ör. `destek@alanadiniz.com`) — gizlilik sayfasında görünür | ✅ |
   | `ADMIN_UIDS` | Boş bırakın (admin'i adım 4.6'da komutla ekleyeceğiz) | — |
   | `SENTRY_DSN` | sentry.io'da ücretsiz proje → Python/FastAPI → DSN. Boşsa hata izleme kapalı | İsteğe bağlı |
   | `VERI_ANAHTARI` | Kişisel veri şifreleme anahtarı — **boş bırakın**, açmak için adım 4.8 | İsteğe bağlı |

4. **Apply** → ilk derleme 5–8 dk. Web servisi adı `premium-berber-api` ise adres `https://premium-berber-api.onrender.com`
   olur (başka ad verdiyseniz bundan sonraki her yerde kendi adresinizi kullanın).
5. Kontrol: tarayıcıda `https://premium-berber-api.onrender.com/health` → `{"durum":"ok","veritabani":"ok",...}`
   ve `https://premium-berber-api.onrender.com/yasal/gizlilik` → gizlilik sayfası.
6. Render → `premium-berber-api` → **Shell**:
   ```bash
   python araclar.py saglik                      # DB, Firebase ve admin sayısı
   python araclar.py admin-ekle sizin@eposta.com # önce uygulamada bu e-postayla hesap açmış olmalısınız
   ```
7. Worker'ı kontrol: Render → `premium-berber-gorevler` → **Logs** → `Worker başladı: hatirlatma, tamamlama, idempotency_temizlik`.
8. **(İsteğe bağlı, önerilir) Kişisel veriyi veritabanında şifreleme.** Ad, telefon, e-posta, notlar ve yorumlar
   veritabanında şifreli durur; veritabanı yedeği/dökümü sızsa bile okunamaz (KVKK teknik tedbir).
   > ⚠️ **Anahtarı kaybederseniz şifreli veri geri getirilemez.** Önce yedekleyin, sonra açın.
   1. Shell'de: `python araclar.py anahtar-uret` → çıkan değeri **parola yöneticinize** kaydedin (upload anahtarının yanına).
   2. Render → **Env Groups → premium-berber-ortak** → `VERI_ANAHTARI` = o değer → **Save** (web ve worker yeniden başlar).
   3. Shell'de mevcut kayıtları şifreleyin: `python araclar.py veri-sifrele` → tablo başına sayı yazar.
      `python araclar.py saglik` → "Veri şifreleme: açık".
   - Anahtarı değiştirmek: yeni değeri `VERI_ANAHTARI`'na, eskisini `VERI_ANAHTARI_ESKI`'ye yazın → `veri-sifrele` →
     eskisini silin. Kapatmak: önce `python araclar.py veri-coz`, sonra `VERI_ANAHTARI`'nı silin.

## 5. Gerçek API adresiyle AAB derleyin (~5 dk)

Adım 1 ve 4 bittikten sonra, `App/` klasöründe:

```bash
flutter build appbundle --release --dart-define=API_URL=https://premium-berber-api.onrender.com --dart-define=DESTEK_EPOSTA=destek@alanadiniz.com
```

Tur 4–5 özellikleri `main`'de olduğu için daha önce derlenmiş bir AAB'yi değil bu komutla yenisini yükleyin.
Çıktı: `App/build/app/outputs/bundle/release/app-release.aab`. Telefonda denemek için aynı parametrelerle
`flutter build apk --release ...` → `App/build/app/outputs/flutter-apk/app-release.apk` dosyasını telefona atıp kurun.

## 6. Google Play Console (~1 saat, sonra 14 gün kapalı test)

1. https://play.google.com/console → geliştirici hesabı (tek seferlik 25 $, kimlik doğrulama 1–3 gün sürebilir).
2. **Uygulama oluştur:** ad `Premium Berber: Berber Randevu`, dil Türkçe, Uygulama, Ücretsiz, beyanları onaylayın.
3. **Mağaza girişi:** metinler ve görseller `MAGAZA/magaza_metinleri.md`, `MAGAZA/gorseller/`, ekran görüntüleri `MAGAZA/ekran_goruntuleri/`.
4. **Uygulama içeriği:** `MAGAZA/veri_guvenligi.md` ve `MAGAZA/icerik_derecelendirme.md`'deki yanıtları birebir girin.
   Gizlilik politikası URL'si: `https://premium-berber-api.onrender.com/yasal/gizlilik` ·
   Hesap silme URL'si: `https://premium-berber-api.onrender.com/yasal/hesap-silme`
5. **Test → Kapalı test** → kanal oluştur → AAB yükle → **Play App Signing**'i kabul edin (varsayılan) → incelemeye gönderin.
6. **12+ testçi, 14 gün:** `MAGAZA/kapali_test_rehberi.md` (davet mesajı hazır).
7. 14 gün dolunca **Üretime erişim başvurusu** → onay → Üretim sürümü.

## 7. İnceleme hesabı (Google'ın işletme panelini görebilmesi için, ~5 dk)

Play Console → Uygulama içeriği → **Uygulama erişimi** → "Bazı işlevler kısıtlı":
1. Uygulamadan bir müşteri hesabı ve bir işletme hesabı açın (ör. `inceleme.musteri@...`, `inceleme.isletme@...`).
2. İşletmeyi onaylayın (Render Shell): `python araclar.py basvurular` → `python araclar.py onayla <id> --sehir Konya --ilce Selçuklu`
3. İki hesabın e-posta/şifresini ve "İşletme hesabıyla giriş → Akış sekmesi" talimatını formdaki alana yazın.

## 8. Gerçek cihaz kontrolü (~15 dk)

Otomatik testler Firebase giriş ekranlarını kapsamıyor (gerçek hesap açmamak için). Adım 5'teki APK ile:
kayıt ol → e-posta doğrulama gelir mi → çıkış/giriş → şifremi unuttum → randevu al → bildirim izni (Android 13+) → randevu
onay bildirimi gelir mi → bildirime dokununca Randevularım açılıyor mu → Profil → Hesabımı Sil.

## 9. Hukuki / içerik

- **Gizlilik, KVKK, kullanım koşulları** (`backend/yasal/*.md`, uygulama aynı metni gösterir): veri sorumlusunun unvanı,
  adresi ve VERBİS durumu hukukçu kontrolüyle eklenmeli. Değiştirince: `python scripts/yasal_senkron.py` ve yeniden dağıtım.
- **Müşteri notu (yeni, Tur 4):** İşletmeler artık müşteri kartına kalıcı not yazabiliyor ("yanlar 1 numara, üstü makas").
  Not yalnızca o salonda görünür, en fazla 500 karakterdir, müşteri hesabını silince silinir. Gizlilik metnine bir cümle
  eklenmesi önerilir; hukukçu onayından sonra `backend/yasal/gizlilik.md` 34. satırın ardına ekleyip
  `python scripts/yasal_senkron.py` çalıştırın. Taslak:
  > Randevu aldığınız salon, size daha iyi hizmet verebilmek için sizinle ilgili kısa hizmet notları (ör. tercih
  > ettiğiniz kesim) tutabilir. Bu notlar yalnızca o salon tarafından görülür ve hesabınızı sildiğinizde silinir.
  Ayrıca işletmelere "notlara sağlık bilgisi gibi özel nitelikli veri yazmayın" uyarısı (ör. işletme sözleşmesinde) eklenmeli.
- **Kampanya ve indirim gösterimi (yeni, Tur 5):** İşletmeler yüzde kampanya ve sadakat kartı tanımlayabiliyor; uygulama
  liste fiyatını üstü çizili, indirimli tutarı yanında gösteriyor. Ticaret Bakanlığı'nın indirimli satış kuralları
  (indirim öncesi fiyat olarak son 30 günün en düşük fiyatının gösterilmesi) hizmet fiyatlarına uygulanıyor mu,
  hukukçuya sorun. Gerekirse işletme sözleşmesine "menü fiyatını kampanyadan hemen önce yükseltmeyin" maddesi
  eklenebilir. Uygulama içi kampanya gösterimi ticari ileti (SMS/e-posta) değildir, İYS gerektirmez.
- **Ticari ileti:** kampanya mesajı gönderecekseniz İYS kaydı gerekir (uygulama izni ayrı ve isteğe bağlı topluyor).
- **iOS** isterseniz: Apple Developer (99 $/yıl), `GoogleService-Info.plist`, APNs anahtarı.

## 10. Sonra (yayını engellemez)

- Kullanıcı sayısı artınca Render web planını yükseltin (eşikler: KARARLAR.md "Render planı", ölçümler: YUK_TESTI.md).
- Android Gradle Plugin 9'a yükseltme (Flutter uyarıyor; şimdilik 8.13 ile derleniyor).
- Fotoğraf depolama (Cloudinary / S3) — Render diski kalıcı değil.
- Veritabanı yedeği: Render PostgreSQL günlük yedek alır; ek olarak `scripts/yedekle.sh`'i haftalık çalıştırın.
