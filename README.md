# Premium Berber

Berber ve kuaför randevu uygulaması. Müşteri salon keşfeder, berber + hizmet seçer, uygun saati alır;
işletme sahibi günün akışını, ekibini, menüsünü ve kapalı günlerini telefonundan yönetir.

| Klasör | İçerik |
|---|---|
| `backend/` | FastAPI + SQLAlchemy + Alembic, gunicorn/uvicorn, ayrı zamanlayıcı worker'ı (APScheduler + DB kilidi), Firebase Admin (token + FCM), slowapi, Sentry |
| `App/` | Flutter uygulaması (müşteri + işletme paneli tek uygulamada, rol bazlı) |
| `docker-compose.yml` | Yerel production benzeri yığın: PostgreSQL + API + worker |
| `render.yaml` | Render blueprint (web + worker + PostgreSQL, Frankfurt) |
| `backend/yuk/` | Yük, yarış ve kesinti testleri (Locust) — sonuçlar [YUK_TESTI.md](YUK_TESTI.md) |
| `MAGAZA/` | Play Store metinleri, görseller, Veri Güvenliği ve içerik derecelendirme yanıtları, kapalı test rehberi |
| `scripts/` | Görsel üretimi, yasal metin senkronu, mağaza kontrolü, google-services yükleme, yedekleme |

**Yayın durumu:** [YAYIN_KONTROL_LISTESI.md](YAYIN_KONTROL_LISTESI.md) · **Sizden gerekenler:** [BENDEN_GEREKENLER.md](BENDEN_GEREKENLER.md) · **Dağıtım:** [CANLIYA_ALMA.md](CANLIYA_ALMA.md)

Diğer belgeler: [KARARLAR.md](KARARLAR.md) · [YUK_TESTI.md](YUK_TESTI.md) · [ANALIZ_RAPORU.md](ANALIZ_RAPORU.md) · [ILHAM_ANALIZI.md](ILHAM_ANALIZI.md) · [DEMO.md](DEMO.md) · [YAPILACAKLAR.md](YAPILACAKLAR.md)

---

## 1. Backend — yerel kurulum

Gereksinim: Python 3.12+ (3.14 ile de test edildi).

```bash
cd backend
python -m venv .venv
# Windows: .venv\Scripts\activate    macOS/Linux: source .venv/bin/activate
pip install -r requirements-dev.txt
cp .env.example .env                 # AUTH_MODE=dev ile gelir
alembic upgrade head                 # şemayı oluşturur (SQLite: berber_yeni.db)
python seed_demo.py                  # demo verisi (TÜM tabloları temizler; production'da çalışmaz)
uvicorn main:app --reload --host 0.0.0.0 --port 8010
python worker.py                     # (ayrı terminal, isteğe bağlı) hatırlatma/otomatik tamamlama görevleri
```

- API belgesi: http://localhost:8010/docs (production'da kapalı) · sağlık: http://localhost:8010/health
- Testler: `pytest` (161 test: slot/çakışma/eşzamanlılık/idempotency/hız sınırı/DB kesintisi/zamanlayıcı kilidi/yasal sayfalar/panel yetkileri/KVKK, erteleme, öğle arası/saatlik kapatma, yorumlar, müşteri kartı, arama, takvim dosyası, berbere özel hizmet, kampanya/sadakat, takvimde taşıma, veri şifreleme, en az önceden, tekrar randevu, İngilizce sunucu mesajları). PostgreSQL'e karşı: `TEST_DATABASE_URL=postgresql://... pytest` · şifreleme açıkken: `VERI_ANAHTARI=deneme pytest` · Lint: `ruff check .`
- Yönetim: `python araclar.py --help` (admin ekleme, işletme onay/red, hesap silme talepleri, sağlık kontrolü, veri şifreleme anahtarı ve toplu şifreleme)

### Kimlik doğrulama

Her istek `Authorization: Bearer <Firebase ID token>` taşır.

- `AUTH_MODE=firebase` (production): token Firebase Admin SDK ile doğrulanır → `serviceAccountKey.json` veya `FIREBASE_CREDENTIALS_JSON` gerekir.
- `AUTH_MODE=dev` (yerel): imza doğrulanmaz; Postman/curl için `Authorization: Bearer dev:<uid>` yazılabilir.
  Seed'deki hazır kullanıcılar: `dev:demo-musteri`, `dev:demo-isletme`.

Roller: **müşteri** (varsayılan) · **işletme** (`isletmeler` kaydı, admin onaylı) · **personel** (işletmenin girdiği e-postayla giriş) · **admin** (`ADMIN_UIDS`).

```bash
curl -H "Authorization: Bearer dev:demo-isletme" localhost:8010/panel/akis
```

### Veritabanı / migration

- Geliştirme SQLite, production PostgreSQL — yalnızca `DATABASE_URL` değişir.
- Model değiştirdiğinizde: `alembic revision --autogenerate -m "aciklama"` → oluşan dosyayı gözden geçirin → `alembic upgrade head`.

## 2. Flutter uygulaması

Gereksinim: Flutter 3.4x, JDK 17–25 (Gradle 9.1 / AGP 8.13), kabul edilmiş Android SDK lisansları (`flutter doctor --android-licenses`).

```bash
cd App
flutter pub get
# Android emülatör + yerel backend (varsayılan adres zaten 10.0.2.2:8010):
flutter run
# Gerçek telefon + aynı Wi-Fi'daki bilgisayar:
flutter run --dart-define=API_URL=http://192.168.1.20:8010
# Production derlemesi (release yalnızca https:// kabul eder):
flutter build appbundle --release --dart-define=API_URL=https://premium-berber-api.onrender.com
```

- `flutter analyze` → temiz · `flutter test` → birim, widget, gün takvimi sürükle-bırak, 360 dp + 1,3× yazı taşma testleri, gömülü yazı tipi koruması
  - `flutter_tester` engelliyse (Windows Smart App Control) aynı testler emülatörde, İngilizce taşma turuyla birlikte:
    `flutter test integration_test/birim_cihazda_test.dart -d emulator-5554` (93 test)
- Dil: metinler `lib/l10n/app_tr.arb` (şablon) ve `app_en.arb`; ekledikten sonra `flutter gen-l10n`. Kodda `Dil.t.anahtar`.
- Uçtan uca: `bash backend/yuk/yigin.sh entegrasyon` → `flutter test integration_test/musteri_akisi_test.dart --dart-define=API_URL=http://10.0.2.2:8020` (ve `isletme_akisi_test.dart`, `yeni_ozellikler_test.dart`)
- Görsel inceleme (demo verisiyle 15 ekran → `build/inceleme/`): `flutter drive --driver=test_driver/inceleme.dart --target=integration_test/inceleme_test.dart --dart-define=API_URL=http://10.0.2.2:8020`
  (İngilizce görüntüler için `--dart-define=TEST_DIL=en`; diğer entegrasyon testleri Türkçe sabitlenir)

### Kod yapısı

```
lib/
├── core/          config, tema, biçimlendirme, dış uygulama açıcı, ortak bileşenler (form alanları, durum görünümleri…)
├── data/
│   ├── api/       ApiClient (HTTP + hata) ve alan servisleri: HesapApi, SalonApi, RandevuApi, PanelApi
│   ├── models/    Berber, Hizmet, Randevu, Salon
│   └── sabit/     il/ilçe, SSS, yasal metinler
├── features/      her özellik kendi klasöründe: ekran + widgets/
│   ├── giris/     splash, rol seçimi, giriş, kayıt, işletme başvurusu
│   ├── musteri/   ana sayfa (Her Zamanki), randevularım, favoriler, profil, değerlendirme
│   ├── kesfet/    salon listesi (konuma göre), salon detayı
│   ├── randevu_al/ 5 adımlı akış + onay
│   ├── isletme/   panel: akış, ekip & menü, kapalı günler, rapor
│   └── destek/    SSS, bize ulaşın, yasal metinler
└── services/      kimlik, bildirim (FCM), rol bazlı yönlendirme, hata raporlama (Crashlytics), analitik
```

Kural: ekran dosyası durum + düzen taşır; görsel parçalar `widgets/` altına. Dosya başına ≤ 250 satır.
- Paket adı `com.tevfikuner.premiumberber`, minSdk 24, targetSdk 36, R8 açık.
- Release imzası: `android/key.properties` (gitignore) → anahtar deposu repo dışında; ayrıntı BENDEN_GEREKENLER §2.
- Debug derlemesi `http` adreslerine izin verir; release yalnızca HTTPS kullanır.
- Yasal metinler `backend/yasal/*.md`'den üretilir: `python scripts/yasal_senkron.py` (elle düzenlemeyin).

## 3. Yayına alma

Adım adım: [CANLIYA_ALMA.md](CANLIYA_ALMA.md) (Render + Play Console + güncelleme/geri alma). Hesap gerektiren işler: [BENDEN_GEREKENLER.md](BENDEN_GEREKENLER.md).

Yerelde production benzeri yığın (Docker gerekir):

```bash
API_PORT=8020 docker compose -p premium-berber up -d --build    # api (gunicorn) + worker + PostgreSQL
curl localhost:8020/health
docker compose -p premium-berber exec api python seed_demo.py   # isteğe bağlı demo verisi
```

- Migration'lar Render'da `preDeployCommand` ile bir kez çalışır; compose'da api konteyneri açılışta çalıştırır (`RUN_MIGRATIONS`).
- Zamanlanmış görevler yalnızca `worker` sürecinde çalışır; her görev DB kilidiyle korunur, birden çok kopya güvenlidir.
- **Yedekleme:** Render PostgreSQL günlük yedek alır. Elle: `./scripts/yedekle.sh "$DATABASE_URL"`.

## 4. Önemli uçlar

| Uç | Açıklama |
|---|---|
| `GET /health` | Sağlık (DB dahil; DB yoksa 503) |
| `GET /ben` | Oturumdaki kullanıcının rolü ve bağlamı |
| `GET /salonlar?sehir=&ilce=&lat=&lng=&q=&min_puan=`, `/salonlar/{id}` | Keşfet (harf duyarsız filtre ve arama — salon/ilçe/hizmet adı, konuma göre sıralama, favori işareti, berber tıraş/yorum sayısı) |
| `GET /hizmetler/?salon_id=&berber_id=` | Salonun menüsü (personel arası fiyat/süre aralığı, kampanya yüzdesi); berberle: yalnızca onun verdikleri, onun fiyatıyla |
| `GET /berberler/?salon_id=&hizmet_ids=` | Personel; hizmet verilirse her birinde `uygun`, vermedikleri ve o berberdeki toplam fiyat/süre |
| `GET /randevular/fiyat?berber_id=&tarih=&saat=&hizmet_ids=` | Onay öncesi tutar: liste fiyatı, kampanya veya sadakat indirimi, toplam |
| `GET /randevular/{id}/tekrar-onerisi?hafta=` | "N hafta sonra aynı saatte" önerisi (varsayılan: müşterinin olağan aralığı) |
| `GET /randevular/musait-takvim?berber_id=&hizmet_ids=` | Açık günler (tatil/izin/kapalı gün/berberin haftalık izni hariç); hizmet verilirse gün başına boş saat sayısı ve `dolu` |
| `GET /degerlendirmeler/salon/{id}?sayfa=` | Salon yorumları: ortalama, 1–5 dağılımı, sayfalı liste |
| `GET /randevular/musait-saatler/{berber_id}?tarih=&hizmet_ids=` | Tek doğruluk kaynağı: müsait saatler |
| `POST /randevular/olustur` | Randevu (çakışmada 409 + öneriler; `Idempotency-Key` başlığı ile tekrar güvenli) |
| `POST /randevular/{id}/iptal` | Müşteri iptali (son 30 dk hariç); işletmeye ve berbere push |
| `POST /randevular/{id}/ertele` | Müşteri ertelemesi: aynı berber, süre/fiyat mühürlü, en fazla 2 kez, son 30 dk hariç (`Idempotency-Key`) |
| `GET /randevular/{id}/takvim.ics` | Randevunun iCalendar dosyası (yalnızca sahibine) |
| `GET /randevular/her-zamanki` | ⭐ "Her Zamanki" + en yakın boş slotlar |
| `POST /randevular/bekleme-listesi` | Yer açılırsa haber ver |
| `GET /panel/akis?tarih=` | ⭐ Bugünün Akışı (özet, güven skoru, WhatsApp linki) |
| `PATCH /panel/randevular/{id}/durum` | tamamlandi / gelmedi / iptal |
| `POST /panel/randevular` | Telefonla/kapıdan gelen müşteri |
| `GET /panel/musteriler/{id}`, `PUT /panel/musteriler/{id}/not` | Müşteri kartı (bu salondaki geçmiş, harcama, güven skoru) ve kalıcı işletme notu |
| `POST /panel/bloke`, `DELETE /panel/bloke/{id}` | Berberi bir günün belirli saatlerinde kapatma |
| `POST /panel/randevular/{id}/tasi` | Gün takviminde sürükle-bırak: başka saat/gün/personel (fiyat ve süre aynı, müşteriye bildirim) |
| `GET/PUT /panel/personel/{id}/hizmetler` | Personelin verdiği hizmetler ve kendine özel fiyat/süre |
| `/panel/kampanyalar`, `PUT /panel/sadakat` | Kampanyalar (gün/saat/tarih/hizmet koşullu yüzde) ve sadakat kartı (her N. ziyaret %X) |
| `/panel/personel`, `/panel/hizmetler`, `/panel/tatil`, `/panel/izin`, `/panel/rapor`, `/panel/salon` | İşletme yönetimi (personelin haftalık izin günleri, salonun öğle arası ve "en az önceden" süresi dahil) |
| `POST /isletmeler/kayit`, `POST /isletmeler/{id}/onayla` | İşletme başvurusu ve admin onayı |
| `DELETE /musteriler/hesabim` | Hesap silme (müşteri, işletme, personel — anonimleştirme) |
| `GET /yasal/{gizlilik,kvkk,kullanim}` | Herkese açık yasal sayfalar (Play gizlilik URL'si) |
| `GET/POST /yasal/hesap-silme` | Web'den hesap silme talebi (oturumsuz) |
