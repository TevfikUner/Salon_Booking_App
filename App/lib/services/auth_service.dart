import 'package:firebase_auth/firebase_auth.dart';

import 'package:berber_app_ui/core/demo_oturum.dart';
import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/data/api/hesap_api.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> girisYap(String email, String sifre) =>
      _auth.signInWithEmailAndPassword(email: email, password: sifre);

  /// Firebase hesabı oluşturur ve backend'e müşteri kaydını (KVKK onayıyla) yapar.
  static Future<void> kayitOl({
    required String email,
    required String sifre,
    required String ad,
    required String soyad,
    required String telefon,
    required bool kvkkOnay,
    required bool ticariIletiIzni,
  }) =>
      _hesapAcVeKaydet(email, sifre, '$ad $soyad'.trim(), () => HesapApi.musteriKayit(
            ad: ad,
            soyad: soyad,
            telefon: telefon,
            kvkkOnay: kvkkOnay,
            ticariIletiIzni: ticariIletiIzni,
          ));

  static Future<void> sifreSifirla(String email) async {
    await _auth.setLanguageCode('tr');
    await _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> cikisYap() {
    DemoOturum.bitir();
    return _auth.signOut();
  }

  static Future<void> isletmeKayitOl({
    required String email,
    required String sifre,
    required String ad,
    required String soyad,
    required String telefon,
    required String isletmeAdi,
  }) =>
      _hesapAcVeKaydet(email, sifre, '$ad $soyad'.trim(), () => HesapApi.isletmeKayit(
            ad: ad,
            soyad: soyad,
            telefon: telefon,
            email: email,
            isletmeAdi: isletmeAdi,
          ));

  /// Firebase hesabını açar, sunucu kaydını yapar. Sunucu kaydı başarısız olursa Firebase hesabı geri alınır;
  /// aksi halde kullanıcı aynı e-postayla tekrar denediğinde "e-posta zaten kullanımda" hatasına takılırdı.
  /// Doğrulama e-postası da gönderilir (personel davetinin eşleşmesi doğrulanmış e-posta ister).
  static Future<void> _hesapAcVeKaydet(String email, String sifre, String adSoyad, Future<void> Function() kayit) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: sifre);
    try {
      await cred.user?.updateDisplayName(adSoyad);
      await kayit();
    } catch (_) {
      await cred.user?.delete();
      rethrow;
    }
    try {
      await _auth.setLanguageCode('tr');
      await cred.user?.sendEmailVerification();
    } catch (_) {
      // Doğrulama e-postası gönderilemese de kayıt geçerlidir.
    }
  }

  /// Hesabı siler: önce backend'deki kişisel veriler, sonra Firebase kullanıcısı.
  /// Firebase son girişin eski olduğunu söylerse kullanıcı çıkış yaptırılır;
  /// backend tarafı zaten silinmiş olur.
  static Future<bool> hesabiSil() async {
    await HesapApi.hesapSil();
    try {
      await _auth.currentUser?.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        await _auth.signOut();
        return false;
      }
      rethrow;
    }
  }

  /// Firebase hata kodlarını uygulama dilinde mesaja çevirir.
  static String hataMesaji(Object e) {
    if (e is FirebaseAuthException) {
      return switch (e.code) {
        'invalid-email' => Dil.t.hataEpostaGecersiz,
        'user-not-found' || 'wrong-password' || 'invalid-credential' => Dil.t.hataEpostaSifreHatali,
        'email-already-in-use' => Dil.t.hataEpostaKullanimda,
        'weak-password' => Dil.t.hataSifreZayif,
        'too-many-requests' => Dil.t.hataCokFazlaDenemeYapildi,
        'network-request-failed' => Dil.t.internetYok,
        _ => e.message ?? Dil.t.hataKimlikDogrulama,
      };
    }
    return e.toString();
  }
}
