import 'package:firebase_auth/firebase_auth.dart';

import 'api_service.dart';

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
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: sifre);
    await cred.user?.updateDisplayName('$ad $soyad'.trim());
    await ApiService.musteriKayit(
      ad: ad,
      soyad: soyad,
      telefon: telefon,
      kvkkOnay: kvkkOnay,
      ticariIletiIzni: ticariIletiIzni,
    );
  }

  static Future<void> sifreSifirla(String email) async {
    await _auth.setLanguageCode('tr');
    await _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> cikisYap() => _auth.signOut();

  static Future<void> isletmeKayitOl({
    required String email,
    required String sifre,
    required String ad,
    required String soyad,
    required String telefon,
    required String isletmeAdi,
  }) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: sifre);
    await ApiService.isletmeKayit(
      ad: ad,
      soyad: soyad,
      telefon: telefon,
      email: email,
      isletmeAdi: isletmeAdi,
    );
  }

  /// Hesabı siler: önce backend'deki kişisel veriler, sonra Firebase kullanıcısı.
  /// Firebase son girişin eski olduğunu söylerse kullanıcı çıkış yaptırılır;
  /// backend tarafı zaten silinmiş olur.
  static Future<bool> hesabiSil() async {
    await ApiService.hesapSil();
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

  /// Firebase hata kodlarını Türkçe mesaja çevirir.
  static String hataMesaji(Object e) {
    if (e is FirebaseAuthException) {
      return switch (e.code) {
        'invalid-email' => 'E-posta adresi geçersiz.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' => 'E-posta veya şifre hatalı.',
        'email-already-in-use' => 'Bu e-posta ile zaten bir hesap var. Giriş yapmayı deneyin.',
        'weak-password' => 'Şifre çok zayıf. En az 6 karakter kullanın.',
        'too-many-requests' => 'Çok fazla deneme yapıldı. Lütfen biraz sonra tekrar deneyin.',
        'network-request-failed' => 'İnternet bağlantısı yok.',
        _ => e.message ?? 'Kimlik doğrulama hatası.',
      };
    }
    return e.toString();
  }
}
