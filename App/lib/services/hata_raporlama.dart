import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';

/// Yakalanmamış hatalar: Crashlytics'e raporlanır, kullanıcıya kırmızı ekran yerine sade bir mesaj gösterilir.
/// Kişisel veri (ad, e-posta, telefon) Crashlytics'e GÖNDERİLMEZ.
class HataRaporlama {
  HataRaporlama._();

  static Future<void> kur() async {
    final crashlytics = FirebaseCrashlytics.instance;
    // Geliştirme sırasında raporlama kapalı; yalnızca release derlemeleri raporlar
    await crashlytics.setCrashlyticsCollectionEnabled(kReleaseMode);

    FlutterError.onError = (detay) {
      if (kDebugMode) FlutterError.presentError(detay);
      crashlytics.recordFlutterFatalError(detay);
    };
    PlatformDispatcher.instance.onError = (hata, iz) {
      crashlytics.recordError(hata, iz, fatal: true);
      return true; // uygulamayı kapatma
    };
    ErrorWidget.builder = (detay) => kDebugMode ? ErrorWidget(detay.exception) : const _DostcaHata();
  }

  /// Beklenen ama izlenmesi gereken (ölümcül olmayan) hatalar için.
  static void kaydet(Object hata, StackTrace? iz, {String? neden}) {
    if (kReleaseMode) FirebaseCrashlytics.instance.recordError(hata, iz, reason: neden);
  }
}

/// Bir widget çizilemediğinde (release) görünen sade kutu — kırmızı/gri hata ekranı yerine.
class _DostcaHata extends StatelessWidget {
  const _DostcaHata();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(Dil.t.bolumGosterilemiyor,
              textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
        ),
      ),
    );
  }
}
