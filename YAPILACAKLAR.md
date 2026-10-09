# Yapılacaklar — 10 Ekim 2026

Kod hazır ve `main` dalında. Kalan işler yalnızca sizin hesaplarınızla yapılabilir.
Sırayla gidin; her adım bir sonrakinin ön koşulu. Ayrıntılar: [BENDEN_GEREKENLER.md](BENDEN_GEREKENLER.md).

**Toplam süre:** ~1–1,5 saat (mağaza yayını hariç)

---

## ☐ 1. Güvenlik — 5 dk
- [ ] Eski admin şifresi `***KALDIRILDI***` git geçmişinde açık. Başka bir hesapta (e-posta, Firebase, sunucu) kullandıysanız **orada değiştirin**.

## ☐ 2. Firebase — 15 dk
- [ ] Console → ⚙ Proje ayarları → **Hizmet hesapları** → *Yeni özel anahtar oluştur* → JSON'u indirin.
- [ ] Dosyayı `backend/serviceAccountKey.json` olarak kaydedin (git'e eklenmez).
- [ ] Authentication → Sign-in method → **E-posta/Şifre açık** olsun. Templates → dili **Türkçe** yapın.
- [ ] Admin UID'nizi bulun:
  ```bash
  cd backend
  python araclar.py uid sizin@eposta.com
  python araclar.py saglik        # "Firebase: OK" görmelisiniz
  ```
- [ ] Çıkan UID'yi `backend/.env` içindeki `ADMIN_UIDS=` satırına yazın.

## ☐ 3. Render'a yayın — 15 dk
- [ ] render.com → **New → Blueprint** → `TevfikUner/pro_berber_full` → dal: **main**.
- [ ] Gizli değerleri girin:
  - `FIREBASE_CREDENTIALS_JSON` = indirdiğiniz JSON'un **tüm içeriği**
  - `ADMIN_UIDS` = 2. adımdaki UID
- [ ] Deploy bitince tarayıcıda açın: `https://<servis>.onrender.com/saglik` → `{"durum":"ok"}`.
- [ ] Render → servis → **Shell** → `python araclar.py saglik`.
- [ ] Servis adresini not edin: `https://________________________.onrender.com`

## ☐ 4. Telefonda deneme — 20 dk
- [ ] Telefonda Geliştirici seçenekleri → **USB hata ayıklama** açık → USB ile bağlayın.
  ```bash
  cd App
  flutter devices                                   # telefon listede görünmeli
  flutter run --dart-define=API_BASE_URL=https://<servis>.onrender.com
  ```
- [ ] Bir müşteri, bir işletme hesabı açın. İşletme başvurusunu Render Shell'den onaylayın:
  ```bash
  python araclar.py basvurular
  python araclar.py onayla <id> --sehir Konya --ilce Selçuklu
  ```
- [ ] [DEMO.md](DEMO.md) senaryosunu baştan sona deneyin; garip gelen her şeyi buraya not edin:
  - …
  - …

## ☐ 5. Paket adı ve mağazaya hazırlık — 20 dk
- [ ] Firebase → Proje ayarları → **Uygulama ekle → Android** → paket adı `com.premiumberber.app` → yeni `google-services.json`'u indirin.
  ```bash
  python scripts/paket_adi_degistir.py com.premiumberber.app ~/Downloads/google-services.json --dene
  python scripts/paket_adi_degistir.py com.premiumberber.app ~/Downloads/google-services.json
  ```
- [ ] Release imza anahtarı (şifreleri **güvenli yerde yedekleyin**, kaybolursa uygulama güncellenemez):
  ```bash
  keytool -genkey -v -keystore App/premium-berber.jks -keyalg RSA -keysize 2048 -validity 10000 -alias premium
  cp App/android/key.properties.example App/android/key.properties    # şifreleri doldurun
  cd App && flutter build appbundle --release --dart-define=API_BASE_URL=https://<servis>.onrender.com
  ```
- [ ] Yukarıdaki değişiklikleri commit'leyin (`key.properties` ve `.jks` git'e girmez, bu doğru).

## ☐ 6. Sonraki günler
- [ ] KVKK aydınlatma metni ve gizlilik politikasını hukukçuya kontrol ettirin (`App/lib/data/sabit/yasal_metinler.dart`).
- [ ] Gerçek destek e-postası → derlemeye `--dart-define=DESTEK_EPOSTA=...` ekleyin.
- [ ] Google Play Console hesabı (25 $), mağaza görselleri, Veri Güvenliği formu.
- [ ] Kotlin'i ≥ 2.3.20'ye yükseltin (Flutter uyarıyor).
- [ ] Fotoğraf depolama (Cloudinary/S3), ödeme/kapora, Reserve with Google → [ANALIZ_RAPORU.md](ANALIZ_RAPORU.md) "Sonraya" bölümü.

---

**Takılırsanız:** `python araclar.py saglik` neyin eksik olduğunu söyler. Uygulama "Sunucuya ulaşılamadı" diyorsa `API_BASE_URL`'i kontrol edin.
