# Premium Berber

Berber ve kuaför randevu uygulaması. Müşteri salon keşfeder, berber + hizmet seçer, uygun saati alır;
işletme sahibi günün akışını, ekibini, menüsünü ve kapalı günlerini telefonundan yönetir.

| Klasör | İçerik |
|---|---|
| `backend/` | FastAPI + SQLAlchemy + Alembic, APScheduler, Firebase Admin (token doğrulama + FCM) |
| `App/` | Flutter uygulaması (müşteri + işletme paneli tek uygulamada, rol bazlı) |
| `docker-compose.yml` | Yerel PostgreSQL + API |
| `render.yaml` | Render blueprint (API + PostgreSQL) |

Diğer belgeler: [ANALIZ_RAPORU.md](ANALIZ_RAPORU.md) · [KARARLAR.md](KARARLAR.md) · [BENDEN_GEREKENLER.md](BENDEN_GEREKENLER.md) · [DEMO.md](DEMO.md) · [YAPILACAKLAR.md](YAPILACAKLAR.md)

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
python seed.py                       # demo verisi (TÜM tabloları temizler!)
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

- API belgesi: http://localhost:8000/docs · sağlık: http://localhost:8000/saglik
- Testler: `pytest` (48 test: slot/çakışma/eşzamanlılık/iptal/bekleme listesi/panel yetkileri/KVKK/keşfet) · Lint: `ruff check .`
- Yönetim: `python araclar.py --help` (admin UID bulma, işletme başvurusu onay/red, sağlık kontrolü)

### Kimlik doğrulama

Her istek `Authorization: Bearer <Firebase ID token>` taşır.

- `AUTH_MODE=firebase` (production): token Firebase Admin SDK ile doğrulanır → `serviceAccountKey.json` veya `FIREBASE_CREDENTIALS_JSON` gerekir.
- `AUTH_MODE=dev` (yerel): imza doğrulanmaz; Postman/curl için `Authorization: Bearer dev:<uid>` yazılabilir.
  Seed'deki hazır kullanıcılar: `dev:demo-musteri`, `dev:demo-isletme`.

Roller: **müşteri** (varsayılan) · **işletme** (`isletmeler` kaydı, admin onaylı) · **personel** (işletmenin girdiği e-postayla giriş) · **admin** (`ADMIN_UIDS`).

```bash
curl -H "Authorization: Bearer dev:demo-isletme" localhost:8000/panel/akis
```

### Veritabanı / migration

- Geliştirme SQLite, production PostgreSQL — yalnızca `DATABASE_URL` değişir.
- Model değiştirdiğinizde: `alembic revision --autogenerate -m "aciklama"` → oluşan dosyayı gözden geçirin → `alembic upgrade head`.

## 2. Flutter uygulaması

Gereksinim: Flutter 3.4x, JDK 17–25 (Gradle 9.1 / AGP 8.13), kabul edilmiş Android SDK lisansları (`flutter doctor --android-licenses`).

```bash
cd App
flutter pub get
# Android emülatör + yerel backend (varsayılan adres zaten 10.0.2.2:8000):
flutter run
# Gerçek telefon + aynı Wi-Fi'daki bilgisayar:
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000
# Production derlemesi:
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.premiumberber.app
```

- `flutter analyze` → temiz · `flutter test` → 14 birim/widget testi

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
└── services/      kimlik, bildirim (FCM), rol bazlı yönlendirme
```

Kural: ekran dosyası durum + düzen taşır; görsel parçalar `widgets/` altına. Dosya başına ≤ 250 satır.
- Release imzası: `android/key.properties.example` → `android/key.properties`
- Debug derlemesi `http` adreslerine izin verir; release yalnızca HTTPS kullanır.

## 3. Yayına alma (Render)

Adım adım kopyala-çalıştır talimatı: [BENDEN_GEREKENLER.md](BENDEN_GEREKENLER.md) (Firebase → Render → paket adı → cihaz).

1. Render → **New → Blueprint** → repo ve dal (`main`). `render.yaml` bir Docker web servisi ve PostgreSQL oluşturur.
2. Render panelinde gizli değişkenleri girin: `FIREBASE_CREDENTIALS_JSON` (servis hesabı JSON'unun tamamı), `ADMIN_UIDS`.
3. Konteyner her açılışta `alembic upgrade head` çalıştırır; sağlık kontrolü `/saglik`.
4. Özel alan adı ekleyin (HTTPS otomatik) ve uygulamayı `--dart-define=API_BASE_URL=https://...` ile derleyin.

Yerelde production benzeri ortam (Docker gerekir):

```bash
docker compose up --build
docker compose exec api python seed.py     # isteğe bağlı demo verisi
```

**Yedekleme:** Render PostgreSQL günlük yedek alır. Elle yedek: `./scripts/yedekle.sh "$DATABASE_URL"` (geri yükleme komutu betiğin içinde).

**Ölçekleme notu:** Zamanlayıcı (hatırlatma, otomatik tamamlama) API sürecinin içinde çalışır. Birden fazla instance'a çıkarken bir tanesi dışında `SCHEDULER_ENABLED=false` yapın.

## 4. Önemli uçlar

| Uç | Açıklama |
|---|---|
| `GET /ben` | Oturumdaki kullanıcının rolü ve bağlamı |
| `GET /salonlar?sehir=&ilce=&lat=&lng=`, `/salonlar/{id}` | Keşfet (harf duyarsız filtre, konuma göre sıralama, favori işareti) |
| `GET /hizmetler/?salon_id=` | Salonun menüsü |
| `GET /randevular/musait-takvim?berber_id=` | Açık günler (tatil/izin/kapalı gün hariç) |
| `GET /randevular/musait-saatler/{berber_id}?tarih=&hizmet_ids=` | Tek doğruluk kaynağı: müsait saatler |
| `POST /randevular/olustur` | Randevu (çakışmada 409 + öneriler) |
| `POST /randevular/{id}/iptal` | Müşteri iptali (son 30 dk hariç) |
| `GET /randevular/her-zamanki` | ⭐ "Her Zamanki" + en yakın boş slotlar |
| `POST /randevular/bekleme-listesi` | Yer açılırsa haber ver |
| `GET /panel/akis?tarih=` | ⭐ Bugünün Akışı (özet, güven skoru, WhatsApp linki) |
| `PATCH /panel/randevular/{id}/durum` | tamamlandi / gelmedi / iptal |
| `POST /panel/randevular` | Telefonla/kapıdan gelen müşteri |
| `/panel/personel`, `/panel/hizmetler`, `/panel/tatil`, `/panel/izin`, `/panel/rapor`, `/panel/salon` | İşletme yönetimi |
| `POST /isletmeler/kayit`, `POST /isletmeler/{id}/onayla` | İşletme başvurusu ve admin onayı |
| `DELETE /musteriler/hesabim` | KVKK hesap silme (anonimleştirme) |
