import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @uygulamaAdi.
  ///
  /// In tr, this message translates to:
  /// **'Premium Berber'**
  String get uygulamaAdi;

  /// No description provided for @bugun.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get bugun;

  /// No description provided for @yarin.
  ///
  /// In tr, this message translates to:
  /// **'Yarın'**
  String get yarin;

  /// No description provided for @dun.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get dun;

  /// No description provided for @ara.
  ///
  /// In tr, this message translates to:
  /// **'Ara…'**
  String get ara;

  /// No description provided for @internetYok.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok'**
  String get internetYok;

  /// No description provided for @yenidenDene.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden Dene'**
  String get yenidenDene;

  /// No description provided for @zorunluAlan.
  ///
  /// In tr, this message translates to:
  /// **'Zorunlu alan'**
  String get zorunluAlan;

  /// No description provided for @eposta.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get eposta;

  /// No description provided for @gecerliEpostaGirin.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta girin'**
  String get gecerliEpostaGirin;

  /// No description provided for @cepTelefonu.
  ///
  /// In tr, this message translates to:
  /// **'Cep Telefonu'**
  String get cepTelefonu;

  /// No description provided for @telefonKurali.
  ///
  /// In tr, this message translates to:
  /// **'5 ile başlayan 10 rakam girin'**
  String get telefonKurali;

  /// No description provided for @evet.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get evet;

  /// No description provided for @vazgec.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get vazgec;

  /// No description provided for @hataOturumDogrulanamadi.
  ///
  /// In tr, this message translates to:
  /// **'Oturum doğrulanamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.'**
  String get hataOturumDogrulanamadi;

  /// No description provided for @hataSunucuYanitVermiyor.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu yanıt vermiyor. İnternet bağlantınızı kontrol edip tekrar deneyin.'**
  String get hataSunucuYanitVermiyor;

  /// No description provided for @hataGuvenliBaglanti.
  ///
  /// In tr, this message translates to:
  /// **'Güvenli bağlantı kurulamadı. Lütfen tekrar deneyin.'**
  String get hataGuvenliBaglanti;

  /// No description provided for @hataSunucuyaUlasilamadi.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.'**
  String get hataSunucuyaUlasilamadi;

  /// No description provided for @hataIslemTamamlanamadi.
  ///
  /// In tr, this message translates to:
  /// **'İşlem tamamlanamadı.'**
  String get hataIslemTamamlanamadi;

  /// No description provided for @hataBilgileriKontrolEdin.
  ///
  /// In tr, this message translates to:
  /// **'Girilen bilgileri kontrol edin.'**
  String get hataBilgileriKontrolEdin;

  /// No description provided for @hataCokFazlaDeneme.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme yaptınız. Lütfen biraz bekleyin.'**
  String get hataCokFazlaDeneme;

  /// No description provided for @hataHizmetKullanilamiyor.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet geçici olarak kullanılamıyor. Lütfen birazdan tekrar deneyin.'**
  String get hataHizmetKullanilamiyor;

  /// No description provided for @hataOturumSuresiDoldu.
  ///
  /// In tr, this message translates to:
  /// **'Oturumunuzun süresi doldu. Lütfen tekrar giriş yapın.'**
  String get hataOturumSuresiDoldu;

  /// No description provided for @hataYetkiYok.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için yetkiniz yok.'**
  String get hataYetkiYok;

  /// No description provided for @hataKayitBulunamadi.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt bulunamadı.'**
  String get hataKayitBulunamadi;

  /// No description provided for @hataSunucu.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu hatası ({kod}). Lütfen daha sonra tekrar deneyin.'**
  String hataSunucu(int kod);

  /// No description provided for @hataEpostaGecersiz.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi geçersiz.'**
  String get hataEpostaGecersiz;

  /// No description provided for @hataEpostaSifreHatali.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre hatalı.'**
  String get hataEpostaSifreHatali;

  /// No description provided for @hataEpostaKullanimda.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta ile zaten bir hesap var. Giriş yapmayı deneyin.'**
  String get hataEpostaKullanimda;

  /// No description provided for @hataSifreZayif.
  ///
  /// In tr, this message translates to:
  /// **'Şifre çok zayıf. En az 6 karakter kullanın.'**
  String get hataSifreZayif;

  /// No description provided for @hataCokFazlaDenemeYapildi.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme yapıldı. Lütfen biraz sonra tekrar deneyin.'**
  String get hataCokFazlaDenemeYapildi;

  /// No description provided for @hataKimlikDogrulama.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik doğrulama hatası.'**
  String get hataKimlikDogrulama;

  /// No description provided for @puanla.
  ///
  /// In tr, this message translates to:
  /// **'Puanla'**
  String get puanla;

  /// No description provided for @ac.
  ///
  /// In tr, this message translates to:
  /// **'Aç'**
  String get ac;

  /// No description provided for @berber.
  ///
  /// In tr, this message translates to:
  /// **'Berber'**
  String get berber;

  /// No description provided for @bolumGosterilemiyor.
  ///
  /// In tr, this message translates to:
  /// **'Bu bölüm şu an gösterilemiyor.\nLütfen geri dönüp tekrar deneyin.'**
  String get bolumGosterilemiyor;

  /// No description provided for @takvimeEkle.
  ///
  /// In tr, this message translates to:
  /// **'Takvime Ekle'**
  String get takvimeEkle;

  /// No description provided for @googleTakvim.
  ///
  /// In tr, this message translates to:
  /// **'Google Takvim'**
  String get googleTakvim;

  /// No description provided for @digerTakvimUygulamasi.
  ///
  /// In tr, this message translates to:
  /// **'Diğer takvim uygulaması (.ics)'**
  String get digerTakvimUygulamasi;

  /// No description provided for @digerTakvimOrnekleri.
  ///
  /// In tr, this message translates to:
  /// **'Samsung Takvim, Outlook, Apple Takvim…'**
  String get digerTakvimOrnekleri;

  /// No description provided for @takvimAcilamadi.
  ///
  /// In tr, this message translates to:
  /// **'Takvim açılamadı.'**
  String get takvimAcilamadi;

  /// No description provided for @berberRandevusu.
  ///
  /// In tr, this message translates to:
  /// **'Berber randevusu'**
  String get berberRandevusu;

  /// No description provided for @sureDk.
  ///
  /// In tr, this message translates to:
  /// **'{dk} dk'**
  String sureDk(int dk);

  /// No description provided for @sureSa.
  ///
  /// In tr, this message translates to:
  /// **'{sa} sa'**
  String sureSa(int sa);

  /// No description provided for @sureSaDk.
  ///
  /// In tr, this message translates to:
  /// **'{sa} sa {dk} dk'**
  String sureSaDk(int sa, int dk);

  /// No description provided for @kvkkOnaylamalisiniz.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için KVKK Aydınlatma Metni\'ni onaylamalısınız.'**
  String get kvkkOnaylamalisiniz;

  /// No description provided for @girisBasarisiz.
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız: {neden}'**
  String girisBasarisiz(String neden);

  /// No description provided for @basvuruGonderilemedi.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru gönderilemedi: {neden}'**
  String basvuruGonderilemedi(String neden);

  /// No description provided for @kayitBasarisiz.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarısız: {neden}'**
  String kayitBasarisiz(String neden);

  /// No description provided for @sifreSifirlamaGonderildi.
  ///
  /// In tr, this message translates to:
  /// **'Şifre sıfırlama bağlantısı {eposta} adresine gönderildi.'**
  String sifreSifirlamaGonderildi(String eposta);

  /// No description provided for @hosGeldiniz.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz'**
  String get hosGeldiniz;

  /// No description provided for @randevunuzSiziBekliyor.
  ///
  /// In tr, this message translates to:
  /// **'Randevunuz sizi bekliyor'**
  String get randevunuzSiziBekliyor;

  /// No description provided for @sifremiUnuttum.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get sifremiUnuttum;

  /// No description provided for @girisYap.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get girisYap;

  /// No description provided for @hesabinizYokMu.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu?'**
  String get hesabinizYokMu;

  /// No description provided for @kayitOlun.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Olun'**
  String get kayitOlun;

  /// No description provided for @isletmeBasvurusu.
  ///
  /// In tr, this message translates to:
  /// **'İşletme Başvurusu'**
  String get isletmeBasvurusu;

  /// No description provided for @salonunuzuKaydedin.
  ///
  /// In tr, this message translates to:
  /// **'Salonunuzu kaydedin, onaylandığında paneliniz açılır'**
  String get salonunuzuKaydedin;

  /// No description provided for @isletmeSalonAdi.
  ///
  /// In tr, this message translates to:
  /// **'İşletme / Salon Adı'**
  String get isletmeSalonAdi;

  /// No description provided for @ad.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get ad;

  /// No description provided for @soyad.
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get soyad;

  /// No description provided for @kvkkOkudumKabul.
  ///
  /// In tr, this message translates to:
  /// **'KVKK Aydınlatma Metni\'ni okudum, kabul ediyorum. (Zorunlu)'**
  String get kvkkOkudumKabul;

  /// No description provided for @basvuruyuGonder.
  ///
  /// In tr, this message translates to:
  /// **'Başvuruyu Gönder'**
  String get basvuruyuGonder;

  /// No description provided for @isletmeHesabinizVarMi.
  ///
  /// In tr, this message translates to:
  /// **'İşletme hesabınız var mı?'**
  String get isletmeHesabinizVarMi;

  /// No description provided for @girisYapin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yapın'**
  String get girisYapin;

  /// No description provided for @hesapOlustur.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get hesapOlustur;

  /// No description provided for @birkacAdimdaRandevu.
  ///
  /// In tr, this message translates to:
  /// **'Birkaç adımda randevu almaya başlayın'**
  String get birkacAdimdaRandevu;

  /// No description provided for @kvkkMusteriOnay.
  ///
  /// In tr, this message translates to:
  /// **'KVKK Aydınlatma Metni\'ni okudum; kişisel verilerimin randevu hizmeti için işlenmesini kabul ediyorum. (Zorunlu)'**
  String get kvkkMusteriOnay;

  /// No description provided for @ticariIletiOnay.
  ///
  /// In tr, this message translates to:
  /// **'Kampanya ve fırsatlardan haberdar olmak için ticari elektronik ileti almak istiyorum. (İsteğe bağlı)'**
  String get ticariIletiOnay;

  /// No description provided for @kayitOl.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get kayitOl;

  /// No description provided for @rolunuzuSecin.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için rolünüzü seçin'**
  String get rolunuzuSecin;

  /// No description provided for @musteri.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri'**
  String get musteri;

  /// No description provided for @musteriRolAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Randevu al, berber bul\nve hizmetlerden yararlan'**
  String get musteriRolAciklama;

  /// No description provided for @isletmeSahibi.
  ///
  /// In tr, this message translates to:
  /// **'İşletme Sahibi'**
  String get isletmeSahibi;

  /// No description provided for @isletmeRolAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Salonunuzu kaydedin\nve müşterilerinizi yönetin'**
  String get isletmeRolAciklama;

  /// No description provided for @zatenHesabinizVarMi.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabınız var mı?'**
  String get zatenHesabinizVarMi;

  /// No description provided for @guvensizYapilandirma.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama güvenli sunucuya bağlanacak şekilde yapılandırılmamış. Lütfen uygulamayı güncelleyin.'**
  String get guvensizYapilandirma;

  /// No description provided for @premiumBerberHizmetleri.
  ///
  /// In tr, this message translates to:
  /// **'Premium Berber Hizmetleri'**
  String get premiumBerberHizmetleri;

  /// No description provided for @geri.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get geri;

  /// No description provided for @logoEtiketi.
  ///
  /// In tr, this message translates to:
  /// **'Premium Berber logosu'**
  String get logoEtiketi;

  /// No description provided for @sifre.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get sifre;

  /// No description provided for @sifreyiGoster.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi göster'**
  String get sifreyiGoster;

  /// No description provided for @sifreyiGizle.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi gizle'**
  String get sifreyiGizle;

  /// No description provided for @enAz6Karakter.
  ///
  /// In tr, this message translates to:
  /// **'En az 6 karakter'**
  String get enAz6Karakter;

  /// No description provided for @metniOku.
  ///
  /// In tr, this message translates to:
  /// **'Metni oku'**
  String get metniOku;

  /// No description provided for @sifreSifirlamaAciklama.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresinizi girin, şifre sıfırlama bağlantısını gönderelim.'**
  String get sifreSifirlamaAciklama;

  /// No description provided for @iptal.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get iptal;

  /// No description provided for @gonder.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get gonder;

  /// No description provided for @yardimDestek.
  ///
  /// In tr, this message translates to:
  /// **'Yardım & Destek'**
  String get yardimDestek;

  /// No description provided for @sss.
  ///
  /// In tr, this message translates to:
  /// **'SSS'**
  String get sss;

  /// No description provided for @bizeUlasin.
  ///
  /// In tr, this message translates to:
  /// **'Bize Ulaşın'**
  String get bizeUlasin;

  /// No description provided for @tarayicidaAc.
  ///
  /// In tr, this message translates to:
  /// **'Tarayıcıda aç'**
  String get tarayicidaAc;

  /// No description provided for @yasalMetinTurkce.
  ///
  /// In tr, this message translates to:
  /// **''**
  String get yasalMetinTurkce;

  /// No description provided for @konuRandevu.
  ///
  /// In tr, this message translates to:
  /// **'Randevu Sorunu'**
  String get konuRandevu;

  /// No description provided for @konuOdeme.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme / Fiyat'**
  String get konuOdeme;

  /// No description provided for @konuHesap.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Problemi'**
  String get konuHesap;

  /// No description provided for @konuHata.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Hatası'**
  String get konuHata;

  /// No description provided for @konuOneri.
  ///
  /// In tr, this message translates to:
  /// **'Öneri / İstek'**
  String get konuOneri;

  /// No description provided for @konuDiger.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get konuDiger;

  /// No description provided for @fotografCek.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Çek'**
  String get fotografCek;

  /// No description provided for @galeridenSec.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden Seç'**
  String get galeridenSec;

  /// No description provided for @dosyaSec.
  ///
  /// In tr, this message translates to:
  /// **'Dosya Seç'**
  String get dosyaSec;

  /// No description provided for @konuSecin.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir konu seçin.'**
  String get konuSecin;

  /// No description provided for @mesajYazin.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen mesajınızı yazın.'**
  String get mesajYazin;

  /// No description provided for @sorununuzuBildirin.
  ///
  /// In tr, this message translates to:
  /// **'Sorununuzu bize bildirin, en kısa sürede dönüş yapalım.'**
  String get sorununuzuBildirin;

  /// No description provided for @konu.
  ///
  /// In tr, this message translates to:
  /// **'Konu'**
  String get konu;

  /// No description provided for @mesajiniz.
  ///
  /// In tr, this message translates to:
  /// **'Mesajınız'**
  String get mesajiniz;

  /// No description provided for @mesajIpucu.
  ///
  /// In tr, this message translates to:
  /// **'Sorununuzu veya isteğinizi açıklayın…'**
  String get mesajIpucu;

  /// No description provided for @ekEkle.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf veya dosya ekle'**
  String get ekEkle;

  /// No description provided for @ekiKaldir.
  ///
  /// In tr, this message translates to:
  /// **'Eki kaldır'**
  String get ekiKaldir;

  /// No description provided for @epostaGonder.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Gönder'**
  String get epostaGonder;

  /// No description provided for @eklerleGonder.
  ///
  /// In tr, this message translates to:
  /// **'Eklerle Gönder'**
  String get eklerleGonder;

  /// No description provided for @epostaAcilamadi.
  ///
  /// In tr, this message translates to:
  /// **'E-posta uygulaması açılamadı. Bize {eposta} adresinden ulaşabilirsiniz.'**
  String epostaAcilamadi(String eposta);

  /// No description provided for @alici.
  ///
  /// In tr, this message translates to:
  /// **'Alıcı: {eposta}'**
  String alici(String eposta);

  /// No description provided for @yeni.
  ///
  /// In tr, this message translates to:
  /// **'Yeni'**
  String get yeni;

  /// No description provided for @sehirSecin.
  ///
  /// In tr, this message translates to:
  /// **'Şehir Seçin'**
  String get sehirSecin;

  /// No description provided for @ilceSecin.
  ///
  /// In tr, this message translates to:
  /// **'İlçe Seçin'**
  String get ilceSecin;

  /// No description provided for @filtreleriTemizle.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri temizle'**
  String get filtreleriTemizle;

  /// No description provided for @salonBulunamadi.
  ///
  /// In tr, this message translates to:
  /// **'Salon bulunamadı'**
  String get salonBulunamadi;

  /// No description provided for @farkliKelimeDeneyin.
  ///
  /// In tr, this message translates to:
  /// **'Farklı bir kelime deneyin veya filtreleri temizleyin.'**
  String get farkliKelimeDeneyin;

  /// No description provided for @kesfet.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get kesfet;

  /// No description provided for @aramaSonucYok.
  ///
  /// In tr, this message translates to:
  /// **'\"{aranan}\" için sonuç yok'**
  String aramaSonucYok(String aranan);

  /// No description provided for @konumServisiKapali.
  ///
  /// In tr, this message translates to:
  /// **'Konum servisi kapalı. Lütfen cihaz ayarlarından açın.'**
  String get konumServisiKapali;

  /// No description provided for @konumIzniKaliciRed.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni kalıcı olarak reddedilmiş. Ayarlardan izin verebilirsiniz.'**
  String get konumIzniKaliciRed;

  /// No description provided for @konumIzniGerekli.
  ///
  /// In tr, this message translates to:
  /// **'Yakındaki salonları göstermek için konum izni gerekiyor.'**
  String get konumIzniGerekli;

  /// No description provided for @konumAlinamadi.
  ///
  /// In tr, this message translates to:
  /// **'Konum alınamadı. Lütfen tekrar deneyin.'**
  String get konumAlinamadi;

  /// No description provided for @salon.
  ///
  /// In tr, this message translates to:
  /// **'Salon'**
  String get salon;

  /// No description provided for @randevuAl.
  ///
  /// In tr, this message translates to:
  /// **'Randevu Al'**
  String get randevuAl;

  /// No description provided for @kampanyalar.
  ///
  /// In tr, this message translates to:
  /// **'Kampanyalar'**
  String get kampanyalar;

  /// No description provided for @sadakatKartiBaslik.
  ///
  /// In tr, this message translates to:
  /// **'Sadakat Kartı'**
  String get sadakatKartiBaslik;

  /// No description provided for @ekibimiz.
  ///
  /// In tr, this message translates to:
  /// **'Ekibimiz'**
  String get ekibimiz;

  /// No description provided for @degerlendirmeler.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirmeler'**
  String get degerlendirmeler;

  /// No description provided for @bugunkuDurum.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü Durum'**
  String get bugunkuDurum;

  /// No description provided for @calismaSaatleri.
  ///
  /// In tr, this message translates to:
  /// **'Çalışma Saatleri'**
  String get calismaSaatleri;

  /// No description provided for @favorilereEklendi.
  ///
  /// In tr, this message translates to:
  /// **'{ad} favorilere eklendi.'**
  String favorilereEklendi(String ad);

  /// No description provided for @favorilerdenCikarildi.
  ///
  /// In tr, this message translates to:
  /// **'{ad} favorilerden çıkarıldı.'**
  String favorilerdenCikarildi(String ad);

  /// No description provided for @henuzDegerlendirmeYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz değerlendirme yok.'**
  String get henuzDegerlendirmeYok;

  /// No description provided for @favorilerdenCikar.
  ///
  /// In tr, this message translates to:
  /// **'Favorilerden çıkar'**
  String get favorilerdenCikar;

  /// No description provided for @favorilereEkle.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere ekle'**
  String get favorilereEkle;

  /// No description provided for @randevu.
  ///
  /// In tr, this message translates to:
  /// **'Randevu'**
  String get randevu;

  /// No description provided for @trasSayisi.
  ///
  /// In tr, this message translates to:
  /// **'{n} tıraş'**
  String trasSayisi(int n);

  /// No description provided for @uygulamaAcilamadi.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama açılamadı.'**
  String get uygulamaAcilamadi;

  /// No description provided for @harita.
  ///
  /// In tr, this message translates to:
  /// **'Harita'**
  String get harita;

  /// No description provided for @yolTarifi.
  ///
  /// In tr, this message translates to:
  /// **'Yol Tarifi'**
  String get yolTarifi;

  /// No description provided for @indirimOnaydaYansir.
  ///
  /// In tr, this message translates to:
  /// **'İndirim, uygun gün ve saati seçtiğinizde onay ekranında tutara yansır.'**
  String get indirimOnaydaYansir;

  /// No description provided for @sadakatGirisYap.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yaptığınızda ziyaretleriniz burada sayılır.'**
  String get sadakatGirisYap;

  /// No description provided for @yuzde.
  ///
  /// In tr, this message translates to:
  /// **'%{y}'**
  String yuzde(int y);

  /// No description provided for @sadakatKurali.
  ///
  /// In tr, this message translates to:
  /// **'Her {esik}. ziyaretiniz %{yuzde} indirimli'**
  String sadakatKurali(int esik, int yuzde);

  /// No description provided for @sadakatDamga.
  ///
  /// In tr, this message translates to:
  /// **'{esik} ziyaretten {n} tanesi tamam'**
  String sadakatDamga(int esik, int n);

  /// No description provided for @sadakatSiradaki.
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki randevunuz %{yuzde} indirimli! 🎉'**
  String sadakatSiradaki(int yuzde);

  /// No description provided for @sadakatKalan.
  ///
  /// In tr, this message translates to:
  /// **'{n} ziyaret sonra indirim kazanırsınız.'**
  String sadakatKalan(int n);

  /// No description provided for @yakindanUzaga.
  ///
  /// In tr, this message translates to:
  /// **'Yakından uzağa sıralanıyor'**
  String get yakindanUzaga;

  /// No description provided for @konumumaYakin.
  ///
  /// In tr, this message translates to:
  /// **'Konumuma Yakın Salonlar'**
  String get konumumaYakin;

  /// No description provided for @salonAramaIpucu.
  ///
  /// In tr, this message translates to:
  /// **'Salon, ilçe veya hizmet ara (ör. sakal)'**
  String get salonAramaIpucu;

  /// No description provided for @aramayiTemizle.
  ///
  /// In tr, this message translates to:
  /// **'Aramayı temizle'**
  String get aramayiTemizle;

  /// No description provided for @yuksekPuanIpucu.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca 4.5 ve üzeri puanlı salonlar'**
  String get yuksekPuanIpucu;

  /// No description provided for @bugunkuRandevu.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü\nRandevu'**
  String get bugunkuRandevu;

  /// No description provided for @bosKontenjan.
  ///
  /// In tr, this message translates to:
  /// **'Boş\nKontenjan'**
  String get bosKontenjan;

  /// No description provided for @doluluk.
  ///
  /// In tr, this message translates to:
  /// **'Doluluk'**
  String get doluluk;

  /// No description provided for @salonBugunKapali.
  ///
  /// In tr, this message translates to:
  /// **'Salon bugün kapalı veya günün saatleri doldu.'**
  String get salonBugunKapali;

  /// No description provided for @kapali.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get kapali;

  /// No description provided for @bugunKapali.
  ///
  /// In tr, this message translates to:
  /// **'Bugün kapalı'**
  String get bugunKapali;

  /// No description provided for @sadakatKarti.
  ///
  /// In tr, this message translates to:
  /// **'Sadakat kartı'**
  String get sadakatKarti;

  /// No description provided for @salonSemantik.
  ///
  /// In tr, this message translates to:
  /// **'{ad}, {konum}, puan {puan}'**
  String salonSemantik(String ad, String konum, String puan);

  /// No description provided for @bugunSaat.
  ///
  /// In tr, this message translates to:
  /// **'Bugün {saat}'**
  String bugunSaat(String saat);

  /// No description provided for @varanIndirim.
  ///
  /// In tr, this message translates to:
  /// **'%{yuzde}{ek} varan indirim'**
  String varanIndirim(int yuzde, String ek);

  /// No description provided for @anonim.
  ///
  /// In tr, this message translates to:
  /// **'Anonim'**
  String get anonim;

  /// No description provided for @degerlendirmeSayisi.
  ///
  /// In tr, this message translates to:
  /// **'{n} değerlendirme'**
  String degerlendirmeSayisi(int n);

  /// No description provided for @yildizSemantik.
  ///
  /// In tr, this message translates to:
  /// **'5 üzerinden {n} yıldız'**
  String yildizSemantik(int n);

  /// No description provided for @degerlendirmelerYuklenemedi.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirmeler yüklenemedi.'**
  String get degerlendirmelerYuklenemedi;

  /// No description provided for @tekrar.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar'**
  String get tekrar;

  /// No description provided for @ilkYorumuSizYapin.
  ///
  /// In tr, this message translates to:
  /// **'Henüz değerlendirme yok. Randevunuzdan sonra ilk yorumu siz yapabilirsiniz.'**
  String get ilkYorumuSizYapin;

  /// No description provided for @tumunuGor.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü gör ({n})'**
  String tumunuGor(int n);

  /// No description provided for @tarih.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get tarih;

  /// No description provided for @saat.
  ///
  /// In tr, this message translates to:
  /// **'Saat'**
  String get saat;

  /// No description provided for @personel.
  ///
  /// In tr, this message translates to:
  /// **'Personel'**
  String get personel;

  /// No description provided for @hizmetler.
  ///
  /// In tr, this message translates to:
  /// **'Hizmetler'**
  String get hizmetler;

  /// No description provided for @takvimAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Berber: {berber}\nToplam: {toplam}'**
  String takvimAciklama(String berber, String toplam);

  /// No description provided for @randevunuzOnaylandi.
  ///
  /// In tr, this message translates to:
  /// **'Randevunuz Onaylandı!'**
  String get randevunuzOnaylandi;

  /// No description provided for @siziBekliyoruz.
  ///
  /// In tr, this message translates to:
  /// **'Sizi bekliyoruz 💈'**
  String get siziBekliyoruz;

  /// No description provided for @birSaatOnceHatirlatma.
  ///
  /// In tr, this message translates to:
  /// **'Randevudan 1 saat önce hatırlatma bildirimi alacaksınız.'**
  String get birSaatOnceHatirlatma;

  /// No description provided for @anaSayfayaDon.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfaya Dön'**
  String get anaSayfayaDon;

  /// No description provided for @randevularimiGor.
  ///
  /// In tr, this message translates to:
  /// **'Randevularımı Gör'**
  String get randevularimiGor;

  /// No description provided for @hizmetSecin.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet Seçin'**
  String get hizmetSecin;

  /// No description provided for @personelSecin.
  ///
  /// In tr, this message translates to:
  /// **'Personel Seçin'**
  String get personelSecin;

  /// No description provided for @tarihSecin.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Seçin'**
  String get tarihSecin;

  /// No description provided for @saatSecin.
  ///
  /// In tr, this message translates to:
  /// **'Saat Seçin'**
  String get saatSecin;

  /// No description provided for @bilgileriniz.
  ///
  /// In tr, this message translates to:
  /// **'Bilgileriniz'**
  String get bilgileriniz;

  /// No description provided for @enAzBirHizmet.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen en az bir hizmet seçin'**
  String get enAzBirHizmet;

  /// No description provided for @lutfenTarih.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir tarih seçin'**
  String get lutfenTarih;

  /// No description provided for @lutfenSaat.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir saat seçin'**
  String get lutfenSaat;

  /// No description provided for @lutfenPersonel.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir personel seçin'**
  String get lutfenPersonel;

  /// No description provided for @ileri.
  ///
  /// In tr, this message translates to:
  /// **'İleri →'**
  String get ileri;

  /// No description provided for @adim.
  ///
  /// In tr, this message translates to:
  /// **'Adım {n} / {toplam}'**
  String adim(int n, int toplam);

  /// No description provided for @menuYok.
  ///
  /// In tr, this message translates to:
  /// **'Bu salon henüz hizmet menüsünü eklemedi.'**
  String get menuYok;

  /// No description provided for @fiyatPersoneleGore.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat ve süre personele göre değişir'**
  String get fiyatPersoneleGore;

  /// No description provided for @kesinSurePersonelle.
  ///
  /// In tr, this message translates to:
  /// **'Kesin süre personel seçince'**
  String get kesinSurePersonelle;

  /// No description provided for @sureAraligi.
  ///
  /// In tr, this message translates to:
  /// **'{min}–{max} dk'**
  String sureAraligi(int min, int max);

  /// No description provided for @hizmetSecildi.
  ///
  /// In tr, this message translates to:
  /// **'{n} hizmet seçildi'**
  String hizmetSecildi(int n);

  /// No description provided for @personelYok.
  ///
  /// In tr, this message translates to:
  /// **'Bu salonda henüz personel bulunmuyor.'**
  String get personelYok;

  /// No description provided for @vermiyor.
  ///
  /// In tr, this message translates to:
  /// **'Vermiyor: {hizmetler}'**
  String vermiyor(String hizmetler);

  /// No description provided for @ay.
  ///
  /// In tr, this message translates to:
  /// **'Ay'**
  String get ay;

  /// No description provided for @kapaliGunlerOtomatik.
  ///
  /// In tr, this message translates to:
  /// **'Salonun kapalı olduğu günler ve personel izinleri otomatik olarak kapalıdır.'**
  String get kapaliGunlerOtomatik;

  /// No description provided for @gunKampanyasi.
  ///
  /// In tr, this message translates to:
  /// **'Bu günde %{yuzde}{ek} varan kampanya var; indirimli saatler sonraki adımda işaretli.'**
  String gunKampanyasi(int yuzde, String ek);

  /// No description provided for @musait.
  ///
  /// In tr, this message translates to:
  /// **'Müsait'**
  String get musait;

  /// No description provided for @dolu.
  ///
  /// In tr, this message translates to:
  /// **'Dolu'**
  String get dolu;

  /// No description provided for @yerAcilirsaBildirim.
  ///
  /// In tr, this message translates to:
  /// **'Bu günde yer açılırsa size hemen bildirim göndereceğiz.'**
  String get yerAcilirsaBildirim;

  /// No description provided for @onceTarihSecin.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen önce bir tarih seçin.'**
  String get onceTarihSecin;

  /// No description provided for @bosSaatKalmadi.
  ///
  /// In tr, this message translates to:
  /// **'Bu gün seçtiğiniz hizmetler için boş saat kalmadı.'**
  String get bosSaatKalmadi;

  /// No description provided for @beklemeListesindesiniz.
  ///
  /// In tr, this message translates to:
  /// **'Bekleme listesindesiniz'**
  String get beklemeListesindesiniz;

  /// No description provided for @yerAcilirsaHaberVer.
  ///
  /// In tr, this message translates to:
  /// **'Yer açılırsa haber ver'**
  String get yerAcilirsaHaberVer;

  /// No description provided for @enYakinBosSaatler.
  ///
  /// In tr, this message translates to:
  /// **'En yakın boş saatler'**
  String get enYakinBosSaatler;

  /// No description provided for @toplamSureAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Toplam süre: {sure} — yalnızca hizmetin tamamının sığdığı saatler açıktır.'**
  String toplamSureAciklama(String sure);

  /// No description provided for @enAzOnceden.
  ///
  /// In tr, this message translates to:
  /// **'Bu salon en az {sure} önceden randevu alıyor.'**
  String enAzOnceden(String sure);

  /// No description provided for @gunSayisi.
  ///
  /// In tr, this message translates to:
  /// **'{n} gün'**
  String gunSayisi(int n);

  /// No description provided for @tumAdimlariTamamlayin.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tüm adımları tamamlayın.'**
  String get tumAdimlariTamamlayin;

  /// No description provided for @sure.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get sure;

  /// No description provided for @iletisimBilgileriniz.
  ///
  /// In tr, this message translates to:
  /// **'İletişim Bilgileriniz'**
  String get iletisimBilgileriniz;

  /// No description provided for @randevumuOnayla.
  ///
  /// In tr, this message translates to:
  /// **'Randevumu Onayla'**
  String get randevumuOnayla;

  /// No description provided for @uygunSaatler.
  ///
  /// In tr, this message translates to:
  /// **'Uygun saatler: {saatler}'**
  String uygunSaatler(String saatler);

  /// No description provided for @bildirimlerKapali.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler kapalı'**
  String get bildirimlerKapali;

  /// No description provided for @hatirlatalimMi.
  ///
  /// In tr, this message translates to:
  /// **'Randevunuza 1 saat kala hatırlatalım mı?'**
  String get hatirlatalimMi;

  /// No description provided for @bildirimKapaliAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma ve \"yer açıldı\" haberlerini alamazsınız. Açmak için: Telefon Ayarları › Uygulamalar › Premium Berber › Bildirimler.'**
  String get bildirimKapaliAciklama;

  /// No description provided for @bildirimIzniAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma, salonun değişiklikleri ve bekleme listesinde yer açılınca haber vereceğiz. Reklam göndermeyiz.'**
  String get bildirimIzniAciklama;

  /// No description provided for @tamam.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get tamam;

  /// No description provided for @simdiDegil.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi değil'**
  String get simdiDegil;

  /// No description provided for @evetHatirlat.
  ///
  /// In tr, this message translates to:
  /// **'Evet, hatırlat'**
  String get evetHatirlat;

  /// No description provided for @listeFiyati.
  ///
  /// In tr, this message translates to:
  /// **'Liste fiyatı'**
  String get listeFiyati;

  /// No description provided for @indirim.
  ///
  /// In tr, this message translates to:
  /// **'İndirim'**
  String get indirim;

  /// No description provided for @toplam.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get toplam;

  /// No description provided for @yuzdeIndirim.
  ///
  /// In tr, this message translates to:
  /// **'%{y} indirim'**
  String yuzdeIndirim(int y);

  /// No description provided for @gunDoluAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Bu gün dolu. Sonraki adımda \"yer açılırsa haber ver\" diyebilir veya en yakın boş saati seçebilirsiniz.'**
  String get gunDoluAciklama;

  /// No description provided for @azYer.
  ///
  /// In tr, this message translates to:
  /// **'Az yer'**
  String get azYer;

  /// No description provided for @kampanyali.
  ///
  /// In tr, this message translates to:
  /// **'Kampanyalı'**
  String get kampanyali;

  /// No description provided for @azYerKaldi.
  ///
  /// In tr, this message translates to:
  /// **'Bu günde yalnızca {n} uygun saat kaldı.'**
  String azYerKaldi(int n);

  /// No description provided for @randevularim.
  ///
  /// In tr, this message translates to:
  /// **'Randevularım'**
  String get randevularim;

  /// No description provided for @iptalEt.
  ///
  /// In tr, this message translates to:
  /// **'İptal Et'**
  String get iptalEt;

  /// No description provided for @ertele.
  ///
  /// In tr, this message translates to:
  /// **'Ertele'**
  String get ertele;

  /// No description provided for @randevuIptali.
  ///
  /// In tr, this message translates to:
  /// **'Randevu İptali'**
  String get randevuIptali;

  /// No description provided for @cikisYap.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get cikisYap;

  /// No description provided for @anaSayfa.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get anaSayfa;

  /// No description provided for @profil.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profil;

  /// No description provided for @yaklasanRandevulariniz.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan Randevularınız'**
  String get yaklasanRandevulariniz;

  /// No description provided for @favoriBerberlerim.
  ///
  /// In tr, this message translates to:
  /// **'Favori Berberlerim'**
  String get favoriBerberlerim;

  /// No description provided for @tumu.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get tumu;

  /// No description provided for @hosGeldinizMakas.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz ✂️'**
  String get hosGeldinizMakas;

  /// No description provided for @kendinizeRandevu.
  ///
  /// In tr, this message translates to:
  /// **'Bugün kendinize güzel bir randevu alın'**
  String get kendinizeRandevu;

  /// No description provided for @sihhatlerOlsun.
  ///
  /// In tr, this message translates to:
  /// **'Sıhhatler olsun, {ad}!'**
  String sihhatlerOlsun(String ad);

  /// No description provided for @favoriYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz favori berberiniz yok'**
  String get favoriYok;

  /// No description provided for @favoriNasil.
  ///
  /// In tr, this message translates to:
  /// **'Salon sayfasındaki ♥ ile ekleyebilirsiniz'**
  String get favoriNasil;

  /// No description provided for @herZamankiRandevu.
  ///
  /// In tr, this message translates to:
  /// **'Her zamanki randevu'**
  String get herZamankiRandevu;

  /// No description provided for @randevuyuAl.
  ///
  /// In tr, this message translates to:
  /// **'Randevuyu Al'**
  String get randevuyuAl;

  /// No description provided for @herZamanki.
  ///
  /// In tr, this message translates to:
  /// **'Her Zamanki'**
  String get herZamanki;

  /// No description provided for @yakinBosSaatYok.
  ///
  /// In tr, this message translates to:
  /// **'Yakın tarihte boş saat yok.'**
  String get yakinBosSaatYok;

  /// No description provided for @enYakinDokun.
  ///
  /// In tr, this message translates to:
  /// **'En yakın boş saatler — dokun, onayla, bitti:'**
  String get enYakinDokun;

  /// No description provided for @kacKez.
  ///
  /// In tr, this message translates to:
  /// **'{n} kez aldınız'**
  String kacKez(int n);

  /// No description provided for @nasilDevam.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl devam etmek istersiniz?'**
  String get nasilDevam;

  /// No description provided for @yeniSalonKesfet.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Bir Salon Keşfet'**
  String get yeniSalonKesfet;

  /// No description provided for @farkliSalonlar.
  ///
  /// In tr, this message translates to:
  /// **'Farklı salonları keşfet'**
  String get farkliSalonlar;

  /// No description provided for @kapat.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get kapat;

  /// No description provided for @randevunuzuNasilBuldunuz.
  ///
  /// In tr, this message translates to:
  /// **'Randevunuzu nasıl buldunuz?'**
  String get randevunuzuNasilBuldunuz;

  /// No description provided for @yorumunuz.
  ///
  /// In tr, this message translates to:
  /// **'Yorumunuz (isteğe bağlı)'**
  String get yorumunuz;

  /// No description provided for @degerlendir.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendir'**
  String get degerlendir;

  /// No description provided for @tesekkurler.
  ///
  /// In tr, this message translates to:
  /// **'Teşekkürler! ⭐'**
  String get tesekkurler;

  /// No description provided for @degerlendirmeKaydedildi.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirmeniz kaydedildi.'**
  String get degerlendirmeKaydedildi;

  /// No description provided for @puanKotu.
  ///
  /// In tr, this message translates to:
  /// **'Kötü'**
  String get puanKotu;

  /// No description provided for @puanFenaDegil.
  ///
  /// In tr, this message translates to:
  /// **'Fena değil'**
  String get puanFenaDegil;

  /// No description provided for @puanIyi.
  ///
  /// In tr, this message translates to:
  /// **'İyi'**
  String get puanIyi;

  /// No description provided for @puanCokIyi.
  ///
  /// In tr, this message translates to:
  /// **'Çok iyi'**
  String get puanCokIyi;

  /// No description provided for @puanMukemmel.
  ///
  /// In tr, this message translates to:
  /// **'Mükemmel!'**
  String get puanMukemmel;

  /// No description provided for @yildizSayisi.
  ///
  /// In tr, this message translates to:
  /// **'{n} yıldız'**
  String yildizSayisi(int n);

  /// No description provided for @berberlerim.
  ///
  /// In tr, this message translates to:
  /// **'Berberlerim'**
  String get berberlerim;

  /// No description provided for @berberGecmisiYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz favori veya geçmiş berberiniz yok'**
  String get berberGecmisiYok;

  /// No description provided for @favoriEkleIpucu.
  ///
  /// In tr, this message translates to:
  /// **'Salon sayfasında ♥ ile favori ekleyebilirsiniz'**
  String get favoriEkleIpucu;

  /// No description provided for @favorileriniz.
  ///
  /// In tr, this message translates to:
  /// **'Favorileriniz'**
  String get favorileriniz;

  /// No description provided for @dahaOnceGittikleriniz.
  ///
  /// In tr, this message translates to:
  /// **'Daha önce gittikleriniz'**
  String get dahaOnceGittikleriniz;

  /// No description provided for @cikisEminMisiniz.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızdan çıkış yapmak istediğinize emin misiniz?'**
  String get cikisEminMisiniz;

  /// No description provided for @hesabiSil.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get hesabiSil;

  /// No description provided for @hesapSilAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel bilgileriniz silinecek ve gelecekteki randevularınız iptal edilecek. Bu işlem geri alınamaz.'**
  String get hesapSilAciklama;

  /// No description provided for @kaliciSil.
  ///
  /// In tr, this message translates to:
  /// **'Kalıcı Olarak Sil'**
  String get kaliciSil;

  /// No description provided for @hesapSilindi.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız ve kişisel verileriniz silindi.'**
  String get hesapSilindi;

  /// No description provided for @verilerSilindiOturum.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel verileriniz silindi. Güvenlik nedeniyle oturumunuz kapatıldı.'**
  String get verilerSilindiOturum;

  /// No description provided for @yasalGizlilik.
  ///
  /// In tr, this message translates to:
  /// **'Yasal & Gizlilik'**
  String get yasalGizlilik;

  /// No description provided for @gizlilikPolitikasi.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get gizlilikPolitikasi;

  /// No description provided for @kvkkMetni.
  ///
  /// In tr, this message translates to:
  /// **'KVKK Aydınlatma Metni'**
  String get kvkkMetni;

  /// No description provided for @kullanimKosullari.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get kullanimKosullari;

  /// No description provided for @sikcaSorulanSorular.
  ///
  /// In tr, this message translates to:
  /// **'Sıkça Sorulan Sorular'**
  String get sikcaSorulanSorular;

  /// No description provided for @hesap.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get hesap;

  /// No description provided for @uygulamayiPaylas.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı Paylaş'**
  String get uygulamayiPaylas;

  /// No description provided for @hesabimiSil.
  ///
  /// In tr, this message translates to:
  /// **'Hesabımı Sil'**
  String get hesabimiSil;

  /// No description provided for @hesapSilinemedi.
  ///
  /// In tr, this message translates to:
  /// **'Hesap silinemedi: {neden}'**
  String hesapSilinemedi(String neden);

  /// No description provided for @paylasMetni.
  ///
  /// In tr, this message translates to:
  /// **'Premium Berber ile saniyeler içinde berber randevusu al 💈'**
  String get paylasMetni;

  /// No description provided for @dil.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get dil;

  /// No description provided for @cihazDili.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz dili'**
  String get cihazDili;

  /// No description provided for @bilgilerKaydedildi.
  ///
  /// In tr, this message translates to:
  /// **'Bilgileriniz kaydedildi.'**
  String get bilgilerKaydedildi;

  /// No description provided for @kisiselBilgiler.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Bilgiler'**
  String get kisiselBilgiler;

  /// No description provided for @kaydet.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get kaydet;

  /// No description provided for @duzenle.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get duzenle;

  /// No description provided for @adiniz.
  ///
  /// In tr, this message translates to:
  /// **'Adınız'**
  String get adiniz;

  /// No description provided for @soyadiniz.
  ///
  /// In tr, this message translates to:
  /// **'Soyadınız'**
  String get soyadiniz;

  /// No description provided for @telefon.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get telefon;

  /// No description provided for @randevuyuErtele.
  ///
  /// In tr, this message translates to:
  /// **'Randevuyu Ertele'**
  String get randevuyuErtele;

  /// No description provided for @acikGunYok.
  ///
  /// In tr, this message translates to:
  /// **'Önümüzdeki günlerde açık gün yok.'**
  String get acikGunYok;

  /// No description provided for @yeniSaatSecin.
  ///
  /// In tr, this message translates to:
  /// **'Yeni saat seçin'**
  String get yeniSaatSecin;

  /// No description provided for @buGunBosSaatYok.
  ///
  /// In tr, this message translates to:
  /// **'Bu gün boş saat yok.'**
  String get buGunBosSaatYok;

  /// No description provided for @baskaGunSecin.
  ///
  /// In tr, this message translates to:
  /// **'Başka bir gün seçin.'**
  String get baskaGunSecin;

  /// No description provided for @oneri.
  ///
  /// In tr, this message translates to:
  /// **'Öneri: {saatler}'**
  String oneri(String saatler);

  /// No description provided for @suAn.
  ///
  /// In tr, this message translates to:
  /// **'Şu an: {bilgi}'**
  String suAn(String bilgi);

  /// No description provided for @kalanErteleme.
  ///
  /// In tr, this message translates to:
  /// **'Kalan erteleme hakkı: {n}'**
  String kalanErteleme(int n);

  /// No description provided for @kampanya.
  ///
  /// In tr, this message translates to:
  /// **'kampanya'**
  String get kampanya;

  /// No description provided for @indirimKalkar.
  ///
  /// In tr, this message translates to:
  /// **'Bu saat \"{kampanya}\" kapsamında değil: indirim kalkar, tutar {tutar} olur. İndirimli saatler işaretli.'**
  String indirimKalkar(String kampanya, String tutar);

  /// No description provided for @olarakErtele.
  ///
  /// In tr, this message translates to:
  /// **'{zaman} olarak ertele'**
  String olarakErtele(String zaman);

  /// No description provided for @randevunuzErtelendi.
  ///
  /// In tr, this message translates to:
  /// **'Randevunuz ertelendi.'**
  String get randevunuzErtelendi;

  /// No description provided for @randevunuzIptalEdildi.
  ///
  /// In tr, this message translates to:
  /// **'Randevunuz iptal edildi.'**
  String get randevunuzIptalEdildi;

  /// No description provided for @yaklasanlar.
  ///
  /// In tr, this message translates to:
  /// **'YAKLAŞANLAR'**
  String get yaklasanlar;

  /// No description provided for @gecmis.
  ///
  /// In tr, this message translates to:
  /// **'GEÇMİŞ'**
  String get gecmis;

  /// No description provided for @aktifRandevuYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz aktif randevunuz yok'**
  String get aktifRandevuYok;

  /// No description provided for @gecmisRandevuYok.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş randevu bulunamadı'**
  String get gecmisRandevuYok;

  /// No description provided for @iptalEminMisiniz.
  ///
  /// In tr, this message translates to:
  /// **'{randevu} randevunuzu iptal etmek istiyor musunuz?'**
  String iptalEminMisiniz(String randevu);

  /// No description provided for @iptalYerineErtele.
  ///
  /// In tr, this message translates to:
  /// **'Gelemiyorsanız iptal yerine başka bir saate erteleyebilirsiniz.'**
  String get iptalYerineErtele;

  /// No description provided for @tekrarRandevuAl.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Randevu Al'**
  String get tekrarRandevuAl;

  /// No description provided for @kacHaftaSonra.
  ///
  /// In tr, this message translates to:
  /// **'Kaç hafta sonra?'**
  String get kacHaftaSonra;

  /// No description provided for @herZamankiAraliginiz.
  ///
  /// In tr, this message translates to:
  /// **'★ her zamanki aralığınız'**
  String get herZamankiAraliginiz;

  /// No description provided for @saatSecinKisa.
  ///
  /// In tr, this message translates to:
  /// **'Saat seçin'**
  String get saatSecinKisa;

  /// No description provided for @bosSaatBulunamadi.
  ///
  /// In tr, this message translates to:
  /// **'Önümüzdeki günlerde boş saat bulunamadı.'**
  String get bosSaatBulunamadi;

  /// No description provided for @haftaSayisi.
  ///
  /// In tr, this message translates to:
  /// **'{n} hafta'**
  String haftaSayisi(int n);

  /// No description provided for @randevusunuAl.
  ///
  /// In tr, this message translates to:
  /// **'{zaman} randevusunu al'**
  String randevusunuAl(String zaman);

  /// No description provided for @herZamankiSaatBos.
  ///
  /// In tr, this message translates to:
  /// **'{gun}, her zamanki saatiniz {saat} boş.'**
  String herZamankiSaatBos(String gun, String saat);

  /// No description provided for @kapaliEnYakin.
  ///
  /// In tr, this message translates to:
  /// **'{gun}: {neden} En yakın boş saatler:'**
  String kapaliEnYakin(String gun, String neden);

  /// No description provided for @saatDoluEnYakin.
  ///
  /// In tr, this message translates to:
  /// **'{gun} {saat} dolu. O günün en yakın saatleri:'**
  String saatDoluEnYakin(String gun, String saat);

  /// No description provided for @tekrarFiyatNotu.
  ///
  /// In tr, this message translates to:
  /// **'Liste fiyatı {bilgi}. Kampanya veya sadakat indirimi varsa onayda uygulanır.'**
  String tekrarFiyatNotu(String bilgi);

  /// No description provided for @durumOnaylandi.
  ///
  /// In tr, this message translates to:
  /// **'✓ Onaylandı'**
  String get durumOnaylandi;

  /// No description provided for @durumTamamlandi.
  ///
  /// In tr, this message translates to:
  /// **'✔ Tamamlandı'**
  String get durumTamamlandi;

  /// No description provided for @durumIptal.
  ///
  /// In tr, this message translates to:
  /// **'✗ İptal'**
  String get durumIptal;

  /// No description provided for @durumGelinmedi.
  ///
  /// In tr, this message translates to:
  /// **'Gelinmedi'**
  String get durumGelinmedi;

  /// No description provided for @salonIptalEtti.
  ///
  /// In tr, this message translates to:
  /// **'Salon tarafından iptal edildi.'**
  String get salonIptalEtti;

  /// No description provided for @hizmetiDegerlendir.
  ///
  /// In tr, this message translates to:
  /// **'Hizmeti Değerlendir'**
  String get hizmetiDegerlendir;

  /// No description provided for @aynisiniTekrarAl.
  ///
  /// In tr, this message translates to:
  /// **'Aynısını Tekrar Al'**
  String get aynisiniTekrarAl;

  /// No description provided for @degerlendirildi.
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirildi ({yildiz})'**
  String degerlendirildi(String yildiz);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
