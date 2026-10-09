# Premium Berber — Analiz Raporu

Tarih: 2026-10-09 · Branch: `feature/v1-hazirlik`

Format: `[Öncelik] · [Efor] · Dosya:satır · Açıklama · Çözüm · Karar` — Durum: ✅ yapıldı / 🟡 kısmen / ⏭️ sonraya / ⬜ bekliyor

> Not: Dosya:satır referansları taramanın yapıldığı andaki (backend `backend/` klasörüne taşındıktan sonraki) koda aittir.

## 0. Tarama Özeti (Adım 1)

| Kontrol | Sonuç |
|---|---|
| Repo yapısı | Backend kökteydi (brief'teki `backend/` yoktu), Flutter `App/` altında. `.venv` (3.416 dosya), `__pycache__`, `berber_yeni.db`, `desktop.ini` git'e eklenmişti. Kökte `.gitignore` yoktu. |
| `.venv` | Bozuk: başka makinedeki Python yoluna işaret ediyor, çalışmıyor. `requirements.txt` yok. |
| `test_slots.py` | **KIRMIZI** — `AssertionError: Bugün geçmiş değil!` (tarihler 2026-04-23'e sabit). Ayrıca test, `utils`'i import etmek yerine fonksiyonları kopyalıyor; yani gerçek kodu test etmiyor. |
| uvicorn / `/docs` | Ayağa kalkıyor, `/docs` 200. `serviceAccountKey.json` yok → push devre dışı. |
| `/isletmeler/*` | **404** — router `main.py`'de bağlanmamış. Uygulamadaki işletme kaydı her zaman hata veriyor. |
| `flutter pub get` | OK (91 paket güncel değil, 1 paket discontinued). |
| `flutter analyze` | 0 error, 0 warning, 179 info (168'i `withOpacity` deprecation). |

## 0.1 Rakip Analizi

| Rakip | Öne çıkan özellikler | Fiyat modeli | En çok şikâyet edilen 3 şey |
|---|---|---|---|
| **Booksy** | Pazaryeri (müşteri uygulaması), online ödeme, no-show ücreti, "Boost" pazarlama | ~29,99 $/ay + personel başı ~20 $/ay; Boost 49,99 $+ | 1) Müşteri hizmetleri (Trustpilot 3,1 / 16.500 yorum) 2) Ödeme/iade ve kartla ilgili sürprizler 3) Pazaryeri müşterisinin kime yazıldığı ve yorumların Google'a taşınmaması |
| **Fresha** | Ücretsiz/ucuz yazılım, pazaryeri, ödeme, pazarlama | 2025'ten itibaren abonelik (~14,95–19,95 $/ay, kaynaklar çelişkili) + pazaryeri yeni müşterisine %20 komisyon + kart komisyonu | 1) Beklenmedik ücretler/fatura itirazları 2) Yavaş destek (telefon desteği ücretli) 3) Komisyonun "yeni müşteri" tanımı |
| **Squire** | Berberlere özel, POS, ödeme, berber başına ciro | Sabit ~100–250 $/ay (kaynaklar 30 $'dan başlatıyor, çelişkili) | 1) Katı/esnek olmayan sistem 2) Booking linki UI'ı 3) Fiyat bilgilerinin belirsizliği |
| **Treatwell** | Avrupa pazaryeri, salon yazılımı | Yeni müşterinin ilk randevusunda ~%35 komisyon + aylık ücret | 1) "Yeni müşteri" komisyonunun eski müşteriye de kesilmesi 2) Geç iptalde bile komisyon 3) Sorunlu müşteriye karşı salonun elinin bağlı olması (Litvanya rekabet kurumu 09/2026'da ücret şeffaflığı kararı verdi) |
| **TR uygulamaları** (Kolay Randevu, Kuafix, Salon Randevu, Kuaförvar) | Takvim, SMS hatırlatma, işletme paneli | Kuafix: temel ücretsiz, gelişmiş 199 ₺/ay; diğerleri fiyat yayımlamıyor; SMS genelde kontörlü | 1) Uygulamadaki fiyatın salondakiyle tutmaması (Şikâyetvar) 2) Düşük kullanıcı puanları 3) SMS maliyeti / işletmenin güncel bilgi girmemesi |
| **Google Haritalar (Reserve with Google)** | Haritadaki işletme kartından "Randevu al" butonu, Google Takvim'e ekleme | Ücretsiz ama yalnızca anlaşmalı yazılım ortağı üzerinden | 1) Tek başına kullanılamaz (partner şart) 2) Değişikliklerin yansıması 48 saate kadar 3) TR'de berberler için partner kapsamı dar |

**Bizim için fırsatlar**
1. **Komisyonsuz, sabit ve şeffaf fiyat** — rakiplerin en büyük şikâyeti sürpriz ücretler.
2. **WhatsApp ile tek dokunuş onay/hatırlatma** — TR'de SMS kontörü yerine `wa.me` derin linki: maliyet sıfır, açılma oranı yüksek.
3. **Güven/no-show skoru** — Treatwell'de salonun sorunlu müşteriye karşı elinin bağlı olması şikâyeti var; biz işletmeye geçmişe dayalı görünürlük veriyoruz.
4. **"Her zamanki" tek dokunuş randevu** — müdavimler için berber + hizmet + en yakın boş slot otomatik.
5. **Fiyat tutarlılığı** — fiyat randevu anında mühürleniyor (zaten var), işletme panelinden güncel tutuluyor.
6. **Google Haritalar** — ileride Reserve with Google partnerliği veya en azından Google İşletme Profili'ne randevu linki.

---

## 1. Hatalar, Eksikler ve Sorunlar

| # | Öncelik · Efor | Dosya:satır | Açıklama | Çözüm | Karar | Durum |
|---|---|---|---|---|---|---|
| H1 | Kritik · S | backend/auth.py:9 | `ADMIN_SECRET` varsayılanı (`***KALDIRILDI***`) public repoda açık. Tüm admin uçları bu tek header'a bağlı. | Varsayılan kaldırıldı; env yoksa admin-secret yolu tamamen kapalı. Admin yetkisi Firebase UID listesiyle (`ADMIN_UIDS`). **Şifre git geçmişinde kaldığı için değiştirilmeli** (BENDEN_GEREKENLER). | UYGULA | ✅ |
| H2 | Kritik · M | backend/routers/*.py (`x_firebase_uid: Header`) | Kimlik doğrulama yok: istemci `x-firebase-uid` header'ını kendisi yazıyor; herkes başkası adına randevu alabilir/silebilir, profil okuyabilir. | Firebase ID token (`Authorization: Bearer`) backend'de `firebase_admin.auth.verify_id_token` ile doğrulanıyor. Geliştirme modunda (`AUTH_MODE=dev`) imzasız çözümleme. | UYGULA | ✅ |
| H3 | Kritik · S | backend/main.py:9-10 | `isletmeler` router'ı bağlanmamış → `/isletmeler/kayit` 404, işletme kaydı hiç çalışmıyor. | Router bağlandı; kayıt token'dan UID alıyor. | UYGULA | ✅ |
| H4 | Kritik · S | App/lib/main.dart:40-48 | FCM token hiçbir zaman backend'e gönderilmiyor (`fcm-token-guncelle` çağrılmıyor) → hiçbir push bildirimi ulaşmıyor. Ön planda gelen bildirim gösterilmiyor. | Girişten sonra token kaydı + `onTokenRefresh`; ön planda SnackBar. | UYGULA | ✅ |
| H5 | Kritik · M | backend/utils.py:84,97,108,230,257,296 | Tüm "şimdi" hesapları sunucu saatine (`datetime.now()`) bağlı. Render/Docker UTC çalışır → İstanbul'a göre 3 saat kayma: geçmiş saatlere randevu, yanlış hatırlatma. | `Europe/Istanbul` (zoneinfo + tzdata) tek kaynak `simdi()` fonksiyonu. | UYGULA | ✅ |
| H6 | Kritik · M | backend/routers/randevular.py:123-279 | Randevu oluştururken tatil günü ve berber izni kontrol edilmiyor (API ile tatile randevu alınabiliyor); berberin salona ait olduğu, hizmetlerin salona ait olduğu kontrol edilmiyor; `hizmet_ids`'in bir kısmı bulunamazsa sessizce yok sayılıyor; `salon_id` hiç kaydedilmiyor (Randevularım'da "Bilinmiyor"). | Tüm doğrulamalar tek `slot_servisi` içinde; `salon_id` berberden türetiliyor. | UYGULA | ✅ |
| H7 | Kritik · M | backend/routers/randevular.py:221-278 | Yarış durumu: aynı slota eşzamanlı iki istek ikisi de "boş" görüp çift randevu oluşturabiliyor. | Berber satırı kilidi (`SELECT … FOR UPDATE` PostgreSQL) + süreç içi kilit + işlem içinde tekrar kontrol; çakışmada 409. | UYGULA | ✅ |
| H8 | Yüksek · M | backend/utils.py:155,196; randevular.py:203-216,409,467; App/lib/screens/randevu_al/adim4_saat.dart:46-94 | Çalışma saatleri 10:00–22:00 / Pazar 17:00 olarak 5 farklı yerde sabit yazılmış; salonların `acilis_saati/kapanis_saati` alanları yok sayılıyor. Flutter slot mantığını ayrıca kopyalıyor (iki doğruluk kaynağı). | Salon bazlı saat + kapalı gün; slot hesabı yalnızca backend'de (`/randevular/musait-saatler`), Flutter sadece gösteriyor. | UYGULA | ✅ |
| H9 | Yüksek · S | backend/routers/randevular.py:489-510 | İptal = kalıcı silme (geçmiş kaybolur, rapor bozulur). Geçmiş randevular da "iptal" edilebiliyor (dakika farkı negatifken kontrol atlanıyor). | Soft iptal (`durum=iptal`), geçmiş randevu iptal edilemez, son 30 dk kuralı korunuyor. | UYGULA | ✅ |
| H10 | Yüksek · S | backend/routers/degerlendirmeler.py:98 | `d.musteri.soyad[0]` — soyadı boş müşteride (otomatik "Misafir" kayıtları) `IndexError` → endpoint 500. | Güvenli kısaltma. | UYGULA | ✅ |
| H11 | Yüksek · S | backend/routers/degerlendirmeler.py:56-74 | Değerlendirme `Randevu.puan`'ı güncellemiyor → Randevularım'da "Değerlendir" butonu kaybolmuyor; salon puanı hiç güncellenmiyor. | Randevuya da yazılıyor, berber ve salon ortalaması yeniden hesaplanıyor. | UYGULA | ✅ |
| H12 | Yüksek · S | backend/routers/randevular.py:370-383 | `/randevular/berber-plani/{id}` kimlik doğrulamasız; müşteri adlarını herkese açıyor (KVKK ihlali). | İşletme/personel yetkisi şart. | UYGULA | ✅ |
| H13 | Yüksek · S | backend/routers/isletmeler.py:47-62 | `/isletmeler/` işletme sahiplerinin telefon ve e-postasını herkese listeliyor. | Admin'e kısıtlandı. | UYGULA | ✅ |
| H14 | Yüksek · S | backend/main.py:16-19,39-61 | İki ayrı scheduler oluşturuluyor, biri import anında başlatılıyor → değerlendirme görevi iki kez çalışıyor; testlerde/çoklu worker'da tekrar eden bildirimler. `@app.on_event` deprecated. | `lifespan` + tek scheduler + `SCHEDULER_ENABLED` env. | UYGULA | ✅ |
| H15 | Yüksek · S | backend/utils.py:246-280 | Hatırlatma görevi yalnızca bugünün randevularına bakıyor (gece yarısını geçen pencere kaçıyor) ve mesajda "kanki" gibi gayriresmî dil. | İki günlük sorgu + profesyonel metin. | UYGULA | ✅ |
| H16 | Yüksek · S | backend/routers/randevular.py:330-353 | GET `/benim-randevularim` veritabanına yazıyor (otomatik tamamlandı). Yan etkili GET. | Otomatik tamamlama scheduler görevine taşındı (okuma anında da güvenli yardımcı). | UYGULA | ✅ |
| H17 | Yüksek · S | backend/routers/randevular.py:302 | Randevu durumu yalnızca admin-secret ile değişiyor → işletme "tamamlandı/gelmedi" işaretleyemiyor, değerlendirme akışı fiilen hiç başlamıyor. | İşletme paneli uçları (`/panel/randevular/{id}/durum`). | UYGULA | ✅ |
| H18 | Yüksek · S | App/lib/screens/randevu_al/randevu_flow.dart:50-60 | Provider akış başında sıfırlanmıyor: yarıda bırakılan akışın hizmet/berber seçimleri başka salona taşınıyor (başka salonun berberiyle randevu!). | Akış açılışında `reset()` + salon/berber ataması. | UYGULA | ✅ |
| H19 | Yüksek · S | App/lib/screens/randevu_al/adim1_hizmet.dart:30; api_service.dart:50 | Hizmetler salondan bağımsız global liste; pazaryeri modeliyle uyumsuz. | `Hizmet.salon_id`; liste `?salon_id=` ile. | UYGULA | ✅ |
| H20 | Yüksek · M | App/lib/screens/auth/login_screen.dart:30; splash_screen.dart:41 | İşletme sahibi giriş yapınca müşteri ekranına düşüyor; işletme paneli yok. | `/ben` ucu ile rol tespiti → rol bazlı yönlendirme + İşletme Paneli. | UYGULA | ✅ |
| H21 | Yüksek · S | App/lib/screens/profil_ekrani.dart:212 | "Hesabı Sil" butonu hiçbir şey yapmıyor (mağaza reddi + KVKK). | Backend anonimleştirme + Firebase kullanıcı silme. | UYGULA | ✅ |
| H22 | Orta · S | App/lib/screens/randevu_al/adim3_tarih.dart:70-72 | Takvim 2 ay gösteriyor, backend yalnızca 14 gün açıyor; kullanıcı neden seçemediğini anlamıyor. | Rezervasyon ufku backend'den (`REZERVASYON_UFKU_GUN`) ve takvim sınırı ona göre. | UYGULA | ✅ |
| H23 | Orta · S | backend/seed.py:12-16 | Seed salon/berber/hizmet siliyor ama randevuları silmiyor → yetim FK'ler. Kişisel telefon/Instagram gerçek kişiye ait. | Tüm tablolar sıralı temizleniyor; demo verileri kurgusal. | UYGULA | ✅ |
| H24 | Orta · S | backend/test_slots.py:76 | Sabit tarihler, kopya kod, pytest değil. | pytest + `simdi()` sabitleme + gerçek modül importu. | UYGULA | ✅ |
| H25 | Orta · S | backend/routers/berberler.py:162-163 | Yüklenen dosya uzantısı istemcinin dosya adından alınıyor. | Uzantı content-type'tan türetiliyor. | UYGULA | ✅ |
| H26 | Orta · S | backend/routers/berberler.py:73; hizmetler.py:66 | Randevusu olan berber/hizmet kalıcı siliniyor → geçmiş randevular bozuk. | Soft silme (`aktif=False`). | UYGULA | ✅ |
| H27 | Orta · S | backend/routers/tatil.py; models.py:123-127 | Tatil günleri tüm salonlar için global; `tarih` unique → iki salon aynı günü kapatamaz. | `salon_id` + (salon_id, tarih) unique. | UYGULA | ✅ |
| H28 | Orta · S | backend/routers/musteriler.py:9; randevular.py:512-558 | Müşteri profili iki farklı router'da çift implementasyon; `/musteriler/ekle` UID'yi query'den alıyor. | Token'dan UID; uçlar korunuyor, mantık tek yerde. | UYGULA | ✅ |
| H29 | Düşük · S | App/lib/screens/home/home_screen.dart | 845 satırlık kullanılmayan eski tek-salon ana sayfası (ölü kod). | Kaldırıldı (git geçmişinde duruyor). | UYGULA | ✅ |
| H30 | Düşük · S | backend/routers/dukkan.py:9-80; kurumsal.py | Tek-dükkan dönemi uçları (`/dukkan/`, `/kurumsal/bilgiler`). | Geriye uyumluluk için duruyor, `deprecated` işaretlendi. | UYGULA | ✅ |
| H31 | Düşük · S | App/lib/screens/profil_ekrani.dart:85 | Profil fotoğrafı yalnızca yerelde tutuluyor, sunucuya gitmiyor. | — | SONRAYA (depolama servisi gerekir) | ⏭️ |

## 2. Geliştirme ve İyileştirmeler

| # | Öncelik · Efor | Dosya:satır | Açıklama | Çözüm | Karar | Durum |
|---|---|---|---|---|---|---|
| G1 | Yüksek · M | backend/utils.py | Slot mantığı string listesi eşleştirmesi; yardımcılar Firebase importuna bağlı olduğu için test edilemiyor. | `slot_servisi.py`: dakika aralıklarıyla saf fonksiyonlar (Firebase'den bağımsız), `bildirim.py` ayrı. | UYGULA | ✅ |
| G2 | Yüksek · S | backend/models.py:90-108 | Randevunun süresi saklanmıyor; hizmet süresi sonradan değişirse dolu slotlar kayıyor. | `Randevu.sure_dk` mühürleniyor (fiyat gibi). | UYGULA | ✅ |
| G3 | Yüksek · M | App/lib/services/api_service.dart | Her metod kendi hata ayrıştırmasını yapıyor; hatalar `Exception: Exception: …` olarak kullanıcıya gösteriliyor. | Ortak `_istek` yardımcı + `ApiHata` sınıfı + Türkçe mesajlar. | UYGULA | ✅ |
| G4 | Orta · S | backend/*.py | `print` ile loglama; konuşma dili ("kanki") API yanıtlarında. | `logging`; kullanıcıya dönen metinler profesyonel. | UYGULA | ✅ |
| G5 | Orta · S | App/lib (168 yer) | `withOpacity` deprecated. | `withValues(alpha:)`. | UYGULA | ✅ |
| G6 | Orta · S | backend/routers/raporlar.py | Raporlar salon ayrımı olmadan global. | İşletme panelinde salon bazlı özet rapor. | UYGULA | ✅ |
| G7 | Orta · S | App/lib/screens/randevu_al/adim2_personel.dart:51 | Hata yutuluyor, "berber bulunamadı" gösteriliyor. | Hata durumu + yeniden dene. | UYGULA | ✅ |
| G8 | Düşük · M | backend | Yanıt şemaları (Pydantic response_model) yok; elle dict. | Yeni uçlarda kısmen. | SONRAYA | ⏭️ |
| G9 | Düşük · M | App/lib | Erişilebilirlik: ikon butonlarında `tooltip`/`Semantics` eksik, sabit font boyutları. | Yeni ekranlarda tooltip; geneli sonraya. | SONRAYA | 🟡 |
| G10 | Düşük · S | App/pubspec.yaml | 91 paket güncel değil, 1 discontinued (`clipboard`). | Kullanılmayan `clipboard` kaldırılabilir; toplu güncelleme ayrı iş. | SONRAYA | ⏭️ |

## 3. Gerçek Kullanıma Hazırlık

| # | Öncelik · Efor | Konu | Açıklama | Çözüm | Karar | Durum |
|---|---|---|---|---|---|---|
| P1 | Kritik · M | Kimlik & roller | Roller tanımsız. | `musteri / isletme / personel / admin`; `/ben` ucu; `rol_gerekli` dependency. | UYGULA | ✅ |
| P2 | Kritik · M | PostgreSQL + Alembic | `create_all`, sabit SQLite URL. | `DATABASE_URL` env; Alembic ilk migration; SQLite'ta `render_as_batch`. | UYGULA | ✅ |
| P3 | Kritik · S | `.env` | Gizli bilgiler kodda. | `config.py` + `.env.example`. | UYGULA | ✅ |
| P4 | Yüksek · M | Docker & Render | Yok. | `backend/Dockerfile`, `docker-compose.yml` (Postgres), `render.yaml`. | UYGULA | 🟡 |
| P5 | Yüksek · S | CORS | `*` + credentials. | `CORS_ORIGINS` env (mobil uygulama CORS'a tabi değil; web paneli için). | UYGULA | ✅ |
| P6 | Yüksek · S | Flutter baseUrl | Sabit yerel IP (App/lib/config.dart:5). | `--dart-define=API_BASE_URL`; varsayılan localhost (Android emülatörde 10.0.2.2). | UYGULA | ✅ |
| P7 | Yüksek · S | HTTPS / cleartext | `usesCleartextTraffic="true"` release manifest'te. | Yalnızca debug/profile manifest'te. Render HTTPS sağlar. | UYGULA | ✅ |
| P8 | Yüksek · S | FCM | Token kaydı yok, Android 13 bildirim izni yok, servis hesabı yalnızca dosyadan. | Token kaydı, `POST_NOTIFICATIONS`, `FIREBASE_CREDENTIALS_JSON` env desteği. | UYGULA | ✅ |
| P9 | Yüksek · S | KVKK | Açık rıza alınmıyor; hesap silme yok. | Kayıtta zorunlu aydınlatma onayı + isteğe bağlı ticari ileti izni (tarihleriyle saklanıyor); hesap silme = anonimleştirme. | UYGULA | ✅ |
| P10 | Yüksek · S | Mağaza | `applicationId=com.example…`, release debug anahtarıyla imzalanıyor. | `key.properties` varsa release imzası; applicationId değişikliği Firebase kaydı gerektirdiği için BENDEN_GEREKENLER. | UYGULA | 🟡 |
| P11 | Orta · S | Yedekleme | Yok. | Render Postgres otomatik yedek + `scripts/yedekle.sh` (pg_dump). | UYGULA | ✅ |
| P12 | Orta · S | Uploads | Render diski kalıcı değil. | Kalıcı disk/obje depolama → BENDEN_GEREKENLER. | SONRAYA | ⏭️ |
| P13 | Orta · S | Sağlık kontrolü | Yok. | `/saglik` ucu (DB ping). | UYGULA | ✅ |
| P14 | Düşük · M | Rate limiting | Yok. | Render/Cloudflare katmanında; sonraya. | SONRAYA | ⏭️ |

## 4. Üst Seviyeye Taşıyacak Özellikler

| # | Fikir | Rakiplerde | Değer | Karar | Durum |
|---|---|---|---|---|---|
| F1 | **⭐ İMZA: "Her Zamanki" — tek dokunuş randevu.** Müşterinin en sık gittiği berber + hizmet kombinasyonu ve **en yakın boş slot** otomatik bulunur; ana sayfada tek kart, tek dokunuşla onay. | Booksy/Fresha'da "tekrar randevu al" var ama slotu kullanıcı arar. | Müşteri: 3 saniyede randevu. İşletme: müdavim sadakati. Demo: çok etkileyici. | UYGULA | ✅ |
| F2 | **⭐ İMZA: "Bugünün Akışı" + Güven Skoru + WhatsApp tek dokunuş onay.** İşletme günün randevularını saat sırasıyla, müşteri/hizmet/süre/ücret, toplam ciro ve her müşterinin geçmişe dayalı güven skoruyla (gelmedi/geç iptal) görür; riskli müşteriye tek dokunuşla hazır WhatsApp onay mesajı (`wa.me`, SMS kontörü yok). | Rakiplerde no-show ücreti var, şeffaf güven skoru + ücretsiz WhatsApp onayı yok. | İşletme: no-show azalır, sıfır maliyet. Müşteri: tanıdık kanaldan hatırlatma. | UYGULA | ✅ |
| F3 | Bekleme listesi + boşalan slot bildirimi: dolu güne "boşalırsa haber ver"; iptal olunca ilk sıradakilere push. | Booksy/Fresha'da var. | Boş koltuk kalmaz. | UYGULA | ✅ |
| F4 | Akıllı en yakın boş slot (çakışma yanıtında ve "Her zamanki" kartında). | Kısmen. | Daha az terk. | UYGULA | ✅ |
| F5 | İşletmenin telefonla/kapıdan gelen müşteriyi panelden eklemesi (walk-in). | Var. | Takvim tek kaynak olur. | UYGULA | ✅ |
| F6 | Google Haritalar / İşletme Profili için paylaşılabilir salon linki. | Partnerlik gerekir. | Keşfedilebilirlik. | SONRAYA (partner başvurusu) | ⏭️ |
| F7 | Online kapora / no-show ücreti (iyzico). | Booksy/Fresha. | No-show azaltır. | SONRAYA (ödeme sözleşmesi) | ⏭️ |
| F8 | Berberin kendi takvimini gördüğü personel görünümü. | Var. | Personel bağımsızlığı. | UYGULA (rol + uç; UI işletme panelini paylaşır) | 🟡 |

## Uygulama Sırası

| Sıra | Madde(ler) | "Bitti" tanımı |
|---|---|---|
| 1 | H1, H2, H3, H5, H12, H13, P1, P3, P5 | Admin şifresi kodda yok; tüm kullanıcı uçları doğrulanmış token istiyor; testlerde sahte UID ile başkasının randevusu silinemiyor. |
| 2 | G1, G2, H6, H7, H8, H9, H10, H11, H16, H24, P2 | `pytest` yeşil; slot/çakışma/tatil/izin/geçmiş saat/yarış testleri var; Alembic `upgrade head` boş DB'yi kuruyor; seed çalışıyor. |
| 3 | H4, H14, H15, H17, H18, H19, H22, G3, G7, P6 | Uygulamada: kayıt → salon → hizmet → berber → tarih → backend'den gelen saatler → onay; randevu salon adıyla görünüyor; FCM token kaydediliyor; `flutter analyze` hatasız. |
| 4 | H20, F5, G6, H27, H26 | İşletme sahibi girişte panele düşüyor; günün randevuları müşteri/hizmet/süre/toplam ücretle görünüyor; tamamlandı/gelmedi işaretlenebiliyor; personel/hizmet/tatil yönetiliyor. |
| 5 | P4, P7, P8, P9, P10, P11, P13, H21 | `docker compose up` ile Postgres + API ayağa kalkıyor; hesap silme çalışıyor; KVKK onayı kaydediliyor. |
| 6 | F1, F2, F3, F4 | "Her zamanki" kartı en yakın slotu öneriyor; güven skoru ve WhatsApp butonu panelde; iptal → bekleme listesine bildirim (testli). |
| 7 | G4, G5, H23, H25, H28, H29, H30 | Kalan iyileştirmeler; `flutter analyze` info sayısı belirgin düşük. |

---

## Doğrulama Sonuçları (Adım 2 sonu)

| Kontrol | Sonuç |
|---|---|
| `pytest` (backend) | ✅ 44/44 geçti — saf slot kuralları, çakışma, kapanış/Pazar/kapalı gün, tatil & izin, geçmiş saat, ufuk, salonlar arası hizmet, 8 eşzamanlı istekte tek kazanan, iptal kuralları, bekleme listesi bildirimi, değerlendirme, "Her zamanki", panel yetki izolasyonu, walk-in, güven skoru, admin, KVKK, hesap silme, zamanlayıcı görevleri |
| `alembic upgrade head` + `alembic check` | ✅ boş DB'den şema kuruluyor, model ile fark yok |
| `seed.py` | ✅ 6 salon, 12 berber, 60 hizmet, 16 randevu |
| Canlı API uçtan uca (uvicorn + httpx) | ✅ kayıt (KVKK) → salon → hizmet → berber → takvim → saat → randevu → aynı slota ikinci kişi 409 → işletme panelinde görünme → bekleme listesi → iptal → Her Zamanki |
| `flutter analyze` | ✅ **No issues found** (başlangıçta 179 info) |
| `flutter test` | ✅ 7/7 (yardımcılar, model ayrıştırma, slot widget'ı) |
| `flutter build apk --debug` | ⚠️ Ortam engeli. 1. deneme: JDK 25 ↔ Gradle 8.14 uyumsuz → Gradle 9.1.0 + AGP 8.13.0'a yükseltildi, bu aşama geçildi. 2. deneme: Android SDK lisansları kabul edilmemiş (NDK 28.2) → `flutter doctor --android-licenses` gerekiyor (BENDEN_GEREKENLER #5). Dart tarafı `analyze` ile derleme hatasız. |
| Docker imajı | ⚠️ Bu makinede Docker yok; Dockerfile/compose derlenerek doğrulanamadı |

## Sonraya Bırakılanlar

| Madde | Neden |
|---|---|
| H31 Profil fotoğrafını sunucuya yükleme | Kalıcı obje depolama (Cloudinary/S3) hesabı gerekiyor; Render diski geçici. |
| G8 Tüm uçlara Pydantic `response_model` | Davranış değiştirmeyen, geniş kapsamlı bir refactor; çekirdek akış önceliklendirildi. |
| G9 Kapsamlı erişilebilirlik denetimi | Yeni ekranlarda tooltip/Semantics eklendi; eski ekranların tamamı ayrı bir tur ister. |
| G10 Paket sürümlerinin toplu yükseltilmesi | 82 paketin major güncellemesi regresyon riski taşıyor; ayrı branch'te yapılmalı. |
| P10 `applicationId` değişikliği | Firebase'de yeni Android uygulaması kaydı gerektiriyor (BENDEN_GEREKENLER #8). |
| P12 Kalıcı yükleme depolaması | Ücretli/harici servis hesabı gerekiyor. |
| P14 Rate limiting | Render önünde Cloudflare veya `slowapi`; trafik oluşunca. |
| F6 Reserve with Google | Partnerlik başvurusu gerekiyor. |
| F7 Online kapora / no-show ücreti | Ödeme kuruluşu sözleşmesi gerekiyor; güven skoru + WhatsApp onayı ilk adım olarak bunun yerine geçiyor. |
| F8 Personel için ayrı takvim görünümü | Rol ve uçlar hazır, personel şimdilik panelin "Akış" sekmesini (yalnızca kendi randevuları) görüyor. |
| Zamanlayıcının ayrı cron'a taşınması | Tek instance için gerek yok; ölçeklenirken. |

---

## Tur 2 — Tam Kod Taraması ve Mimari (2026-10-09)

### Düzeltilen hatalar

| # | Öncelik | Yer | Hata | Durum |
|---|---|---|---|---|
| T1 | Kritik | backend/routers/hesap.py | Personel daveti doğrulanmamış e-postayla eşleşiyordu → biri personelin adresiyle hesap açıp salonun müşteri verilerine erişebilirdi. | ✅ `email_verified` şartı + test |
| T2 | Yüksek | backend/routers/panel.py | Panelden eklenen randevu, aynı telefonlu **kayıtlı** kullanıcının hesabına bağlanıyordu (onun "Randevularım"ına düşüyordu). | ✅ yalnızca UID'siz kayıtla eşleşir + test |
| T3 | Yüksek | App auth_service | Firebase hesabı açılıp sunucu kaydı başarısız olursa hesap yarım kalıyor, tekrar denemede "e-posta zaten kullanımda". | ✅ geri alma |
| T4 | Yüksek | App (tüm uygulama) | Favoriye ekleme butonu hiçbir ekranda yoktu; favoriler hiç doldurulamıyordu. | ✅ salon detayında ♥ |
| T5 | Yüksek | App favoriler | Favoriler ekranı yalnızca geçmiş randevulardaki berberleri gösteriyordu. | ✅ birleşik liste |
| T6 | Orta | App salon detay | Pazar günü sabit "Kapalı"; salonun gerçek Pazar saatleri ve kapalı günleri yok sayılıyordu. | ✅ `Salon.calismaSaati` |
| T7 | Orta | App keşfet + backend | "Konumuma yakın" mesafeye göre sıralamıyordu; il adı harf farkında ("Istanbul"/"İstanbul") sonuç boş. | ✅ Haversine + normalize + test |
| T8 | Orta | App destek | "Dosya ekle" sahteydi; dosyalar e-postaya eklenmiyordu. | ✅ paylaşım menüsüyle gerçek ek |
| T9 | Orta | App profil | Profil fotoğrafı yalnızca bellekte; uygulama kapanınca kayboluyordu. | ✅ kaldırıldı (baş harfli avatar) |
| T10 | Orta | App giriş | Mevcut işletme sahibinin giriş yapacağı yol yoktu (yalnızca kayıt). | ✅ "Giriş Yapın" bağlantıları |
| T11 | Orta | App (8 ekran) | Yükleme hataları yutuluyor, ekran "bulunamadı/boş" diyordu. | ✅ `AsenkronGorunum` |
| T12 | Düşük | App adım 1 | Salonda hizmet yokken "Hizmetler yüklenemedi" hatası. | ✅ ayrı boş durum |
| T13 | Düşük | App ana sayfa / randevularım | Sekmeye dönünce veri tazelenmiyordu. | ✅ sekme değişiminde yenileme |
| T14 | Düşük | App | İki ayrı değerlendirme arayüzü; dialog yorum alanı kullanmıyordu. | ✅ tek ekran, yorumlu |
| T15 | Düşük | backend | Ruff: kullanılmayan import, `raise ... from` eksikleri, tek satır `if`. | ✅ `ruff check` temiz |
| T16 | Düşük | App | Ölü kod: `home_screen.dart` (dışarıdan geri gelmişti), `webview_screen.dart`; kullanılmayan `geocoding`, `flutter_rating_bar`, `webview_flutter`. | ✅ kaldırıldı |

### Mimari

- Flutter: `screens/ widgets/ services/ models/` → **özellik bazlı** `core/ data/ features/ services/`.
- En büyük dosya 845 → **250** satır; 400+ satırlık 10 dosya bölündü (Keşfet 457 → 140 + 4 bileşen, Ana sayfa 635 → 190 + 4 bileşen, Profil 495 → 165 + 2 bileşen …).
- `ApiService` (50 metot) → `ApiClient` + `HesapApi` / `SalonApi` / `RandevuApi` / `PanelApi`.

### Doğrulama

| Kontrol | Sonuç |
|---|---|
| `pytest` | ✅ 48/48 (yeni: Türkçe normalize, mesafe sıralaması, favori işareti, doğrulanmamış e-posta, walk-in izolasyonu) |
| `ruff check` | ✅ temiz |
| `flutter analyze` | ✅ No issues found |
| `flutter test` | ✅ 14/14 (yeni: Salon saatleri, API hata çözümleme, favori JSON, telefon biçimi) |
| Canlı API duman testi | ✅ kayıt → harf duyarsız/konumlu keşfet → randevu → çakışma 409 |
| Paket adı betiği | ✅ geçici kopyada gerçek çalıştırma; yanlış JSON'u reddediyor |
| APK derlemesi | ✅ Android SDK kuruldu, lisanslar kabul edildi → `flutter build apk --debug` ve `--release` (59 MB, R8 + release manifest) başarılı. Release şimdilik debug anahtarıyla imzalı (key.properties yok). Gerçek cihaz/emülatör bağlı olmadığı için cihazda çalıştırılmadı. |
