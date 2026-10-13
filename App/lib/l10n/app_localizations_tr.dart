// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get uygulamaAdi => 'Premium Berber';

  @override
  String get bugun => 'Bugün';

  @override
  String get yarin => 'Yarın';

  @override
  String get dun => 'Dün';

  @override
  String get ara => 'Ara…';

  @override
  String get internetYok => 'İnternet bağlantısı yok';

  @override
  String get yenidenDene => 'Yeniden Dene';

  @override
  String get zorunluAlan => 'Zorunlu alan';

  @override
  String get eposta => 'E-posta';

  @override
  String get gecerliEpostaGirin => 'Geçerli bir e-posta girin';

  @override
  String get cepTelefonu => 'Cep Telefonu';

  @override
  String get telefonKurali => '5 ile başlayan 10 rakam girin';

  @override
  String get evet => 'Evet';

  @override
  String get vazgec => 'Vazgeç';

  @override
  String get hataOturumDogrulanamadi =>
      'Oturum doğrulanamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get hataSunucuYanitVermiyor =>
      'Sunucu yanıt vermiyor. İnternet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get hataGuvenliBaglanti =>
      'Güvenli bağlantı kurulamadı. Lütfen tekrar deneyin.';

  @override
  String get hataSunucuyaUlasilamadi =>
      'Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.';

  @override
  String get hataIslemTamamlanamadi => 'İşlem tamamlanamadı.';

  @override
  String get hataBilgileriKontrolEdin => 'Girilen bilgileri kontrol edin.';

  @override
  String get hataCokFazlaDeneme =>
      'Çok fazla deneme yaptınız. Lütfen biraz bekleyin.';

  @override
  String get hataHizmetKullanilamiyor =>
      'Hizmet geçici olarak kullanılamıyor. Lütfen birazdan tekrar deneyin.';

  @override
  String get hataOturumSuresiDoldu =>
      'Oturumunuzun süresi doldu. Lütfen tekrar giriş yapın.';

  @override
  String get hataYetkiYok => 'Bu işlem için yetkiniz yok.';

  @override
  String get hataKayitBulunamadi => 'Kayıt bulunamadı.';

  @override
  String hataSunucu(int kod) {
    return 'Sunucu hatası ($kod). Lütfen daha sonra tekrar deneyin.';
  }

  @override
  String get hataEpostaGecersiz => 'E-posta adresi geçersiz.';

  @override
  String get hataEpostaSifreHatali => 'E-posta veya şifre hatalı.';

  @override
  String get hataEpostaKullanimda =>
      'Bu e-posta ile zaten bir hesap var. Giriş yapmayı deneyin.';

  @override
  String get hataSifreZayif => 'Şifre çok zayıf. En az 6 karakter kullanın.';

  @override
  String get hataCokFazlaDenemeYapildi =>
      'Çok fazla deneme yapıldı. Lütfen biraz sonra tekrar deneyin.';

  @override
  String get hataKimlikDogrulama => 'Kimlik doğrulama hatası.';

  @override
  String get puanla => 'Puanla';

  @override
  String get ac => 'Aç';

  @override
  String get berber => 'Berber';

  @override
  String get bolumGosterilemiyor =>
      'Bu bölüm şu an gösterilemiyor.\nLütfen geri dönüp tekrar deneyin.';

  @override
  String get takvimeEkle => 'Takvime Ekle';

  @override
  String get googleTakvim => 'Google Takvim';

  @override
  String get digerTakvimUygulamasi => 'Diğer takvim uygulaması (.ics)';

  @override
  String get digerTakvimOrnekleri => 'Samsung Takvim, Outlook, Apple Takvim…';

  @override
  String get takvimAcilamadi => 'Takvim açılamadı.';

  @override
  String get berberRandevusu => 'Berber randevusu';

  @override
  String sureDk(int dk) {
    return '$dk dk';
  }

  @override
  String sureSa(int sa) {
    return '$sa sa';
  }

  @override
  String sureSaDk(int sa, int dk) {
    return '$sa sa $dk dk';
  }

  @override
  String get kvkkOnaylamalisiniz =>
      'Devam etmek için KVKK Aydınlatma Metni\'ni onaylamalısınız.';

  @override
  String girisBasarisiz(String neden) {
    return 'Giriş başarısız: $neden';
  }

  @override
  String basvuruGonderilemedi(String neden) {
    return 'Başvuru gönderilemedi: $neden';
  }

  @override
  String kayitBasarisiz(String neden) {
    return 'Kayıt başarısız: $neden';
  }

  @override
  String sifreSifirlamaGonderildi(String eposta) {
    return 'Şifre sıfırlama bağlantısı $eposta adresine gönderildi.';
  }

  @override
  String get hosGeldiniz => 'Hoş Geldiniz';

  @override
  String get randevunuzSiziBekliyor => 'Randevunuz sizi bekliyor';

  @override
  String get sifremiUnuttum => 'Şifremi Unuttum';

  @override
  String get girisYap => 'Giriş Yap';

  @override
  String get hesabinizYokMu => 'Hesabınız yok mu?';

  @override
  String get kayitOlun => 'Kayıt Olun';

  @override
  String get isletmeBasvurusu => 'İşletme Başvurusu';

  @override
  String get salonunuzuKaydedin =>
      'Salonunuzu kaydedin, onaylandığında paneliniz açılır';

  @override
  String get isletmeSalonAdi => 'İşletme / Salon Adı';

  @override
  String get ad => 'Ad';

  @override
  String get soyad => 'Soyad';

  @override
  String get kvkkOkudumKabul =>
      'KVKK Aydınlatma Metni\'ni okudum, kabul ediyorum. (Zorunlu)';

  @override
  String get basvuruyuGonder => 'Başvuruyu Gönder';

  @override
  String get isletmeHesabinizVarMi => 'İşletme hesabınız var mı?';

  @override
  String get girisYapin => 'Giriş Yapın';

  @override
  String get hesapOlustur => 'Hesap Oluştur';

  @override
  String get birkacAdimdaRandevu => 'Birkaç adımda randevu almaya başlayın';

  @override
  String get kvkkMusteriOnay =>
      'KVKK Aydınlatma Metni\'ni okudum; kişisel verilerimin randevu hizmeti için işlenmesini kabul ediyorum. (Zorunlu)';

  @override
  String get ticariIletiOnay =>
      'Kampanya ve fırsatlardan haberdar olmak için ticari elektronik ileti almak istiyorum. (İsteğe bağlı)';

  @override
  String get kayitOl => 'Kayıt Ol';

  @override
  String get rolunuzuSecin => 'Devam etmek için rolünüzü seçin';

  @override
  String get musteri => 'Müşteri';

  @override
  String get musteriRolAciklama =>
      'Randevu al, berber bul\nve hizmetlerden yararlan';

  @override
  String get isletmeSahibi => 'İşletme Sahibi';

  @override
  String get isletmeRolAciklama =>
      'Salonunuzu kaydedin\nve müşterilerinizi yönetin';

  @override
  String get zatenHesabinizVarMi => 'Zaten hesabınız var mı?';

  @override
  String get guvensizYapilandirma =>
      'Uygulama güvenli sunucuya bağlanacak şekilde yapılandırılmamış. Lütfen uygulamayı güncelleyin.';

  @override
  String get premiumBerberHizmetleri => 'Premium Berber Hizmetleri';

  @override
  String get geri => 'Geri';

  @override
  String get logoEtiketi => 'Premium Berber logosu';

  @override
  String get sifre => 'Şifre';

  @override
  String get sifreyiGoster => 'Şifreyi göster';

  @override
  String get sifreyiGizle => 'Şifreyi gizle';

  @override
  String get enAz6Karakter => 'En az 6 karakter';

  @override
  String get metniOku => 'Metni oku';

  @override
  String get sifreSifirlamaAciklama =>
      'E-posta adresinizi girin, şifre sıfırlama bağlantısını gönderelim.';

  @override
  String get iptal => 'İptal';

  @override
  String get gonder => 'Gönder';

  @override
  String get yardimDestek => 'Yardım & Destek';

  @override
  String get sss => 'SSS';

  @override
  String get bizeUlasin => 'Bize Ulaşın';

  @override
  String get tarayicidaAc => 'Tarayıcıda aç';

  @override
  String get yasalMetinTurkce => '';

  @override
  String get konuRandevu => 'Randevu Sorunu';

  @override
  String get konuOdeme => 'Ödeme / Fiyat';

  @override
  String get konuHesap => 'Hesap Problemi';

  @override
  String get konuHata => 'Uygulama Hatası';

  @override
  String get konuOneri => 'Öneri / İstek';

  @override
  String get konuDiger => 'Diğer';

  @override
  String get fotografCek => 'Fotoğraf Çek';

  @override
  String get galeridenSec => 'Galeriden Seç';

  @override
  String get dosyaSec => 'Dosya Seç';

  @override
  String get konuSecin => 'Lütfen bir konu seçin.';

  @override
  String get mesajYazin => 'Lütfen mesajınızı yazın.';

  @override
  String get sorununuzuBildirin =>
      'Sorununuzu bize bildirin, en kısa sürede dönüş yapalım.';

  @override
  String get konu => 'Konu';

  @override
  String get mesajiniz => 'Mesajınız';

  @override
  String get mesajIpucu => 'Sorununuzu veya isteğinizi açıklayın…';

  @override
  String get ekEkle => 'Fotoğraf veya dosya ekle';

  @override
  String get ekiKaldir => 'Eki kaldır';

  @override
  String get epostaGonder => 'E-posta Gönder';

  @override
  String get eklerleGonder => 'Eklerle Gönder';

  @override
  String epostaAcilamadi(String eposta) {
    return 'E-posta uygulaması açılamadı. Bize $eposta adresinden ulaşabilirsiniz.';
  }

  @override
  String alici(String eposta) {
    return 'Alıcı: $eposta';
  }

  @override
  String get yeni => 'Yeni';

  @override
  String get sehirSecin => 'Şehir Seçin';

  @override
  String get ilceSecin => 'İlçe Seçin';

  @override
  String get filtreleriTemizle => 'Filtreleri temizle';

  @override
  String get salonBulunamadi => 'Salon bulunamadı';

  @override
  String get farkliKelimeDeneyin =>
      'Farklı bir kelime deneyin veya filtreleri temizleyin.';

  @override
  String get kesfet => 'Keşfet';

  @override
  String aramaSonucYok(String aranan) {
    return '\"$aranan\" için sonuç yok';
  }

  @override
  String get konumServisiKapali =>
      'Konum servisi kapalı. Lütfen cihaz ayarlarından açın.';

  @override
  String get konumIzniKaliciRed =>
      'Konum izni kalıcı olarak reddedilmiş. Ayarlardan izin verebilirsiniz.';

  @override
  String get konumIzniGerekli =>
      'Yakındaki salonları göstermek için konum izni gerekiyor.';

  @override
  String get konumAlinamadi => 'Konum alınamadı. Lütfen tekrar deneyin.';

  @override
  String get salon => 'Salon';

  @override
  String get randevuAl => 'Randevu Al';

  @override
  String get kampanyalar => 'Kampanyalar';

  @override
  String get sadakatKartiBaslik => 'Sadakat Kartı';

  @override
  String get ekibimiz => 'Ekibimiz';

  @override
  String get degerlendirmeler => 'Değerlendirmeler';

  @override
  String get bugunkuDurum => 'Bugünkü Durum';

  @override
  String get calismaSaatleri => 'Çalışma Saatleri';

  @override
  String favorilereEklendi(String ad) {
    return '$ad favorilere eklendi.';
  }

  @override
  String favorilerdenCikarildi(String ad) {
    return '$ad favorilerden çıkarıldı.';
  }

  @override
  String get henuzDegerlendirmeYok => 'Henüz değerlendirme yok.';

  @override
  String get favorilerdenCikar => 'Favorilerden çıkar';

  @override
  String get favorilereEkle => 'Favorilere ekle';

  @override
  String get randevu => 'Randevu';

  @override
  String trasSayisi(int n) {
    return '$n tıraş';
  }

  @override
  String get uygulamaAcilamadi => 'Uygulama açılamadı.';

  @override
  String get harita => 'Harita';

  @override
  String get yolTarifi => 'Yol Tarifi';

  @override
  String get indirimOnaydaYansir =>
      'İndirim, uygun gün ve saati seçtiğinizde onay ekranında tutara yansır.';

  @override
  String get sadakatGirisYap =>
      'Giriş yaptığınızda ziyaretleriniz burada sayılır.';

  @override
  String yuzde(int y) {
    return '%$y';
  }

  @override
  String sadakatKurali(int esik, int yuzde) {
    return 'Her $esik. ziyaretiniz %$yuzde indirimli';
  }

  @override
  String sadakatDamga(int esik, int n) {
    return '$esik ziyaretten $n tanesi tamam';
  }

  @override
  String sadakatSiradaki(int yuzde) {
    return 'Sıradaki randevunuz %$yuzde indirimli! 🎉';
  }

  @override
  String sadakatKalan(int n) {
    return '$n ziyaret sonra indirim kazanırsınız.';
  }

  @override
  String get yakindanUzaga => 'Yakından uzağa sıralanıyor';

  @override
  String get konumumaYakin => 'Konumuma Yakın Salonlar';

  @override
  String get salonAramaIpucu => 'Salon, ilçe veya hizmet ara (ör. sakal)';

  @override
  String get aramayiTemizle => 'Aramayı temizle';

  @override
  String get yuksekPuanIpucu => 'Yalnızca 4.5 ve üzeri puanlı salonlar';

  @override
  String get bugunkuRandevu => 'Bugünkü\nRandevu';

  @override
  String get bosKontenjan => 'Boş\nKontenjan';

  @override
  String get doluluk => 'Doluluk';

  @override
  String get salonBugunKapali =>
      'Salon bugün kapalı veya günün saatleri doldu.';

  @override
  String get kapali => 'Kapalı';

  @override
  String get bugunKapali => 'Bugün kapalı';

  @override
  String get sadakatKarti => 'Sadakat kartı';

  @override
  String salonSemantik(String ad, String konum, String puan) {
    return '$ad, $konum, puan $puan';
  }

  @override
  String bugunSaat(String saat) {
    return 'Bugün $saat';
  }

  @override
  String varanIndirim(int yuzde, String ek) {
    return '%$yuzde$ek varan indirim';
  }

  @override
  String get anonim => 'Anonim';

  @override
  String degerlendirmeSayisi(int n) {
    return '$n değerlendirme';
  }

  @override
  String yildizSemantik(int n) {
    return '5 üzerinden $n yıldız';
  }

  @override
  String get degerlendirmelerYuklenemedi => 'Değerlendirmeler yüklenemedi.';

  @override
  String get tekrar => 'Tekrar';

  @override
  String get ilkYorumuSizYapin =>
      'Henüz değerlendirme yok. Randevunuzdan sonra ilk yorumu siz yapabilirsiniz.';

  @override
  String tumunuGor(int n) {
    return 'Tümünü gör ($n)';
  }

  @override
  String get tarih => 'Tarih';

  @override
  String get saat => 'Saat';

  @override
  String get personel => 'Personel';

  @override
  String get hizmetler => 'Hizmetler';

  @override
  String takvimAciklama(String berber, String toplam) {
    return 'Berber: $berber\nToplam: $toplam';
  }

  @override
  String get randevunuzOnaylandi => 'Randevunuz Onaylandı!';

  @override
  String get siziBekliyoruz => 'Sizi bekliyoruz 💈';

  @override
  String get birSaatOnceHatirlatma =>
      'Randevudan 1 saat önce hatırlatma bildirimi alacaksınız.';

  @override
  String get anaSayfayaDon => 'Ana Sayfaya Dön';

  @override
  String get randevularimiGor => 'Randevularımı Gör';

  @override
  String get hizmetSecin => 'Hizmet Seçin';

  @override
  String get personelSecin => 'Personel Seçin';

  @override
  String get tarihSecin => 'Tarih Seçin';

  @override
  String get saatSecin => 'Saat Seçin';

  @override
  String get bilgileriniz => 'Bilgileriniz';

  @override
  String get enAzBirHizmet => 'Lütfen en az bir hizmet seçin';

  @override
  String get lutfenTarih => 'Lütfen bir tarih seçin';

  @override
  String get lutfenSaat => 'Lütfen bir saat seçin';

  @override
  String get lutfenPersonel => 'Lütfen bir personel seçin';

  @override
  String get ileri => 'İleri →';

  @override
  String adim(int n, int toplam) {
    return 'Adım $n / $toplam';
  }

  @override
  String get menuYok => 'Bu salon henüz hizmet menüsünü eklemedi.';

  @override
  String get fiyatPersoneleGore => 'Fiyat ve süre personele göre değişir';

  @override
  String get kesinSurePersonelle => 'Kesin süre personel seçince';

  @override
  String sureAraligi(int min, int max) {
    return '$min–$max dk';
  }

  @override
  String hizmetSecildi(int n) {
    return '$n hizmet seçildi';
  }

  @override
  String get personelYok => 'Bu salonda henüz personel bulunmuyor.';

  @override
  String vermiyor(String hizmetler) {
    return 'Vermiyor: $hizmetler';
  }

  @override
  String get ay => 'Ay';

  @override
  String get kapaliGunlerOtomatik =>
      'Salonun kapalı olduğu günler ve personel izinleri otomatik olarak kapalıdır.';

  @override
  String gunKampanyasi(int yuzde, String ek) {
    return 'Bu günde %$yuzde$ek varan kampanya var; indirimli saatler sonraki adımda işaretli.';
  }

  @override
  String get musait => 'Müsait';

  @override
  String get dolu => 'Dolu';

  @override
  String get yerAcilirsaBildirim =>
      'Bu günde yer açılırsa size hemen bildirim göndereceğiz.';

  @override
  String get onceTarihSecin => 'Lütfen önce bir tarih seçin.';

  @override
  String get bosSaatKalmadi =>
      'Bu gün seçtiğiniz hizmetler için boş saat kalmadı.';

  @override
  String get beklemeListesindesiniz => 'Bekleme listesindesiniz';

  @override
  String get yerAcilirsaHaberVer => 'Yer açılırsa haber ver';

  @override
  String get enYakinBosSaatler => 'En yakın boş saatler';

  @override
  String toplamSureAciklama(String sure) {
    return 'Toplam süre: $sure — yalnızca hizmetin tamamının sığdığı saatler açıktır.';
  }

  @override
  String enAzOnceden(String sure) {
    return 'Bu salon en az $sure önceden randevu alıyor.';
  }

  @override
  String gunSayisi(int n) {
    return '$n gün';
  }

  @override
  String get tumAdimlariTamamlayin => 'Lütfen tüm adımları tamamlayın.';

  @override
  String get sure => 'Süre';

  @override
  String get iletisimBilgileriniz => 'İletişim Bilgileriniz';

  @override
  String get randevumuOnayla => 'Randevumu Onayla';

  @override
  String uygunSaatler(String saatler) {
    return 'Uygun saatler: $saatler';
  }

  @override
  String get bildirimlerKapali => 'Bildirimler kapalı';

  @override
  String get hatirlatalimMi => 'Randevunuza 1 saat kala hatırlatalım mı?';

  @override
  String get bildirimKapaliAciklama =>
      'Hatırlatma ve \"yer açıldı\" haberlerini alamazsınız. Açmak için: Telefon Ayarları › Uygulamalar › Premium Berber › Bildirimler.';

  @override
  String get bildirimIzniAciklama =>
      'Hatırlatma, salonun değişiklikleri ve bekleme listesinde yer açılınca haber vereceğiz. Reklam göndermeyiz.';

  @override
  String get tamam => 'Tamam';

  @override
  String get simdiDegil => 'Şimdi değil';

  @override
  String get evetHatirlat => 'Evet, hatırlat';

  @override
  String get listeFiyati => 'Liste fiyatı';

  @override
  String get indirim => 'İndirim';

  @override
  String get toplam => 'Toplam';

  @override
  String yuzdeIndirim(int y) {
    return '%$y indirim';
  }

  @override
  String get gunDoluAciklama =>
      'Bu gün dolu. Sonraki adımda \"yer açılırsa haber ver\" diyebilir veya en yakın boş saati seçebilirsiniz.';

  @override
  String get azYer => 'Az yer';

  @override
  String get kampanyali => 'Kampanyalı';

  @override
  String azYerKaldi(int n) {
    return 'Bu günde yalnızca $n uygun saat kaldı.';
  }

  @override
  String get randevularim => 'Randevularım';

  @override
  String get iptalEt => 'İptal Et';

  @override
  String get ertele => 'Ertele';

  @override
  String get randevuIptali => 'Randevu İptali';

  @override
  String get cikisYap => 'Çıkış Yap';

  @override
  String get anaSayfa => 'Ana Sayfa';

  @override
  String get profil => 'Profil';

  @override
  String get yaklasanRandevulariniz => 'Yaklaşan Randevularınız';

  @override
  String get favoriBerberlerim => 'Favori Berberlerim';

  @override
  String get tumu => 'Tümü';

  @override
  String get hosGeldinizMakas => 'Hoş Geldiniz ✂️';

  @override
  String get kendinizeRandevu => 'Bugün kendinize güzel bir randevu alın';

  @override
  String sihhatlerOlsun(String ad) {
    return 'Sıhhatler olsun, $ad!';
  }

  @override
  String get favoriYok => 'Henüz favori berberiniz yok';

  @override
  String get favoriNasil => 'Salon sayfasındaki ♥ ile ekleyebilirsiniz';

  @override
  String get herZamankiRandevu => 'Her zamanki randevu';

  @override
  String get randevuyuAl => 'Randevuyu Al';

  @override
  String get herZamanki => 'Her Zamanki';

  @override
  String get yakinBosSaatYok => 'Yakın tarihte boş saat yok.';

  @override
  String get enYakinDokun => 'En yakın boş saatler — dokun, onayla, bitti:';

  @override
  String kacKez(int n) {
    return '$n kez aldınız';
  }

  @override
  String get nasilDevam => 'Nasıl devam etmek istersiniz?';

  @override
  String get yeniSalonKesfet => 'Yeni Bir Salon Keşfet';

  @override
  String get farkliSalonlar => 'Farklı salonları keşfet';

  @override
  String get kapat => 'Kapat';

  @override
  String get randevunuzuNasilBuldunuz => 'Randevunuzu nasıl buldunuz?';

  @override
  String get yorumunuz => 'Yorumunuz (isteğe bağlı)';

  @override
  String get degerlendir => 'Değerlendir';

  @override
  String get tesekkurler => 'Teşekkürler! ⭐';

  @override
  String get degerlendirmeKaydedildi => 'Değerlendirmeniz kaydedildi.';

  @override
  String get puanKotu => 'Kötü';

  @override
  String get puanFenaDegil => 'Fena değil';

  @override
  String get puanIyi => 'İyi';

  @override
  String get puanCokIyi => 'Çok iyi';

  @override
  String get puanMukemmel => 'Mükemmel!';

  @override
  String yildizSayisi(int n) {
    return '$n yıldız';
  }

  @override
  String get berberlerim => 'Berberlerim';

  @override
  String get berberGecmisiYok => 'Henüz favori veya geçmiş berberiniz yok';

  @override
  String get favoriEkleIpucu =>
      'Salon sayfasında ♥ ile favori ekleyebilirsiniz';

  @override
  String get favorileriniz => 'Favorileriniz';

  @override
  String get dahaOnceGittikleriniz => 'Daha önce gittikleriniz';

  @override
  String get cikisEminMisiniz =>
      'Hesabınızdan çıkış yapmak istediğinize emin misiniz?';

  @override
  String get hesabiSil => 'Hesabı Sil';

  @override
  String get hesapSilAciklama =>
      'Kişisel bilgileriniz silinecek ve gelecekteki randevularınız iptal edilecek. Bu işlem geri alınamaz.';

  @override
  String get kaliciSil => 'Kalıcı Olarak Sil';

  @override
  String get hesapSilindi => 'Hesabınız ve kişisel verileriniz silindi.';

  @override
  String get verilerSilindiOturum =>
      'Kişisel verileriniz silindi. Güvenlik nedeniyle oturumunuz kapatıldı.';

  @override
  String get yasalGizlilik => 'Yasal & Gizlilik';

  @override
  String get gizlilikPolitikasi => 'Gizlilik Politikası';

  @override
  String get kvkkMetni => 'KVKK Aydınlatma Metni';

  @override
  String get kullanimKosullari => 'Kullanım Koşulları';

  @override
  String get sikcaSorulanSorular => 'Sıkça Sorulan Sorular';

  @override
  String get hesap => 'Hesap';

  @override
  String get uygulamayiPaylas => 'Uygulamayı Paylaş';

  @override
  String get hesabimiSil => 'Hesabımı Sil';

  @override
  String hesapSilinemedi(String neden) {
    return 'Hesap silinemedi: $neden';
  }

  @override
  String get paylasMetni =>
      'Premium Berber ile saniyeler içinde berber randevusu al 💈';

  @override
  String get dil => 'Dil';

  @override
  String get cihazDili => 'Cihaz dili';

  @override
  String get bilgilerKaydedildi => 'Bilgileriniz kaydedildi.';

  @override
  String get kisiselBilgiler => 'Kişisel Bilgiler';

  @override
  String get kaydet => 'Kaydet';

  @override
  String get duzenle => 'Düzenle';

  @override
  String get adiniz => 'Adınız';

  @override
  String get soyadiniz => 'Soyadınız';

  @override
  String get telefon => 'Telefon';

  @override
  String get randevuyuErtele => 'Randevuyu Ertele';

  @override
  String get acikGunYok => 'Önümüzdeki günlerde açık gün yok.';

  @override
  String get yeniSaatSecin => 'Yeni saat seçin';

  @override
  String get buGunBosSaatYok => 'Bu gün boş saat yok.';

  @override
  String get baskaGunSecin => 'Başka bir gün seçin.';

  @override
  String oneri(String saatler) {
    return 'Öneri: $saatler';
  }

  @override
  String suAn(String bilgi) {
    return 'Şu an: $bilgi';
  }

  @override
  String kalanErteleme(int n) {
    return 'Kalan erteleme hakkı: $n';
  }

  @override
  String get kampanya => 'kampanya';

  @override
  String indirimKalkar(String kampanya, String tutar) {
    return 'Bu saat \"$kampanya\" kapsamında değil: indirim kalkar, tutar $tutar olur. İndirimli saatler işaretli.';
  }

  @override
  String olarakErtele(String zaman) {
    return '$zaman olarak ertele';
  }

  @override
  String get randevunuzErtelendi => 'Randevunuz ertelendi.';

  @override
  String get randevunuzIptalEdildi => 'Randevunuz iptal edildi.';

  @override
  String get yaklasanlar => 'YAKLAŞANLAR';

  @override
  String get gecmis => 'GEÇMİŞ';

  @override
  String get aktifRandevuYok => 'Henüz aktif randevunuz yok';

  @override
  String get gecmisRandevuYok => 'Geçmiş randevu bulunamadı';

  @override
  String iptalEminMisiniz(String randevu) {
    return '$randevu randevunuzu iptal etmek istiyor musunuz?';
  }

  @override
  String get iptalYerineErtele =>
      'Gelemiyorsanız iptal yerine başka bir saate erteleyebilirsiniz.';

  @override
  String get tekrarRandevuAl => 'Tekrar Randevu Al';

  @override
  String get kacHaftaSonra => 'Kaç hafta sonra?';

  @override
  String get herZamankiAraliginiz => '★ her zamanki aralığınız';

  @override
  String get saatSecinKisa => 'Saat seçin';

  @override
  String get bosSaatBulunamadi => 'Önümüzdeki günlerde boş saat bulunamadı.';

  @override
  String haftaSayisi(int n) {
    return '$n hafta';
  }

  @override
  String randevusunuAl(String zaman) {
    return '$zaman randevusunu al';
  }

  @override
  String herZamankiSaatBos(String gun, String saat) {
    return '$gun, her zamanki saatiniz $saat boş.';
  }

  @override
  String kapaliEnYakin(String gun, String neden) {
    return '$gun: $neden En yakın boş saatler:';
  }

  @override
  String saatDoluEnYakin(String gun, String saat) {
    return '$gun $saat dolu. O günün en yakın saatleri:';
  }

  @override
  String tekrarFiyatNotu(String bilgi) {
    return 'Liste fiyatı $bilgi. Kampanya veya sadakat indirimi varsa onayda uygulanır.';
  }

  @override
  String get durumOnaylandi => '✓ Onaylandı';

  @override
  String get durumTamamlandi => '✔ Tamamlandı';

  @override
  String get durumIptal => '✗ İptal';

  @override
  String get durumGelinmedi => 'Gelinmedi';

  @override
  String get salonIptalEtti => 'Salon tarafından iptal edildi.';

  @override
  String get hizmetiDegerlendir => 'Hizmeti Değerlendir';

  @override
  String get aynisiniTekrarAl => 'Aynısını Tekrar Al';

  @override
  String degerlendirildi(String yildiz) {
    return 'Değerlendirildi ($yildiz)';
  }

  @override
  String get ekle => 'Ekle';

  @override
  String get kaldir => 'Kaldır';

  @override
  String get gelmedi => 'Gelmedi';

  @override
  String get tamamlandi => 'Tamamlandı';

  @override
  String get iptalKisa => 'İptal';

  @override
  String get riskli => 'Riskli';

  @override
  String get ogleArasi => 'Öğle arası';

  @override
  String get kadrodanCikar => 'Kadrodan çıkar';

  @override
  String get menudenKaldir => 'Menüden kaldır';

  @override
  String get basvuruOnaylanmadi => 'Başvurunuz onaylanmadı';

  @override
  String get basvuruInceleniyor => 'Başvurunuz inceleniyor';

  @override
  String get destekleIletisim =>
      'Ayrıntılar için destek ekibimizle iletişime geçebilirsiniz.';

  @override
  String get durumuKontrolEt => 'Durumu Kontrol Et';

  @override
  String basvuruAlindi(String ad) {
    return '$ad için başvurunuz alındı. Onaylandığında salon paneliniz açılacak; günün randevularını, personelinizi ve hizmetlerinizi buradan yöneteceksiniz.';
  }

  @override
  String get akis => 'Akış';

  @override
  String get ekipMenu => 'Ekip & Menü';

  @override
  String get kapaliGunler => 'Kapalı Günler';

  @override
  String get rapor => 'Rapor';

  @override
  String get personelPaneli => 'Personel Paneli';

  @override
  String get isletmePaneli => 'İşletme Paneli';

  @override
  String get randevuyuIptalEt => 'Randevuyu iptal et';

  @override
  String get randevuGuncellendi => 'Randevu güncellendi.';

  @override
  String get randevuyuTasi => 'Randevuyu taşı';

  @override
  String get tasimaAciklama =>
      'Fiyat ve süre değişmez; müşteriye bildirim gönderilir.';

  @override
  String get tasi => 'Taşı';

  @override
  String get randevuEkle => 'Randevu Ekle';

  @override
  String get tasimaIpucu => 'Taşımak için randevuya basılı tutup sürükleyin.';

  @override
  String get liste => 'Liste';

  @override
  String get takvim => 'Takvim';

  @override
  String get buGunRandevuYok => 'Bu gün için randevu yok.';

  @override
  String get randevuEkleIpucu =>
      '\"Randevu Ekle\" ile telefonla gelen müşteriyi ekleyebilirsiniz.';

  @override
  String get digerPersonel => 'diğer personel';

  @override
  String saatineTasindi(String saat) {
    return 'Randevu $saat saatine taşındı.';
  }

  @override
  String get notKaydedildi => 'Not kaydedildi.';

  @override
  String get ziyaret => 'Ziyaret';

  @override
  String get harcama => 'Harcama';

  @override
  String get sonZiyaret => 'Son ziyaret';

  @override
  String get isletmeNotu => 'İşletme notu';

  @override
  String get notIpucu => 'Ör: Yanlar 1 numara, üstü makas, ense düz.';

  @override
  String get ozelVeriYazmayin =>
      'Sağlık bilgisi gibi özel nitelikli veri yazmayın.';

  @override
  String get notYalnizSalon => 'Not yalnızca salonunuzda görünür.';

  @override
  String get notuSil => 'Notu Sil';

  @override
  String get sonRandevular => 'Son randevular';

  @override
  String genelde(String ad) {
    return 'Genelde: $ad';
  }

  @override
  String sonGuncelleme(String bilgi) {
    return 'Son: $bilgi';
  }

  @override
  String get musteriAdiGirin => 'Müşteri adını girin.';

  @override
  String get telefonKuraliOrnek =>
      'Telefon 5 ile başlayan 10 rakam olmalı (ör. 532 123 45 67).';

  @override
  String get randevuEklendi => 'Randevu eklendi.';

  @override
  String get telefonlaGelen => 'Telefonla veya kapıdan gelen müşteri için';

  @override
  String get tarihSaat => 'Tarih & Saat';

  @override
  String get saatIcinHizmet => 'Saatleri görmek için hizmet seçin.';

  @override
  String get uygunSaatKalmadi => 'Bu gün için uygun saat kalmadı.';

  @override
  String get adSoyad => 'Ad Soyad';

  @override
  String get telefonIstegeBagli => 'Telefon (isteğe bağlı)';

  @override
  String get notIstegeBagli => 'Not (isteğe bağlı)';

  @override
  String get randevuyuKaydet => 'Randevuyu Kaydet';

  @override
  String get randevuSayisiEtiket => 'Randevu';

  @override
  String get toplamSure => 'Toplam süre';

  @override
  String get beklenenCiro => 'Beklenen ciro';

  @override
  String get siradaki => 'SIRADAKİ';

  @override
  String get whatsappOnay => 'WhatsApp onay';

  @override
  String get araTelefon => 'Ara';

  @override
  String get musteriNotuVar => 'Müşteri notu var';

  @override
  String get bekleniyor => 'Bekleniyor';

  @override
  String get panelden => 'panelden eklendi';

  @override
  String notMetni(String not) {
    return 'Not: $not';
  }

  @override
  String get tasimakIcinBasiliTut => 'taşımak için basılı tutun';

  @override
  String get personelEkle => 'Personel Ekle';

  @override
  String get unvan => 'Unvan (Usta, Kalfa...)';

  @override
  String get epostaIstegeBagli => 'E-posta (isteğe bağlı)';

  @override
  String get personelEpostaIpucu =>
      'Personel bu e-postayla kayıt olursa kendi takvimini görür.';

  @override
  String get personelEklendi => 'Personel eklendi.';

  @override
  String get calismaGunleri => 'Çalışma günleri';

  @override
  String get verdigiHizmetler => 'Verdiği hizmetler ve fiyatlar';

  @override
  String get verdigiHizmetlerAciklama =>
      'Bu personele özel fiyat, süre veya vermediği hizmetler';

  @override
  String get cikar => 'Çıkar';

  @override
  String get personelCikarildi => 'Personel kadrodan çıkarıldı.';

  @override
  String get hizmetEkle => 'Hizmet Ekle';

  @override
  String get hizmetiDuzenle => 'Hizmeti Düzenle';

  @override
  String get hizmetAdi => 'Hizmet adı';

  @override
  String get fiyat => 'Fiyat';

  @override
  String get dkKisa => 'dk';

  @override
  String get aciklamaIstegeBagli => 'Açıklama (isteğe bağlı)';

  @override
  String get fiyatDegisikligi =>
      'Fiyat değişikliği mevcut randevuları etkilemez.';

  @override
  String get hizmetKurali => 'Ad, fiyat ve en az 5 dakikalık süre girin.';

  @override
  String get hizmetEklendi => 'Hizmet eklendi.';

  @override
  String get hizmetGuncellendi => 'Hizmet güncellendi.';

  @override
  String get hizmetKaldirildi => 'Hizmet kaldırıldı.';

  @override
  String get personeleDokunun =>
      'Çalışma günleri ve verdiği hizmetler için personele dokunun.';

  @override
  String get henuzPersonelYok => 'Henüz personel yok.';

  @override
  String get hizmetMenusu => 'Hizmet Menüsü';

  @override
  String get henuzHizmetYok => 'Henüz hizmet yok.';

  @override
  String calismaGunleriKaydedildi(String ad) {
    return '$ad için çalışma günleri kaydedildi.';
  }

  @override
  String hizmetlerKaydedildi(String ad) {
    return '$ad için hizmetler kaydedildi.';
  }

  @override
  String kadrodanCikarilsinMi(String ad) {
    return '$ad kadrodan çıkarılsın mı? Geçmiş randevu kayıtları korunur.';
  }

  @override
  String menudenKaldirilsinMi(String ad) {
    return '\"$ad\" menüden kaldırılsın mı?';
  }

  @override
  String get hesabiBagli => 'hesabı bağlı';

  @override
  String davet(String eposta) {
    return 'davet: $eposta';
  }

  @override
  String hizmetiVermiyor(int n) {
    return '$n hizmeti vermiyor';
  }

  @override
  String ozelFiyatli(int n) {
    return '$n hizmette özel fiyat/süre';
  }

  @override
  String haftalikIzin(String gunler) {
    return 'Haftalık izin: $gunler';
  }

  @override
  String get calismaGunleriAciklama =>
      'İşaretli günlerde çalışır. İşaretsiz günlerde müşteriler bu personelden randevu alamaz.';

  @override
  String get salonBuGunKapali => 'Salon bu gün kapalı';

  @override
  String get solukGunler => 'Soluk günlerde salon kapalı.';

  @override
  String get kampanyaEklendi => 'Kampanya eklendi.';

  @override
  String get kampanyaGuncellendi => 'Kampanya güncellendi.';

  @override
  String get kampanyayiKaldir => 'Kampanyayı kaldır';

  @override
  String get sadakatAciklama =>
      'Müşterinin bu salondaki her N. randevusu indirimli olur. Tamamlanan ve alınmış randevular sayılır; gelinmeyen ve iptal edilenler sayılmaz.';

  @override
  String get kacinciZiyaret => 'Kaçıncı ziyaret (2–50)';

  @override
  String get ziyaretEki => '. ziyaret';

  @override
  String get indirimAraligi => 'İndirim (5–100)';

  @override
  String get sadakatKuraliHata =>
      'Ziyaret 2–50, indirim 5–100 arasında olmalı.';

  @override
  String get sadakatKapatildi => 'Sadakat kartı kapatıldı.';

  @override
  String get kampanyaAciklama =>
      'Boş günleri doldurmak için: ör. \"Salı %20\" veya \"Hafta içi 10:00–14:00 sakal %30\". İndirimler üst üste binmez; müşteriye en yüksek olanı uygulanır.';

  @override
  String get henuzKampanyaYok => 'Henüz kampanya yok.';

  @override
  String get sadakatKapaliAc => 'Kapalı · açmak için dokunun';

  @override
  String get kampanyaKurali => 'Ad girin; indirim %5 ile %90 arasında olmalı.';

  @override
  String get bitisBaslangictanOnce => 'Bitiş tarihi başlangıçtan önce olamaz.';

  @override
  String get yeniKampanya => 'Yeni Kampanya';

  @override
  String get kampanyayiDuzenle => 'Kampanyayı Düzenle';

  @override
  String get kampanyaFormAciklama =>
      'Boş bıraktığınız koşul kısıt koymaz. Değişiklik yalnızca bundan sonraki randevulara uygulanır.';

  @override
  String get kampanyaAdi => 'Kampanya adı';

  @override
  String get kampanyaAdiOrnek => 'Salı İndirimi';

  @override
  String get gunler => 'Günler';

  @override
  String get herGun => 'Her gün';

  @override
  String get saatAraligi => 'Saat aralığı';

  @override
  String get gunBoyu => 'Gün boyu';

  @override
  String get saatAraligiSec => 'Saat aralığı seç';

  @override
  String get tarihAraligi => 'Tarih aralığı';

  @override
  String get suresiz => 'Süresiz';

  @override
  String get baslangicHemen => 'Başlangıç: hemen';

  @override
  String get bitisYok => 'Bitiş: yok';

  @override
  String get temizle => 'Temizle';

  @override
  String get tumHizmetler => 'Tüm hizmetler';

  @override
  String get kampanyaAcik => 'Kampanya açık';

  @override
  String get kapatirsanizDuraklatilir => 'Kapatırsanız silinmez, duraklatılır.';

  @override
  String sadakatKaydedildi(int esik, int yuzde) {
    return 'Sadakat kartı: her $esik. ziyaret %$yuzde.';
  }

  @override
  String get duraklatildi => 'Duraklatıldı';

  @override
  String get suresiDoldu => 'Süresi doldu';

  @override
  String baslangic(String tarih) {
    return 'Başlangıç: $tarih';
  }

  @override
  String bitis(String tarih) {
    return 'Bitiş: $tarih';
  }

  @override
  String get enAzBirHizmetVermeli => 'Personel en az bir hizmet vermeli.';

  @override
  String get personelHizmetAciklama =>
      'Kapalı hizmetler bu personelden alınamaz. Fiyat ve süre boşsa menüdeki geçerli; değişiklik mevcut randevuları etkilemez.';

  @override
  String get menudeHizmetYok => 'Menüde hizmet yok.';

  @override
  String get ozelFiyat => 'Özel fiyat';

  @override
  String get ozelSure => 'Özel süre';

  @override
  String sureEnAz5(String ad) {
    return '$ad: süre en az 5 dakika olmalı.';
  }

  @override
  String menuDegeri(String deger) {
    return 'Menü: $deger';
  }

  @override
  String get kapaliGunEklendi => 'Kapalı gün eklendi.';

  @override
  String get oncePersonelEkle =>
      'Önce Ekip & Menü sekmesinden personel ekleyin.';

  @override
  String get hangiPersonel => 'Hangi personel?';

  @override
  String get kaydedildi => 'Kaydedildi.';

  @override
  String get hangiPersonelIzinli => 'Hangi personel izinli?';

  @override
  String get izinEklendi => 'İzin eklendi.';

  @override
  String get kapaliAciklama =>
      'Öğle arası, kapalı gün, izin ve kapatılan saatlerde müşteriler randevu alamaz.';

  @override
  String get salonKapaliGunler => 'Salonun kapalı olduğu günler';

  @override
  String get kapaliGunYok => 'Planlanmış kapalı gün yok.';

  @override
  String get personelIzinleri => 'Personel izinleri';

  @override
  String get izinYok => 'Planlanmış izin yok.';

  @override
  String get saatlikKapatmalar => 'Saatlik kapatmalar';

  @override
  String get kapatilmisSaatYok =>
      'Kapatılmış saat yok. Ör: \"Ali 14:00–16:00 dışarıda\".';

  @override
  String salonKapaliTarih(String tarih) {
    return 'Salon kapalı: $tarih';
  }

  @override
  String saatlerdeRandevuVar(int n) {
    return 'Kaydedildi. Bu saatlerde $n aktif randevu var; müşterilere haber verin.';
  }

  @override
  String izinGununderandevuVar(int n) {
    return 'İzin eklendi. Bu günde $n aktif randevu var; müşterilere haber verin.';
  }

  @override
  String get molaKaldirildi => 'Öğle arası kaldırıldı.';

  @override
  String get molaYok => 'Öğle arası tanımlı değil';

  @override
  String get molaAciklama => 'Her gün bu saatlerde randevu alınmaz.';

  @override
  String get molayiKaldir => 'Öğle arasını kaldır';

  @override
  String molaKaydedildi(String aralik) {
    return 'Öğle arası $aralik olarak kaydedildi.';
  }

  @override
  String get sinirYok => 'Sınır yok';

  @override
  String get oncedenSoru => 'Müşteri en az ne kadar önceden randevu alsın?';

  @override
  String get oncedenOrnek =>
      'Örneğin 1 saat: saat 12:10\'da en erken 13:30 alınabilir. Sizin panelden eklediğiniz randevular bu sınırdan etkilenmez.';

  @override
  String get sonDakikaAcikNokta => 'Son dakika randevuya açık.';

  @override
  String get sonDakikaAcik => 'Son dakika randevuya açık';

  @override
  String get oncedenAciklama =>
      'Müşterinin uygulamadan alabileceği en yakın saat.';

  @override
  String musterilerEnAz(String sure) {
    return 'Müşteriler en az $sure önceden alabilir.';
  }

  @override
  String enAzOncedenKisa(String sure) {
    return 'En az $sure önceden';
  }

  @override
  String get baslangicSaati => 'Başlangıç saati';

  @override
  String get bitisSaati => 'Bitiş saati';

  @override
  String get bitisSonraOlmali => 'Bitiş saati başlangıçtan sonra olmalı.';

  @override
  String get oncekiAy => 'Önceki ay';

  @override
  String get sonrakiAy => 'Sonraki ay';

  @override
  String get ciro => 'Ciro';

  @override
  String get tamamlanan => 'Tamamlanan';

  @override
  String get ortalamaSepet => 'Ortalama sepet';

  @override
  String get gelmemeOrani => 'Gelmeme oranı';

  @override
  String get verilenIndirim => 'Verilen indirim';

  @override
  String get personelCiro => 'Personel bazlı ciro';

  @override
  String get buAyTamamlananYok => 'Bu ay tamamlanan randevu yok.';

  @override
  String get populerHizmetler => 'En çok tercih edilen hizmetler';

  @override
  String yuzdeMetin(String y) {
    return '%$y';
  }

  @override
  String randevuSayisi(int n) {
    return '$n randevu';
  }

  @override
  String raporAlt(int iptal, int gelmedi, int uygulama) {
    return 'İptal: $iptal · Gelmedi: $gelmedi · Uygulamadan gelen: $uygulama';
  }

  @override
  String get ilkZiyaret => 'İlk ziyaret — geçmiş kaydı yok';

  @override
  String guvenOzet(int tamam, int gelmedi, int gec) {
    return '$tamam tamamlanan · $gelmedi gelmedi · $gec geç iptal';
  }

  @override
  String get guvenilir => 'Güvenilir';

  @override
  String get dikkat => 'Dikkat';

  @override
  String get isletmeHesapSilAciklama =>
      'Hesabınıza ait kişisel bilgiler (ad, telefon, e-posta) silinecek ve panel erişiminiz kapanacak. Salon kaydı ve geçmiş randevular kimliksiz olarak kalır. Bu işlem geri alınamaz.';

  @override
  String get hesapSilinemediTekrar =>
      'Hesap silinemedi. Lütfen tekrar deneyin.';

  @override
  String panelIptalSoru(String randevu) {
    return '$randevu randevusu iptal edilsin mi? Müşteriye bildirim gönderilir.';
  }

  @override
  String get kapaliKucuk => 'kapalı';

  @override
  String bosSaatSayisi(int n) {
    return '$n boş saat';
  }

  @override
  String kampanyaKaldirSoru(String ad) {
    return '\"$ad\" kaldırılsın mı? Bu kampanyayla alınmış randevuların indirimi korunur.';
  }

  @override
  String randevudaKullanildi(int n) {
    return '$n randevuda kullanıldı';
  }
}
