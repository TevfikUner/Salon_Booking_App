# Kararlar

Format: `[Konu] → Seçilen: X | Alternatifler: Y, Z | Gerekçe: ...`

## Yapı ve altyapı

- **[Repo yapısı]** → Seçilen: Backend dosyaları `backend/` klasörüne `git mv` ile taşındı, Flutter `App/` olarak kaldı | Alternatifler: Her şeyi kökte bırakmak; `App/` → `frontend/` olarak yeniden adlandırmak | Gerekçe: Brief `backend/` bekliyordu ve kökteki dağınıklık Docker bağlamını zorlaştırıyordu. `App/` adını değiştirmek IDE/Android Studio yollarını ve kullanıcının alışkanlığını bozacağı, karşılığında bir şey kazandırmayacağı için korundu.
- **[.venv, __pycache__, berber_yeni.db git'te]** → Seçilen: `git rm --cached` ile takipten çıkarıldı, `.gitignore` eklendi | Alternatifler: Olduğu gibi bırakmak | Gerekçe: 3.416 dosyalık bozuk venv (başka makinenin Python yolunu gösteriyor) ve kişisel veri içerebilecek DB repoda olmamalı. Dosyalar git geçmişinde duruyor. Eski DB `%TEMP%\berber_yeni_eski.db`'ye yedeklendi.
- **[Python bağımlılıkları]** → Seçilen: `requirements.txt` (sabit sürümler) + `requirements-dev.txt` | Alternatifler: Poetry, uv | Gerekçe: En az sürtünme; Docker ve Render doğrudan destekliyor.
- **[Ayarlar]** → Seçilen: `pydantic-settings` ile `config.py` + `.env` | Alternatifler: düz `os.getenv` | Gerekçe: Tip güvenliği, tek yer, `.env.example` ile belgeli.

## Güvenlik ve kimlik

- **[Kimlik doğrulama]** → Seçilen: Firebase ID token (`Authorization: Bearer`) backend'de `firebase_admin.auth.verify_id_token` ile doğrulanıyor | Alternatifler: Kendi JWT'miz; `x-firebase-uid` header'ını korumak | Gerekçe: Uygulama zaten Firebase Auth kullanıyor; UID header'ı istemci tarafından taklit edilebiliyordu (herkes başkası adına randevu alıp silebiliyordu).
- **[Yerel geliştirme kimliği]** → Seçilen: `AUTH_MODE=dev` — token imzası doğrulanmadan çözülüyor, ayrıca `Bearer dev:<uid>` kabul ediliyor; `ORTAM=production` iken `dev` modu başlangıçta reddediliyor | Alternatifler: Geliştirmede de servis hesabı zorunlu | Gerekçe: Servis hesabı olmadan da uygulama + Postman + testler çalışabilsin; production'a sızma riski config doğrulamasıyla kapatıldı.
- **[Roller]** → Seçilen: Rol tablosu yerine mevcut tablolardan türetme: `ADMIN_UIDS` → admin, `isletmeler` → işletme, `berberler.firebase_uid` → personel, diğerleri → müşteri | Alternatifler: Firebase custom claims; ayrı `kullanicilar` tablosu | Gerekçe: Migration ve veri taşıma gerektirmiyor; custom claims için Admin SDK ile ayrı bir yönetim akışı gerekirdi.
- **[Admin şifresi]** → Seçilen: Kodda varsayılan YOK; admin yetkisi `ADMIN_UIDS` ile; `ADMIN_SECRET` yalnızca env'de verilirse ve sabit zamanlı karşılaştırmayla çalışıyor | Alternatifler: Tamamen kaldırmak | Gerekçe: Mevcut Postman/betik kullanımına geçiş yolu bırakmak. Eski şifre git geçmişinde açık → değiştirilmeli (BENDEN_GEREKENLER).
- **[Personel hesabı bağlama]** → Seçilen: İşletme personelin e-postasını girer; personel o e-postayla kayıt olup giriş yaptığında `/ben` otomatik eşleştirir | Alternatifler: Davet kodu, SMS | Gerekçe: Ek altyapı gerektirmiyor, Firebase token'ındaki doğrulanmış e-posta kullanılıyor.
- **[CORS]** → Seçilen: `CORS_ORIGINS` env listesi, `allow_credentials=False` | Alternatifler: `*` | Gerekçe: Mobil uygulama CORS'a tabi değil; kimlik cookie değil header ile taşındığı için credentials gereksiz.

## Veri modeli ve iş kuralları

- **[Zaman dilimi]** → Seçilen: Tüm "şimdi" hesapları `Europe/Istanbul` (zoneinfo + tzdata) üzerinden tek `zaman.simdi()` fonksiyonundan | Alternatifler: UTC saklayıp istemcide çevirmek | Gerekçe: Render/Docker UTC çalışır; eski kod 3 saat kayıyordu. Tarih/saat alanları string olarak (salonun yerel saati) kaldı — mevcut veri ve istemciyle uyumlu, tek ülkeli üründe yeterli.
- **[Slot mantığı]** → Seçilen: Dakika aralıkları ile çakışma (`[bas, bit)`), süre 30 dk'ya yukarı yuvarlanıyor, başlangıçlar açılıştan itibaren 30 dk ızgarada, hesap yalnızca backend'de (`slot_servisi.py`) | Alternatifler: Eski string-slot eşleştirmesi; serbest başlangıç saatleri | Gerekçe: Mevcut iş kuralı (30 dk birim) korunurken kenar durumlar (bitişik randevu, kapanış, kısmi boşluk) doğru ve test edilebilir hale geldi. Flutter'daki kopya slot algoritması kaldırıldı (iki doğruluk kaynağı vardı).
- **[Çalışma saatleri]** → Seçilen: Salon başına hafta içi + Pazar saatleri ve `kapali_gunler` (weekday listesi) | Alternatifler: 7 günlük ayrı saat tablosu | Gerekçe: Mevcut `acilis/kapanis` alanlarını genişletiyor; berberlerin %95'i bu modele uyuyor. 7 günlük tablo sonraya.
- **[Hizmetler]** → Seçilen: `Hizmet.salon_id` (NULL = ortak) | Alternatifler: Ayrı salon-hizmet köprü tablosu | Gerekçe: Pazaryerinde her salonun fiyatı farklı; en basit doğru model.
- **[Süre mühürleme]** → Seçilen: `Randevu.sure_dk` randevu anında saklanıyor (fiyat gibi) | Alternatifler: Her seferinde hizmetlerden hesaplamak | Gerekçe: Hizmet süresi değişince geçmiş/gelecek takvim kaymasın.
- **[Çift rezervasyon]** → Seçilen: Süreç içi kilit + berber satırında `SELECT … FOR UPDATE` + kilit içinde yeniden müsaitlik hesabı; çakışmada 409 + öneriler | Alternatifler: DB exclusion constraint (yalnızca PostgreSQL), iyimser kilit | Gerekçe: SQLite ve PostgreSQL'de aynı davranış; 8 eşzamanlı istekle test edildi (tek kazanan).
- **[İptal]** → Seçilen: Soft iptal (`durum=iptal`, `iptal_eden`, `iptal_zamani`); geçmiş randevu ve son 30 dk iptal edilemez | Alternatifler: Kalıcı silme (eski) | Gerekçe: Rapor, güven skoru ve denetim izi için geçmiş korunmalı.
- **[Silme işlemleri]** → Seçilen: Berber ve hizmet "silme"si `aktif=False` | Alternatifler: Kalıcı silme | Gerekçe: Geçmiş randevular bu kayıtlara referans veriyor.
- **[Otomatik tamamlama]** → Seçilen: Bitişten 60 dk sonra işaretlenmemiş randevu `tamamlandi` + değerlendirme bildirimi (zamanlayıcıda) | Alternatifler: GET isteğinde (eski), hiç otomatik yapmamak | Gerekçe: Yan etkili GET kaldırıldı; işletmeye "gelmedi" işaretlemek için 1 saat pay.
- **[Durum değerleri]** → Seçilen: `onaylandi / tamamlandi / iptal / gelmedi` | Alternatifler: `beklemede` onay akışı | Gerekçe: Berberlerde anında onay norm; `gelmedi` güven skoru için şart.
- **[Rezervasyon ufku]** → Seçilen: 30 gün (`REZERVASYON_UFKU_GUN`) | Alternatifler: 14 (eski), 60 | Gerekçe: Takvim 2 ay gösterip 14 gün açıyordu; 30 gün berberler için yaygın ve env ile değiştirilebilir.
- **[Migration]** → Seçilen: Alembic, tek "ilk şema" migration'ı, SQLite için `render_as_batch` | Alternatifler: Eski DB'yi yerinde dönüştüren migration | Gerekçe: Eski DB yalnızca demo verisi içeriyordu (2 müşteri, 7 randevu); yeniden seed daha güvenli. Bundan sonraki her model değişikliği `alembic revision --autogenerate` ile.

## Ürün

- **[İmza özellik 1]** → Seçilen: **"Her Zamanki"** — müşterinin en sık aldığı berber + hizmet kombinasyonu ve en yakın 3 boş slot ana sayfada; dokun → onayla → randevu | Alternatifler: Bekleme listesi (rakiplerde var), sesli asistan | Gerekçe: Rakiplerde "tekrar al" var ama slotu kullanıcı arıyor; bizde sıfır arama. Müşteriye hız, işletmeye müdavim sadakati; demoda 3 saniyelik randevu çok etkileyici; mevcut veriden hesaplanıyor, ek altyapı yok.
- **[İmza özellik 2]** → Seçilen: **"Bugünün Akışı" + Güven Skoru + WhatsApp tek dokunuş onay** | Alternatifler: Online kapora (ödeme sözleşmesi gerekir), SMS hatırlatma (kontör maliyeti) | Gerekçe: İşletmenin en büyük kaybı no-show. Geçmişe dayalı şeffaf skor (gelmedi −30, geç iptal −10, tamamlanan +5) riskli müşteriyi işaretliyor; `wa.me` linki hazır mesajla WhatsApp'ı açıyor — Türkiye'de en yüksek açılma oranı, sıfır maliyet, API onayı gerektirmiyor.
- **[Ek özellik]** → Seçilen: Bekleme listesi (iptal olunca süresi sığan bekleyenlere push) ve panelden walk-in randevu | Gerekçe: Az eforla boş koltuk ve çift kayıt sorunlarını çözüyor.
- **[Hesap silme]** → Seçilen: Anonimleştirme (ad/telefon/UID/FCM silinir, gelecek randevular iptal, geçmiş randevular kimliksiz kalır) + istemcide Firebase kullanıcısını silme | Alternatifler: Tüm kayıtları kalıcı silmek | Gerekçe: KVKK silme hakkı karşılanırken işletmenin muhasebe kayıtları (ciro) bozulmuyor.
- **[KVKK rızası]** → Seçilen: Kayıtta zorunlu aydınlatma onayı + ayrı, isteğe bağlı ticari ileti izni; ikisi de tarihle saklanıyor | Gerekçe: Açık rıza ve ticari ileti izni hukuken ayrı olmalı (İYS).

## Flutter

- **[API adresi]** → Seçilen: `--dart-define=API_BASE_URL`; verilmezse Android'de `http://10.0.2.2:8000` (emülatörün localhost'u), diğerlerinde `http://localhost:8000` | Alternatifler: Düz `localhost` | Gerekçe: Brief "varsayılan localhost" diyordu; Android emülatöründe `localhost` cihazın kendisi olduğu için çalışmaz, `10.0.2.2` aynı anlamın doğru karşılığı.
- **[Rol yönlendirmesi]** → Seçilen: Splash/giriş sonrası `/ben` çağrısı → müşteri ana ekranı / işletme paneli / onay bekleme ekranı / personel paneli | Gerekçe: Tek kaynak backend; istemcide rol saklanmıyor.
- **[Panel tasarımı]** → Seçilen: Aynı uygulama içinde, mevcut siyah-altın tema ile 4 sekme (Akış, Ekip & Menü, Kapalı Günler, Rapor) | Alternatifler: Ayrı web paneli | Gerekçe: Berber gün içinde telefondan yönetiyor; ayrı uygulama/web ikinci bakım yükü.
- **[Bağımlılıklar]** → Seçilen: `intl` 0.20'ye yükseltildi (flutter_localizations gereği), kullanılmayan `clipboard` (discontinued), `flutter_markdown`, `permission_handler`, `path_provider` kaldırıldı | Gerekçe: Türkçe tarih seçici için `flutter_localizations` şart; kullanılmayan paketler derleme süresi ve risk.

## Yayına alma

- **[Platform]** → Seçilen: Render (Docker web servisi + yönetilen PostgreSQL, Frankfurt), `render.yaml` blueprint | Alternatifler: Railway, Fly.io, VPS | Gerekçe: Brief hedefi; otomatik HTTPS, yönetilen yedek, TR'ye yakın bölge.
- **[Konteyner]** → Seçilen: `python:3.12-slim`, root olmayan kullanıcı, başlangıçta `alembic upgrade head` | Alternatifler: Python 3.14 imajı | Gerekçe: 3.12 için tüm tekerlekler (psycopg2, grpcio) hazır; yerel geliştirme 3.14'te de test edildi.
- **[Zamanlayıcı]** → Seçilen: Uygulama içinde APScheduler, tek worker | Alternatifler: Render Cron Job, Celery | Gerekçe: Mevcut kod; tek instance için yeterli. Ölçeklenirken `SCHEDULER_ENABLED=false` + ayrı cron (Sonraya).

## Tur 2 — Mimari ve tarama (2026-10-09)

- **[Flutter klasör yapısı]** → Seçilen: Özellik bazlı (`core/`, `data/`, `features/<özellik>/{ekran, widgets/}`, `services/`), tüm import'lar `package:` biçiminde | Alternatifler: Katman bazlı (`screens/`, `widgets/`), Clean Architecture (domain/usecase katmanları) | Gerekçe: Ekranın tüm parçaları tek klasörde; dosya taşımak import kırmıyor. Clean Architecture'ın ek katmanları bu boyuttaki uygulamada fayda getirmeden dosya sayısını ikiye katlardı.
- **[Dosya boyutu]** → Seçilen: Ekran dosyası yalnızca durum + düzen; tekrar kullanılan veya 60+ satırlık her görsel parça `widgets/` altına. Hedef ≤ 250 satır (en büyük dosya 250) | Gerekçe: 400–600 satırlık dosyalar okunmuyor ve aynı kalıp (kart, başlık, hata görünümü) her ekranda kopyalanmıştı.
- **[API katmanı]** → Seçilen: `ApiClient` (HTTP, kimlik başlığı, hata çözümleme) + alan servisleri `HesapApi`, `SalonApi`, `RandevuApi`, `PanelApi` | Alternatifler: tek `ApiService` (eski, 50 metot), Dio + Retrofit kod üretimi | Gerekçe: Sorumluluk ayrımı, bağımlılık eklemeden. Kod üretimi bu boyutta gereksiz karmaşa.
- **[Modeller]** → Seçilen: Salon için tipli `Salon` modeli (çalışma saati ve kapalı gün mantığı modelde); panel yanıtları şimdilik `Map` | Gerekçe: Müşteri tarafı en çok kullanılan ve hataya en açık yer; panel uçları tek ekranda tüketiliyor.
- **[Ortak bileşenler]** → Seçilen: `AsenkronGorunum` (yükleniyor/hata/içerik), `BosGorunum`, `BolumBasligi`, `YuzeyKart`, `aramaListesiGoster`, `Alanlar` (doğrulamalı form alanları), `Harici` (telefon, WhatsApp, harita, e-posta) | Gerekçe: Her ekranda farklı yazılmış hata gösterimi, birçok yerde "hata yutma" hatasına yol açmıştı.
- **[State management]** → Seçilen: Mevcut `provider` + ekran içi `StatefulWidget` | Alternatifler: Riverpod, Bloc | Gerekçe: Paylaşılan durum yalnızca randevu akışında var; yeni bir kütüphane bu sorunu çözmeden öğrenme ve geçiş maliyeti getirirdi.
- **[Personel daveti güvenliği]** → Seçilen: E-posta eşleşmesi yalnızca Firebase `email_verified=true` ise; kayıt sonrası doğrulama e-postası otomatik gönderiliyor | Gerekçe: Doğrulanmamış e-postayla personel rolü (salon müşteri verisi) ele geçirilebiliyordu.
- **[Walk-in eşleşmesi]** → Seçilen: Panelden eklenen müşteri yalnızca uygulaması olmayan (UID'siz) kayıtla telefon üzerinden eşleşir | Gerekçe: Kayıtlı kullanıcının hesabına onun bilgisi dışında randevu düşüyordu.
- **[Keşfet]** → Seçilen: Konuma göre listeleme backend'de Haversine mesafesiyle; il/ilçe filtresi Türkçe harf ve aksan duyarsız | Alternatifler: Reverse geocoding ile il/ilçe tahmini (eski), PostGIS | Gerekçe: Eski yöntem il adı tam eşleşmeyince boş liste dönüyordu. Salon sayısı binleri bulunca PostGIS'e geçilir.
- **[Destek ekleri]** → Seçilen: Ek varsa paylaşım menüsüyle (e-posta uygulamasına dosya iliştirerek), yoksa `mailto` | Gerekçe: `mailto` dosya taşıyamaz; eski ekran ekleri "eklendi" deyip göndermiyordu.
- **[Profil fotoğrafı]** → Seçilen: Kaldırıldı, yerine baş harfli avatar | Gerekçe: Fotoğraf sunucuya gitmiyor, uygulama kapanınca kayboluyordu; depolama servisi gelince geri eklenir.
- **[Android derleme ortamı]** → Seçilen: Android SDK `%LOCALAPPDATA%\Android\Sdk`'ya cmdline-tools ile kuruldu, lisanslar kabul edildi, `flutter config --android-sdk` ile bağlandı (kullanıcının açık yetkisiyle) | Gerekçe: Makinede yalnızca platform-tools vardı; APK derlenemiyordu.
- **[Admin işlemleri]** → Seçilen: `backend/araclar.py` CLI (UID bulma, başvuru onay/red, sağlık kontrolü) | Alternatifler: Admin web paneli | Gerekçe: Başvuru hacmi düşükken Render Shell'den tek komut yeterli; web paneli sonraya.
