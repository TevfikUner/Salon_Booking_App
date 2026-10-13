# 5 Dakikalık Demo Senaryosu

**Hikâye:** "Ahmet her iki haftada bir Ali Usta'ya saç-sakal için gidiyor. Premium Berber Center'ın sahibi ise
günün akışını telefonundan yönetiyor ve gelmeyen müşteriler yüzünden boş koltuk kaybetmekten bıkmış."

## Hazırlık (demo öncesi, 10 dk)

1. Firebase Console → Authentication'da iki test hesabı açın: `musteri@demo.com` ve `isletme@demo.com`. UID'lerini kopyalayın.
2. Backend:
   ```bash
   cd backend
   # .env içinde: AUTH_MODE=dev
   alembic upgrade head
   SEED_MUSTERI_UID=<musteri uid>  SEED_ISLETME_UID=<isletme uid>  python seed_demo.py
   uvicorn main:app --host 0.0.0.0 --port 8010
   ```
   (Windows PowerShell: `$env:SEED_MUSTERI_UID="..."; $env:SEED_ISLETME_UID="..."; python seed_demo.py`)
3. İki cihaz/emülatör: birinde müşteri, diğerinde işletme hesabıyla giriş yapın
   (`flutter run --dart-define=API_URL=http://<bilgisayar-ip>:8010`).
4. Seed demo için şunları hazırlar: Ahmet'in Ali Usta ile 4 geçmiş randevusu (→ "Her Zamanki"), Tolga'nın 2 kez gelmemesi
   (→ "Riskli"), salonda bugün 6 randevu, 10 gün sonra "Tadilat" kapalı günü, Mehmet Kalfa'nın 2 gün sonra izni.

> Seed'deki bugünkü randevular sabit saatlerdedir (10:00–19:00). Demo akşam yapılıyorsa geçmiş olanlar
> otomatik "tamamlandı"ya döner — akıştaki "Tamamlandı / Gelmedi" butonlarını göstermek için ideal.

---

## Müşteri tarafı (≈2,5 dk)

| Süre | Ekran | Ne gösterilir / söylenir |
|---|---|---|
| 0:00 | Ana sayfa | **"Her Zamanki" kartı:** "Ali Usta · Saç & Sakal · 45 dk · 450 ₺ — en yakın boş saatler." *"Ahmet hiçbir şey aramıyor."* |
| 0:20 | Kartta bir saat çipine dokun → onay | 3 saniyede randevu; onay ekranında salon, saat aralığı (örn. 18:00–18:45), toplam (Ahmet'in 6. ziyareti olduğu için sadakat kartıyla 450 → 225 ₺). *"Rakiplerde 'tekrar al' var ama boş saati yine siz arıyorsunuz."* |
| 0:45 | Keşfet → **Konumuma Yakın Salonlar** | Salonlar yakından uzağa, mesafe rozetiyle sıralanır ("1,2 km"). İl seçicide "istanbul" yazmak da "İstanbul"u bulur. |
| 0:55 | Premium Berber Center → ekipte **♥** → Randevu Al | Favoriye ekleme anında; ana sayfadaki favori şeridine düşer. Hizmetler bu salonun menüsü ve fiyatları; birden fazla hizmet seçin → toplam süre ve fiyat altta. |
| 1:15 | Personel → Mehmet Kalfa → Takvim | 2 gün sonrası (izin) ve 10 gün sonrası (tadilat) **kapalı**. *"Salon saatleri, tatil ve izinler tek yerden; müşteri asla kapalı güne randevu alamaz."* |
| 1:35 | Saat seçimi | Yalnızca hizmetin **tamamının sığdığı** saatler yeşil. 90 dk'lık seçimde kapanışa yakın saatler kapanır. |
| 1:50 | Dolu bir gün seçin (veya tüm saatleri dolu bir berber) | "Bu gün boş saat kalmadı" → **Yer açılırsa haber ver** + **En yakın boş saatler** çipleri. |
| 2:10 | Randevularım | Yaklaşan randevu; "İptal Et" (son 30 dk'da kapalı). İptal edince bekleme listesindeki kişiye push gider. |

## İşletme tarafı (≈2,5 dk)

| Süre | Ekran | Ne gösterilir / söylenir |
|---|---|---|
| 2:30 | Giriş → otomatik **İşletme Paneli** | Rol bazlı yönlendirme; müşteri ekranı yerine panel. |
| 2:40 | **Bugünün Akışı** | Üstte: randevu sayısı, toplam süre, beklenen ciro, riskli sayısı. "SIRADAKİ" kartı. Her satır: saat–bitiş, müşteri, hizmetler (fiyat/süre), toplam, berber. Müşteri tarafında az önce alınan randevu burada. |
| 3:00 | Tolga'nın kartı (kırmızı çerçeve, **Riskli** rozeti) | Rozete basılı tutun: "1 tamamlanan · 2 gelmedi". *"Booksy/Treatwell'de salon bu bilgiyi göremiyor."* |
| 3:15 | **WhatsApp onay** butonu | WhatsApp hazır mesajla açılır: "Merhaba Tolga, … randevunuzu hatırlatırız, geliyorsanız 'Evet' yazın." *"SMS kontörü yok, API onayı yok, sıfır maliyet."* |
| 3:35 | Geçmiş bir randevuda **Gelmedi** / **Tamamlandı** | "Tamamlandı" → müşteriye değerlendirme bildirimi gider; "Gelmedi" → güven skoru düşer. |
| 3:55 | **Randevu Ekle** (sağ alt) | Telefonla arayan müşteri: personel + hizmet + saat (aynı kurallar, çift kayıt imkânsız) + ad/telefon. |
| 4:20 | **Ekip & Menü** | Hizmet fiyatını değiştir: "Mevcut randevuların fiyatı mühürlü, etkilenmez." Personel ekle (e-postayla davet). |
| 4:35 | **Kapalı Günler** | Yarını kapat → "Bu günde X aktif randevu var" uyarısı. |
| 4:45 | **Rapor** | Aylık ciro, ortalama sepet, gelmeme oranı, personel bazlı ciro, popüler hizmetler. |

## Yeni özellikler (Tur 4) — isteğe bağlı +3 dk

Hazırlık aynı (`seed_demo.py` artık birkaç yorum ve Kerem için bir işletme notu da yükler). İşletme cihazında bildirim
izni açık olsun.

| Süre | Taraf · Ekran | Ne gösterilir / söylenir |
|---|---|---|
| +0:00 | Müşteri · Keşfet | Arama kutusuna **"sakal"** yazın → yalnızca sakal hizmeti olan salonlar, kartta eşleşen hizmetler ("Sakal Tıraşı"). **★ 4.5+** çipi düşük puanlıları gizler. |
| +0:15 | Müşteri · Salon detayı | **Değerlendirmeler:** ortalama, 5→1 yıldız dağılımı, son yorumlar, "Tümünü gör". Ekipte "★ 5.0 (3) · 4 tıraş"; hiç yorumu olmayan berberde "Yeni". |
| +0:35 | Müşteri · Randevu al → takvim | Dolu gün **kırmızı**, az yer kalan gün **turuncu** nokta; dolu güne dokununca "bekleme listesine yazılabilirsiniz" bilgisi. |
| +0:50 | Müşteri · Onay ekranı | **Takvime Ekle** (Google Takvim veya .ics) ve ilk randevuda **"1 saat kala hatırlatalım mı?"** kartı (sistem izni ancak burada sorulur). |
| +1:05 | İşletme cihazı | Müşteri randevuyu aldığı anda **"Yeni randevu 💈"** bildirimi; dokununca panel o günün akışıyla açılır. *"Berber paneli açmadan haberdar."* |
| +1:20 | Müşteri · Randevularım → **Ertele** | Aynı berberde başka gün/saat seçilir (süre ve fiyat değişmez, en fazla 2 kez). İşletmeye "Randevu ertelendi (önceki: …)" bildirimi. **İptal Et**'e basınca diyalog önce ertelemeyi önerir. |
| +1:45 | İşletme · Akış → Kerem'in adına dokun | **Müşteri kartı:** 2 ziyaret, toplam harcama, genelde Eren · Saç Kesimi, 📝 "Yanlar 1 numara, üstü makas. Ense düz." Not düzenlenip kaydedilir. *"Yeni gelen kalfa da müdavimi tanır."* |
| +2:10 | İşletme · Kapalı Günler | **Öğle arası** 13:00–14:00 kaydedin → müşteri tarafında 13:00 ve 13:30 kapanır. **Saatlik kapatma:** "Ali, yarın 14:00–16:00 dışarıda" → sadece o saatler kapanır, etkilenen randevu sayısı uyarısı. |
| +2:40 | İşletme · Ekip & Menü → personele dokun | **Çalışma günleri:** Pazartesi'yi kaldırın → müşteri takviminde o berber için Pazartesiler kapanır (her hafta izin girmeye gerek yok). |

## Yeni özellikler (Tur 5) — isteğe bağlı +3 dk

Seed bunları da hazırlar: Premium Berber Center'da **"Hafta İçi Sabah"** kampanyası (hafta içi 09:00–12:00 saç kesimi
%20), **sadakat kartı** (her 6. ziyaret %50 — Ahmet'in 5 ziyareti var, sıradaki randevusu indirimli), **Ali Usta'nın
saç kesimi 350 ₺ / 40 dk** (menü 300 ₺ / 30 dk), **Eren Kalfa damat tıraşı ve keratin yapmıyor**.

| Süre | Taraf · Ekran | Ne gösterilir / söylenir |
|---|---|---|
| +0:00 | Müşteri · Keşfet | Salon kartında **"%20'ye varan indirim"** ve **"Sadakat kartı"** rozetleri. |
| +0:10 | Müşteri · Salon detayı | **Kampanyalar:** "Hafta İçi Sabah · Hafta içi · 09:00–12:00 · Saç Kesimi". **Sadakat Kartı:** 6 damganın 5'i dolu, "Sıradaki randevunuz %50 indirimli! 🎉" |
| +0:25 | Müşteri · Randevu al → Saç Kesimi | Hizmette **%20** rozeti ve **"300–350 ₺"** aralığı ("Fiyat ve süre personele göre değişir"). Personel adımında her berberin kendi fiyatı: Ali Usta **350 ₺ · 40 dk**, diğerleri 300 ₺ · 30 dk. Damat Tıraşı seçilirse Eren soluk: "Vermiyor: Damat Tıraşı". |
| +0:50 | Müşteri · Takvim → saat | Takvimde kampanyalı günlerin köşesinde **%**; saatlerde **"%20 indirim"** etiketi (yalnızca 09:00–12:00). |
| +1:05 | Müşteri · Onay öncesi özet | Liste fiyatı üstü çizili, **"Hafta İçi Sabah %20 −60 ₺"**, toplam 240 ₺. Ahmet'in kendisiyse sadakat (%50) daha büyük olduğu için o uygulanır: *"İndirimler üst üste binmez, müşteriye en iyisi uygulanır."* |
| +1:20 | Müşteri · Randevularım → Geçmiş → **Aynısını Tekrar Al** | "2 hafta ★" (Ahmet'in olağan aralığı) seçili gelir: "19 Ekim Pazartesi, her zamanki saatiniz 18:00 boş." Tek dokunuşla alınır. |
| +1:40 | İşletme · Akış → **Takvim** (sağ üstteki seçici) | Personel sütunları; randevuya **basılı tutup** başka saate veya başka berbere sürükleyin → "Taşı" → müşteriye "Randevunuz güncellendi" bildirimi. Boş hücreye dokununca o personel ve saatle **Randevu Ekle** açılır. |
| +2:10 | İşletme · Ekip & Menü → personele dokun → **Verdiği hizmetler ve fiyatlar** | Ali Usta: Saç Kesimi özel 350 ₺ / 40 dk. Bir hizmeti kapatın → müşteri tarafında o berber bu hizmet için seçilemez. |
| +2:30 | İşletme · Ekip & Menü → **Kampanyalar** → Ekle | "Salı İndirimi %15, Sal" → kaydedin; müşteri tarafında Salı günleri **%** ile işaretlenir. **Sadakat kartı** satırından eşik/yüzde değişir. *"Boş saatleri doldurmak için SMS'e gerek yok."* |
| +2:50 | İşletme · Kapalı Günler | **"Son dakika randevuya açık"** kartı → "1 saat" seçin: müşteri en erken 1 saat sonrasını alabilir; panelden ekleme serbest. Rapor sekmesinde **"Verilen indirim"** kutusu. |

## Kapanış cümlesi (15 sn)

*"Müşteri için 3 saniyede randevu, işletme için gelmeyen müşteriyi önceden gören ve WhatsApp'tan tek dokunuşla teyit
eden bir akış. Komisyon yok, SMS maliyeti yok."*

---

### Yedek plan (internet/cihaz sorunu olursa)

Tarayıcıda `http://localhost:8010/docs` → sağ üst **Authorize** → `dev:demo-isletme` → `GET /panel/akis` ve
`dev:demo-musteri` → `GET /randevular/her-zamanki` yanıtlarını gösterin.
