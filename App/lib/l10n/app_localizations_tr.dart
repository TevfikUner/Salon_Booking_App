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
}
