# Yapılacaklar

Tek liste: biten iş buradan **silinir**. Ayrıntılı adımlar [BENDEN_GEREKENLER.md](BENDEN_GEREKENLER.md)'de (§ numaraları oraya bakar).
Neyin hazır olduğu: [YAYIN_KONTROL_LISTESI.md](YAYIN_KONTROL_LISTESI.md) · Son güncelleme: 12 Ekim 2026

Kodun güncel hali GitHub `main` dalında; Tur 4 özellikleri `feature/ilham-ozellikler` dalında (birleştirilmedi).

---

## A. Sizin yapacaklarınız — önce bu 3'ü

1. **Firebase'e yeni Android uygulamasını ekleyin** — yayını bu engelliyor (§1)
   - Firebase Console → proje `berberapp-9859f` → Proje ayarları → Uygulama ekle → Android
   - Paket adı: `com.tevfikuner.premiumberber` · SHA-1: `C3:32:F3:DA:D6:34:7E:10:F4:9C:33:0F:59:A0:A9:95:71:6D:16:31`
   - İnen dosyayı yerleştirin: `python scripts/google_services_yukle.py ~/Downloads/google-services.json`
2. **Upload anahtarını yedekleyin** (§2)
   - `C:\Users\VICTUS\.premium-berber\` klasörünü iki ayrı yere kopyalayın (USB + bulut/parola yöneticisi)
   - Kaybolursa uygulamaya güncelleme yükleyemezsiniz
3. **Render'a yayın** (§3–4)
   - Firebase → Hizmet hesapları → yeni özel anahtar (JSON) indirin; E-posta/Şifre girişi açık olsun
   - render.com → New → Blueprint → `TevfikUner/pro_berber_full`, dal `main`
   - `FIREBASE_CREDENTIALS_JSON` (JSON'un tamamı) ve `DESTEK_EPOSTA` girin
   - Kontrol: `https://premium-berber-api.onrender.com/health` → `"durum":"ok"`
   - Render Shell: `python araclar.py admin-ekle sizin@eposta.com`

## B. Sizin yapacaklarınız — sonra

4. Gerçek adresle AAB derleyin (§5): `cd App && flutter build appbundle --release --dart-define=API_URL=https://premium-berber-api.onrender.com`
5. Play Console: geliştirici hesabı (25 $), uygulama oluştur, mağaza girişi ve uygulama içeriği — metinler `MAGAZA/` klasöründe (§6)
6. Kapalı test: 12+ testçi, 14 gün — davet mesajı `MAGAZA/kapali_test_rehberi.md`
7. İnceleme hesabı (müşteri + onaylı işletme) → Play Console "Uygulama erişimi" (§7)
8. Gerçek telefonda giriş/kayıt/bildirim/hesap silme kontrolü (§8)
9. Yasal metinlere veri sorumlusu unvanı/adresi (hukukçu) → `python scripts/yasal_senkron.py` (§9)
10. Eski admin şifresi `***KALDIRILDI***` başka bir yerde kullanıldıysa değiştirin

11. **Tur 4 (ilham özellikleri) dalını değerlendirin:** `feature/ilham-ozellikler` — 9 yeni özellik, main'e birleştirilmedi.
    Özet: [ILHAM_ANALIZI.md](ILHAM_ANALIZI.md) §4 · demo: [DEMO.md](DEMO.md) "Yeni özellikler". Birleşirse Render
    migration 0003–0005'i dağıtımda kendisi çalıştırır; AAB'yi (madde 4) birleştirmeden sonra derleyin.
12. Müşteri notu için gizlilik metnine bir cümle (hukukçu onayı; taslak hazır) → BENDEN_GEREKENLER §9

## C. Benim yapacaklarım

1. (İsteğe bağlı, siz isterseniz) Mağaza ekran görüntülerini yenileme: Keşfet'te arama kutusu, salon detayında
   yorumlar ve onay ekranında "Takvime Ekle" yeni. Komut: YAYIN_KONTROL_LISTESI Kapı 5 "Telefon ekran görüntüleri".

1. madde (Firebase) bitince A-4. maddeyi (AAB derleme) ben de yapabilirim.
Emülatör hazır: `emulator -avd berber_test` (testlerden önce saat dilimi: `adb shell cmd alarm set-timezone Europe/Istanbul`).
