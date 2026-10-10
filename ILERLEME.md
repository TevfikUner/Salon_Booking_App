# İlerleme — Tur 3: Sağlamlık ve Yayına Hazırlık

Dal: `feature/v1-hazirlik` · Başlangıç: 2026-10-10 · Kanıtlar: [YAYIN_KONTROL_LISTESI.md](YAYIN_KONTROL_LISTESI.md)

"Devam et" denirse: aşağıdaki ilk ☐/⏳ maddeden sürdür.

| Kapı | Durum | Not |
|---|---|---|
| 1. Android AAB | ✅ | AAB 62,0 MB + release APK 62,8 MB, upload anahtarıyla imzalı. Manifest değişikliği sonrası son AAB tekrar alınacak (Kapı 6) |
| 2. Canlı backend | ✅ | Compose yığını (gunicorn 2/6 worker + worker süreci + PG16) çalıştı; 70 pytest SQLite + PostgreSQL |
| 3. Yük ve dayanıklılık | ✅ | YUK_TESTI.md — 1000 kullanıcı/6 worker hedefler içinde, çift randevu 0, kesintide kayıp 0 |
| 4. Uygulama kalitesi | ⏳ | Kod + birim/taşma testleri tamam. Kalan: entegrasyon testlerini emülatörde koşmak (sistem imajı iniyor) |
| 5. Play politika & mağaza | ⏳ | Belgeler tamam. Kalan: ekran görüntüleri (`flutter drive … ekran_goruntusu_test.dart`, emülatör gerekli) |
| 6. Son kontrol & teslim | ⏳ | Belgeler ve son AAB (62,1 MB) tamam. Kalan: YAYIN_KONTROL_LISTESI'ndeki `__…__` yer tutucuları (emülatör sonuçları), son özet |

## Ortam notları
- Android SDK: `%LOCALAPPDATA%\Android\Sdk` (lisanslar kabul edildi). PATH'te ayrıca WinGet adb var → cihaz komutlarında SDK adb'si kullanılmalı.
- 127.0.0.1:8000 WSL'deki başka bir servise ait; yerel backend **8010**'da, docker yığını **8020**'de (`API_PORT=8020 docker compose -p premium-berber up -d`).
- Emülatör: indirme 10.10.2026 iptal edildi (kullanıcı isteği); kalan işler YAPILACAKLAR.md bölüm C.
- Entegrasyon testi: `bash backend/yuk/yigin.sh entegrasyon` → `flutter test integration_test/<dosya> --dart-define=API_URL=http://10.0.2.2:8020`
- Git Bash'ten WSL'e yol verirken `MSYS_NO_PATHCONV=1` gerekli.
