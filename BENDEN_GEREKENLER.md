# Benden Gerekenler

Kodda yer tutucu/mock ile geçilen, yalnızca sizin yapabileceğiniz işler. Öncelik sırasıyla.

## 🔴 Hemen

1. **Eski admin şifresini geçersiz sayın.** `***KALDIRILDI***` public repoda ve git geçmişinde açık duruyor. Kodda artık kullanılmıyor ama başka bir yerde (e-posta, Firebase, sunucu) aynı şifreyi kullandıysanız değiştirin. `ADMIN_SECRET` kullanacaksanız uzun, rastgele yeni bir değer verin (`python -c "import secrets;print(secrets.token_urlsafe(32))"`).
2. **Repo'yu private yapmayı düşünün** veya en azından `App/android/app/google-services.json`'daki API anahtarına Firebase Console → Google Cloud → API kısıtlaması (Android paket adı + SHA-1) ekleyin.
3. **Firebase servis hesabı (Admin SDK) anahtarı:** Firebase Console → Proje Ayarları → Hizmet Hesapları → "Yeni özel anahtar oluştur".
   - Yerel: `backend/serviceAccountKey.json` olarak kaydedin (git'e eklenmez).
   - Render: dosyanın tüm içeriğini `FIREBASE_CREDENTIALS_JSON` ortam değişkenine yapıştırın.
   - Bu olmadan production'da token doğrulanamaz (`AUTH_MODE=firebase`) ve push bildirimi gitmez.
4. **Admin UID'niz:** Firebase Console → Authentication'dan kendi kullanıcınızın UID'sini `ADMIN_UIDS` değişkenine yazın (işletme başvurularını onaylamak için).

## 🟠 Yayın öncesi

5. **Android SDK lisanslarını kabul edin:** `flutter doctor --android-licenses` (hepsine `y`). Derleme NDK 28.2 lisansı kabul edilmediği için duruyor. Bu makinedeki JDK 25 için Gradle 9.1.0 / AGP 8.13.0'a yükselttim; sorun çıkarsa JDK 21 kurup `flutter config --jdk-dir "<jdk21 yolu>"` ile eski sürümlere dönebilirsiniz.
6. **Render hesabı:** render.com → New → Blueprint → bu repo. `render.yaml` servis + PostgreSQL'i oluşturur. Panelde `FIREBASE_CREDENTIALS_JSON` ve `ADMIN_UIDS` girin. Sonra bir kez Shell'den demo veri istemiyorsanız hiçbir şey yapmayın; istiyorsanız `SEED_ZORLA=1 python seed.py` (production verisini SİLER, yalnızca ilk kurulumda).
7. **Alan adı:** `api.premiumberber.app` gibi bir alan adı alıp Render'a bağlayın; `render.yaml`'daki `CORS_ORIGINS` ve uygulama derleme komutundaki `API_BASE_URL`'i güncelleyin.
8. **Android paket adı:** Şu an `com.example.berber_app_ui` — Google Play `com.example` kabul etmez. Örn. `com.premiumberber.app` seçin; Firebase Console'da bu paket adıyla yeni Android uygulaması ekleyip yeni `google-services.json` indirin. Sonra `App/android/app/build.gradle.kts` içindeki `namespace` ve `applicationId` ile `MainActivity.kt` paket yolunu değiştirin (bunu ben yapmadım çünkü Firebase kaydı olmadan uygulama açılmaz).
9. **Release imza anahtarı:** `keytool` ile `.jks` oluşturun, `App/android/key.properties.example`'ı `key.properties` olarak kopyalayıp doldurun. Anahtarı ve şifreleri güvenli yerde yedekleyin (kaybolursa uygulama güncellenemez).
10. **Google Play Console** hesabı (tek seferlik 25 $), mağaza görselleri, gizlilik politikası URL'si (mevcut PDF'i bir web sayfasına koyun), Veri Güvenliği formu (toplanan veriler: ad, telefon, e-posta, randevu geçmişi; hesap silme: uygulama içinden).
11. **Apple** (iOS yayını isterseniz): Apple Developer (99 $/yıl), `GoogleService-Info.plist`, APNs anahtarı Firebase'e yüklenmeli.

## 🟡 Hukuki / içerik

12. **KVKK aydınlatma metni ve gizlilik politikası** hukukçu kontrolünden geçmeli. Uygulamadaki metin (`yasal_dokuman_screen.dart`) ve kökteki PDF taslak niteliğinde; veri sorumlusu unvanı, adres, VERBİS durumu, saklama süreleri doldurulmalı.
13. **Ticari elektronik ileti:** Kampanya mesajı gönderecekseniz İYS (İleti Yönetim Sistemi) kaydı gerekir. Uygulama izni zaten ayrı ve isteğe bağlı topluyor.
14. **Demo salon verileri** kurgusaldır (telefonlar `0332 000 00 0x`). Gerçek salonları admin onayıyla ekleyin.

## 🟢 Sonra

15. **Fotoğraf depolama:** Render diski kalıcı değil; berber/salon fotoğrafları için Cloudinary / S3 / Firebase Storage hesabı.
16. **Yedekleme:** Render PostgreSQL'in günlük yedeği plan dahilinde; ek olarak `scripts/yedekle.sh`'i haftalık çalıştıracak bir yer (GitHub Actions / kendi bilgisayarınız).
17. **Ödeme (kapora / no-show ücreti)** isterseniz iyzico veya PayTR üye işyeri sözleşmesi.
18. **Reserve with Google** partnerliği (Google Haritalar'da "Randevu al" butonu) için başvuru.
