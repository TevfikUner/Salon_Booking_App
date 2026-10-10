# İlerleme — Tur 3: Sağlamlık ve Yayına Hazırlık

Dal: `feature/v1-hazirlik` · Başlangıç: 2026-10-10 · Kanıtlar: [YAYIN_KONTROL_LISTESI.md](YAYIN_KONTROL_LISTESI.md)

"Devam et" denirse: aşağıdaki ilk ☐ maddeden sürdür.

| Kapı | Durum | Not |
|---|---|---|
| 1. Android AAB | ⏳ | |
| 2. Canlı backend | ☐ | |
| 3. Yük ve dayanıklılık | ☐ | |
| 4. Uygulama kalitesi | ☐ | |
| 5. Play politika & mağaza | ☐ | |
| 6. Son kontrol & teslim | ☐ | |

## Ortam notları
- Android SDK: `%LOCALAPPDATA%\Android\Sdk` (lisanslar kabul edildi). PATH'te ayrıca WinGet adb var → cihaz komutlarında SDK adb'si kullanılmalı.
- 127.0.0.1:8000 WSL'deki başka bir servise ait; yerel backend **8010**'da çalıştırılır.
- Emülatör: AVD `berber_test` (android-35, google_apis_playstore, x86_64).
