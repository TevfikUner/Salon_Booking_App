# İlerleme — Tur 4: İlham Özellikleri

Dal: `feature/ilham-ozellikler` (`feature/v1-hazirlik`'ten) · Başlangıç: 2026-10-12 · Plan ve gerekçeler: [ILHAM_ANALIZI.md](ILHAM_ANALIZI.md)

"Devam et" denirse: aşağıdaki ilk ⬜ maddeden sürdür. Sıra kullanıcı isteğiyle **önem sırası**.

| # | Özellik | Durum | Not |
|---|---|---|---|
| 1 | İşletmeye/personele anlık bildirim | ✅ | `rs.salona_bildir`; `type=panel_randevu` → panel Akış o günle |
| 2 | Randevu erteleme | ✅ | `POST /randevular/{id}/ertele`, migration 0003, `ErtelemeSheet` |
| 3 | Yorumlar ve berber istatistikleri | ✅ | `GET /degerlendirmeler/salon/{id}`, salon detayında bölüm + `YorumlarScreen`, ekipte puan(sayı) · tıraş |
| 4 | Haftalık izin günü + öğle arası + saatlik bloke | ✅ | migration 0004 (`saat_blokeleri` ayrı tablo), `/panel/bloke`, Kapalı Günler'de mola kartı, Ekip'te çalışma günleri |
| 5 | Müşteri kartı + kalıcı not | ⬜ | KVKK metni → BENDEN_GEREKENLER |
| 6 | Takvimde dolu günler | ⬜ | |
| 7 | Salon ve hizmet araması | ⬜ | |
| 8 | Takvime ekle (.ics) | ⬜ | |
| 9 | Bildirim izni ön ekranı | ⬜ | |
| — | Son: DEMO.md, KARARLAR.md, README test sayıları, özet | ⬜ | |

Her maddeden sonra: `pytest` + `ruff check .` (backend), `flutter analyze` + `flutter test` (App), migration varsa boş SQLite'ta `alembic upgrade head` / `check` / `downgrade`.

## Ortam notları
- Backend testleri: `cd backend && .venv/Scripts/python.exe -m pytest -q -p no:warnings`
- Android SDK: `%LOCALAPPDATA%\Android\Sdk`. PATH'te ayrıca WinGet adb var → cihaz komutlarında SDK adb'si kullanılmalı.
- Yerel backend **8010**'da, docker yığını **8020**'de (`API_PORT=8020 docker compose -p premium-berber up -d`).
- Entegrasyon testi: `bash backend/yuk/yigin.sh entegrasyon` → `flutter test integration_test/<dosya> --dart-define=API_URL=http://10.0.2.2:8020`
- Emülatör: `emulator -avd berber_test`, önce `adb shell cmd alarm set-timezone Europe/Istanbul`.
- Git Bash'ten WSL'e yol verirken `MSYS_NO_PATHCONV=1` gerekli.
