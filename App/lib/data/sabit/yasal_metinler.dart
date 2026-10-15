// OTOMATİK ÜRETİLDİ — elle düzenlemeyin. Kaynak: backend/yasal/*.md
// Güncellemek için: python scripts/yasal_senkron.py
import 'package:berber_app_ui/core/config.dart';

class YasalMetin {
  final String baslik;
  final String _ham;

  /// Web'deki aynı belgenin adresi (Play Console ve tarayıcı için).
  final String yol;
  const YasalMetin(this.baslik, this._ham, this.yol);

  String get icerik => _ham
      .replaceAll('{DESTEK_EPOSTA}', AppConfig.destekEposta)
      .replaceAll('{HESAP_SILME_URL}', AppConfig.hesapSilmeUrl)
      .replaceAll('{KVKK_URL}', '${AppConfig.baseUrl}/yasal/kvkk');

  String get webAdresi => '${AppConfig.baseUrl}/yasal/$yol';
}

class YasalMetinler {
  YasalMetinler._();

  static const gizlilik = YasalMetin('Gizlilik Politikası', _gizlilik, 'gizlilik');
  static const kvkk = YasalMetin('KVKK Aydınlatma Metni', _kvkk, 'kvkk');
  static const kullanim = YasalMetin('Kullanım Koşulları', _kullanim, 'kullanim');

  static const String _gizlilik = r'''
Son güncelleme: 15.10.2026

Bu politika, Premium Berber mobil uygulamasının (“Uygulama”) hangi kişisel verileri neden topladığını, kimlerle paylaştığını, ne kadar sakladığını ve haklarınızı açıklar. Uygulamayı kullanarak bu politikayı okuduğunuzu kabul edersiniz.

1. TOPLADIĞIMIZ VERİLER

Hesap bilgileri: ad, soyad, cep telefonu, e-posta adresi ve isteğe bağlı olarak yüklediğiniz profil fotoğrafı. Şifreniz bizim sunucularımıza gelmez; Google Firebase Authentication tarafından şifrelenmiş olarak saklanır.

Randevu bilgileri: seçtiğiniz salon, personel, hizmetler, tarih ve saat, ücret, randevu durumu (onaylandı, tamamlandı, iptal, gelinmedi), bekleme listesi kayıtları, favori berberleriniz, verdiğiniz puan ve yorumlar.

Konum: yalnızca “Konumuma Yakın Salonlar” düğmesine bastığınızda ve izin verdiğinizde, cihazınızın yaklaşık konumu salonları mesafeye göre sıralamak için bir kez kullanılır. Konumunuz sunucularımızda saklanmaz.

Cihaz ve bildirim: randevu hatırlatması ve bildirim göndermek için cihazınıza ait bildirim anahtarı (Firebase Cloud Messaging token).

Uygulama kararlılığı ve kullanım istatistikleri: uygulama çöktüğünde cihaz modeli, işletim sistemi sürümü ve hata ayrıntısı (Firebase Crashlytics); kayıt, randevu oluşturma ve iptal gibi temel olaylar (Firebase Analytics). Bu veriler adınız, e-postanız veya telefonunuzla eşleştirilmez; reklam kimliği toplanmaz.

Destek talepleri: “Bize Ulaşın” ile gönderdiğiniz e-posta, mesaj ve ekler.

2. VERİLERİ HANGİ AMAÇLA İŞLİYORUZ

• Hesabınızı oluşturmak ve oturumunuzu doğrulamak
• Randevu almanızı, iptal etmenizi ve randevularınızı görüntülemenizi sağlamak
• Randevu onayı, hatırlatma, iptal ve değerlendirme bildirimleri göndermek
• Seçtiğiniz salonun randevunuzu yönetebilmesi
• Uygulama hatalarını tespit edip düzeltmek, hizmet kalitesini ölçmek
• Yasal yükümlülükleri yerine getirmek

Ticari elektronik ileti (kampanya bildirimi) yalnızca kayıt sırasında ayrıca onay verirseniz gönderilir; bu onayı istediğiniz zaman geri alabilirsiniz.

3. SALONLARLA PAYLAŞIM VE GÜVEN SKORU

Randevu aldığınızda adınız, telefon numaranız, randevu ayrıntılarınız ve notlarınız, seçtiğiniz salonla paylaşılır. Bu paylaşım randevunun yerine getirilebilmesi için gereklidir ve sizin talebinizle yapılır.

Salonlar, randevuları planlayabilmek için müşterinin geçmiş randevularından otomatik hesaplanan bir güven skorunu (tamamlanan, gelinmeyen ve randevuya kısa süre kala iptal edilen randevu sayıları) görür. Skor yalnızca randevu aldığınız salonlara gösterilir; sizin hakkınızda başka bir karar verilmesi için kullanılmaz. Gelinmedi olarak işaretlenen bir randevuya itiraz etmek için bizimle iletişime geçebilirsiniz.

4. HİZMET SAĞLAYICILAR (VERİ İŞLEYENLER)

• Google Firebase (Authentication, Cloud Messaging, Crashlytics, Analytics) — kimlik doğrulama, bildirim, hata ve kullanım istatistikleri
• Render — uygulama sunucusu ve veritabanı (Avrupa Birliği / Frankfurt bölgesi)

Bu sağlayıcılar verileri yalnızca bizim adımıza ve hizmet sunmak amacıyla işler. Verileriniz bunlar dışında hiçbir üçüncü tarafa satılmaz, kiralanmaz veya reklam amacıyla paylaşılmaz. Yasal zorunluluk hâlinde yetkili makamlarla paylaşılabilir.

5. GÜVENLİK

Uygulama ile sunucu arasındaki tüm iletişim HTTPS (TLS) ile şifrelenir. Sunucuya yapılan her istek Firebase oturum anahtarıyla doğrulanır; her kullanıcı yalnızca kendi verisine, her salon yalnızca kendi randevularına erişebilir.

6. SAKLAMA SÜRESİ

Hesabınız aktif olduğu sürece verileriniz saklanır. Hesabınızı sildiğinizde ad, soyad, telefon, profil fotoğrafı, bildirim anahtarı ve yorum metinleriniz silinir, gelecekteki randevularınız iptal edilir. Salonların muhasebe kayıtları için geçmiş randevular kimliğinizle ilişkilendirilemeyecek şekilde (anonim) kalır. Sunucu kayıtları en fazla 30 gün tutulur.

7. HESAP VE VERİ SİLME

• Uygulamadan: Profil → Hesap → Hesabımı Sil
• Uygulamaya erişemiyorsanız: {HESAP_SILME_URL} adresindeki formdan talep gönderebilirsiniz. Talepler en geç 30 gün içinde sonuçlandırılır.

8. HAKLARINIZ

6698 sayılı KVKK'nın 11. maddesi kapsamındaki haklarınız için KVKK Aydınlatma Metni ({KVKK_URL})'ne bakınız. Verilerinize erişim, düzeltme veya silme talepleriniz için bize yazabilirsiniz.

9. ÇOCUKLAR

Uygulama 13 yaşından küçük çocuklara yönelik değildir ve bilerek bu yaştaki çocuklardan veri toplamaz.

10. İLETİŞİM

E-posta: {DESTEK_EPOSTA}

Bu politika değişirse güncel sürüm bu sayfada yayımlanır ve önemli değişiklikler uygulama içinden duyurulur.
''';

  static const String _kvkk = r'''
Son güncelleme: 15.10.2026

6698 sayılı Kişisel Verilerin Korunması Kanunu (“KVKK”) uyarınca, Premium Berber uygulamasında kişisel verilerinizin işlenmesine ilişkin sizi bilgilendiririz.

1. VERİ SORUMLUSU

Premium Berber uygulaması işletmecisi (“Premium Berber”). İletişim: {DESTEK_EPOSTA}

2. İŞLENEN KİŞİSEL VERİLER

• Kimlik ve iletişim: ad, soyad, cep telefonu, e-posta
• Görsel: yalnızca yüklerseniz profil fotoğrafı (dilediğiniz an kaldırabilirsiniz)
• Müşteri işlem: randevu, hizmet, ücret, bekleme listesi, favori, puan ve yorum bilgileri; randevu geçmişinden hesaplanan güven skoru
• İşlem güvenliği: oturum anahtarı, bildirim anahtarı, sunucu erişim kayıtları, uygulama hata kayıtları
• Konum: yalnızca talep ettiğinizde yaklaşık konum (saklanmaz)
• Pazarlama: yalnızca açık rızanız varsa ticari elektronik ileti izni

3. İŞLEME AMAÇLARI

Üyelik oluşturulması ve yönetimi; randevu hizmetinin sunulması ve seçtiğiniz salonun randevuyu yerine getirebilmesi; randevu hatırlatma ve bilgilendirme bildirimleri; hizmet kalitesinin ölçülmesi (değerlendirme); bilgi güvenliği ve hata tespiti; hukuki yükümlülüklerin yerine getirilmesi; açık rızanız varsa kampanya bildirimleri.

4. HUKUKİ SEBEPLER

• Bir sözleşmenin kurulması veya ifası için gerekli olması (KVKK m.5/2-c): hesap ve randevu işlemleri
• Veri sorumlusunun hukuki yükümlülüğü (m.5/2-ç)
• Meşru menfaat (m.5/2-f): bilgi güvenliği, hata tespiti, salonun randevuyu planlayabilmesi için güven skoru
• Açık rıza (m.5/1): ticari elektronik ileti

5. AKTARIM

Randevu bilgileriniz, talebiniz üzerine seçtiğiniz salona aktarılır. Hizmet sağlayıcılarımız Google Firebase (kimlik doğrulama, bildirim, hata ve kullanım istatistikleri) ve Render (sunucu ve veritabanı) ile, yalnızca hizmetin sunulması amacıyla paylaşılır. Bu sağlayıcıların sunucuları yurt dışında (Avrupa Birliği ve ABD) bulunabileceğinden aktarım KVKK m.9 kapsamında gerçekleştirilir. Yasal zorunluluk hâlinde yetkili kamu kurumlarına aktarılabilir.

6. TOPLAMA YÖNTEMİ

Veriler mobil uygulama üzerinden elektronik ortamda, sizin girdiğiniz bilgilerden ve uygulamayı kullanımınızdan otomatik olarak toplanır.

7. HAKLARINIZ (KVKK M.11)

Kişisel verilerinizin işlenip işlenmediğini öğrenme; işlenmişse bilgi talep etme; işlenme amacını ve amacına uygun kullanılıp kullanılmadığını öğrenme; aktarıldığı üçüncü kişileri bilme; eksik veya yanlış işlenmişse düzeltilmesini, KVKK m.7 çerçevesinde silinmesini ve bu işlemlerin aktarıldığı kişilere bildirilmesini isteme; münhasıran otomatik sistemlerle analiz edilmesi sonucu aleyhinize bir sonuca itiraz etme; kanuna aykırı işleme sebebiyle zarara uğramanız hâlinde zararın giderilmesini talep etme.

8. BAŞVURU

Taleplerinizi {DESTEK_EPOSTA} adresine iletebilirsiniz. Başvurular en geç 30 gün içinde ücretsiz olarak sonuçlandırılır. Hesap silme için uygulamada Profil → Hesabımı Sil adımını veya {HESAP_SILME_URL} formunu kullanabilirsiniz.
''';

  static const String _kullanim = r'''
Son güncelleme: 10.10.2026

Premium Berber uygulamasını kullanarak aşağıdaki koşulları kabul etmiş olursunuz.

1. HİZMET

Premium Berber; salon keşfetme, online randevu alma, randevu yönetimi, bekleme listesi ve değerlendirme hizmetleri sunan bir aracı platformdur. Berberlik hizmetini salonlar verir; hizmetin kalitesi, fiyatı ve salondaki uygulamalar ilgili salonun sorumluluğundadır.

2. HESAP

• Hesap oluşturmak için geçerli bir e-posta adresi ve cep telefonu gerekir.
• Verdiğiniz bilgilerin doğruluğundan ve hesabınızın güvenliğinden siz sorumlusunuz.
• 13 yaşından küçükler hesap oluşturamaz.

3. RANDEVU KURALLARI

• Fiyat ve süre, randevu anında geçerli olan salon menüsüne göre belirlenir ve randevunuzda sabitlenir.
• Randevular, başlangıcına 30 dakikadan fazla süre varken uygulamadan iptal edilebilir. Daha geç iptaller için salonu arayın.
• Salonun kapalı olduğu veya personelin izinli olduğu günlerde randevu alınamaz.
• Gelinmeyen randevular salon tarafından “gelinmedi” olarak işaretlenebilir ve güven skorunu etkiler (bkz. Gizlilik Politikası).
• Salon, zorunlu durumlarda randevuyu iptal edebilir; bu durumda bildirim alırsınız.

4. DEĞERLENDİRMELER

Yalnızca tamamlanan randevular bir kez değerlendirilebilir. Hakaret, küfür, kişisel veri veya yanıltıcı içerik barındıran yorumlar kaldırılabilir.

5. YASAK KULLANIMLAR

Sahte hesap veya sahte randevu oluşturmak; sistemi otomatik araçlarla zorlamak veya kötüye kullanmak; başka kullanıcıların veya salonların verilerine erişmeye çalışmak yasaktır. Bu durumlarda hesap askıya alınabilir.

6. SORUMLULUĞUN SINIRLANDIRILMASI

Planlı bakım veya teknik arızalar nedeniyle hizmet geçici olarak kesintiye uğrayabilir. Premium Berber, salonun sunduğu hizmetten doğan uyuşmazlıklarda taraf değildir; ancak çözüm için iletişim sağlamaya yardımcı olur.

7. DEĞİŞİKLİKLER

Koşullar güncellenebilir; önemli değişiklikler uygulama içinden duyurulur.

8. İLETİŞİM

{DESTEK_EPOSTA}
''';
}
