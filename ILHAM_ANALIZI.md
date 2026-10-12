# İlham Analizi — Açık Kaynak Randevu Uygulamalarıyla Karşılaştırma

Tarih: 2026-10-11 · Dal: `feature/v1-hazirlik` (değişiklik yapılmadı) · Aşama 1 (yalnızca inceleme)

**Yöntem:** 26 repo `git clone --depth 1` ile proje dışına (`../ilham_repolar/`) klonlandı. Hiçbir repoda kod, betik, build ya da paket kurulumu çalıştırılmadı; yalnızca README, klasör yapısı, model/şema, ekran ve iş mantığı dosyaları okundu. Bizim taraf tahminle değil kodla karşılaştırıldı: `backend/models.py`, `backend/routers/*`, `slot_servisi.py`, `randevu_servisi.py`, `gorevler.py`, `App/lib/features/*`.

**Durum işaretleri:** ✅ var · 🟡 kısmen · ❌ yok — Uygulama sonrası: ✅ yapıldı / 🟡 kısmen / ⏭️ sonraya
**Efor:** S ≤ yarım gün · M 1–2 gün · L 3+ gün

---

## 0. Yönetici Özeti

**En değerli 5 bulgu**
1. **İşletme hiç bildirim almıyor.** Push yalnızca müşteriye gidiyor (`bildirim_gonder` 4 çağrının 4'ü de `r.musteri.fcm_token`). Müşteri randevu alınca ya da iptal edince berberin haberi olmuyor. Token altyapısı işletme ve personel için zaten var. vfix ve thunderbird her olayda sahibe de bildirim gönderiyor.
2. **Erteleme yok.** Müşteri iptal edip yeniden almak zorunda; bu arada slotu kaybedebiliyor. django-appointment (erteleme sınırı + geçmiş + neden), Doctor-Hunt (tek işlemde eski slotu bırak, yenisini tut) ve calma bunu çözüyor.
3. **Personel takvimi kaba.** Öğle arası, berbere özel haftalık izin günü ve saatlik bloke yok; her Pazartesi izinli bir berber için her hafta ayrı izin girilmesi gerekiyor. Gerato25 (günde 2 vardiya), vfix (gün başına çoklu aralık + tarihe özel saat istisnası) ve django (WorkingHours + Unavailability) iyi modeller sunuyor.
4. **Elimizdeki veri gösterilmiyor.** Yorumlar backend'de var (`GET /degerlendirmeler/berber/{id}`) ama uygulamada hiçbir ekranda okunmuyor; salon fotoğrafları API'de dönüyor ama gösterilmiyor ve yüklenemiyor. Takvimde tamamen dolu günler açık görünüyor.
5. **Sağlamlıkta öndeyiz.** İncelenen 26 reponun hiçbirinde idempotency, çok worker'lı kilit, kısmi tekil indeks, yük testi ya da KVKK akışı yok. Bazıları anti-örnek: Stripe gizli anahtarı istemcide (DebankurMandal), SQL injection + düz metin parola (edoc), düz `http://IP` (Snipped). Fikir alınacak, mimari alınmayacak. Tek istisna thunderbird (bizimle aynı yığın).

**Önerilen ilk 3 özellik:** #1 İşletmeye anlık bildirim (S) · #2 Müşterinin randevu ertelemesi (M) · #4 Berber haftalık izin + öğle arası + saatlik bloke (M)

---

## 1. Repo Özetleri

Klonlanamayan repo yok (26/26). Atlananlar (konu dışı): `DietrichGebert/ponytail`, `walkinglabs/learn-harness-engineering`, `google-research/arco-era5`.

> **Lisans notu:** "Yok" = LICENSE dosyası yok → tüm hakları saklı; **kod alınmaz**, yalnızca fikir. İki Laravel reposunda `composer.json` içinde `"license": "MIT"` var; bu, Laravel iskeletinin varsayılan alanı. Projenin kendi lisansı sayılmaz, yine kod alınmaz. MPL-2.0 (thunderbird) brief'teki izinli listede olmadığından ondan da yalnızca fikir alınır.

### A) Berber/kuaför randevu

| Repo | Ne yapıyor / öne çıkan | Teknoloji | Lisans | Fayda |
|---|---|---|---|---|
| **DebankurMandal/barber-booking-app** | Tek dükkan; hizmet → tarih/saat → Stripe ödeme; admin tüm randevuları canlı görür; onboarding, hesap silme. ⚠️ Stripe `payment_intents` çağrısı gizli anahtarla doğrudan istemciden yapılıyor (güvenlik açığı). | Flutter, Firebase Auth/Firestore, flutter_stripe | Yok | Düşük |
| **dalpat98/Barber-Booking-App** | Haritada yakındaki berberler, dükkan ve konum araması, galeri ve müşteri yorumları, hizmet/fiyat listesi, teklif. | Flutter, Google Maps, Provider | Yok | Düşük |
| **Sarah358/smartsalonapp** | Şube → stilist → tarih → slot adımlı akışı (stepper); Firestore'da gün bazlı slot dokümanı. UI kitinden gelen: walkthrough, **konum ve bildirim izni için "Belki sonra" seçenekli ön ekranlar**, portföy, favoriler, sohbet (sahte veri), karanlık mod anahtarı. | Flutter, Firebase, GetX/MobX | Yok | Orta |
| **musmanflutter/Sohna-Salon-App** | Hizmetlerin yanında ayrı satın alınabilen **"Deals" (paket fiyatlı kampanya)**; uzman listesi, yorumlar, SSS, salon bilgisi; randevuda paket + hizmet birlikte seçilebiliyor. | Flutter, Firebase, Riverpod | Yok | Düşük |
| **stackmasteraliza/sohna-studio** | Bir önceki reponun kopyası (`lib/` farkı yalnızca 4 dosyada: giriş, açılış ve randevu ekranlarında küçük değişiklikler). | Flutter, Firebase | Yok | Düşük |
| **himanshugoyal77/salon-booking-app** | Ad + hizmet + puan filtresiyle **birleşik arama**, sanatçı detayı ve "geçmiş işler" galerisi, harita, favoriler, takvim. Stripe kodu yorum satırında (çalışmıyor). | Flutter, Firebase, Google Maps | Yok | Orta |
| **himanshugoyal77/salon_booking_app** | Aynı yazarın daha erken ve daha küçük sürümü (onboarding, harita, tarih seçici). | Flutter, Firebase | Yok | Düşük |
| **hashemsh/salon_booking_app** | Dribbble tasarımından yalnızca arayüz: stilist kartları, yıldız gösterimi, hizmet listesi. Backend yok. | Flutter | Yok | Düşük |
| **shivamvk/Snipped-Mobile** | Evde hizmet (adres seçimi), sepet, kupon, kategori/alt kategori/cinsiyete göre hizmet, siparişler için Bugün/Yaklaşan/Geçmiş sekmeleri. ⚠️ Backend'e şifresiz `http://IP` ile bağlanıyor. | Flutter, REST | Yok | Düşük |
| **MohammadAftabAlam/calma-salon** | 4 km yarıçapta yakın salonlar, uzman seçimi, Razorpay/UPI/nakit ödeme, **acil durumda erteleme**, **iptal nedeni seçimi** (program değişikliği, hava durumu, iş, yolculuk gecikmesi…). | Flutter + Spring Boot + MySQL | Yok | Orta |
| **Gerato25/BarberShopSchedule** | Berber tarafı takvim yönetimi. `Schedule`: haftanın günü başına **iki vardiya** (açılış1/kapanış1 + açılış2/kapanış2 = öğle arası) ve **aynı anda kaç randevu** kapasitesi. `SpecialDay` (ulusal/yerel/kişisel tatil türleri), hizmete bağlı `Promotion`, onay bekleyen randevu, yorumlar, FCM. | Android Java, REST, FCM | Yok | Yüksek |
| **jjxmonster/barber-booking-app** | Rol bazlı (müşteri / salon sahibi) web paneli; sahip personel ve hizmet ekler, müşteri arama kartı ve önerilen dükkanlar. Prisma şeması bizimkinin sade bir alt kümesi. | Next.js 14, Prisma, PostgreSQL, NextAuth | Yok | Düşük |
| **rafaelmachadobr/barbershop** | Dart Week 11 projesi. Repoda yalnızca açılış ekranı kodu var; asıl değer **veri modeli**: personel başına `work_days` + `work_hours`, dükkan açılış saatleri listesi (aradaki boşluk = mola). Admin ve çalışan ekranlarının görüntüleri mevcut. | Flutter, json_rest_server | **MIT** | Orta |
| **antoni-codes/Barber_Booking-UI-Flutter_App** | Yalnızca arayüz: **berber profilinde puan ve tıraş sayısı**, stil galerisi (Fade, Undercut…), popüler aramalar, randevular. | Flutter | Yok | Düşük |

### B) Genel randevu ve yönetim sistemleri

| Repo | Ne yapıyor / öne çıkan | Teknoloji | Lisans | Fayda |
|---|---|---|---|---|
| **sachintha-lk/CRM-laravel** | Salon CRM'i: şubeler, kategoriler, hizmette süre, görsel ve **bakım ipuçları**; **Deal** (indirim %, başlangıç–bitiş tarihi, gizli bayrağı); sepet; randevu kodu; **hizmet görüntüleme → randevu analitiği** (kuyruk işiyle); kullanıcı askıya alma; e-posta bildirimleri; tüm şubelerin günlük programı. | Laravel 10, Livewire, Jetstream | Yok (composer: iskelet MIT) | Orta |
| **vfixtechnology/appointment-booking-system** | Çok rollü (Admin/Çalışan/Moderatör/Abone). Çalışan başına **gün → çoklu saat aralığı** (09–12 + 15–18), **tarihe özel istisna** (o gün kısmi saat ya da tamamen kapalı, yıllık tekrarlı), randevular arası `break_duration`, **6 bildirim türü** (admin/çalışan/müşteri × oluşturuldu/güncellendi), erteleme ve iptal, takvim görünümü, "Ödeme bekliyor" durumu. | Laravel 11, spatie/opening-hours | Yok (composer: iskelet MIT) | Yüksek |
| **adamspd/django-appointment** | Olgun bir paket. Hizmet başına **`allow_rescheduling` + `reschedule_limit`**; `AppointmentRescheduleHistory` (neden, bekliyor/onaylandı, süreli bağlantıyla onay); personel başına `WorkingHours`, `DayOff` (tarih aralığı), **`Unavailability` (tarih + saat aralığı)**; kapora (`down_payment`); 24 saat önce e-posta hatırlatma (django-q); **ICS eki**; i18n; Docker ve kapsamlı testler. | Django, django-q | **Apache-2.0** | Yüksek |
| **thunderbird/appointment** | **Bizimle aynı yığın: FastAPI + SQLAlchemy + Alembic** (68 migration). Takvim paylaşımı; `Schedule`: `earliest_booking`, `farthest_booking`, `booking_confirmation`, haftalık özel müsaitlik. Kullanıcı başına dil, açık/koyu/sistem tema, haftanın ilk günü; **`ftue_level` (ilk kullanım rehberinin sunucuda takibi)**; kişisel veriler DB'de şifreli (`encrypted_type`); soft delete mixin'i; Fluent ile l10n (en/de); Celery e-postaları (yeni, bekleyen, iptal, red) ve ICS; pytest fabrikaları. | FastAPI, Vue, Celery, Redis | MPL-2.0 | Yüksek (mimari) |
| **UretzkyZvi/planner** | **Kaynak (personel) satırları × zaman sütunları** takvim bileşeni; gün/hafta/ay/yıl görünümü, sürükle-bırakla randevu taşıma, koyu/açık tema. | React, Next.js, shadcn/ui, Pragmatic DnD | **MIT** | Orta |

### C) Doktor randevu uygulamaları

| Repo | Ne yapıyor / öne çıkan | Teknoloji | Lisans | Fayda |
|---|---|---|---|---|
| **DevExplorerr/Doctor-Hunt** | En olgun mobil örnek. Haftalık slot şablonu, 7 günlük pencere için **2 okumada gün başına boş slot sayısı**, deterministik rezervasyon anahtarı (`YYYY-MM-dd_HH-mm`) + transaction ile çift kayıt koruması, **transaction ile iptal ve erteleme**, Yaklaşan/Tamamlanan/İptal grupları, canlı arama, favoriler; yapay zekâ semptom kontrolü (konu dışı). | Flutter, GetX, Firebase, Node AI | Yok | Orta |
| **masifdevs/Medical-Appointment** | Doktor/hasta rolleri, "talep edildi" durumlu randevu, sohbet, Agora görüntülü arama, tahlil raporları, EN/UR yerelleştirme. | Flutter, Firebase, Agora | **MIT** | Düşük |
| **iamzaidsoomro/doctor_appointment_app_…** | Öğrenci projesi: doktor listesi, randevu, randevularım. | Flutter, Firebase | Yok | Düşük |
| **GENESDEMON/Telecare** | Arayüz demosu: sohbet listesi, reçeteler, randevular (sahte veri). | Flutter | Yok | Düşük |
| **sailesh307/health_app** | Hasta ve doktor için tek uygulama; Firebase Realtime DB ile gerçek zamanlı sohbet, bildirim listesi, en yüksek puanlılar, randevu geçmişi. | Flutter, Firebase | Yok | Düşük |
| **TareqAlKushari/Flutter-Doctor-Appointment-App** | Mimari örneği: BLoC/Cubit, Dio + Retrofit, GetIt, `easy_localization`, shimmer iskelet yükleme, onboarding. | Flutter | **MIT** | Düşük |
| **HashenUdara/edoc-doctor-appointment-system** | PHP oturum (seans) bazlı randevu: seans başına kontenjan (`nop`) ve sıra numarası (`apponum`). ⚠️ SQL injection (`"…where email='$email'"`) ve düz metin parola → anti-örnek. | PHP, MySQL | **MIT** | Düşük |

### Bizim önde olduğumuz yanlar (korunmalı)

- **Çift randevu:** süreç kilidi + `SELECT … FOR UPDATE` + kısmi tekil indeks + `Idempotency-Key`. Repoların çoğunda koruma yok; yalnızca Doctor-Hunt'ta transaction var.
- **Tek doğruluk kaynağı slot hesabı** backend'de (`slot_servisi.py`). Repoların çoğu slotu istemcide hesaplıyor.
- **İmza özellikler:** Her Zamanki, Güven Skoru, WhatsApp tek dokunuşla onay, bekleme listesi. **Hiçbir repoda bunların karşılığı yok.**
- KVKK rızası, hesap silme (uygulama + web), hız sınırı, yük testi, ayrı worker + DB kilidi, Crashlytics, 70 backend + 30 Flutter testi.

---

## 2. Özellik Karşılaştırma Matrisi

| Özellik | Bizde (Aşama 1 → Aşama 2) | Kanıt (bizim kod, Aşama 1) | Hangi repolarda |
|---|---|---|---|
| Randevu erteleme | ❌ → ✅ #2 | Yalnızca `POST /randevular/{id}/iptal`; erteleme ucu yok | django-appointment (sınır + geçmiş + neden), Doctor-Hunt (transaction), calma (acil erteleme), vfix |
| İptal politikası | ✅ | Son 30 dk kuralı (`iptal_son_dk`), soft iptal, geç iptal güven skorunda −10 | Çoğunda yalnızca iptal düğmesi var, zaman kuralı yok. İptal nedeni: calma. Atomik iptal: Doctor-Hunt |
| Tekrarlayan randevu | 🟡 | Yok; "Her Zamanki" tek dokunuşla tekrar almayı sağlıyor | Hiçbirinde yok (Doctor-Hunt'taki "recurring", randevu değil haftalık slot şablonu) |
| Takvim görünümü (gün/hafta) | 🟡 | İşletme: tarih seçilebilen günlük akış listesi + berber doluluğu; hafta/ızgara yok | planner (gün/hafta/ay + personel satırları + sürükle-bırak), vfix, CRM-laravel (tüm şubelerin günlük programı), Gerato25, Sarah358 |
| Personel çalışma saatleri | 🟡 → 🟡 #4 (haftalık izin günü + saatlik kapatma; berbere özel saat aralığı yok) | Salon saati (hafta içi + Pazar) + gün bazlı berber izni; berbere özel haftalık düzen yok | django (WorkingHours), vfix (gün → aralıklar), rafaelmachadobr (work_days/hours), thunderbird (Availability), Gerato25 |
| Mola / öğle arası | ❌ → ✅ #4 | `gun_mesaisi` tek aralık döndürüyor | Gerato25 (2 vardiya), vfix (çoklu aralık + break_duration), django (Unavailability), rafaelmachadobr |
| Hizmet süresi ve fiyat varyasyonları | 🟡 | Salon bazlı fiyat/süre, randevuda mühürleniyor; berbere göre fiyat yok, her berber her hizmeti yapıyor | Gerato25 (dükkan × hizmet fiyatı), vfix ve django (personel ↔ hizmet eşleşmesi), Snipped (kategori/cinsiyet), CRM-laravel (kategori, bakım ipuçları) |
| Paket / kampanya | ❌ | — | Sohna (Deals), CRM-laravel (indirim % + tarih aralığı), Gerato25 (Promotion), Snipped (kupon), Doctor-Hunt (promo kodu) |
| Ödeme / kapora | ❌ | ANALIZ_RAPORU F7 → SONRAYA | DebankurMandal (Stripe ⚠️), himanshugoyal77 (Stripe, kapalı), calma (Razorpay/nakit), django (tam/kapora), vfix ("Ödeme bekliyor") |
| Sadakat puanı | ❌ | — (Güven Skoru sadakat değil, risk göstergesi) | Gerçek sadakat hiçbirinde yok; en yakını kupon/promo (Snipped, Doctor-Hunt) |
| Yorum ve fotoğraflı değerlendirme | 🟡 → 🟡 #3 (yorumlar görünür; fotoğraf ⏭️ #11) | Puan + yorum yazılıyor, berber/salon ortalaması güncelleniyor; **uygulamada yorumlar okunmuyor**, fotoğraf yok | dalpat98, Sohna, Gerato25, Doctor-Hunt, antoni-codes (puan + tıraş sayısı), Sarah358. Fotoğraflı yorum hiçbirinde yok |
| Galeri / portföy | 🟡 | `SalonFotograf` tablosu var, `/salonlar/{id}` dönüyor; yükleme ucu ve gösterim yok | dalpat98, Sarah358 (portfolio), antoni-codes (stil galerisi), himanshugoyal77 (past work) |
| Favoriler | ✅ | `favori_berberler`, salon detayında ♥, Favoriler ekranı | Sarah358, himanshugoyal77, calma, Doctor-Hunt |
| Harita ve yakınlık sıralaması | ✅ | Haversine ile sıralama, harita uygulamasına yönlendirme (uygulama içi harita yok) | dalpat98, himanshugoyal77, calma (4 km), Sarah358, Gerato25 |
| Arama ve filtre | 🟡 → ✅ #7 | İl/ilçe (harf duyarsız) + konum; ad veya hizmetle arama yok | himanshugoyal77 (ad + hizmet + puan), Doctor-Hunt (canlı arama), calma, dalpat98, jjxmonster |
| Chat / mesajlaşma | ❌ | Bilinçli: WhatsApp + telefon derin bağlantısı | sailesh307 (Firebase RTDB), masifdevs, Sarah358 ve Telecare (sahte veri) |
| Bildirim türleri | 🟡 → ✅ #1 | Müşteriye: 1 saat kala hatırlatma, işletme iptali, değerlendirme, bekleme listesi. **İşletmeye/personele: hiçbiri** | vfix (3 rol × oluştur/güncelle), thunderbird (yeni/bekleyen/iptal/red), django (onay + 24 saat + erteleme), CRM-laravel, Gerato25 (FCM) |
| SMS / WhatsApp hatırlatma | 🟡 | İşletmenin elle gönderdiği `wa.me` onay bağlantısı (ücretsiz) | SMS/WhatsApp hiçbirinde yok; e-posta hatırlatma: django (24 saat), vfix |
| İşletme raporları | ✅ | Aylık: ciro, berber cirosu, gelmeme oranı, ortalama sepet, popüler hizmet, kaynak | CRM-laravel (görüntüleme → randevu analitiği), vfix (dashboard) |
| Müşteri notları (CRM) | 🟡 → ✅ #5 | Randevu notu (yalnızca panel kaydında) + güven skoru; kalıcı müşteri notu ve geçmiş kartı yok | CRM-laravel (müşteri yönetimi, askıya alma), edoc (hasta detayı), masifdevs (geçmiş), django (`additional_info`) |
| Çoklu dil | ❌ | `supportedLocales: [tr_TR]`, metinler kodda Türkçe | TareqAlKushari (easy_localization), thunderbird (Fluent en/de), django (gettext), masifdevs (en/ur) |
| Karanlık / aydınlık tema | 🟡 | Yalnızca siyah-altın koyu tema (marka kararı) | Sarah358, thunderbird (açık/koyu/sistem), planner |
| Onboarding | 🟡 → 🟡 #9 (bağlamlı bildirim izni) | Karşılama = rol seçimi; tanıtım ve izin ön ekranı yok, bildirim izni doğrudan sistem diyaloğuyla isteniyor | Sarah358 (walkthrough + konum/bildirim ön ekranı), DebankurMandal, himanshugoyal77, TareqAlKushari, Doctor-Hunt, thunderbird (`ftue_level`) |
| *Ek:* Takvime ekle (ICS) | ❌ → ✅ #8 | — | django (ICS eki), thunderbird (icalendar) |
| *Ek:* Dolu günün takvimde gösterimi | 🟡 → ✅ #6 | Kapalı/tatil/izinli günler gizleniyor; **tamamen dolu gün açık görünüyor** | Doctor-Hunt (gün başına boş slot sayısı), Sarah358 ve CRM-laravel (dolu slot gri) |
| *Ek:* Bekleme listesi | ✅ | Boşalınca süresi sığan bekleyenlere push | Hiçbirinde yok |
| *Ek:* Çift randevu koruması | ✅ | Kilit + kısmi tekil indeks + idempotency | Doctor-Hunt (transaction + deterministik anahtar), django (çakışma kontrolü) |

---

## 3. Eksikler ve İyileştirme Fırsatları

### UYGULA önerilenler

**#1 — İşletmeye ve personele anlık bildirim**
[Öncelik: Kritik] · [Efor: S] · İlham: vfix (Admin/Employee × BookingCreated/Updated), thunderbird (`send_new_booking_email`, `send_cancel_email`), django, CRM-laravel
- **Bizdeki durum:** ❌ İşletme ve personelin FCM token'ı `musteriler` tablosunda tutuluyor (`fcm-token-guncelle` bütün roller için çalışıyor) ama `bildirim_gonder` hiçbir yerde işletmeye çağrılmıyor. Müşteri uygulamadan randevu alınca ya da 31 dk kala iptal edince berber bunu ancak paneli açınca görüyor.
- **Backend:** `bildirim.py`'ye `salona_bildir(db, randevu, baslik, govde)` eklenir: salonun `Isletme.firebase_uid`'si ve randevunun berberinin `firebase_uid`'si → `Musteri.fcm_token`. Şu olaylarda çağrılır: uygulamadan yeni randevu (`kaynak=uygulama`), müşteri iptali, erteleme (#2). Panelden eklenen randevu bildirim üretmez. Yeni model yok, yeni migration yok. **pytest:** `bildirim_gonder` monkeypatch'lenir; yeni randevu → işletme ve ilgili berber token'ı; panel kaydı → bildirim yok; başka salonun işletmesi bildirim almaz.
- **Frontend:** `BildirimServisi._ac` içinde yeni `type: "panel_randevu"` → İşletme Paneli > Akış, ilgili tarihle açılır. Ön planda gelen bildirimde SnackBar gösterilir (mevcut davranış).
- **Fayda:** Berber yeni müşteriyi ve son dakika iptalini anında öğrenir; boşalan koltuğu walk-in'le doldurabilir.
- **Önerim: UYGULA.** En düşük eforla en büyük işletme değeri; altyapının tamamı mevcut, ücretli servis gerekmiyor (FCM ücretsiz).

**#2 — Müşterinin randevu ertelemesi (+ iptal yerine erteleme önerisi)**
[Öncelik: Yüksek] · [Efor: M] · İlham: django-appointment (`allow_rescheduling`, `reschedule_limit`, `AppointmentRescheduleHistory.reason`), Doctor-Hunt (eski slotu bırak + yenisini tut tek işlemde), calma (iptal nedeni seçimi), vfix
- **Bizdeki durum:** ❌ Müşteri iptal edip yeniden almak zorunda; iptal ile yeniden alma arasında slot başkasına gidebiliyor ve geç iptal güven skorunu düşürüyor.
- **Backend:** `Randevu.erteleme_sayisi` (int, varsayılan 0) + Alembic migration. `POST /randevular/{id}/ertele {tarih, saat}` kuralları: yalnızca sahibi; durum `onaylandi`; iptaldeki son 30 dk kuralı; en fazla `ERTELEME_LIMITI=2` (config); aynı berber, aynı hizmetler ve mühürlü süre. Mevcut rezervasyon kilidi içinde, randevunun kendi aralığı dışarıda bırakılarak müsaitlik yeniden hesaplanır. Çakışmada 409 + öneriler (mevcut biçim). Başarıda `hatirlatma_gonderildi=False` olur, eski gün için `bekleme_listesine_haber_ver` çalışır, işletmeye bildirim gider (#1). `Idempotency-Key` desteklenir. `musait-saatler` uca isteğe bağlı `ertelenen_id` eklenir (yalnızca sahibine etkili; kendi slotunu dolu saymaz). **pytest:** başarılı erteleme; çakışma 409; limit; son 30 dk; başkasının randevusu 403; aynı günde 30 dk kaydırma (kendi aralığıyla çakışmamalı); eşzamanlı iki erteleme; eski günün bekleme listesine bildirim.
- **Frontend:** Randevularım kartında "Ertele" → alt sayfa (takvim + saatler, mevcut `adim3/adim4` bileşenleri yeniden kullanılır), yükleniyor/boş/hata durumlarıyla. İptal diyaloğu önce "Bunun yerine ertelemek ister misiniz?" diye sorar (calma'daki neden seçimi yerine ertelemeye yönlendirme).
- **Fayda:** Müşteri slot kaybetmeden saat değiştirir; işletme müşteri kaybetmez; iptal ve no-show oranı düşer.
- **Önerim: UYGULA.** Mevcut slot ve kilit altyapısına oturuyor; ücretli servis gerekmiyor.

**#3 — Yorumların ve berber istatistiklerinin gösterilmesi**
[Öncelik: Yüksek] · [Efor: S] · İlham: dalpat98 (galeri + yorumlar), Sohna (yorum ekranı), Gerato25 (ReviewsActivity), antoni-codes (puan + tıraş sayısı), Doctor-Hunt (puan, yorum, hasta istatistiği)
- **Bizdeki durum:** 🟡 Yorum yazılıyor, `GET /degerlendirmeler/berber/{id}` var ama **uygulamada hiçbir yerde okunmuyor**; salon bazlı uç yok. Müşteri salonu seçerken yalnızca puanı görüyor.
- **Backend:** Yeni model yok. `GET /degerlendirmeler/salon/{id}?sayfa=`: ortalama, toplam, 1–5 dağılımı, yorumlu olanlar önce, berber adıyla, sayfalı. Berber ucuna ve salon detayındaki berber listesine `tamamlanan_sayisi` ("120 tıraş") eklenir (tek gruplu sorgu, N+1 yok). İsim mevcut `_kisa_ad` ile kısaltılır ("Ahmet Y."). **pytest:** dağılım, sayfalama, silinmiş müşteri "Anonim", sorgu sayısı.
- **Frontend:** Salon detayına "Yorumlar" bölümü (özet çubuğu + son 3 yorum + "Tümünü gör" ekranı), boş durum "Henüz yorum yok"; ekip listesinde berber puanı ve tıraş sayısı.
- **Fayda:** Müşteri güvenle seçim yapar; iyi çalışan berber görünür olur.
- **Önerim: UYGULA.** Veri zaten var, yalnızca gösterilmesi gerekiyor.

**#4 — Berber haftalık izin günü, öğle arası ve saatlik bloke**
[Öncelik: Yüksek] · [Efor: M] · İlham: Gerato25 (`Schedule` iki vardiya), vfix (gün → çoklu aralık, tarihe özel saat istisnası), django (`WorkingHours`, `Unavailability` tarih+saat, `DayOff` aralık), rafaelmachadobr (personel `work_days`)
- **Bizdeki durum:** ❌ Yalnızca salon saati + tam gün berber izni. Her Pazartesi izinli bir berber için her hafta ayrı izin girmek gerekiyor; öğle arası ve "14:00–16:00 dışarıdayım" tanımlanamıyor.
- **Backend:** Migration ile üç alan. (a) `Salon.mola_baslangic/mola_bitis` (nullable "HH:MM"). (b) `Berber.kapali_gunler` (salondaki gibi weekday listesi). (c) `BerberIzin.bas_saat/bit_saat` (nullable; boşsa tam gün, doluysa kısmi bloke); `(berber_id, tarih)` tekilliği kaldırılır ki aynı güne birden çok bloke girilebilsin (SQLite `render_as_batch`). `slot_servisi`: berberin haftalık izni `kapali_nedenler`'e; mola ve kısmi blokeler `dolu_araliklar`'a aralık olarak eklenir (mevcut çakışma mantığı aynen çalışır). Panel: `PUT /panel/personel/{id}` (kapali_gunler), `POST /panel/izin` (isteğe bağlı saat aralığı), `PUT /panel/salon` (mola). Alanlar boşken davranış bugünküyle birebir aynı. **pytest:** mola slotu kapatır; molaya taşan 60 dk hizmet reddedilir; haftalık izin günü takvimde yok; kısmi bloke yalnızca o saatleri kapatır; bloke saatine panelden de randevu girilemez; mevcut testler değişmeden yeşil.
- **Frontend:** Ekip & Menü → personel düzenle: haftalık izin günü çipleri. Kapalı Günler: "Saat aralığı bloke et" (tarih + başlangıç/bitiş). Salon ayarları: öğle arası.
- **Fayda:** Gerçek berber düzenine uyar (öğle arası, sabit izin günü, kısa dışarı çıkış); müşteri berberin olmadığı saate randevu alamaz.
- **Önerim: UYGULA.** KARARLAR'daki "7 günlük ayrı saat tablosu sonraya" kararını bozmaz; aynı modeli küçük adımla genişletir.

**#5 — Müşteri kartı ve kalıcı işletme notu (mini CRM)**
[Öncelik: Yüksek] · [Efor: M] · İlham: CRM-laravel (müşteri yönetimi ve analitik), edoc (hasta detayı), masifdevs (geçmiş sekmeleri), django (`additional_info`)
- **Bizdeki durum:** 🟡 Akış kartında güven skoru ve (yalnızca panel kaydında) randevu notu var. Berber "bu müşteri yanları 1 numara, üstü makas" gibi kalıcı bir not tutamıyor ve müşterinin geçmişini göremiyor.
- **Backend:** `MusteriNotu(salon_id, musteri_id, metin ≤500, guncelleme)` + tekil `(salon_id, musteri_id)` + migration. `GET /panel/musteriler/{musteri_id}`: **yalnızca o salonda randevusu olan müşteri** için ziyaret sayısı, son ziyaret, toplam harcama, en sık berber ve hizmet, son 10 randevu, güven skoru ve not. `PUT /panel/musteriler/{id}/not`. İşletme ve personel okuyup yazabilir (`panel_baglami`). Hesap silmede (`hesap_servisi`) notlar silinir. **pytest:** başka salonun müşterisi 404; personel erişimi; not 500 karakter sınırı; hesap silmede notun silinmesi.
- **Frontend:** Akış kartında müşteri adına dokununca "Müşteri Kartı" alt sayfası (yükleniyor/boş/hata); not varsa kartta 📝 işareti.
- **Fayda:** Müdavime kişisel hizmet ("her zamanki gibi mi?"); yeni personel müşteriyi tanır.
- **Önerim: UYGULA.** ⚠️ İşletmenin müşteri hakkında tuttuğu not kişisel veridir: yasal metne bir cümle eklenmesi hukukçu onayı ister (BENDEN_GEREKENLER'e yazılacak). Ücretli servis gerekmiyor.

**#6 — Takvimde dolu günlerin işaretlenmesi**
[Öncelik: Orta] · [Efor: S] · İlham: Doctor-Hunt (7 günlük pencerede 2 okumayla gün başına boş slot sayısı), Sarah358 ve CRM-laravel (dolu slotlar gri)
- **Bizdeki durum:** 🟡 Kapalı, tatil ve izinli günler gizleniyor ama tamamen dolu gün açık görünüyor; müşteri dokununca boş saat listesiyle karşılaşıyor.
- **Backend:** `GET /randevular/musait-takvim` uca isteğe bağlı `hizmet_ids` eklenir; berber verilmişse ufuktaki aktif randevular **tek sorguyla** çekilir ve gün başına `bos_slot` ile `dolu` alanları eklenir (alanlar yeni, mevcut istemci bozulmaz). #4'teki mola ve bloke de hesaba katılır. **pytest:** dolu gün `dolu=true`; sorgu sayısı gün sayısından bağımsız.
- **Frontend:** `adim3_tarih`: dolu gün gri ve "Dolu" etiketli; dokununca doğrudan bekleme listesi önerisi; az kalan günlerde "Son 2 saat" ipucu.
- **Fayda:** Boşa dokunma ve hayal kırıklığı azalır, bekleme listesi daha çok kullanılır.
- **Önerim: UYGULA.**

**#7 — Salon ve hizmet adıyla arama**
[Öncelik: Orta] · [Efor: S] · İlham: himanshugoyal77 (ad + hizmet + puan filtresi), Doctor-Hunt (canlı arama + temizle), calma, dalpat98
- **Bizdeki durum:** 🟡 Keşfet yalnızca il/ilçe ve konumla filtreliyor; "Makas Kuaför" ya da "sakal" yazıp aramak mümkün değil.
- **Backend:** `/salonlar?q=&min_puan=`: mevcut Türkçe `normalize` ile salon adı, ilçe ve salonun aktif hizmet adlarında eşleşme (hizmetler tek sorguda), konum sıralamasıyla birlikte çalışır. Yeni model yok. **pytest:** "istanbul/İSTANBUL" eşdeğerliği, hizmet adıyla bulma, `min_puan`.
- **Frontend:** Keşfet'in üstünde arama kutusu (300 ms gecikmeli istek, temizle düğmesi), boş durumda "Sonuç yok · Filtreleri temizle".
- **Fayda:** Bildiği salonu ya da istediği hizmeti hemen bulur.
- **Önerim: UYGULA.**

**#8 — Randevuyu takvime ekle (.ics)**
[Öncelik: Orta] · [Efor: S] · İlham: django-appointment (`ics_utils.generate_ics_file`, e-postaya ek), thunderbird (icalendar)
- **Bizdeki durum:** ❌
- **Backend:** `GET /randevular/{id}/ics` (yalnızca sahibi, `text/calendar`; `Europe/Istanbul` saat dilimli VEVENT, salon adresi, 60 dk önce VALARM). Bağımlılık eklenmez: RFC 5545 kaçışlarıyla elle üretilir. **pytest:** içerik alanları, başkasının randevusu 404, özel karakter kaçışı.
- **Frontend:** Onay ekranında ve yaklaşan randevu kartında "Takvime Ekle" → mevcut `share_plus` ile .ics paylaşılır (Google Takvim, Samsung Takvim vb. açar).
- **Fayda:** Müşterinin kendi takvimi de hatırlatır; push izni vermeyenlerde no-show azalır.
- **Önerim: UYGULA.** Ücretsiz ve bağımlılıksız.

**#9 — Bildirim izni ön ekranı (permission priming)**
[Öncelik: Orta] · [Efor: S] · İlham: Sarah358 (`BMEnableNotificationScreen` / `BMEnableLocationScreen`, "Belki sonra"), thunderbird (`ftue_level`), TareqAlKushari/DebankurMandal (onboarding)
- **Bizdeki durum:** 🟡 Bildirim izni bağlamsız biçimde doğrudan sistem diyaloğuyla isteniyor. Android 13+'ta iki kez reddedilirse bir daha sorulamıyor; reddeden kullanıcıya 1 saat kala hatırlatma hiç ulaşmıyor.
- **Backend:** Gerek yok.
- **Frontend:** İzin, ilk randevu onaylandığında (değerin en net olduğu an) siyah-altın bir kartla istenir: "Randevunuza 1 saat kala hatırlatalım mı?" → [Evet, hatırlat] / [Şimdi değil]. Reddedilmişse "Ayarlardan aç" bağlantısı gösterilir. "Bir daha sorma" bilgisi `shared_preferences` ile tutulur (tek resmi paket eklenir). Widget testi yazılır.
- **Fayda:** Hatırlatma alan kullanıcı oranı artar, no-show azalır.
- **Önerim: UYGULA.**

### SONRAYA / GEREK YOK

> **Tur 5 (2026-10-12, dal `feature/tur5`, `main`'e birleştirildi):** #12, #13, #14, #15, #16, #19, #20 ✅ uygulandı
> (ayrıntı ve kararlar: KARARLAR.md "Tur 5", ILERLEME.md). #10, #11, #17 ücretli servis/sözleşme gerektirdiği için
> bekliyor; #18 çoklu dil ayrı kayıtta (YAPILACAKLAR.md).

**#10 — Online kapora / ödeme** · [Yüksek] · [L] · İlham: django (`down_payment`), calma (Razorpay), DebankurMandal ve himanshugoyal77 (Stripe) · Bizde ❌ · Backend: ödeme kuruluşu entegrasyonu, webhook, iade; frontend: ödeme sayfası · Fayda: no-show'a karşı en güçlü araç · **Önerim: SONRAYA.** 💰 Ücretli servis ve sözleşme gerekiyor (TR'de iyzico/PayTR; Stripe TR'de doğrudan yok). Ayrıca DebankurMandal'daki gibi gizli anahtar asla istemcide olmamalı. ANALIZ_RAPORU F7 ile aynı karar.

**#11 — Salon galerisi / berber portföyü + fotoğraflı yorum** · [Orta] · [M] · İlham: dalpat98, Sarah358 (portfolio), antoni-codes, himanshugoyal77 · Bizde 🟡 (tablo var, yükleme ve gösterim yok) · **Önerim: SONRAYA.** Render diski kalıcı değil (P12); 💰 obje depolama gerekiyor (Firebase Storage yeni projelerde Blaze planı ister, alternatif Cloudinary ücretsiz katmanı) ve fotoğraflı yorumda moderasyon gerekiyor.

**#12 — Kampanya / paket fiyat** ✅ Tur 5 · [Orta] · [M–L] · İlham: Sohna (Deals), CRM-laravel (indirim % + tarih aralığı + gizli), Gerato25 (Promotion), Snipped (kupon) · Bizde ❌ · **Önerim: SONRAYA.** Boş günleri doldurmak için değerli ama fiyat mühürleme, rapor ve "uygulamadaki fiyat salondakiyle tutmuyor" (ANALIZ_RAPORU'ndaki TR şikâyeti) riskleri ayrı bir ürün kararı gerektiriyor.

**#13 — Berber ↔ hizmet eşleşmesi ve berbere göre fiyat/süre** ✅ Tur 5 · [Orta] · [M] · İlham: vfix (`employee_service`), django (`services_offered`), Gerato25 (Price) · Bizde 🟡 · **Önerim: SONRAYA.** Boyacı/usta berber ayrımı olan salonlar için yararlı; randevu akışı sırası (hizmet → berber) ve slot hesabı etkilenir. #4'ten sonra ele alınmalı.

**#14 — Berber sütunlu gün/hafta takvimi + sürükle-bırak** ✅ Tur 5 (gün görünümü) · [Orta] · [L] · İlham: planner (kaynak × zaman ızgarası), vfix, CRM-laravel · Bizde 🟡 · **Önerim: SONRAYA.** Çok koltuklu salonlar için güzel ama 360 dp telefonda ızgara zor; mevcut "Akış + doluluk" listesi ilk sürüm için yeterli. Sürükle-bırak #2'deki erteleme servisini kullanabilir.

**#15 — Minimum önceden rezervasyon süresi** ✅ Tur 5 · [Düşük] · [S] · İlham: thunderbird (`earliest_booking`), django (`lead_time`) · Bizde 🟡 (şimdiden sonraki her slot alınabiliyor) · **Önerim: SONRAYA.** Berberlerde son dakika randevu genelde istenen bir şey; talep gelirse salon ayarına tek alan olarak eklenir.

**#16 — Sadakat kartı (ör. 10. tıraş indirimli)** ✅ Tur 5 · [Orta] · [M] · İlham: repolarda yok (en yakını kupon/promo) · **Önerim: SONRAYA.** Kampanya (#12) altyapısıyla birlikte tasarlanmalı.

**#17 — SMS / otomatik WhatsApp hatırlatma** · [Orta] · [M] · İlham: repolarda yalnızca e-posta hatırlatma var (django, vfix) · Bizde 🟡 (`wa.me` elle) · **Önerim: SONRAYA.** 💰 SMS kontörü (Netgsm/İleti Merkezi) + İYS kaydı veya WhatsApp Business API (Meta onayı + mesaj başı ücret).

**#18 — Çoklu dil** · [Düşük] · [L] · İlham: TareqAlKushari (easy_localization), thunderbird (Fluent), django (gettext) · Bizde ❌ · **Önerim: SONRAYA.** Hedef pazar TR; bütün metinlerin ARB'ye taşınması geniş bir iş.

**#19 — Tekrarlayan randevu** ✅ Tur 5 ("Aynısını Tekrar Al") · [Düşük] · [M] · İlham: hiçbir repoda yok · Bizde 🟡 (Her Zamanki) · **Önerim: SONRAYA.** Tamamlanan randevudan sonra "3 hafta sonra aynı saate al?" önerisi daha az riskli bir ara adım olur.

**#20 — Kişisel verinin DB'de şifrelenmesi** ✅ Tur 5 (isteğe bağlı anahtarla) · [Orta] · [M] · İlham: thunderbird (`encrypted_type` ile ad, e-posta, telefon) · **Önerim: SONRAYA.** KVKK açısından güçlü ama arama (il/ilçe, telefon eşleşmesi) ve veri taşıma etkisi var; ayrı bir güvenlik turunda ele alınmalı.

**#21 — Uygulama içi mesajlaşma** · İlham: sailesh307, masifdevs, Sarah358, Telecare · **Önerim: GEREK YOK.** WhatsApp/telefon derin bağlantısı TR'de daha yüksek etkileşim sağlıyor; sohbet moderasyon, KVKK ve altyapı yükü getirir.

**#22 — İşletme onaylı (bekleyen) randevu** · İlham: thunderbird (`booking_confirmation`), Gerato25 (`pending`), masifdevs ("requested"), vfix · **Önerim: GEREK YOK.** KARARLAR: berberde anında onay norm; Güven Skoru + WhatsApp onayı riski zaten yönetiyor.

**#23 — Aydınlık tema** · İlham: Sarah358, thunderbird, planner · **Önerim: GEREK YOK.** Siyah-altın kimlik marka kararı; ikinci tema bütün ekranların test yükünü ikiye katlar.

**#24 — E-posta bildirimleri** · İlham: django, vfix, CRM-laravel, thunderbird · **Önerim: GEREK YOK.** Push + WhatsApp (+ #8 .ics) yeterli; SMTP servisi ve teslim edilebilirlik ek iş getirir.

**#25 — Tanıtım slaytları (walkthrough), sepet, evde hizmet** · İlham: Sarah358, DebankurMandal (slaytlar); CRM-laravel, Snipped (sepet, evde hizmet) · **Önerim: GEREK YOK.** Slaytları kullanıcı çoğunlukla atlıyor (#9'daki bağlamlı izin daha etkili); çoklu hizmet seçimi sepetin işini zaten görüyor; evde hizmet farklı bir iş modeli.

### Mimari ve kod kalitesi açısından alınacak dersler

| Ders | Kaynak | Değerlendirme |
|---|---|---|
| Test veri fabrikaları (`test/factory/*_factory.py`) | thunderbird (MPL, yalnızca fikir) | Yeni özelliklerin testlerinde `conftest.py`'ye küçük `salon_olustur / randevu_olustur` yardımcıları eklenecek; eski testlere dokunulmayacak. |
| Erteleme geçmişi (denetim izi) | django (`AppointmentRescheduleHistory`) | #2'de ilk sürümde sayaç yeterli; işletme "kim ne zaman değiştirdi" isterse ayrı tablo eklenir. |
| Zaman damgalarının gerçek `DateTime` olması + `time_created/updated` mixin'i | thunderbird | Bizde string. Değiştirmek bütün sorguları ve migration'ı etkiler → yapılmayacak, KARARLAR'daki tercihimiz korunuyor. |
| Bildirim matrisi (rol × olay) | vfix | #1 bu matrise göre tasarlanacak: müşteri/işletme/personel × oluştur/ertele/iptal. |
| Deterministik rezervasyon anahtarı | Doctor-Hunt | Bizdeki kısmi tekil indeksin karşılığı → ✅ var. |

---

## 4. Önerilen Uygulama Planı

> **Uygulama sonucu (2026-10-12, dal `feature/ilham-ozellikler`, `main`'e birleştirildi):** 9 maddenin 9'u ✅. Doğrulama: `pytest` 108/108
> (SQLite ve PostgreSQL 16), `ruff` temiz, migration 0003–0005 boş ve dolu veritabanında ileri/geri + `alembic check`
> temiz, `flutter analyze` 0 sorun, `flutter test` 49/49, emülatörde entegrasyon testleri 2/2 (müşteri: arayüzden
> erteleme + üç seçenekli iptal; işletme: tamamlandı + müşteri kartı notu). Kod hiçbir repodan kopyalanmadı
> (KAYNAKLAR.md gerekmedi). Kararlar: KARARLAR.md "Tur 4" · Kullanıcıdan gereken: BENDEN_GEREKENLER.md §9 (müşteri
> notu için gizlilik metni cümlesi).

Sıra bağımlılığa göre düzenlendi (#1 bildirimi #2 kullanıyor; #4'teki mola ve bloke hesabı #6'yı etkiliyor). **Uygulamada kullanıcı isteğiyle önem sırası izlendi: #1 → #2 → #3 → … → #9.** Toplam tahmin: ~7–9 iş günü.

| Sıra | Madde | Efor | "Bitti" tanımı | Durum |
|---|---|---|---|---|
| 1 | **#1** İşletmeye/personele anlık bildirim | S | Uygulamadan yeni randevu, müşteri iptali ve erteleme işletme sahibine ve ilgili berbere push gönderiyor; panel kaydı göndermiyor; bildirime dokununca panel Akış o tarihle açılıyor; pytest (3+ yeni test) ve `flutter analyze` 0 | ✅ |
| 2 | **#3** Yorumlar ve berber istatistikleri | S | Salon detayında yorum özeti + son 3 yorum + "Tümünü gör"; berberlerde puan ve tıraş sayısı; boş/hata durumları; sayfalı uç N+1'siz; testler yeşil | ✅ |
| 3 | **#4** Haftalık izin günü + öğle arası + saatlik bloke | M | Migration ileri/geri çalışıyor; alanlar boşken mevcut 70 test değişmeden yeşil; mola, haftalık izin ve kısmi bloke hem müşteri slotlarını hem panel kaydını kapatıyor; panelden üçü de yönetilebiliyor | ✅ |
| 4 | **#2** Randevu erteleme | M | Randevularım'da "Ertele" çalışıyor; limit, 30 dk kuralı, çakışmada 409 + öneriler, eşzamanlılık, eski gün için bekleme listesi bildirimi ve işletme bildirimi testli; iptal diyaloğu ertelemeyi öneriyor; idempotent | ✅ |
| 5 | **#5** Müşteri kartı + kalıcı not | M | Akıştan müşteri kartı açılıyor (geçmiş, harcama, skor, not); salonlar arası izolasyon ve hesap silmede not silme testli; KVKK metni maddesi BENDEN_GEREKENLER'de | ✅ |
| 6 | **#6** Takvimde dolu günler | S | Dolu gün gri + "Dolu" etiketli, dokununca bekleme listesi öneriliyor; uç tek sorguyla hesaplıyor (testli); eski istemciyle geriye uyumlu | ✅ |
| 7 | **#7** Salon ve hizmet araması | S | Keşfet'te arama kutusu; Türkçe harf duyarsız ad/ilçe/hizmet eşleşmesi ve `min_puan` testli; boş durum var | ✅ |
| 8 | **#8** Takvime ekle (.ics) | S | Onay ekranı ve randevu kartından .ics paylaşılıyor, Google Takvim'de doğru saat ve dilimde açılıyor; uç yalnızca sahibine açık (testli) | ✅ |
| 9 | **#9** Bildirim izni ön ekranı | S | İzin ilk randevu onayında bağlamlı kartla isteniyor; "Şimdi değil" bir daha rahatsız etmiyor; reddedilmişse ayarlar bağlantısı; widget testi | ✅ |

**Her madde için ortak kapı:** `pytest` (SQLite) yeşil · `ruff check` temiz · `flutter analyze` 0 sorun · ilgili `flutter test` yeşil · 360 dp / 1,3× taşma testi bozulmuyor · siyah-altın tema ile uyumlu · küçük Türkçe commit'ler `feature/ilham-ozellikler` dalında, main'e merge yok.

**Kod alma notu:** Önerilen maddelerin hiçbiri için dış koddan kopya gerekmiyor; hepsi fikir düzeyinde alınıp bizim mimarimize göre yazılacak. Uyarlama gerekirse yalnızca MIT/Apache lisanslı django-appointment (Apache-2.0), planner, rafaelmachadobr, masifdevs, TareqAlKushari veya edoc (MIT) kullanılacak ve `KAYNAKLAR.md`'ye yazılacak.
