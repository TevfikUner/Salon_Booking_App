# Kapalı Test Rehberi (12 test kullanıcısı × 14 gün)

2023 sonrası açılan **kişisel** Play geliştirici hesaplarında üretime çıkmadan önce zorunlu: en az **12 test kullanıcısı**,
**14 gün boyunca kesintisiz** kapalı teste katılmış olmalı. (Şirket/kuruluş hesabıysanız bu zorunluluk yok; doğrudan
üretime gönderebilirsiniz.)

## 1. Test grubunu hazırla (Play Console)

1. **Test ve yayınla → Test → Kapalı test → Kanal oluştur** (ad: `kapali-test`).
2. **Test kullanıcıları** sekmesi → **E-posta listesi oluştur** → ad: `Premium Berber Testçileri`.
3. En az **15** Gmail adresi ekleyin (12 şart; ayrılan olursa sayı 12'nin altına düşmesin).
   - Adres, kişinin telefonundaki Play Store'da oturum açık olan Google hesabı olmalı.
4. **Geri bildirim URL'si veya e-posta**: `destek@premiumberber.app`
5. **Sürüm oluştur** → `app-release.aab` yükle → sürüm notu (aşağıda) → **İncelemeye gönder**.
6. İnceleme bitince (genelde 1–3 gün) **Test kullanıcıları** sekmesindeki **"Web'de katıl"** bağlantısını kopyalayın.

## 2. Testçilere gönderilecek mesaj

```
Merhaba 👋

Premium Berber'in (berber randevu uygulaması) kapalı testine seni davet ediyorum. Play Store'un kuralı gereği
uygulamanın yayına çıkabilmesi için 14 gün boyunca test grubunda kalman gerekiyor — sadece birkaç dakikanı alır:

1) Bu bağlantıyı Play Store'da kullandığın Gmail hesabıyla aç ve "Test kullanıcısı ol"a dokun:
   <WEB'DE KATIL BAĞLANTISI>
2) Aynı sayfadaki "Google Play'den indir" bağlantısıyla uygulamayı yükle.
3) Hesap oluştur, bir salon seç ve deneme randevusu al; sonra Randevularım'dan iptal et.
4) 14 gün boyunca uygulamayı SİLME ve test grubundan ÇIKMA. Arada bir açman yeterli.

Bir hata görürsen veya bir şey kafanı karıştırırsa ekran görüntüsüyle bana yaz ya da uygulamadaki
Yardım & Destek → Bize Ulaşın'ı kullan.

Teşekkürler! 💈
```

## 3. Sürüm notu (kapalı test, Türkçe)

```
İlk test sürümü:
• Salon keşfet, hizmet/usta/saat seçip randevu al
• Randevularım: görüntüle ve iptal et
• Randevu hatırlatma bildirimleri
• İşletme paneli (onaylı işletmeler için)
Lütfen bulduğunuz hataları Yardım & Destek'ten bildirin.
```

## 4. 14 gün boyunca

| Gün | Yapılacak |
|---|---|
| 0 | Sürüm onaylandı, bağlantı gönderildi. Play Console → Kapalı test → **Test kullanıcısı sayısı** ≥ 12 olana kadar takip |
| 1–3 | Crashlytics'te çökme var mı? (Firebase Console → Crashlytics). Varsa düzelt → yeni sürüm (versionCode +1) aynı kanala |
| 7 | Testçilerden kısa geri bildirim iste ("en çok ne zorladı?") |
| 14 | Play Console → **Üretime erişim başvurusu**: soru formunu doldur (aşağıdaki yanıt taslakları) |

> Sayaç, 12 kişinin **aynı anda** katılmış olduğu ilk günden başlar. Yeni sürüm yüklemek sayacı sıfırlamaz;
> testçilerin gruptan çıkması sıfırlayabilir.

## 5. Üretime erişim formu — yanıt taslakları

- **Testçileri nasıl buldunuz?** Arkadaş, aile ve tanıdık berber/kuaför işletmeleri; davet e-postası ile.
- **Testçiler uygulamayı nasıl kullandı?** Hesap oluşturma, salon keşfetme, randevu alma/iptal, bildirimler; bir işletme hesabıyla panel (günün akışı, randevu ekleme, tamamlandı işaretleme).
- **Hangi geri bildirimleri aldınız, ne değiştirdiniz?** (14 gün sonunda gerçek geri bildirimlerle doldurun.)
- **Uygulama kime yönelik?** Türkiye'deki berber/erkek kuaförü müşterileri ve salon işletmecileri.
- **Üretime hazır olduğunuzu nasıl biliyorsunuz?** Kapalı testte çökme oranı (Crashlytics), 1000 eşzamanlı kullanıcı yük testi (`docs/load-testing.md`), uçtan uca otomatik testler.
