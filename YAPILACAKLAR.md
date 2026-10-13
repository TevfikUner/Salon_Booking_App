# Yapılacaklar

Tek liste: biten iş buradan **silinir**. Son güncelleme: 13 Ekim 2026.

**Hedef (13 Ekim 2026'da değişti):** Uygulama Play Store'a yayınlanmayacak. GitHub'da yayına hazır kalitede,
profesyonel bir proje olarak duracak. Yayına özgü işler (Play Console, kapalı test, AAB, Render, hukukçu) listeden
çıkarıldı; yapılmış olan yayın hazırlığı (mağaza metinleri, imzalama, yük testleri) projenin "üretime hazır" olduğunun
kanıtı olarak belgelerde kalır.

`(SİZ)` işaretli maddeleri siz yaparsınız, diğerlerini ben yaparım.

---

1. **(SİZ) Eski admin şifresini değiştirin.** Repo herkese açık ve şifre git geçmişinde duruyor. Kodda artık
   kullanılmıyor ama başka bir hesapta (e-posta, Firebase vb.) kullandıysanız oralarda değiştirin.
2. **(SİZ) Lisans seçin.** MIT: herkes kodu kullanabilir, yalnızca sizin adınızı korur (portfolyo için yaygın). "Tüm
   hakları saklıdır": kod görünür ama kimse kullanamaz. Seçiminizi söyleyin, dosyayı ben eklerim.
3. **(SİZ) README dilini seçin.** Öneri: ana README İngilizce (işverenler ve yabancı geliştiriciler okur), Türkçe
   sürümü `README.tr.md`'de. İsterseniz yalnızca Türkçe de kalabilir.
4. **GitHub Actions CI:** her push'ta backend `pytest` + `ruff`, Flutter `analyze` + `test` (Linux'ta
   `flutter test` çalışır). README'ye "build passing" rozeti.
5. **README'yi vitrin haline getirme:**
   - Üstte ekran görüntüleri (8 adet hazır, `MAGAZA/ekran_goruntuleri/`) ve kısa bir demo GIF
   - Özellik listesi (müşteri / işletme / admin)
   - Mimari diyagramı (Flutter ↔ FastAPI ↔ PostgreSQL, worker, Firebase)
   - Teknoloji yığını
   - Öne çıkan mühendislik kararları: çakışmasız randevu, eşzamanlılık, idempotency, yük testi, KVKK, şifreleme, çoklu dil
   - "Hızlı başlangıç": tek komutla `docker compose up` + demo verisi
6. **Demo GIF'i / videosu:** emülatörde randevu alma ve işletme takvimi akışlarını kaydedip README'ye koyarım.
7. **Belgeleri düzenleme:**
   - Kökteki .md dosyalarını `docs/` altına taşıyıp yeni hedefe göre sadeleştiririm
   - Kişisel iş listelerini kaldırırım: BENDEN_GEREKENLER, YAYIN_KONTROL_LISTESI, en son bu dosya
   - KARARLAR, YUK_TESTI, ILHAM_ANALIZI kalır
   - Gizlilik politikası PDF'ini kökten kaldırırım
8. **Temiz klondan kurulum denemesi:** repoyu sıfırdan klonlayıp README'deki adımlarla backend + uygulamanın
   gerçekten ayağa kalktığını doğrularım (docker compose, seed, emülatör).
9. **Son kod gözden geçirmesi:**
   - `flutter analyze` ve `ruff` uyarısız
   - Ölü kod ve kullanılmayan dosyalar temizlenir
   - Commit'lenmemesi gereken bir şey kalmadığı doğrulanır (`google-services.json`, demo veritabanı vb.)
10. **"Yol haritası" bölümü:** online kapora, salon galerisi, SMS/WhatsApp hatırlatma README'ye "planlanan" olarak
    girer. Ücretli servis gerektirdikleri için yapılmadılar; bu bir eksik değil, kapsam kararı olarak görünür.
11. **GitHub sayfası:** repo açıklaması ve konu etiketleri (flutter, fastapi, booking-app…) `gh` ile eklenir. `v1.0.0`
    etiketi ve kısa sürüm notu.
12. **(SİZ) Uygulamayı bir tur kendiniz deneyin** (emülatör yeterli, kurulum `docs/DEMO.md`). Çeviriler doğal mı,
    göze batan bir şey var mı? Bulduklarınızı yazın, düzeltirim.
13. **(SİZ) README'nin son halini okuyun** ve repoyu GitHub profilinizde sabitleyin (Customize your pins).
14. **(SİZ, isteğe bağlı) Canlı demo:** Firebase'e uygulamayı ekleyip Render'a dağıtırsanız README'ye canlı API
    linki konur. Gerekmez; ekran görüntüleri ve GIF yeterli vitrin olur. Render'ın ücretsiz PostgreSQL'i 30 gün sonra
    silinir.

Not: Windows "Akıllı Uygulama Denetimi" bu bilgisayarda `flutter test`'i engelliyor; birim testleri emülatörde
koşuyorum (`integration_test/birim_cihazda_test.dart`). CI (madde 4) bu sorunu GitHub tarafında da çözer.
