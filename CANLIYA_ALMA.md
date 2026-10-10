# Canlıya Alma Rehberi

Sıfırdan production kurulumu, Play Store'a yükleme, güncelleme ve geri alma. Hesap gerektiren adımların kısa listesi:
[BENDEN_GEREKENLER.md](BENDEN_GEREKENLER.md). Mimari kararlar: [KARARLAR.md](KARARLAR.md) "Tur 3".

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
.venv/Scripts/python -m pytest -p no:cacheprovider                             # 70 passed beklenir

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

BENDEN_GEREKENLER adım 1 ve 3: yeni Android uygulaması (`com.tevfikuner.premiumberber`) + `google-services.json`
(`python scripts/google_services_yukle.py <dosya>`), E-posta/Şifre girişi, servis hesabı anahtarı, Crashlytics.

## 2. Render

### İlk kurulum
1. GitHub'da `feature/v1-hazirlik` → `main` birleştirin.
2. Render → **New → Blueprint** → repo → dal `main`. `render.yaml` şunları oluşturur:

   | Kaynak | Plan | Not |
   |---|---|---|
   | `premium-berber-api` (web) | Starter | `healthCheckPath: /health`, `preDeployCommand: alembic upgrade head`, `WEB_CONCURRENCY=2` |
   | `premium-berber-gorevler` (worker) | Starter | `python worker.py` — zamanlanmış görevler yalnızca burada |
   | `premium-berber-db` | basic-256mb | Frankfurt, günlük otomatik yedek |

3. Gizli değerler: `FIREBASE_CREDENTIALS_JSON`, `DESTEK_EPOSTA`, isteğe bağlı `SENTRY_DSN` (tablo: BENDEN_GEREKENLER 4.3).
4. Diğer ayarlanabilir değişkenler (varsayılanları uygundur):

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

### Duman testi (dağıtımdan sonra her seferinde)
```bash
API=https://premium-berber-api.onrender.com
curl -s $API/health                                    # durum ok, veritabani ok
curl -s -o /dev/null -w "%{http_code}\n" $API/docs     # 404 (production'da kapalı)
curl -s -o /dev/null -w "%{http_code}\n" $API/yasal/gizlilik       # 200
curl -s -o /dev/null -w "%{http_code}\n" $API/yasal/hesap-silme    # 200
curl -s -o /dev/null -w "%{http_code}\n" $API/salonlar             # 200 (boş liste olabilir)
curl -s $API/ben                                      # 401 Türkçe mesaj (token yok)
```

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

### İzleme
- **Loglar:** Render → servis → Logs. Her satır JSON: `istek_id`, `yontem`, `yol`, `durum`, `sure_ms`. Kullanıcı bir hata
  kodu iletirse (ör. "bu kodu iletin: 3f11313e6986") logda `istek_id` ile aratın.
- **Sentry:** `SENTRY_DSN` verildiyse beklenmeyen hatalar burada (kişisel veri gönderilmez).
- **Crashlytics:** Firebase Console → uygulama çökmeleri (yalnızca release derlemeler).
- **Sağlık:** Render `/health`'i izler; 503 dönerse trafik kesilir ve servis yeniden başlatılır.

### Ölçekleme
Kapasite ölçümleri [YUK_TESTI.md](YUK_TESTI.md). Kısaca: 2 worker ≈ 150 istek/sn; 6 worker 1000 eşzamanlı agresif kullanıcıyı
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
- İmza: `App/android/key.properties` + `C:\Users\VICTUS\.premium-berber\upload-keystore.jks` (yoksa derleme debug anahtarıyla
  imzalar ve Play reddeder — `keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab` çıktısında
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
