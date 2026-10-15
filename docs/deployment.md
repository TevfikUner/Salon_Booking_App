# Canlıya Alma Rehberi

Sıfırdan production kurulumu (Firebase + Render), Android sürümü, güncelleme ve geri alma. Proje mağazada
yayınlanmadı; bu rehber yayın için gereken her adımın hazır ve denenmiş olduğunu belgeler. Mimari kararlar:
[decisions.md](decisions.md) "Tur 3".

```
Telefon (Flutter, com.tevfikuner.premiumberber)
   │  HTTPS + Firebase ID token
   ▼
Render web: premium-berber-api  (Docker, gunicorn × WEB_CONCURRENCY uvicorn worker, /health)
Render worker: premium-berber-gorevler (python worker.py: hatırlatma, otomatik tamamlama, temizlik; DB kilidi)
Render PostgreSQL: premium-berber-db (Frankfurt)
Firebase: Auth, Cloud Messaging, Crashlytics, Analytics    ·    Sentry (isteğe bağlı)
```

## 0. Ön kontrol (yerelde, 5 dk)

```bash
# Backend testleri (SQLite)
cd backend
python -m venv .venv && .venv/Scripts/pip install -r requirements-dev.txt     # Linux/macOS: .venv/bin/pip
.venv/Scripts/python -m pytest -p no:cacheprovider

# Aynı testler PostgreSQL'e karşı (Docker varsa)
docker run -d --name pg-test -e POSTGRES_USER=berber -e POSTGRES_PASSWORD=test -e POSTGRES_DB=berber_test -p 127.0.0.1:55432:5432 postgres:16
TEST_DATABASE_URL=postgresql://berber:test@127.0.0.1:55432/berber_test .venv/Scripts/python -m pytest -p no:cacheprovider

# Production imajı + worker + PostgreSQL birlikte
cd ..
API_PORT=8020 docker compose -p premium-berber up -d --build
curl http://127.0.0.1:8020/health          # {"durum":"ok","veritabani":"ok","surum":"1.0.0"}
docker compose -p premium-berber logs worker | grep "Worker başladı"

# Flutter
cd App && flutter analyze && flutter test   # "No issues found!" + "All tests passed!"
python ../scripts/yasal_senkron.py --kontrol && python ../scripts/magaza_kontrol.py
```

## 1. Firebase

1. Firebase Console → proje → ⚙ **Proje ayarları** → **Uygulama ekle** → Android. Paket adı
   `com.tevfikuner.premiumberber`, SHA-1: upload anahtarının parmak izi
   (`keytool -list -v -keystore <upload-keystore.jks> -alias upload`).
2. İnen `google-services.json`'u yerleştirin (paket adını doğrular, yanlış dosyada hiçbir şeyi değiştirmez):
   `python scripts/google_services_yukle.py ~/Downloads/google-services.json`
3. **Authentication → Sign-in method → E-posta/Şifre** açık; **Templates** dili Türkçe.
4. **Hizmet hesapları → Yeni özel anahtar oluştur** → JSON. İçeriği Render'da `FIREBASE_CREDENTIALS_JSON` olur;
   kimseyle paylaşılmaz, repoya girmez.
5. **Crashlytics** → Etkinleştir; **Analytics** bağlı olmalı. Cloud Messaging ek ayar istemez (V1 API).
6. Google Cloud Console → **Kimlik bilgileri** → "Android key (auto created by Firebase)" → **Android uygulamaları**
   kısıtı: paket adı + SHA-1. Repo herkese açık olduğu için önemli.
7. Play'e ilk yüklemeden sonra **Uygulama bütünlüğü → Uygulama imzalama** sayfasındaki SHA-1/SHA-256'yı da Firebase
   uygulamasına ekleyin.

## 2. Render

### İlk kurulum
1. Render → **New → Blueprint** → repo → dal `main`. `render.yaml` şunları oluşturur:

   | Kaynak | Plan | Not |
   |---|---|---|
   | `premium-berber-api` (web) | Starter | `healthCheckPath: /health`, `preDeployCommand: alembic upgrade head`, `WEB_CONCURRENCY=2` |
   | `premium-berber-gorevler` (worker) | Starter | `python worker.py` — zamanlanmış görevler yalnızca burada |
   | `premium-berber-db` | basic-256mb | Frankfurt, günlük otomatik yedek |

   Ücretsiz plan neden kullanılmaz: [decisions.md](decisions.md) "Render planı".
2. Gizli değerler (**premium-berber-ortak** grubu):

   | Değişken | Değer | Zorunlu |
   |---|---|---|
   | `FIREBASE_CREDENTIALS_JSON` | Servis hesabı JSON'unun **tüm içeriği** (Firebase adım 4) | ✅ |
   | `DESTEK_EPOSTA` | Gerçek destek adresi — gizlilik sayfasında görünür | ✅ |
   | `ADMIN_UIDS` | Boş bırakılır; ilk yönetici aşağıda komutla eklenir | — |
   | `SENTRY_DSN` | sentry.io → Python/FastAPI projesi. Boşsa hata izleme kapalı | İsteğe bağlı |
   | `VERI_ANAHTARI` | Kişisel veri şifreleme anahtarı — boş bırakılır, açmak için aşağıdaki bölüm | İsteğe bağlı |
   | `S3_BUCKET`, `S3_ENDPOINT_URL`, `S3_ERISIM_ANAHTARI`, `S3_GIZLI_ANAHTAR`, `S3_GENEL_URL` | Berber fotoğrafları için nesne depolama — aşağıdaki "Dosya depolama" | Fotoğraf yüklenecekse ✅ |

3. Diğer ayarlanabilir değişkenler (varsayılanları uygundur):

   | Değişken | Varsayılan | Ne zaman değiştirilir |
   |---|---|---|
   | `WEB_CONCURRENCY` | 2 | Plan büyüdükçe: Standard → 4 |
   | `DB_POOL_SIZE` / `DB_MAX_OVERFLOW` | 5 / 10 | instance × worker × 15 ≤ PostgreSQL bağlantı sınırı (basic-256mb ≈ 100) |
   | `CORS_ORIGINS` | `https://premiumberber.app` | Web paneli/alan adı olursa (mobil uygulama CORS kullanmaz) |
   | `DOCS_ENABLED` | production'da kapalı | Geçici olarak `/docs` açmak için `true` |
   | `RATE_LIMIT_ENABLED` | `true` | Kapatmayın |
   | `RATE_LIMIT_STORAGE_URI` | `memory://` | Çoklu instance'ta ortak sayaç için `redis://...` |
   | `LOG_LEVEL` | `INFO` | Sorun ayıklarken `DEBUG` |
   | `SENTRY_TRACES_SAMPLE_RATE` | `0.1` | Performans izleme oranı |
   | `REZERVASYON_UFKU_GUN` | 30 | Kaç gün sonrasına randevu alınabileceği |
   | `GUVENILIR_PROXY_SAYISI` | 1 (render.yaml) | İstemci IP'si `X-Forwarded-For`'da sağdan bu kadar sayılır. Render'ın önüne başka proxy/CDN eklenirse artırın; duman testindeki IP kontrolüyle doğrulayın |
   | `FORWARDED_ALLOW_IPS` | `*` (render.yaml) | Proxy başlıklarına (https şeması) güvenilecek adresler; IP tespiti bundan etkilenmez |

### Duman testi (dağıtımdan sonra her seferinde)
```bash
API=https://premium-berber-api.onrender.com
curl -s $API/health                                    # durum ok, veritabani ok
curl -s -o /dev/null -w "%{http_code}\n" $API/docs     # 404 (production'da kapalı)
curl -s -o /dev/null -w "%{http_code}\n" $API/yasal/gizlilik       # 200
curl -s -o /dev/null -w "%{http_code}\n" $API/yasal/hesap-silme    # 200
curl -s -o /dev/null -w "%{http_code}\n" $API/salonlar             # 200 (boş liste olabilir)
curl -s $API/ben                                      # 401 Türkçe mesaj (token yok)
curl -s -H "X-Forwarded-For: 6.6.6.6" $API/salonlar >/dev/null   # sonra Logs: bu isteğin "ip" alanı
```
Son istekten sonra Render → Logs'ta o satırın `ip` alanı **kendi genel IP'niz** olmalı (`6.6.6.6` değil). Sahte değer
görünüyorsa hız sınırı atlatılabilir demektir: `GUVENILIR_PROXY_SAYISI`'nı düzeltin. Kendi IP'niz: `curl -s ifconfig.me`.

### İlk yönetici ve işletme onayı (Render → web servisi → Shell)
```bash
python araclar.py saglik
python araclar.py admin-ekle sizin@eposta.com      # uygulamada önce hesap açılmış olmalı
python araclar.py basvurular                       # bekleyen işletmeler
python araclar.py onayla <isletme_id> --sehir Konya --ilce Selçuklu
python araclar.py silme-talepleri                  # web'den gelen hesap silme talepleri
python araclar.py silme-uygula <talep_id>          # kimliği e-postayla doğruladıktan sonra
```

> Production veritabanına `seed_demo.py` **çalıştırmayın** (zaten `ORTAM=production`'da reddeder).

### Kişisel veri şifreleme (isteğe bağlı)
Ad, telefon, e-posta, notlar ve yorumlar veritabanında Fernet ile şifreli durur; döküm veya yedek sızsa bile okunamaz
(KVKK teknik tedbir). Tasarım: [decisions.md](decisions.md) "Kişisel veri şifreleme".

> ⚠️ Anahtar kaybolursa şifreli veri geri getirilemez. Önce yedekleyin, sonra açın.

1. Shell: `python araclar.py anahtar-uret` → değeri parola yöneticisine kaydedin.
2. Render → **Env Groups → premium-berber-ortak** → `VERI_ANAHTARI` = o değer → Save (web ve worker yeniden başlar).
3. Shell: `python araclar.py veri-sifrele` (mevcut kayıtlar) → `python araclar.py saglik` → "Veri şifreleme: açık".
- Anahtar değişimi: yeni değer `VERI_ANAHTARI`'na, eskisi `VERI_ANAHTARI_ESKI`'ye → `veri-sifrele` → eskisini silin.
- Kapatma: önce `python araclar.py veri-coz`, sonra `VERI_ANAHTARI`'nı silin.

### Dosya depolama
Render'ın diski kalıcı değildir; yerel diske yazılan dosya her deploy'da silinir. Bu yüzden `render.yaml`
`DEPOLAMA=s3` kullanır (S3 uyumlu herhangi bir servis; örnek Cloudflare R2):

1. Cloudflare → **R2 → Create bucket** (`premium-berber-medya`) → **Settings → Public access**: R2.dev alt alan adını
   veya kendi alan adınızı açın → bu adres `S3_GENEL_URL` olur (sonda `/` olmadan).
2. **R2 → Manage API tokens → Create** (izin: Object Read & Write, yalnızca bu bucket) → Access Key ID →
   `S3_ERISIM_ANAHTARI`, Secret → `S3_GIZLI_ANAHTAR`; hesap uç noktası `https://<hesap-id>.r2.cloudflarestorage.com` →
   `S3_ENDPOINT_URL`; bucket adı → `S3_BUCKET`. (AWS S3'te `S3_ENDPOINT_URL` boş, `S3_BOLGE=eu-central-1`.)
3. Doğrulama: yöneticiyle bir berbere fotoğraf yükleyin (`POST /berberler/foto-yukle/{id}`); dönen `foto_url` genel
   adreste açılmalı.

Dosya adı içerik özetini taşır (`berberler/berber_7_3fa2c1d9e0b4.jpg`): yeni fotoğraf yeni URL demektir, CDN ve uygulama
önbelleği eski resmi göstermez; eskisi silinir. Yapılandırılmamışsa yükleme 503 "Dosya depolama yapılandırılmamış." döner.
Yerelde ve Docker Compose'da varsayılan `DEPOLAMA=yerel` (`uploads/`, Compose'da volume).

### İzleme
- **Loglar:** Render → servis → Logs. Her satır JSON: `istek_id`, `yontem`, `yol`, `durum`, `sure_ms`. Kullanıcı bir hata
  kodu iletirse (ör. "bu kodu iletin: 3f11313e6986") logda `istek_id` ile aratın.
- **Sentry:** `SENTRY_DSN` verildiyse beklenmeyen hatalar burada (kişisel veri gönderilmez).
- **Crashlytics:** Firebase Console → uygulama çökmeleri (yalnızca release derlemeler).
- **Sağlık:** Render `/health`'i izler; 503 dönerse trafik kesilir ve servis yeniden başlatılır.

### Ölçekleme
Kapasite ölçümleri [load-testing.md](load-testing.md). Kısaca: 2 worker ≈ 150 istek/sn; 6 worker 1000 eşzamanlı agresif kullanıcıyı
p95 270 ms ile taşıdı. Render → web servisi → **Settings → Instance Type** (Standard) ve `WEB_CONCURRENCY=4`;
daha fazlası için **Scaling → Instances: 2**. Worker tek kopya yeterli (fazlası zararsız, DB kilidi var).

### Geri alma
- Kod: Render → web servisi → **Events** → önceki başarılı dağıtım → **Rollback**.
- Migration geri alma (yalnızca gerekiyorsa, Shell): `alembic downgrade -1`. Yeni migration'lar geriye uyumlu yazılmalı
  (önce kolon ekle → kodu dağıt → sonra eskiyi kaldır).
- Veri: Render PostgreSQL → **Backups** → noktasal geri yükleme.

## 3. Android sürümü

### Derleme
```bash
cd App
flutter build appbundle --release \
  --dart-define=API_URL=https://premium-berber-api.onrender.com \
  --dart-define=DESTEK_EPOSTA=destek@alanadiniz.com
# → build/app/outputs/bundle/release/app-release.aab
```
- İmza: `App/android/key.properties` (örnek: `key.properties.example`) repo dışındaki upload anahtar deposunu gösterir
  (yoksa derleme debug anahtarıyla imzalar ve Play reddeder — `keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab` çıktısında
  `CN=Tevfik Uner, OU=Premium Berber` görünmeli).
- `API_URL` `https://` ile başlamazsa release uygulama açılışta durur (bilinçli koruma).

### Play'e yükleme
1. Play Console → uygulama → **Test → Kapalı test** (ilk sürüm) veya **Üretim** → **Yeni sürüm oluştur**.
2. AAB'yi sürükleyin. İlk yüklemede **Play App Signing** kabul edilir.
3. Sürüm adı otomatik (`1.0.0 (1)`), sürüm notu Türkçe → **İncelemeye gönder**.
4. İlk yüklemeden sonra **Uygulama bütünlüğü** sayfasındaki imzalama anahtarı SHA-1/SHA-256'yı Firebase uygulamasına ekleyin.

### Güncelleme yayınlamak
1. `App/pubspec.yaml` → `version: 1.0.1+2` (artı işaretinden sonraki sayı **her yüklemede artmalı**).
2. Backend değiştiyse önce Render'a dağıtın (API geriye uyumlu olmalı: eski uygulama sürümleri bir süre daha çalışır).
3. Yukarıdaki derleme komutu → Play Console → aynı kanal → yeni sürüm. Üretimde **kademeli dağıtım** (%10 → %50 → %100)
   kullanın; Crashlytics'te sorun görürseniz **Dağıtımı durdur**.

## 4. Yük testi (isteğe bağlı, staging'de)

Production'a **karşı koşmayın** (veri siler/üretir). Staging yığınında:
```bash
bash backend/yuk/yigin.sh veri
cd backend && locust -f yuk/locustfile.py --host http://127.0.0.1:8020 --headless -u 200 -r 20 -t 2m --only-summary
bash yuk/yigin.sh dogrula        # ÇAKIŞAN ÇİFT=0
```
