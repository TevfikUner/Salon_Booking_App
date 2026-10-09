import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/randevu_provider.dart';
import 'screens/splash_screen.dart';
import 'services/bildirim_servisi.dart';
import 'theme/app_theme.dart';

@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('tr_TR', null);
  FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
  runApp(const BerberApp());
}

class BerberApp extends StatelessWidget {
  const BerberApp({super.key});

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
        home: const SplashScreen(),
      ),
    );
  }
}
