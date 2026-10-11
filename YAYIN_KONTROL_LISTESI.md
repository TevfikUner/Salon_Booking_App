# Yayın Kontrol Listesi — Premium Berber v1.0.0

Dal: `feature/v1-hazirlik` · Tarih: 2026-10-11 · Her madde kanıtıyla (komut çıktısı / test / dosya). ❌ olanların engeli ve çözümü yazılı.

## Özet

| Kapı | Durum | Kalan engel |
|---|---|---|
| 1. Android AAB | ✅ (koşullu) | Firebase'de yeni uygulama kaydı + gerçek `google-services.json` → BENDEN_GEREKENLER §1 |
| 2. Canlı backend | ✅ (yerel production yığını) | Render hesabı + gizli değerler → BENDEN_GEREKENLER §4 |
| 3. Yük ve dayanıklılık | ✅ | — |
| 4. Uygulama kalitesi | ✅ | — (gerçek telefonda Firebase giriş/bildirim kontrolü → BENDEN_GEREKENLER §8) |
| 5. Play politika & mağaza | ✅ (belgeler hazır) | Play Console girişi, 12 testçi × 14 gün → BENDEN_GEREKENLER §6 |
| 6. Son kontrol & teslim | ✅ | — |

---

## Kapı 1 — Android AAB

| Madde | Durum | Kanıt |
|---|---|---|
| SDK lisansları, `flutter doctor` | ✅ | `[√] Flutter (stable 3.47.7)`, `[√] Android toolchain (Android SDK 36.0.0)`, `[√] Network resources`. Tek ✗: Visual Studio (yalnızca Windows masaüstü uygulaması için, Android'i etkilemez). Uyarı: PATH'te ikinci adb (WinGet) |
| Paket adı `com.tevfikuner.premiumberber` | ✅ | `aapt dump badging app-release.apk` → `package: name='com.tevfikuner.premiumberber'`; Kotlin `MainActivity` → `kotlin/com/tevfikuner/premiumberber/`; iOS `PRODUCT_BUNDLE_IDENTIFIER` aynı; `git grep com.example` → `App/` altında 0 sonuç (yalnızca eski dönüştürme betiği `scripts/paket_adi_degistir.py`) |
| Uygulama adı "Premium Berber" | ✅ | `application-label:'Premium Berber'` (aapt); iOS `CFBundleDisplayName` |
| google-services.json paket uyumu | ⚠️ geçici | Dosya yeni paket adını içeriyor (derleme geçiyor) ama `mobilesdk_app_id` eski uygulamanın → **Engel:** Firebase'de yeni Android uygulaması kaydı. **Çözüm:** BENDEN_GEREKENLER §1 + `python scripts/google_services_yukle.py <dosya>` (paket adı doğrulamalı) |
| targetSdk 36 / minSdk 24 / sürüm 1.0.0 (1) | ✅ | aapt: `sdkVersion:'24' targetSdkVersion:'36'`, `versionCode='1' versionName='1.0.0'` |
| Upload keystore repo dışında, key.properties gitignore | ✅ | `C:\Users\VICTUS\.premium-berber\upload-keystore.jks` (PKCS12, alias `upload`, 2054'e kadar geçerli); `git check-ignore -v App/android/key.properties` → `App/android/.gitignore:12:key.properties`; kök `.gitignore`: `*.jks`, `*.keystore` |
| Release imzası | ✅ | `keytool -printcert -jarfile app-release.aab` → `Owner: CN=Tevfik Uner, OU=Premium Berber`, SHA256 `53:3F:BC:…:84:9F` |
| R8 / minify + ProGuard | ✅ | `build.gradle.kts`: `isMinifyEnabled = true`, `isShrinkResources = true`, `proguard-rules.pro` (Flutter, Firebase, Play Services, eklentiler) |
| Manifest temiz, gereksiz izin yok | ✅ | Release APK izinleri (aapt): INTERNET, ACCESS_COARSE_LOCATION, POST_NOTIFICATIONS + Firebase'in zorunluları (ACCESS_NETWORK_STATE, WAKE_LOCK, c2dm RECEIVE, INSTALL_REFERRER, GSERVICES). **AD_ID ve ADSERVICES izinleri kaldırıldı** (`tools:node="remove"`) |
| Release'te yalnızca HTTPS | ✅ | `usesCleartextTraffic` yalnızca `src/debug` ve `src/profile` manifestlerinde; release'te `http://` API adresiyle uygulama açılışta durur (`AppConfig.guvensizAdres`, splash) |
| Uyarlanabilir ikon + açılış ekranı | ✅ | `flutter_launcher_icons` (adaptive arka plan #141414, ön plan + monochrome), `flutter_native_splash` (Android 12 API dahil); kaynak `scripts/gorsel_uret.py` |
| `flutter build appbundle --release --dart-define=API_URL=https://...` | ✅ | `√ Built build\app\outputs\bundle\release\app-release.aab (62.1MB)` · SHA-256 `6a7bcf4b9fa3a92479d249924ce07f5fd1b0b63ba447b05c13e87312e4656b5f` |
| Release APK | ✅ | `√ Built build\app\outputs\flutter-apk\app-release.apk (62.8MB)` |
| Emülatör/cihazda kurulum ve açılış | ✅ | Emülatör `berber_test` (Android 15 / API 35, Google Play imajı, Pixel 7): `flutter build apk --release --dart-define=API_URL=https://premium-berber-api.onrender.com` → `adb install` → `Success`; `am start -W` → `Status: ok, LaunchState: COLD, TotalTime: 2304` ms; 8 sn sonra süreç ayakta, `topResumedActivity=…premiumberber/.MainActivity`, logcat'te FATAL/AndroidRuntime yok; karşılama ekranı (Müşteri / İşletme Sahibi) açıldı. `apksigner verify --print-certs` → `CN=Tevfik Uner, OU=Premium Berber`, SHA-256 `533fbc5e…27849f` (11 Ekim 2026) |

## Kapı 2 — Canlı backend

| Madde | Durum | Kanıt |
|---|---|---|
| PostgreSQL + havuz | ✅ | `database.py`: `pool_size=5, max_overflow=10, pool_timeout=5, pool_pre_ping, pool_recycle=1800`; compose yığını PostgreSQL 16 ile çalıştı |
| İndeksler + migration | ✅ | `alembic/versions/0002_saglamlik.py`: `ix_randevu_berber_tarih_durum`, `ix_randevu_salon_tarih`, `ix_randevu_musteri_tarih`, kısmi tekil `uq_randevu_aktif_slot`; boş PostgreSQL'de `alembic upgrade head` → `Running upgrade -> 0001`, `0001 -> 0002`; `alembic check` temiz; `downgrade` denendi |
| Zamanlayıcı tek kopya | ✅ | Ayrı `worker.py` + DB kira kilidi (`gorev_kilidi.py`); log: `Worker başladı: hatirlatma, tamamlama, idempotency_temizlik`; testler: `test_gorev_kilidi_tek_sahip_ve_sure_dolunca_duser`, `test_gorev_eszamanli_iki_surecte_tek_kez_calisir`, `test_zamanlayici_gorevleri_kilitli_tanimli` |
| gunicorn + uvicorn worker, sayı env ile | ✅ | `docker-entrypoint.sh` (`WEB_CONCURRENCY`); log `Using worker: uvicorn_worker.UvicornWorker`, 2 ve 6 worker ile koşuldu |
| `/health` DB kontrollü | ✅ | `{"durum":"ok","veritabani":"ok","surum":"1.0.0"}`; DB durdurulunca `503 {"durum":"hata","veritabani":"erişilemiyor"}` (YUK_TESTI.md kesinti testi) |
| Hız sınırı (giriş/kayıt/randevu), istek boyutu, yükleme tür/boyut | ✅ | `koruma.py` (kayıt 5/dk, /ben 30/dk, randevu 10/dk, hesap silme 3/dk), 1 MB gövde sınırı → 413, fotoğraf 6 MB + sihirli bayt kontrolü; testler `test_hiz_siniri_ben_ucu`, `test_hiz_siniri_randevu_olusturma`, `test_istek_boyutu_siniri`, `test_foto_yukleme_icerik_turunu_denetler` |
| CORS kısıtlı | ✅ | `CORS_ORIGINS` listesi, yöntem ve başlıklar açıkça sayılı, `allow_credentials=False` |
| Production'da /docs kapalı | ✅ | `ORTAM=production` → `/docs 404`, `/openapi.json 404`; `DOCS_ENABLED=true` ile açılabilir |
| Yapılandırılmış log | ✅ | JSON satırları (`zaman, seviye, kaynak, mesaj, istek_id, yontem, yol, durum, sure_ms`), `X-Request-ID`; sorgu dizesi (konum) loglanmaz |
| Sentry (DSN yoksa sessiz) | ✅ | `gozlem.sentry_kur()`, `send_default_pii=False` |
| render.yaml: web + worker + PostgreSQL | ✅ | `render.yaml` (env grubu, `preDeployCommand: alembic upgrade head`, `healthCheckPath: /health`) |
| Free plan etkisi + önerilen plan | ✅ | KARARLAR.md "Render planı" |
| Production seed ayrımı | ✅ | `seed.py` → `seed_demo.py`, production'da reddeder |
| Güvenli ilk admin | ✅ | `python araclar.py admin-ekle <e-posta>` (Firebase'den UID, `yoneticiler` tablosu); test `test_db_yoneticisi_admin_rolunde` |
| Tüm pytest yeşil (SQLite + PostgreSQL) | ✅ | SQLite: `70 passed` · PostgreSQL 16: `TEST_DATABASE_URL=postgresql://…/berber_test pytest` → `70 passed, 19 warnings in 23.13s` |

## Kapı 3 — Yük ve dayanıklılık → ayrıntı [YUK_TESTI.md](YUK_TESTI.md)

| Madde | Durum | Kanıt |
|---|---|---|
| Senaryo (salon listesi, slot, randevu, iptal) | ✅ | `backend/yuk/locustfile.py` |
| 200 eşzamanlı: p95 okuma < 500, yazma < 800, hata < %1 | ✅ | p95 toplam 47 ms, randevu 74 ms, hata %0 |
| 1000 eşzamanlı (6 worker) | ✅ | 73.319 istek, p95 okuma ≤ 270 ms, randevu 530 ms, hata %0,005 |
| Çift randevu = 0 | ✅ | Tüm koşular sonrası `dogrula.py` → `ÇAKIŞAN ÇİFT=0` |
| Darboğaz düzeltme + tekrar ölçüm | ✅ | `musait-takvim` N+1 → p50 52→9 ms; havuz zaman aşımı 500→503; worker sayısı ölçeklemesi |
| Yarış testi: tek kazanan | ✅ | 100 eşzamanlı aynı saat → `{200: 1, 409: 99}` |
| Yeniden başlatma / DB kesintisi | ✅ | 1.225/1.225 randevu kayıtlı (kayıp 0), kesintide Türkçe 503 |

## Kapı 4 — Uygulama kalitesi

| Madde | Durum | Kanıt |
|---|---|---|
| Yükleniyor/boş/hata/çevrimdışı durumları | ✅ | `AsenkronGorunum`, `BosGorunum`, `HataGorunumu` tüm liste ekranlarında; `BaglantiBandi` (connectivity_plus) uygulama genelinde "İnternet bağlantısı yok" |
| Ham exception / kırmızı ekran yok | ✅ | `HataRaporlama`: release'te `ErrorWidget` yerine sade mesaj + Crashlytics; `ApiClient` tüm ağ/TLS/zaman aşımı/oturum hatalarını Türkçe `ApiHata`'ya çevirir; backend 500'de iç ayrıntı sızmaz (test) |
| Zaman aşımı + yeniden deneme | ✅ | `AppConfig.timeout`; GET'ler ağ/502/503/504'te 2 kez geri çekilmeli yeniden denenir |
| Çift dokunma koruması (düğme + backend idempotency) | ✅ | Randevu formu, Her Zamanki kartı, panel randevu ekleme: kilit + `Idempotency-Key`; backend testleri `test_ayni_idempotency_anahtari_tek_randevu`, `test_eszamanli_ayni_anahtar_tek_kayit`, `test_basarisiz_istek_anahtari_serbest_birakir` |
| TR telefon, zorunlu alanlar, Türkçe hata, klavye | ✅ | `Alanlar.telefon` (5 ile başlayan 10 hane), panel formu da doğruluyor; `adjustResize` + kaydırılabilir formlar |
| 360 dp, büyük yazı, geri tuşu, sıfır taşma | ✅ | `test/duzen_test.dart`: 8 ekran/kart × (1,0× ve 1,3×) 360 dp'de 16/16 geçti; aynı test 200 dp/2,0×'te taşmayı yakaladı (kontrol). Randevu akışında geri tuşu önceki adıma (`PopScope`) |
| Türkçe metin/düğme tutarlılığı | ✅ | "RANDEVU AL" → "Randevu Al"; yasal metinler web ile aynı kaynaktan |
| Görsel önbellek, sayfalı liste, gereksiz çağrı yok | ✅ | `cached_network_image`; `ListView.builder`; Randevularım backend'de 200 ile sınırlı + eager loading; takvim N+1 giderildi |
| Crashlytics + analytics (kayıt, randevu, iptal) | ✅ | `services/hata_raporlama.dart`, `services/analitik.dart` (`sign_up`, `randevu_olustur`, `randevu_iptal`) |
| Android 13+ bildirim izni, bildirime dokununca doğru ekran | ✅ | `POST_NOTIFICATIONS` + `FirebaseMessaging.requestPermission()`; `BildirimServisi._ac`: randevu → Randevularım, bekleme → salon, değerlendirme → puanlama |
| `flutter analyze` 0 | ✅ | `No issues found!` |
| Tüm testler yeşil | ✅ | `flutter test` → `All tests passed!` (30) |
| integration_test: müşteri akışı | ✅ | `flutter test integration_test/musteri_akisi_test.dart -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:8020` → `00:25 +1: All tests passed!`; backend logu: `POST /randevular/olustur 200`, `POST /randevular/2/iptal 200`. Backend: SQLite + `AUTH_MODE=dev`, veri `yuk/entegrasyon_veri.py`. Emülatör saat dilimi Europe/Istanbul olmalı (`adb shell cmd alarm set-timezone Europe/Istanbul`) |
| integration_test: işletme akışı | ✅ | `flutter test integration_test/isletme_akisi_test.dart …` → `00:06 +1: All tests passed!`; backend logu: `PATCH /panel/randevular/1/durum 200` (tamamlandı) |

## Kapı 5 — Play politikası ve mağaza

| Madde | Durum | Kanıt |
|---|---|---|
| Gizlilik + KVKK herkese açık URL, uygulamadan erişim | ✅ | `GET /yasal/gizlilik`, `/yasal/kvkk`, `/yasal/kullanim` (200, test); uygulamada Profil → yasal metinler (+ "Tarayıcıda aç"), işletme ⋮ menüsü, kayıt ekranında KVKK |
| Hesap silme: uygulama içi + web | ✅ | Müşteri: Profil → Hesabımı Sil; işletme/personel: ⋮ → Hesabımı Sil; web: `/yasal/hesap-silme` (oturumsuz form, test) |
| Kısa (≤80) / uzun (≤4000) açıklama | ✅ | `MAGAZA/magaza_metinleri.md`; `python scripts/magaza_kontrol.py` → ad 30/30, kısa 72/80, uzun 2143/4000 |
| Veri güvenliği yanıtları kodla tutarlı | ✅ | `MAGAZA/veri_guvenligi.md` (her satırda kaynak dosya) |
| İçerik derecelendirme yanıtları | ✅ | `MAGAZA/icerik_derecelendirme.md` |
| 512×512 ikon, 1024×500 öne çıkan grafik | ✅ | `magaza_kontrol.py` → `ikon_512.png: 512x512 RGBA`, `one_cikan_1024x500.png: 1024x500 RGB` |
| Telefon ekran görüntüleri | ✅ | `flutter drive --driver=test_driver/ekran_goruntusu.dart --target=integration_test/ekran_goruntusu_test.dart` (demo verisi, `wm size 1080x1920`) → `All tests passed`; `MAGAZA/ekran_goruntuleri/` 7 PNG, hepsi 1080×1920 (9:16): ana sayfa, keşfet, salon detay, hizmet seçimi, randevularım, işletme akışı, işletme raporu |
| Kapalı test rehberi (12 testçi, 14 gün, mesaj) | ✅ | `MAGAZA/kapali_test_rehberi.md` |

## Kapı 6 — Teslim

| Madde | Durum | Kanıt |
|---|---|---|
| YAYIN_KONTROL_LISTESI.md | ✅ | bu dosya |
| BENDEN_GEREKENLER.md (sıralı, adım adım) | ✅ | Firebase → anahtar yedeği → Firebase ayarları → Render → AAB → Play → inceleme hesabı → cihaz → hukuk |
| CANLIYA_ALMA.md | ✅ | Sıfırdan Render + Play yükleme + güncelleme + geri alma, komutlarla |
| README güncel | ✅ | Bağlantılar, portlar, test sayıları, yeni klasörler |
| Küçük Türkçe commit'ler, main'e merge yok | ✅ | `git log main..feature/v1-hazirlik --oneline` |
