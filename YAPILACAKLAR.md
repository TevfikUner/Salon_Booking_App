# Yapılacaklar — Tur 3 sonrası (10 Ekim 2026)

Kod `feature/v1-hazirlik` dalında hazır (main'e birleştirilmedi). Ayrıntılı adımlar: [BENDEN_GEREKENLER.md](BENDEN_GEREKENLER.md) ·
Neyin hazır olduğu: [YAYIN_KONTROL_LISTESI.md](YAYIN_KONTROL_LISTESI.md)

## İlk 3 iş (bugün)
- [ ] **Firebase'e `com.tevfikuner.premiumberber` Android uygulamasını ekle**, `google-services.json`'u indir →
      `python scripts/google_services_yukle.py ~/Downloads/google-services.json` (BENDEN_GEREKENLER §1)
- [ ] **Upload anahtarını yedekle:** `C:\Users\VICTUS\.premium-berber\` klasörünü iki ayrı yere kopyala (§2)
- [ ] **Render:** dalı main'e birleştir → Blueprint → `FIREBASE_CREDENTIALS_JSON`, `DESTEK_EPOSTA` → `/health` ok (§3–4)

## Sonra
- [ ] Gerçek adresle AAB derle (§5) → Play Console'da uygulama oluştur, mağaza girişi ve uygulama içeriği (`MAGAZA/`) (§6)
- [ ] Kapalı test: 12+ testçi, 14 gün (`MAGAZA/kapali_test_rehberi.md`)
- [ ] İnceleme hesabı (müşteri + onaylı işletme) Play Console "Uygulama erişimi"ne (§7)
- [ ] Gerçek telefonda giriş/kayıt/bildirim/hesap silme kontrolü (§8)
- [ ] Yasal metinlere veri sorumlusu unvan/adres (hukukçu) → `python scripts/yasal_senkron.py` (§9)
- [ ] Eski admin şifresi `***KALDIRILDI***` başka yerde kullanıldıysa değiştir
