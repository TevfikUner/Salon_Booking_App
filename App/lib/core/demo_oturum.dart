import 'package:flutter/foundation.dart';

/// Firebase hesabı açmadan uygulamayı denemek için (repoyu klonlayan geliştirici):
///   backend: `AUTH_MODE=dev` + `python seed_demo.py`
///   uygulama: `flutter run --dart-define=DEMO=true`
/// Rol seçim ekranında "Müşteri olarak dene / İşletme olarak dene" çıkar; istekler `dev:<uid>` jetonu taşır.
/// Production backend bu jetonu reddeder; release derlemede tamamen kapalıdır.
class DemoOturum {
  DemoOturum._();

  static const bool acik = kDebugMode && bool.fromEnvironment('DEMO');

  /// Seed'deki hazır kullanıcılar (backend/seed_demo.py).
  static const String musteriUid = 'demo-musteri';
  static const String isletmeUid = 'demo-isletme';

  static String? _uid;
  static String? get uid => _uid;
  static bool get aktif => _uid != null;

  static void baslat(String uid) {
    if (acik) _uid = uid;
  }

  static void bitir() => _uid = null;
}
