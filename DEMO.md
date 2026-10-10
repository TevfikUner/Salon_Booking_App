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
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```
   (Windows PowerShell: `$env:SEED_MUSTERI_UID="..."; $env:SEED_ISLETME_UID="..."; python seed_demo.py`)
3. İki cihaz/emülatör: birinde müşteri, diğerinde işletme hesabıyla giriş yapın
   (`flutter run --dart-define=API_BASE_URL=http://<bilgisayar-ip>:8000`).
4. Seed demo için şunları hazırlar: Ahmet'in Ali Usta ile 4 geçmiş randevusu (→ "Her Zamanki"), Tolga'nın 2 kez gelmemesi
   (→ "Riskli"), salonda bugün 6 randevu, 10 gün sonra "Tadilat" kapalı günü, Mehmet Kalfa'nın 2 gün sonra izni.

> Seed'deki bugünkü randevular sabit saatlerdedir (10:00–19:00). Demo akşam yapılıyorsa geçmiş olanlar
> otomatik "tamamlandı"ya döner — akıştaki "Tamamlandı / Gelmedi" butonlarını göstermek için ideal.

---

## Müşteri tarafı (≈2,5 dk)

| Süre | Ekran | Ne gösterilir / söylenir |
|---|---|---|
| 0:00 | Ana sayfa | **"Her Zamanki" kartı:** "Ali Usta · Saç & Sakal · 45 dk · 450 ₺ — en yakın boş saatler." *"Ahmet hiçbir şey aramıyor."* |
| 0:20 | Kartta bir saat çipine dokun → onay | 3 saniyede randevu; onay ekranında salon, saat aralığı (örn. 18:00–18:45), toplam. *"Rakiplerde 'tekrar al' var ama boş saati yine siz arıyorsunuz."* |
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

## Kapanış cümlesi (15 sn)

*"Müşteri için 3 saniyede randevu, işletme için gelmeyen müşteriyi önceden gören ve WhatsApp'tan tek dokunuşla teyit
eden bir akış. Komisyon yok, SMS maliyeti yok."*

---

### Yedek plan (internet/cihaz sorunu olursa)

Tarayıcıda `http://localhost:8000/docs` → sağ üst **Authorize** → `dev:demo-isletme` → `GET /panel/akis` ve
`dev:demo-musteri` → `GET /randevular/her-zamanki` yanıtlarını gösterin.
