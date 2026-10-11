# İlerleme — Tur 4: İlham Özellikleri

Dal: `feature/ilham-ozellikler` (`feature/v1-hazirlik`'ten; 12.10.2026'da `main`'e birleştirildi) · Başlangıç: 2026-10-12 · Plan ve gerekçeler: [ILHAM_ANALIZI.md](ILHAM_ANALIZI.md)

**Tur tamamlandı.** "Devam et" denirse: aşağıdaki ilk ⬜ maddeden sürdür. Sıra kullanıcı isteğiyle **önem sırası**.

| # | Özellik | Durum | Not |
|---|---|---|---|
| 1 | İşletmeye/personele anlık bildirim | ✅ | `rs.salona_bildir`; `type=panel_randevu` → panel Akış o günle |
| 2 | Randevu erteleme | ✅ | `POST /randevular/{id}/ertele`, migration 0003, `ErtelemeSheet` |
| 3 | Yorumlar ve berber istatistikleri | ✅ | `GET /degerlendirmeler/salon/{id}`, salon detayında bölüm + `YorumlarScreen`, ekipte puan(sayı) · tıraş |
| 4 | Haftalık izin günü + öğle arası + saatlik bloke | ✅ | migration 0004 (`saat_blokeleri` ayrı tablo), `/panel/bloke`, Kapalı Günler'de mola kartı, Ekip'te çalışma günleri |
| 5 | Müşteri kartı + kalıcı not | ✅ | migration 0005, `/panel/musteriler/{id}` + `/not`, akışta müşteri adına dokun; KVKK cümlesi BENDEN_GEREKENLER §9 |
| 6 | Takvimde dolu günler | ✅ | `musait-takvim?hizmet_ids=` → `bos_slot`/`dolu` (2 sorgu), takvimde altın/turuncu/kırmızı nokta |
| 7 | Salon ve hizmet araması | ✅ | `/salonlar?q=&min_puan=` (+`eslesen_hizmetler`), Keşfet'te arama kutusu + ★4.5+; entegrasyon testi liste anahtarına bağlandı |
| 8 | Takvime ekle (.ics) | ✅ | `GET /randevular/{id}/takvim.ics` (`takvim_dosyasi.py`), onay ekranı + randevu kartı: Google Takvim bağlantısı veya .ics paylaş |
| 9 | Bildirim izni ön ekranı | ✅ | müşteriye izin girişte değil onay ekranında `BildirimIzniKarti` ile; `shared_preferences` eklendi |
| — | Son: DEMO.md, KARARLAR.md, README, YAPILACAKLAR, PostgreSQL + emülatör doğrulaması | ✅ | pytest 108 (SQLite + PG16), flutter test 49, entegrasyon 2/2 (emülatör) |

Her maddeden sonra: `pytest` + `ruff check .` (backend), `flutter analyze` + `flutter test` (App), migration varsa boş SQLite'ta `alembic upgrade head` / `check` / `downgrade`.

## Ortam notları
- Backend testleri: `cd backend && .venv/Scripts/python.exe -m pytest -q -p no:warnings`
- Android SDK: `%LOCALAPPDATA%\Android\Sdk`. PATH'te ayrıca WinGet adb var → cihaz komutlarında SDK adb'si kullanılmalı.
- Yerel backend **8010**'da, docker yığını **8020**'de (`API_PORT=8020 docker compose -p premium-berber up -d`).
- Entegrasyon testi: `bash backend/yuk/yigin.sh entegrasyon` → `flutter test integration_test/<dosya> --dart-define=API_URL=http://10.0.2.2:8020`
- Emülatör: `emulator -avd berber_test`, önce `adb shell cmd alarm set-timezone Europe/Istanbul`.
- Git Bash'ten WSL'e yol verirken `MSYS_NO_PATHCONV=1` gerekli.
