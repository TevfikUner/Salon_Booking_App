import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/baglanti_bandi.dart';
import 'package:berber_app_ui/features/giris/splash_screen.dart';
import 'package:berber_app_ui/features/randevu_al/randevu_provider.dart';
import 'package:berber_app_ui/l10n/app_localizations.dart';
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
  await initializeDateFormatting('en', null);
  await Dil.ornek.yukle();
  FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
  runApp(const BerberApp());
}

/// Kök. Dil değişince (Profil'den seçim veya cihaz dili) MaterialApp yeni anahtarla baştan kurulur:
/// metinler bağlamsız (`Dil.t`) okunduğu için tüm ekranların yeni dille çizilmesinin en sağlam yolu bu.
class BerberApp extends StatefulWidget {
  final Widget ilkEkran;
  const BerberApp({super.key, this.ilkEkran = const SplashScreen()});

  @override
  State<BerberApp> createState() => _BerberAppState();
}

class _BerberAppState extends State<BerberApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Dil.ornek.addListener(_dilDegisti);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Dil.ornek.removeListener(_dilDegisti);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) => Dil.ornek.cihazDiliDegisti();

  void _dilDegisti() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => RandevuProvider())],
      child: MaterialApp(
        key: ValueKey(Dil.kod),
        title: 'Premium Berber',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        locale: Dil.ingilizce ? const Locale('en') : const Locale('tr', 'TR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        // Sistem yazı boyutu büyütülebilir ama 1.3×'ten fazlası kartları kırar → üst sınır
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3)),
            child: BaglantiBandi(child: child ?? const SizedBox()),
          );
        },
        home: widget.ilkEkran,
      ),
    );
  }
}
