import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/baglanti_bandi.dart';
import 'package:berber_app_ui/features/giris/splash_screen.dart';
import 'package:berber_app_ui/features/randevu_al/randevu_provider.dart';
import 'package:berber_app_ui/services/bildirim_servisi.dart';
import 'package:berber_app_ui/services/hata_raporlama.dart';

@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Yazı tipleri uygulamaya gömülü (assets/google_fonts) → çevrimdışı açılış, Google'a istek yok
  GoogleFonts.config.allowRuntimeFetching = false;
  await Firebase.initializeApp();
  await HataRaporlama.kur();
  await initializeDateFormatting('tr_TR', null);
  FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
  runApp(const BerberApp());
}

class BerberApp extends StatelessWidget {
  final Widget ilkEkran;
  const BerberApp({super.key, this.ilkEkran = const SplashScreen()});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => RandevuProvider())],
      child: MaterialApp(
        title: 'Premium Berber',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        locale: const Locale('tr', 'TR'),
        supportedLocales: const [Locale('tr', 'TR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Sistem yazı boyutu büyütülebilir ama 1.3×'ten fazlası kartları kırar → üst sınır
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3)),
            child: BaglantiBandi(child: child ?? const SizedBox()),
          );
        },
        home: ilkEkran,
      ),
    );
  }
}
