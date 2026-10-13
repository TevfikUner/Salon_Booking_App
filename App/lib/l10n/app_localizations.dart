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

  /// No description provided for @ekle.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get ekle;

  /// No description provided for @kaldir.
  ///
  /// In tr, this message translates to:
  /// **'Kaldır'**
  String get kaldir;

  /// No description provided for @gelmedi.
  ///
  /// In tr, this message translates to:
  /// **'Gelmedi'**
  String get gelmedi;

  /// No description provided for @tamamlandi.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get tamamlandi;

  /// No description provided for @iptalKisa.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get iptalKisa;

  /// No description provided for @riskli.
  ///
  /// In tr, this message translates to:
  /// **'Riskli'**
  String get riskli;

  /// No description provided for @ogleArasi.
  ///
  /// In tr, this message translates to:
  /// **'Öğle arası'**
  String get ogleArasi;

  /// No description provided for @kadrodanCikar.
  ///
  /// In tr, this message translates to:
  /// **'Kadrodan çıkar'**
  String get kadrodanCikar;

  /// No description provided for @menudenKaldir.
  ///
  /// In tr, this message translates to:
  /// **'Menüden kaldır'**
  String get menudenKaldir;

  /// No description provided for @basvuruOnaylanmadi.
  ///
  /// In tr, this message translates to:
  /// **'Başvurunuz onaylanmadı'**
  String get basvuruOnaylanmadi;

  /// No description provided for @basvuruInceleniyor.
  ///
  /// In tr, this message translates to:
  /// **'Başvurunuz inceleniyor'**
  String get basvuruInceleniyor;

  /// No description provided for @destekleIletisim.
  ///
  /// In tr, this message translates to:
  /// **'Ayrıntılar için destek ekibimizle iletişime geçebilirsiniz.'**
  String get destekleIletisim;

  /// No description provided for @durumuKontrolEt.
  ///
  /// In tr, this message translates to:
  /// **'Durumu Kontrol Et'**
  String get durumuKontrolEt;

  /// No description provided for @basvuruAlindi.
  ///
  /// In tr, this message translates to:
  /// **'{ad} için başvurunuz alındı. Onaylandığında salon paneliniz açılacak; günün randevularını, personelinizi ve hizmetlerinizi buradan yöneteceksiniz.'**
  String basvuruAlindi(String ad);

  /// No description provided for @akis.
  ///
  /// In tr, this message translates to:
  /// **'Akış'**
  String get akis;

  /// No description provided for @ekipMenu.
  ///
  /// In tr, this message translates to:
  /// **'Ekip & Menü'**
  String get ekipMenu;

  /// No description provided for @kapaliGunler.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı Günler'**
  String get kapaliGunler;

  /// No description provided for @rapor.
  ///
  /// In tr, this message translates to:
  /// **'Rapor'**
  String get rapor;

  /// No description provided for @personelPaneli.
  ///
  /// In tr, this message translates to:
  /// **'Personel Paneli'**
  String get personelPaneli;

  /// No description provided for @isletmePaneli.
  ///
  /// In tr, this message translates to:
  /// **'İşletme Paneli'**
  String get isletmePaneli;

  /// No description provided for @randevuyuIptalEt.
  ///
  /// In tr, this message translates to:
  /// **'Randevuyu iptal et'**
  String get randevuyuIptalEt;

  /// No description provided for @randevuGuncellendi.
  ///
  /// In tr, this message translates to:
  /// **'Randevu güncellendi.'**
  String get randevuGuncellendi;

  /// No description provided for @randevuyuTasi.
  ///
  /// In tr, this message translates to:
  /// **'Randevuyu taşı'**
  String get randevuyuTasi;

  /// No description provided for @tasimaAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat ve süre değişmez; müşteriye bildirim gönderilir.'**
  String get tasimaAciklama;

  /// No description provided for @tasi.
  ///
  /// In tr, this message translates to:
  /// **'Taşı'**
  String get tasi;

  /// No description provided for @randevuEkle.
  ///
  /// In tr, this message translates to:
  /// **'Randevu Ekle'**
  String get randevuEkle;

  /// No description provided for @tasimaIpucu.
  ///
  /// In tr, this message translates to:
  /// **'Taşımak için randevuya basılı tutup sürükleyin.'**
  String get tasimaIpucu;

  /// No description provided for @liste.
  ///
  /// In tr, this message translates to:
  /// **'Liste'**
  String get liste;

  /// No description provided for @takvim.
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get takvim;

  /// No description provided for @buGunRandevuYok.
  ///
  /// In tr, this message translates to:
  /// **'Bu gün için randevu yok.'**
  String get buGunRandevuYok;

  /// No description provided for @randevuEkleIpucu.
  ///
  /// In tr, this message translates to:
  /// **'\"Randevu Ekle\" ile telefonla gelen müşteriyi ekleyebilirsiniz.'**
  String get randevuEkleIpucu;

  /// No description provided for @digerPersonel.
  ///
  /// In tr, this message translates to:
  /// **'diğer personel'**
  String get digerPersonel;

  /// No description provided for @saatineTasindi.
  ///
  /// In tr, this message translates to:
  /// **'Randevu {saat} saatine taşındı.'**
  String saatineTasindi(String saat);

  /// No description provided for @notKaydedildi.
  ///
  /// In tr, this message translates to:
  /// **'Not kaydedildi.'**
  String get notKaydedildi;

  /// No description provided for @ziyaret.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret'**
  String get ziyaret;

  /// No description provided for @harcama.
  ///
  /// In tr, this message translates to:
  /// **'Harcama'**
  String get harcama;

  /// No description provided for @sonZiyaret.
  ///
  /// In tr, this message translates to:
  /// **'Son ziyaret'**
  String get sonZiyaret;

  /// No description provided for @isletmeNotu.
  ///
  /// In tr, this message translates to:
  /// **'İşletme notu'**
  String get isletmeNotu;

  /// No description provided for @notIpucu.
  ///
  /// In tr, this message translates to:
  /// **'Ör: Yanlar 1 numara, üstü makas, ense düz.'**
  String get notIpucu;

  /// No description provided for @ozelVeriYazmayin.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık bilgisi gibi özel nitelikli veri yazmayın.'**
  String get ozelVeriYazmayin;

  /// No description provided for @notYalnizSalon.
  ///
  /// In tr, this message translates to:
  /// **'Not yalnızca salonunuzda görünür.'**
  String get notYalnizSalon;

  /// No description provided for @notuSil.
  ///
  /// In tr, this message translates to:
  /// **'Notu Sil'**
  String get notuSil;

  /// No description provided for @sonRandevular.
  ///
  /// In tr, this message translates to:
  /// **'Son randevular'**
  String get sonRandevular;

  /// No description provided for @genelde.
  ///
  /// In tr, this message translates to:
  /// **'Genelde: {ad}'**
  String genelde(String ad);

  /// No description provided for @sonGuncelleme.
  ///
  /// In tr, this message translates to:
  /// **'Son: {bilgi}'**
  String sonGuncelleme(String bilgi);

  /// No description provided for @musteriAdiGirin.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri adını girin.'**
  String get musteriAdiGirin;

  /// No description provided for @telefonKuraliOrnek.
  ///
  /// In tr, this message translates to:
  /// **'Telefon 5 ile başlayan 10 rakam olmalı (ör. 532 123 45 67).'**
  String get telefonKuraliOrnek;

  /// No description provided for @randevuEklendi.
  ///
  /// In tr, this message translates to:
  /// **'Randevu eklendi.'**
  String get randevuEklendi;

  /// No description provided for @telefonlaGelen.
  ///
  /// In tr, this message translates to:
  /// **'Telefonla veya kapıdan gelen müşteri için'**
  String get telefonlaGelen;

  /// No description provided for @tarihSaat.
  ///
  /// In tr, this message translates to:
  /// **'Tarih & Saat'**
  String get tarihSaat;

  /// No description provided for @saatIcinHizmet.
  ///
  /// In tr, this message translates to:
  /// **'Saatleri görmek için hizmet seçin.'**
  String get saatIcinHizmet;

  /// No description provided for @uygunSaatKalmadi.
  ///
  /// In tr, this message translates to:
  /// **'Bu gün için uygun saat kalmadı.'**
  String get uygunSaatKalmadi;

  /// No description provided for @adSoyad.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get adSoyad;

  /// No description provided for @telefonIstegeBagli.
  ///
  /// In tr, this message translates to:
  /// **'Telefon (isteğe bağlı)'**
  String get telefonIstegeBagli;

  /// No description provided for @notIstegeBagli.
  ///
  /// In tr, this message translates to:
  /// **'Not (isteğe bağlı)'**
  String get notIstegeBagli;

  /// No description provided for @randevuyuKaydet.
  ///
  /// In tr, this message translates to:
  /// **'Randevuyu Kaydet'**
  String get randevuyuKaydet;

  /// No description provided for @randevuSayisiEtiket.
  ///
  /// In tr, this message translates to:
  /// **'Randevu'**
  String get randevuSayisiEtiket;

  /// No description provided for @toplamSure.
  ///
  /// In tr, this message translates to:
  /// **'Toplam süre'**
  String get toplamSure;

  /// No description provided for @beklenenCiro.
  ///
  /// In tr, this message translates to:
  /// **'Beklenen ciro'**
  String get beklenenCiro;

  /// No description provided for @siradaki.
  ///
  /// In tr, this message translates to:
  /// **'SIRADAKİ'**
  String get siradaki;

  /// No description provided for @whatsappOnay.
  ///
  /// In tr, this message translates to:
  /// **'WhatsApp onay'**
  String get whatsappOnay;

  /// No description provided for @araTelefon.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get araTelefon;

  /// No description provided for @musteriNotuVar.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri notu var'**
  String get musteriNotuVar;

  /// No description provided for @bekleniyor.
  ///
  /// In tr, this message translates to:
  /// **'Bekleniyor'**
  String get bekleniyor;

  /// No description provided for @panelden.
  ///
  /// In tr, this message translates to:
  /// **'panelden eklendi'**
  String get panelden;

  /// No description provided for @notMetni.
  ///
  /// In tr, this message translates to:
  /// **'Not: {not}'**
  String notMetni(String not);

  /// No description provided for @tasimakIcinBasiliTut.
  ///
  /// In tr, this message translates to:
  /// **'taşımak için basılı tutun'**
  String get tasimakIcinBasiliTut;

  /// No description provided for @personelEkle.
  ///
  /// In tr, this message translates to:
  /// **'Personel Ekle'**
  String get personelEkle;

  /// No description provided for @unvan.
  ///
  /// In tr, this message translates to:
  /// **'Unvan (Usta, Kalfa...)'**
  String get unvan;

  /// No description provided for @epostaIstegeBagli.
  ///
  /// In tr, this message translates to:
  /// **'E-posta (isteğe bağlı)'**
  String get epostaIstegeBagli;

  /// No description provided for @personelEpostaIpucu.
  ///
  /// In tr, this message translates to:
  /// **'Personel bu e-postayla kayıt olursa kendi takvimini görür.'**
  String get personelEpostaIpucu;

  /// No description provided for @personelEklendi.
  ///
  /// In tr, this message translates to:
  /// **'Personel eklendi.'**
  String get personelEklendi;

  /// No description provided for @calismaGunleri.
  ///
  /// In tr, this message translates to:
  /// **'Çalışma günleri'**
  String get calismaGunleri;

  /// No description provided for @verdigiHizmetler.
  ///
  /// In tr, this message translates to:
  /// **'Verdiği hizmetler ve fiyatlar'**
  String get verdigiHizmetler;

  /// No description provided for @verdigiHizmetlerAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Bu personele özel fiyat, süre veya vermediği hizmetler'**
  String get verdigiHizmetlerAciklama;

  /// No description provided for @cikar.
  ///
  /// In tr, this message translates to:
  /// **'Çıkar'**
  String get cikar;

  /// No description provided for @personelCikarildi.
  ///
  /// In tr, this message translates to:
  /// **'Personel kadrodan çıkarıldı.'**
  String get personelCikarildi;

  /// No description provided for @hizmetEkle.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet Ekle'**
  String get hizmetEkle;

  /// No description provided for @hizmetiDuzenle.
  ///
  /// In tr, this message translates to:
  /// **'Hizmeti Düzenle'**
  String get hizmetiDuzenle;

  /// No description provided for @hizmetAdi.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet adı'**
  String get hizmetAdi;

  /// No description provided for @fiyat.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat'**
  String get fiyat;

  /// No description provided for @dkKisa.
  ///
  /// In tr, this message translates to:
  /// **'dk'**
  String get dkKisa;

  /// No description provided for @aciklamaIstegeBagli.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama (isteğe bağlı)'**
  String get aciklamaIstegeBagli;

  /// No description provided for @fiyatDegisikligi.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat değişikliği mevcut randevuları etkilemez.'**
  String get fiyatDegisikligi;

  /// No description provided for @hizmetKurali.
  ///
  /// In tr, this message translates to:
  /// **'Ad, fiyat ve en az 5 dakikalık süre girin.'**
  String get hizmetKurali;

  /// No description provided for @hizmetEklendi.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet eklendi.'**
  String get hizmetEklendi;

  /// No description provided for @hizmetGuncellendi.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet güncellendi.'**
  String get hizmetGuncellendi;

  /// No description provided for @hizmetKaldirildi.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet kaldırıldı.'**
  String get hizmetKaldirildi;

  /// No description provided for @personeleDokunun.
  ///
  /// In tr, this message translates to:
  /// **'Çalışma günleri ve verdiği hizmetler için personele dokunun.'**
  String get personeleDokunun;

  /// No description provided for @henuzPersonelYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz personel yok.'**
  String get henuzPersonelYok;

  /// No description provided for @hizmetMenusu.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet Menüsü'**
  String get hizmetMenusu;

  /// No description provided for @henuzHizmetYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz hizmet yok.'**
  String get henuzHizmetYok;

  /// No description provided for @calismaGunleriKaydedildi.
  ///
  /// In tr, this message translates to:
  /// **'{ad} için çalışma günleri kaydedildi.'**
  String calismaGunleriKaydedildi(String ad);

  /// No description provided for @hizmetlerKaydedildi.
  ///
  /// In tr, this message translates to:
  /// **'{ad} için hizmetler kaydedildi.'**
  String hizmetlerKaydedildi(String ad);

  /// No description provided for @kadrodanCikarilsinMi.
  ///
  /// In tr, this message translates to:
  /// **'{ad} kadrodan çıkarılsın mı? Geçmiş randevu kayıtları korunur.'**
  String kadrodanCikarilsinMi(String ad);

  /// No description provided for @menudenKaldirilsinMi.
  ///
  /// In tr, this message translates to:
  /// **'\"{ad}\" menüden kaldırılsın mı?'**
  String menudenKaldirilsinMi(String ad);

  /// No description provided for @hesabiBagli.
  ///
  /// In tr, this message translates to:
  /// **'hesabı bağlı'**
  String get hesabiBagli;

  /// No description provided for @davet.
  ///
  /// In tr, this message translates to:
  /// **'davet: {eposta}'**
  String davet(String eposta);

  /// No description provided for @hizmetiVermiyor.
  ///
  /// In tr, this message translates to:
  /// **'{n} hizmeti vermiyor'**
  String hizmetiVermiyor(int n);

  /// No description provided for @ozelFiyatli.
  ///
  /// In tr, this message translates to:
  /// **'{n} hizmette özel fiyat/süre'**
  String ozelFiyatli(int n);

  /// No description provided for @haftalikIzin.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık izin: {gunler}'**
  String haftalikIzin(String gunler);

  /// No description provided for @calismaGunleriAciklama.
  ///
  /// In tr, this message translates to:
  /// **'İşaretli günlerde çalışır. İşaretsiz günlerde müşteriler bu personelden randevu alamaz.'**
  String get calismaGunleriAciklama;

  /// No description provided for @salonBuGunKapali.
  ///
  /// In tr, this message translates to:
  /// **'Salon bu gün kapalı'**
  String get salonBuGunKapali;

  /// No description provided for @solukGunler.
  ///
  /// In tr, this message translates to:
  /// **'Soluk günlerde salon kapalı.'**
  String get solukGunler;

  /// No description provided for @kampanyaEklendi.
  ///
  /// In tr, this message translates to:
  /// **'Kampanya eklendi.'**
  String get kampanyaEklendi;

  /// No description provided for @kampanyaGuncellendi.
  ///
  /// In tr, this message translates to:
  /// **'Kampanya güncellendi.'**
  String get kampanyaGuncellendi;

  /// No description provided for @kampanyayiKaldir.
  ///
  /// In tr, this message translates to:
  /// **'Kampanyayı kaldır'**
  String get kampanyayiKaldir;

  /// No description provided for @sadakatAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Müşterinin bu salondaki her N. randevusu indirimli olur. Tamamlanan ve alınmış randevular sayılır; gelinmeyen ve iptal edilenler sayılmaz.'**
  String get sadakatAciklama;

  /// No description provided for @kacinciZiyaret.
  ///
  /// In tr, this message translates to:
  /// **'Kaçıncı ziyaret (2–50)'**
  String get kacinciZiyaret;

  /// No description provided for @ziyaretEki.
  ///
  /// In tr, this message translates to:
  /// **'. ziyaret'**
  String get ziyaretEki;

  /// No description provided for @indirimAraligi.
  ///
  /// In tr, this message translates to:
  /// **'İndirim (5–100)'**
  String get indirimAraligi;

  /// No description provided for @sadakatKuraliHata.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret 2–50, indirim 5–100 arasında olmalı.'**
  String get sadakatKuraliHata;

  /// No description provided for @sadakatKapatildi.
  ///
  /// In tr, this message translates to:
  /// **'Sadakat kartı kapatıldı.'**
  String get sadakatKapatildi;

  /// No description provided for @kampanyaAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Boş günleri doldurmak için: ör. \"Salı %20\" veya \"Hafta içi 10:00–14:00 sakal %30\". İndirimler üst üste binmez; müşteriye en yüksek olanı uygulanır.'**
  String get kampanyaAciklama;

  /// No description provided for @henuzKampanyaYok.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kampanya yok.'**
  String get henuzKampanyaYok;

  /// No description provided for @sadakatKapaliAc.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı · açmak için dokunun'**
  String get sadakatKapaliAc;

  /// No description provided for @kampanyaKurali.
  ///
  /// In tr, this message translates to:
  /// **'Ad girin; indirim %5 ile %90 arasında olmalı.'**
  String get kampanyaKurali;

  /// No description provided for @bitisBaslangictanOnce.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş tarihi başlangıçtan önce olamaz.'**
  String get bitisBaslangictanOnce;

  /// No description provided for @yeniKampanya.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kampanya'**
  String get yeniKampanya;

  /// No description provided for @kampanyayiDuzenle.
  ///
  /// In tr, this message translates to:
  /// **'Kampanyayı Düzenle'**
  String get kampanyayiDuzenle;

  /// No description provided for @kampanyaFormAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Boş bıraktığınız koşul kısıt koymaz. Değişiklik yalnızca bundan sonraki randevulara uygulanır.'**
  String get kampanyaFormAciklama;

  /// No description provided for @kampanyaAdi.
  ///
  /// In tr, this message translates to:
  /// **'Kampanya adı'**
  String get kampanyaAdi;

  /// No description provided for @kampanyaAdiOrnek.
  ///
  /// In tr, this message translates to:
  /// **'Salı İndirimi'**
  String get kampanyaAdiOrnek;

  /// No description provided for @gunler.
  ///
  /// In tr, this message translates to:
  /// **'Günler'**
  String get gunler;

  /// No description provided for @herGun.
  ///
  /// In tr, this message translates to:
  /// **'Her gün'**
  String get herGun;

  /// No description provided for @saatAraligi.
  ///
  /// In tr, this message translates to:
  /// **'Saat aralığı'**
  String get saatAraligi;

  /// No description provided for @gunBoyu.
  ///
  /// In tr, this message translates to:
  /// **'Gün boyu'**
  String get gunBoyu;

  /// No description provided for @saatAraligiSec.
  ///
  /// In tr, this message translates to:
  /// **'Saat aralığı seç'**
  String get saatAraligiSec;

  /// No description provided for @tarihAraligi.
  ///
  /// In tr, this message translates to:
  /// **'Tarih aralığı'**
  String get tarihAraligi;

  /// No description provided for @suresiz.
  ///
  /// In tr, this message translates to:
  /// **'Süresiz'**
  String get suresiz;

  /// No description provided for @baslangicHemen.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç: hemen'**
  String get baslangicHemen;

  /// No description provided for @bitisYok.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş: yok'**
  String get bitisYok;

  /// No description provided for @temizle.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get temizle;

  /// No description provided for @tumHizmetler.
  ///
  /// In tr, this message translates to:
  /// **'Tüm hizmetler'**
  String get tumHizmetler;

  /// No description provided for @kampanyaAcik.
  ///
  /// In tr, this message translates to:
  /// **'Kampanya açık'**
  String get kampanyaAcik;

  /// No description provided for @kapatirsanizDuraklatilir.
  ///
  /// In tr, this message translates to:
  /// **'Kapatırsanız silinmez, duraklatılır.'**
  String get kapatirsanizDuraklatilir;

  /// No description provided for @sadakatKaydedildi.
  ///
  /// In tr, this message translates to:
  /// **'Sadakat kartı: her {esik}. ziyaret %{yuzde}.'**
  String sadakatKaydedildi(int esik, int yuzde);

  /// No description provided for @duraklatildi.
  ///
  /// In tr, this message translates to:
  /// **'Duraklatıldı'**
  String get duraklatildi;

  /// No description provided for @suresiDoldu.
  ///
  /// In tr, this message translates to:
  /// **'Süresi doldu'**
  String get suresiDoldu;

  /// No description provided for @baslangic.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç: {tarih}'**
  String baslangic(String tarih);

  /// No description provided for @bitis.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş: {tarih}'**
  String bitis(String tarih);

  /// No description provided for @enAzBirHizmetVermeli.
  ///
  /// In tr, this message translates to:
  /// **'Personel en az bir hizmet vermeli.'**
  String get enAzBirHizmetVermeli;

  /// No description provided for @personelHizmetAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı hizmetler bu personelden alınamaz. Fiyat ve süre boşsa menüdeki geçerli; değişiklik mevcut randevuları etkilemez.'**
  String get personelHizmetAciklama;

  /// No description provided for @menudeHizmetYok.
  ///
  /// In tr, this message translates to:
  /// **'Menüde hizmet yok.'**
  String get menudeHizmetYok;

  /// No description provided for @ozelFiyat.
  ///
  /// In tr, this message translates to:
  /// **'Özel fiyat'**
  String get ozelFiyat;

  /// No description provided for @ozelSure.
  ///
  /// In tr, this message translates to:
  /// **'Özel süre'**
  String get ozelSure;

  /// No description provided for @sureEnAz5.
  ///
  /// In tr, this message translates to:
  /// **'{ad}: süre en az 5 dakika olmalı.'**
  String sureEnAz5(String ad);

  /// No description provided for @menuDegeri.
  ///
  /// In tr, this message translates to:
  /// **'Menü: {deger}'**
  String menuDegeri(String deger);

  /// No description provided for @kapaliGunEklendi.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı gün eklendi.'**
  String get kapaliGunEklendi;

  /// No description provided for @oncePersonelEkle.
  ///
  /// In tr, this message translates to:
  /// **'Önce Ekip & Menü sekmesinden personel ekleyin.'**
  String get oncePersonelEkle;

  /// No description provided for @hangiPersonel.
  ///
  /// In tr, this message translates to:
  /// **'Hangi personel?'**
  String get hangiPersonel;

  /// No description provided for @kaydedildi.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi.'**
  String get kaydedildi;

  /// No description provided for @hangiPersonelIzinli.
  ///
  /// In tr, this message translates to:
  /// **'Hangi personel izinli?'**
  String get hangiPersonelIzinli;

  /// No description provided for @izinEklendi.
  ///
  /// In tr, this message translates to:
  /// **'İzin eklendi.'**
  String get izinEklendi;

  /// No description provided for @kapaliAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Öğle arası, kapalı gün, izin ve kapatılan saatlerde müşteriler randevu alamaz.'**
  String get kapaliAciklama;

  /// No description provided for @salonKapaliGunler.
  ///
  /// In tr, this message translates to:
  /// **'Salonun kapalı olduğu günler'**
  String get salonKapaliGunler;

  /// No description provided for @kapaliGunYok.
  ///
  /// In tr, this message translates to:
  /// **'Planlanmış kapalı gün yok.'**
  String get kapaliGunYok;

  /// No description provided for @personelIzinleri.
  ///
  /// In tr, this message translates to:
  /// **'Personel izinleri'**
  String get personelIzinleri;

  /// No description provided for @izinYok.
  ///
  /// In tr, this message translates to:
  /// **'Planlanmış izin yok.'**
  String get izinYok;

  /// No description provided for @saatlikKapatmalar.
  ///
  /// In tr, this message translates to:
  /// **'Saatlik kapatmalar'**
  String get saatlikKapatmalar;

  /// No description provided for @kapatilmisSaatYok.
  ///
  /// In tr, this message translates to:
  /// **'Kapatılmış saat yok. Ör: \"Ali 14:00–16:00 dışarıda\".'**
  String get kapatilmisSaatYok;

  /// No description provided for @salonKapaliTarih.
  ///
  /// In tr, this message translates to:
  /// **'Salon kapalı: {tarih}'**
  String salonKapaliTarih(String tarih);

  /// No description provided for @saatlerdeRandevuVar.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi. Bu saatlerde {n} aktif randevu var; müşterilere haber verin.'**
  String saatlerdeRandevuVar(int n);

  /// No description provided for @izinGununderandevuVar.
  ///
  /// In tr, this message translates to:
  /// **'İzin eklendi. Bu günde {n} aktif randevu var; müşterilere haber verin.'**
  String izinGununderandevuVar(int n);

  /// No description provided for @molaKaldirildi.
  ///
  /// In tr, this message translates to:
  /// **'Öğle arası kaldırıldı.'**
  String get molaKaldirildi;

  /// No description provided for @molaYok.
  ///
  /// In tr, this message translates to:
  /// **'Öğle arası tanımlı değil'**
  String get molaYok;

  /// No description provided for @molaAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Her gün bu saatlerde randevu alınmaz.'**
  String get molaAciklama;

  /// No description provided for @molayiKaldir.
  ///
  /// In tr, this message translates to:
  /// **'Öğle arasını kaldır'**
  String get molayiKaldir;

  /// No description provided for @molaKaydedildi.
  ///
  /// In tr, this message translates to:
  /// **'Öğle arası {aralik} olarak kaydedildi.'**
  String molaKaydedildi(String aralik);

  /// No description provided for @sinirYok.
  ///
  /// In tr, this message translates to:
  /// **'Sınır yok'**
  String get sinirYok;

  /// No description provided for @oncedenSoru.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri en az ne kadar önceden randevu alsın?'**
  String get oncedenSoru;

  /// No description provided for @oncedenOrnek.
  ///
  /// In tr, this message translates to:
  /// **'Örneğin 1 saat: saat 12:10\'da en erken 13:30 alınabilir. Sizin panelden eklediğiniz randevular bu sınırdan etkilenmez.'**
  String get oncedenOrnek;

  /// No description provided for @sonDakikaAcikNokta.
  ///
  /// In tr, this message translates to:
  /// **'Son dakika randevuya açık.'**
  String get sonDakikaAcikNokta;

  /// No description provided for @sonDakikaAcik.
  ///
  /// In tr, this message translates to:
  /// **'Son dakika randevuya açık'**
  String get sonDakikaAcik;

  /// No description provided for @oncedenAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Müşterinin uygulamadan alabileceği en yakın saat.'**
  String get oncedenAciklama;

  /// No description provided for @musterilerEnAz.
  ///
  /// In tr, this message translates to:
  /// **'Müşteriler en az {sure} önceden alabilir.'**
  String musterilerEnAz(String sure);

  /// No description provided for @enAzOncedenKisa.
  ///
  /// In tr, this message translates to:
  /// **'En az {sure} önceden'**
  String enAzOncedenKisa(String sure);

  /// No description provided for @baslangicSaati.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç saati'**
  String get baslangicSaati;

  /// No description provided for @bitisSaati.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş saati'**
  String get bitisSaati;

  /// No description provided for @bitisSonraOlmali.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş saati başlangıçtan sonra olmalı.'**
  String get bitisSonraOlmali;

  /// No description provided for @oncekiAy.
  ///
  /// In tr, this message translates to:
  /// **'Önceki ay'**
  String get oncekiAy;

  /// No description provided for @sonrakiAy.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki ay'**
  String get sonrakiAy;

  /// No description provided for @ciro.
  ///
  /// In tr, this message translates to:
  /// **'Ciro'**
  String get ciro;

  /// No description provided for @tamamlanan.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan'**
  String get tamamlanan;

  /// No description provided for @ortalamaSepet.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama sepet'**
  String get ortalamaSepet;

  /// No description provided for @gelmemeOrani.
  ///
  /// In tr, this message translates to:
  /// **'Gelmeme oranı'**
  String get gelmemeOrani;

  /// No description provided for @verilenIndirim.
  ///
  /// In tr, this message translates to:
  /// **'Verilen indirim'**
  String get verilenIndirim;

  /// No description provided for @personelCiro.
  ///
  /// In tr, this message translates to:
  /// **'Personel bazlı ciro'**
  String get personelCiro;

  /// No description provided for @buAyTamamlananYok.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay tamamlanan randevu yok.'**
  String get buAyTamamlananYok;

  /// No description provided for @populerHizmetler.
  ///
  /// In tr, this message translates to:
  /// **'En çok tercih edilen hizmetler'**
  String get populerHizmetler;

  /// No description provided for @yuzdeMetin.
  ///
  /// In tr, this message translates to:
  /// **'%{y}'**
  String yuzdeMetin(String y);

  /// No description provided for @randevuSayisi.
  ///
  /// In tr, this message translates to:
  /// **'{n} randevu'**
  String randevuSayisi(int n);

  /// No description provided for @raporAlt.
  ///
  /// In tr, this message translates to:
  /// **'İptal: {iptal} · Gelmedi: {gelmedi} · Uygulamadan gelen: {uygulama}'**
  String raporAlt(int iptal, int gelmedi, int uygulama);

  /// No description provided for @ilkZiyaret.
  ///
  /// In tr, this message translates to:
  /// **'İlk ziyaret — geçmiş kaydı yok'**
  String get ilkZiyaret;

  /// No description provided for @guvenOzet.
  ///
  /// In tr, this message translates to:
  /// **'{tamam} tamamlanan · {gelmedi} gelmedi · {gec} geç iptal'**
  String guvenOzet(int tamam, int gelmedi, int gec);

  /// No description provided for @guvenilir.
  ///
  /// In tr, this message translates to:
  /// **'Güvenilir'**
  String get guvenilir;

  /// No description provided for @dikkat.
  ///
  /// In tr, this message translates to:
  /// **'Dikkat'**
  String get dikkat;

  /// No description provided for @isletmeHesapSilAciklama.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınıza ait kişisel bilgiler (ad, telefon, e-posta) silinecek ve panel erişiminiz kapanacak. Salon kaydı ve geçmiş randevular kimliksiz olarak kalır. Bu işlem geri alınamaz.'**
  String get isletmeHesapSilAciklama;

  /// No description provided for @hesapSilinemediTekrar.
  ///
  /// In tr, this message translates to:
  /// **'Hesap silinemedi. Lütfen tekrar deneyin.'**
  String get hesapSilinemediTekrar;
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
