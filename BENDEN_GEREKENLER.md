# Benden Gerekenler

Yalnızca sizin hesabınızla yapılabilecek işler. Her adımı tek komuta indiren araçlar hazır.
Sıra önemlidir: 1 → 2 → 3 → 4.

## 1. Firebase (≈10 dk) — olmadan production'da kimse giriş yapamaz

1. **Eski admin şifresi:** `***KALDIRILDI***` public repoda ve git geçmişinde açık. Kod artık kullanmıyor; ama aynı şifreyi başka bir yerde (e-posta, Firebase, sunucu) kullandıysanız orada değiştirin.
2. **Servis hesabı anahtarı:** Firebase Console → ⚙ Proje ayarları → Hizmet hesapları → *Yeni özel anahtar oluştur* → JSON iner.
   - Yerel: `backend/serviceAccountKey.json` olarak kaydedin (git'e eklenmez).
   - Render: dosyanın **tüm içeriğini** `FIREBASE_CREDENTIALS_JSON` değişkenine yapıştırın (adım 2).
3. **Authentication → Sign-in method → E-posta/Şifre** açık olmalı. *Templates* bölümünden doğrulama ve şifre sıfırlama e-postalarının dilini Türkçe yapın.
4. **Admin UID'niz:** anahtar yerindeyken
   ```bash
   cd backend && python araclar.py uid sizin@eposta.com
   ```
   Çıkan UID'yi `ADMIN_UIDS` değişkenine yazın (yerelde `backend/.env`, Render'da panel).
5. (Önerilir) Google Cloud Console → API anahtarları → Android anahtarına paket adı + SHA-1 kısıtı ekleyin; repo public.

## 2. Render'a yayın (≈15 dk)

Kod GitHub'da `main` dalında hazır, `render.yaml` blueprint'i API + PostgreSQL'i birlikte kurar.

1. render.com → **New → Blueprint** → `TevfikUner/pro_berber_full` → dal: `main`.
2. İstenen gizli değerleri girin: `FIREBASE_CREDENTIALS_JSON`, `ADMIN_UIDS`.
3. Deploy bitince: `https://<servis>.onrender.com/saglik` → `{"durum":"ok"}`.
4. Render → servis → **Shell**:
   ```bash
   python araclar.py saglik          # DB + Firebase kontrolü
   python araclar.py basvurular      # bekleyen işletme başvuruları
   python araclar.py onayla 3 --sehir Konya --ilce Selçuklu
   ```
5. (İsteğe bağlı) Özel alan adı: Render → Settings → Custom Domain (HTTPS otomatik). `render.yaml`'daki `CORS_ORIGINS`'i güncelleyin.
6. Production DB boş başlar. Demo verisi isterseniz yalnızca ilk kurulumda: `SEED_ZORLA=1 python seed.py` (**tüm verileri siler**).

## 3. Paket adı ve mağaza (≈20 dk)

Google Play `com.example...` kabul etmez. Firebase'e yeni paket adını kaydetmeden değiştirirsek uygulama açılmaz; bu yüzden betik önce JSON'u doğrular.

1. Firebase Console → Proje ayarları → **Uygulama ekle → Android** → paket adı `com.premiumberber.app` → `google-services.json` indir.
2. Repo kökünde:
   ```bash
   python scripts/paket_adi_degistir.py com.premiumberber.app ~/Downloads/google-services.json --dene   # önizleme
   python scripts/paket_adi_degistir.py com.premiumberber.app ~/Downloads/google-services.json
   ```
3. Release imza anahtarı:
   ```bash
   keytool -genkey -v -keystore App/premium-berber.jks -keyalg RSA -keysize 2048 -validity 10000 -alias premium
   cp App/android/key.properties.example App/android/key.properties   # şifreleri doldurun
   ```
   Anahtarı ve şifreleri güvenli yerde yedekleyin (kaybolursa uygulama güncellenemez).
4. Derleme: `cd App && flutter build appbundle --release --dart-define=API_BASE_URL=https://<render-adresi>`
5. Google Play Console (tek seferlik 25 $): mağaza görselleri, gizlilik politikası URL'si, Veri Güvenliği formu (toplanan: ad, telefon, e-posta, randevu geçmişi; hesap silme: uygulama içinden).

## 4. Gerçek cihazda deneme

Bu makineye bağlı cihaz/emülatör yoktu; gerçek cihaz testini yapamadım.

1. Telefonda Geliştirici seçenekleri → USB hata ayıklama → USB ile bağlayın → `flutter devices` cihazı görmeli.
2. Yerel backend + aynı Wi-Fi: `flutter run --dart-define=API_BASE_URL=http://<bilgisayar-ip>:8000`
   veya Render: `flutter run --dart-define=API_BASE_URL=https://<servis>.onrender.com`
3. [DEMO.md](DEMO.md) senaryosunu izleyin.

## 5. Hukuki / içerik

- **KVKK aydınlatma metni ve gizlilik politikası** (`App/lib/data/sabit/yasal_metinler.dart`, kökteki PDF) taslaktır; veri sorumlusu unvanı, adres, VERBİS durumu, saklama süreleri hukukçu kontrolüyle doldurulmalı.
- **Ticari ileti:** kampanya mesajı gönderecekseniz İYS kaydı gerekir (uygulama izni ayrı ve isteğe bağlı topluyor).
- **Destek e-postası:** varsayılan `destek@premiumberber.app`; gerçek adresi derlemede `--dart-define=DESTEK_EPOSTA=...` ile verin.
- **Apple / iOS** yayını isterseniz: Apple Developer (99 $/yıl), `GoogleService-Info.plist`, APNs anahtarı.

## 6. Sonra

- Flutter, projedeki Kotlin 2.2.20 desteğini yakında bırakacağını uyarıyor; bir sonraki bakımda `App/android/settings.gradle.kts`'te Kotlin'i ≥ 2.3.20'ye yükseltin.

- Fotoğraf depolama (Cloudinary / S3 / Firebase Storage) — Render diski kalıcı değil.
- `scripts/yedekle.sh`'i haftalık çalıştıracak bir yer (GitHub Actions / kendi bilgisayarınız).
- Ödeme (kapora / no-show ücreti) için iyzico veya PayTR sözleşmesi.
- Reserve with Google partnerliği.
