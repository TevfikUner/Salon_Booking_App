# İlerleme — Tur 3: Sağlamlık ve Yayına Hazırlık

Dal: `feature/v1-hazirlik` · Başlangıç: 2026-10-10 · Kanıtlar: [YAYIN_KONTROL_LISTESI.md](YAYIN_KONTROL_LISTESI.md)

"Devam et" denirse: aşağıdaki ilk ☐/⏳ maddeden sürdür.

| Kapı | Durum | Not |
|---|---|---|
| 1. Android AAB | ✅ | AAB 62,0 MB + release APK 62,8 MB, upload anahtarıyla imzalı. Manifest değişikliği sonrası son AAB tekrar alınacak (Kapı 6) |
| 2. Canlı backend | ✅ | Compose yığını (gunicorn 2/6 worker + worker süreci + PG16) çalıştı; 70 pytest SQLite + PostgreSQL |
| 3. Yük ve dayanıklılık | ✅ | YUK_TESTI.md — 1000 kullanıcı/6 worker hedefler içinde, çift randevu 0, kesintide kayıp 0 |
| 4. Uygulama kalitesi | ⏳ | Kalan: yasal metin senkronu, 360dp/büyük yazı taşma testleri, splash HTTPS kontrolü, entegrasyon testlerini emülatörde koşmak |
| 5. Play politika & mağaza | ☐ | MAGAZA/ metinleri, veri güvenliği, içerik derecelendirme, ekran görüntüleri, kapalı test rehberi |
| 6. Son kontrol & teslim | ☐ | YAYIN_KONTROL_LISTESI, BENDEN_GEREKENLER, CANLIYA_ALMA, README, KARARLAR, son AAB |

## Ortam notları
- Android SDK: `%LOCALAPPDATA%\Android\Sdk` (lisanslar kabul edildi). PATH'te ayrıca WinGet adb var → cihaz komutlarında SDK adb'si kullanılmalı.
- 127.0.0.1:8000 WSL'deki başka bir servise ait; yerel backend **8010**'da, docker yığını **8020**'de (`API_PORT=8020 docker compose -p premium-berber up -d`).
- Emülatör: AVD `berber_test` (android-35, google_apis_playstore, x86_64) — sistem imajı yavaş iniyor.
- Entegrasyon testi: `bash backend/yuk/yigin.sh entegrasyon` → `flutter test integration_test/<dosya> --dart-define=API_URL=http://10.0.2.2:8020`
- Git Bash'ten WSL'e yol verirken `MSYS_NO_PATHCONV=1` gerekli.
