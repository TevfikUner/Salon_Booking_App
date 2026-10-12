# İlerleme — Tur 5: Yapılacaklar D bölümü

Dal: `feature/tur5` (`main`'den; 12.10.2026'da `main`'e birleştirildi) · Başlangıç: 2026-10-12 · Kararlar: [KARARLAR.md](KARARLAR.md) "Tur 5" · Önceki tur: Tur 4 (İlham özellikleri, [ILHAM_ANALIZI.md](ILHAM_ANALIZI.md))

Kullanıcı isteği: "Yapılacaklar listesindeki her şeyi önem sırasına göre yap." Sıra: Tur 4 kod incelemesi → D maddeleri
(ücretli servis gerektirmeyenler) → emülatör/PostgreSQL doğrulaması → mağaza görüntüleri → çoklu dil.

| # | İş | Durum | Not |
|---|---|---|---|
| — | Tur 4 kod incelemesi | ✅ | Hata: erteleme işletmeye ayrıca "iptal edildi" bildirimi gönderiyordu → düzeltildi, testli |
| 13 | Berber ↔ hizmet, berbere özel fiyat/süre | ✅ | migration 0006 `berber_hizmetleri`; hizmette aralık, personel adımında berber toplamı, vermeyen soluk; panel "Verdiği hizmetler ve fiyatlar" |
| 12+16 | Kampanya + sadakat kartı | ✅ | migration 0007; `fiyat_servisi.py`; mühürlü indirim; `GET /randevular/fiyat`; salon/hizmet/takvim/saat rozetleri; panelde kampanya formu ve sadakat ayarı; raporda indirim |
| 14 | Berber sütunlu gün takvimi + sürükle-bırak | ✅ | `GunTakvimi`; `POST /panel/randevular/{id}/tasi`; boş hücreden Randevu Ekle; Liste/Takvim seçimi hatırlanır |
| 20 | Kişisel veri şifreleme | ✅ | migration 0008 `telefon_ozet`; `veri_sifreleme.py` (Fernet, isteğe bağlı `VERI_ANAHTARI`); `araclar.py anahtar-uret / veri-sifrele / veri-coz` |
| 15 | En az önceden randevu süresi | ✅ | migration 0009 `min_onceden_dk`; Kapalı Günler'de kart; panel muaf |
| 19 | Tekrar randevu | ✅ | `GET /randevular/{id}/tekrar-onerisi`; Randevularım → Geçmiş → "Aynısını Tekrar Al" |
| — | Doğrulama | ✅ | pytest 155 (SQLite + PostgreSQL 16 + `VERI_ANAHTARI` açık); migration 0006–0009 Tur 4 verili PostgreSQL'de; emülatörde 5 uçtan uca test; 15 ekranın görsel incelemesi |
| C-1 | Mağaza ekran görüntüleri | ✅ | 8 PNG (kampanya, indirimli saat, gün takvimi dahil) |
| 18 | Çoklu dil | ⬜ | Sırada — bkz. YAPILACAKLAR.md |
| 10, 11, 17 | Kapora, galeri, SMS | ⏸ | Ücretli servis/sözleşme gerekiyor — kullanıcı kararı |

Her maddeden sonra: `pytest` + `ruff check .` (backend), `flutter analyze` + `flutter test` (App), migration varsa boş SQLite'ta `alembic upgrade head` / `check` / `downgrade`.

## Ortam notları
- Backend testleri: `cd backend && .venv/Scripts/python.exe -m pytest -q -p no:warnings` (şifreleme açık: `VERI_ANAHTARI=x` önüne)
- PostgreSQL testi: geçici konteyner `docker run -d --name pb-test-pg -e POSTGRES_PASSWORD=berber_yerel -e POSTGRES_USER=berber -e POSTGRES_DB=berber_test -p 127.0.0.1:55432:5432 postgres:16-alpine` (WSL içinde) → `TEST_DATABASE_URL=postgresql://berber:berber_yerel@127.0.0.1:55432/berber_test pytest`
- Docker WSL'de: `wsl -d Ubuntu -- bash -lc "cd /mnt/c/.../pro_berber_full && API_PORT=8020 docker compose -p premium-berber up -d --build"`. Aynı makinede başka bir `files` projesi 8000/5432'de çalışıyor — dokunmayın.
- Android SDK: `%LOCALAPPDATA%\Android\Sdk`. PATH'te ayrıca WinGet adb var → cihaz komutlarında SDK adb'si kullanılmalı.
- Entegrasyon testi: `bash backend/yuk/yigin.sh entegrasyon` (WSL'den) → `flutter test integration_test/<dosya> -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:8020`
- Emülatör: `emulator -avd berber_test`, önce `adb shell cmd alarm set-timezone Europe/Istanbul`; mağaza görüntüsü için `adb shell wm size 1080x1920`.
- Git Bash'ten WSL'e yol verirken `MSYS_NO_PATHCONV=1` gerekli.
