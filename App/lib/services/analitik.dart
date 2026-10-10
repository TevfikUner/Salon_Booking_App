import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Temel kullanım olayları (Firebase Analytics). Kişisel veri gönderilmez; yalnızca olay ve sayısal bilgi.
/// Analitik hatası uygulama akışını asla bozmaz.
class Analitik {
  Analitik._();

  static FirebaseAnalytics? get _fa {
    try {
      return FirebaseAnalytics.instance;
    } catch (_) {
      return null; // Firebase başlatılmamış (test ortamı)
    }
  }

  static Future<void> _gonder(Future<void> Function(FirebaseAnalytics fa) islem) async {
    final fa = _fa;
    if (fa == null) return;
    try {
      await islem(fa);
    } catch (e) {
      debugPrint('Analitik olayı gönderilemedi: $e');
    }
  }

  static Future<void> kayit({required String rol}) =>
      _gonder((fa) => fa.logSignUp(signUpMethod: 'eposta', parameters: {'rol': rol}));

  static Future<void> randevuOlusturuldu({required num tutar, required int hizmetSayisi, required String kaynak}) =>
      _gonder((fa) => fa.logEvent(name: 'randevu_olustur', parameters: {
            'tutar': tutar,
            'hizmet_sayisi': hizmetSayisi,
            'kaynak': kaynak, // akis | her_zamanki
            'currency': 'TRY',
          }));

  static Future<void> randevuIptal() => _gonder((fa) => fa.logEvent(name: 'randevu_iptal'));
}
