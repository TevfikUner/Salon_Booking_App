import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:berber_app_ui/features/kesfet/salon_detay_screen.dart';
import 'package:berber_app_ui/features/musteri/degerlendirme/degerlendirme_screen.dart';
import 'package:berber_app_ui/features/musteri/main_screen.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/data/api/hesap_api.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// FCM: izin, token kaydı, ön planda gelen bildirimi gösterme ve bildirime dokununca yönlendirme.
class BildirimServisi {
  static StreamSubscription<String>? _tokenAboneligi;
  static bool _dinleyicilerKuruldu = false;

  /// Girişten sonra çağrılır. Hata uygulamayı durdurmaz (bildirim opsiyonel bir kanaldır).
  static Future<void> baslat() async {
    try {
      final fm = FirebaseMessaging.instance;
      await fm.requestPermission();
      final token = await fm.getToken();
      if (token != null) await HesapApi.fcmTokenKaydet(token);
      _tokenAboneligi ??= fm.onTokenRefresh.listen((t) => HesapApi.fcmTokenKaydet(t).catchError((_) {}));
    } catch (e) {
      debugPrint('Bildirim kaydı yapılamadı: $e');
    }
    if (_dinleyicilerKuruldu) return;
    _dinleyicilerKuruldu = true;

    FirebaseMessaging.onMessage.listen(_onPlanda);
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _ac(m.data));
    final ilk = await FirebaseMessaging.instance.getInitialMessage();
    if (ilk != null) _ac(ilk.data);
  }

  static void _onPlanda(RemoteMessage m) {
    final n = m.notification;
    if (n == null) return;
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      backgroundColor: AppTheme.surface,
      duration: const Duration(seconds: 6),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(n.title ?? '', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold)),
          if (n.body != null) Text(n.body!, style: const TextStyle(color: Colors.white)),
        ],
      ),
      action: switch (m.data['type']) {
        'degerlendirme' => SnackBarAction(label: 'Puanla', textColor: AppTheme.gold, onPressed: () => _ac(m.data)),
        'randevu' || 'bekleme' => SnackBarAction(label: 'Aç', textColor: AppTheme.gold, onPressed: () => _ac(m.data)),
        _ => null,
      },
    ));
  }

  /// Bildirime dokunulunca ilgili ekranı açar: randevu → Randevularım, bekleme → salon, değerlendirme → puanlama.
  static void _ac(Map<String, dynamic> data) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    switch (data['type']) {
      case 'randevu':
        nav.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainScreen(baslangicSekmesi: 1)), (_) => false);
      case 'bekleme':
        final salonId = int.tryParse(data['salon_id']?.toString() ?? '');
        if (salonId != null) nav.push(MaterialPageRoute(builder: (_) => SalonDetayScreen(salonId: salonId)));
      case 'degerlendirme':
        final id = int.tryParse(data['randevu_id']?.toString() ?? '');
        if (id == null) return;
        nav.push(MaterialPageRoute(
          builder: (_) => DegerlendirmeEkrani(
            randevuId: id,
            berberAdi: data['berber_adi']?.toString() ?? 'Berber',
            berberFotoUrl: data['berber_foto_url']?.toString(),
          ),
        ));
    }
  }

  static Future<void> durdur() async {
    await _tokenAboneligi?.cancel();
    _tokenAboneligi = null;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }
}
