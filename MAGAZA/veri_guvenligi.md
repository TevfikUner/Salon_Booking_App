# Play Console — Veri Güvenliği (Data safety) Yanıtları

Play Console → Politika → Uygulama içeriği → Veri güvenliği. Her yanıtın dayandığı kod "Kaynak" sütunundadır;
kod değişirse bu dosya ve `backend/yasal/gizlilik.md` birlikte güncellenmeli.

## Genel sorular

| Soru | Yanıt | Dayanak |
|---|---|---|
| Uygulamanız gerekli kullanıcı veri türlerinden herhangi birini topluyor veya paylaşıyor mu? | **Evet** | Hesap, randevu, analitik |
| Toplanan tüm kullanıcı verileri aktarım sırasında şifreleniyor mu? | **Evet** | Release'te yalnızca HTTPS: `AppConfig.guvensizAdres` + splash koruması, manifest'te cleartext yalnızca debug/profile; Firebase SDK'ları TLS |
| Hangi hesap oluşturma yöntemlerini destekliyorsunuz? | **Kullanıcı adı ve şifre** (e-posta + şifre, Firebase Authentication) | `AuthService.kayitOl` |
| Hesap silme bağlantısı (web) | `https://<API_ADRESİ>/yasal/hesap-silme` | `backend/routers/yasal.py` (form + `HesapSilmeTalebi`) |
| Kullanıcılar verilerinin silinmesini isteyebiliyor mu? | **Evet** — uygulama içinde (Profil → Hesabımı Sil; işletme: ⋮ menü → Hesabımı Sil) ve web formu | `AuthService.hesabiSil`, `HesapMenusu`, `hesap_servisi.hesabi_anonimlestir` |
| Hedef kitle (Uygulama içeriği → Hedef kitle ve içerik) | **13–15, 16–17, 18 ve üzeri**; 13 yaş altı hedeflenmez → Aileler politikası kapsamı dışında | `kullanim.md`: "13 yaşından küçükler hesap oluşturamaz"; `gizlilik.md` bölüm 13 yaş |
| Reklam kimliği kullanıyor mu? (Uygulama içeriği → Reklam kimliği) | **Hayır** | Manifest'te `AD_ID`, `ACCESS_ADSERVICES_*` izinleri `tools:node="remove"`; `google_analytics_adid_collection_enabled=false` |
| Reklam içeriyor mu? | **Hayır** | — |

## Veri türleri

"Paylaşılıyor mu?" sütunu: Hepsi **Hayır**. Gerekçe: Firebase (Google) ve Render, verileri bizim adımıza işleyen
hizmet sağlayıcılardır (Play tanımında "paylaşım" sayılmaz). Randevu alınan salonun müşterinin adını/telefonunu görmesi
kullanıcının kendi başlattığı ve beklediği bir aktarımdır (Play'in "kullanıcı tarafından başlatılan işlem" istisnası).

| Kategori → Veri türü | Toplanıyor | Zorunlu mu | Geçici işleme | Amaç | Kaynak |
|---|---|---|---|---|---|
| Kişisel bilgiler → **Ad** | Evet | Zorunlu | Hayır | Uygulama işlevi, Hesap yönetimi | `/musteriler/kayit`, `/isletmeler/kayit` |
| Kişisel bilgiler → **E-posta adresi** | Evet | Zorunlu | Hayır | Hesap yönetimi, Uygulama işlevi | Firebase Auth; işletme kaydı |
| Kişisel bilgiler → **Telefon numarası** | Evet | Zorunlu | Hayır | Uygulama işlevi (salonun müşteriye ulaşması) | kayıt, randevu formu |
| Konum → **Yaklaşık konum** | Evet | İsteğe bağlı | **Evet** (sunucuda saklanmaz, loglanmaz) | Uygulama işlevi (yakındaki salonları sıralama) | `KonumServisi` (ACCESS_COARSE_LOCATION), `/salonlar?lat&lng`; erişim logu yalnızca yol yazar (`gozlem.py`), yük testinde `lat=` içeren log satırı: 0 |
| Konum → Hassas konum | Hayır | — | — | — | İzin istenmiyor |
| Uygulama etkinliği → **Uygulama etkileşimleri** | Evet | Zorunlu değil (toplanır ama kullanıcı kimliğine bağlanmaz) | Hayır | Analiz | `Analitik`: `sign_up`, `randevu_olustur`, `randevu_iptal` |
| Uygulama etkinliği → **Diğer kullanıcı içerikleri** (puan, yorum) | Evet | İsteğe bağlı | Hayır | Uygulama işlevi | Değerlendirme ekranı |
| Uygulama bilgileri ve performans → **Kilitlenme günlükleri** | Evet | Zorunlu değil | Hayır | Analiz (kararlılık) | `HataRaporlama` (Crashlytics, yalnızca release) |
| Uygulama bilgileri ve performans → **Teşhis** | Evet | Zorunlu değil | Hayır | Analiz | Crashlytics / Analytics cihaz modeli, OS sürümü |
| Cihaz veya diğer kimlikler → **Cihaz veya diğer kimlikler** | Evet | Zorunlu | Hayır | Uygulama işlevi (bildirim), Analiz | FCM token (`/musteriler/fcm-token-guncelle`), Firebase installation ID |
| Finansal bilgiler | Hayır | — | — | — | Uygulama içi ödeme yok; fiyat bilgisi kullanıcı verisi değil |
| Fotoğraflar ve videolar | Hayır | — | — | — | Destek ekleri kullanıcının kendi e-posta uygulamasıyla gönderilir, sunucumuza gelmez (`bize_ulasin_sekmesi.dart`) |
| Mesajlar | Hayır | — | — | — | Destek talebi kullanıcının e-posta uygulamasından gider |
| Kişiler, Takvim, Sağlık, Dosyalar, Web geçmişi, Sesli/ses dosyaları | Hayır | — | — | — | — |

"Zorunlu değil" notu: Play formunda Analytics/Crashlytics için "Kullanıcılar bu veri toplamayı kapatabilir mi?" sorusuna
**Hayır** yanıtı verilir (uygulamada kapatma anahtarı yok); bu nedenle formda "Zorunlu" seçilmelidir. Tabloda bilgi amaçlı ayrıştırıldı.

## Tutarlılık kontrol listesi

- [x] Gizlilik politikası (`/yasal/gizlilik`) aynı veri türlerini sayıyor (bölüm 1)
- [x] Gizlilik politikası işleyenleri sayıyor: Firebase (Google), Render (Frankfurt)
- [x] Reklam kimliği beyanı ile birleştirilmiş manifest uyumlu (release APK `aapt dump permissions`: AD_ID yok)
- [x] Hesap silme hem uygulamada hem web'de; web formu oturum açmadan çalışır
