import 'package:flutter/material.dart';

import 'package:berber_app_ui/features/isletme/isletme_bekleme_screen.dart';
import 'package:berber_app_ui/features/isletme/isletme_panel_screen.dart';
import 'package:berber_app_ui/features/musteri/main_screen.dart';
import 'package:berber_app_ui/data/api/hesap_api.dart';
import 'package:berber_app_ui/services/bildirim_servisi.dart';

/// Girişten sonra kullanıcının rolüne göre açılacak ekranı belirler.
class Yonlendirme {
  static Future<Widget> girisSonrasi() async {
    final ben = await HesapApi.ben();
    BildirimServisi.baslat(); // beklemeden arka planda
    final rol = ben['rol'] as String? ?? 'musteri';
    final isletme = ben['isletme'] as Map<String, dynamic>?;
    if (rol == 'isletme') {
      if (isletme?['durum'] == 'onaylandi' && isletme?['salon_id'] != null) {
        return IsletmePanelScreen(salonAd: ben['salon']?['ad'] ?? isletme?['isletme_adi'] ?? '');
      }
      return IsletmeBeklemeScreen(durum: isletme?['durum'] ?? 'beklemede', isletmeAdi: isletme?['isletme_adi'] ?? '');
    }
    if (rol == 'personel') {
      return IsletmePanelScreen(salonAd: ben['salon']?['ad'] ?? '', personel: true);
    }
    return const MainScreen();
  }

  static Future<void> git(BuildContext context) async {
    final ekran = await girisSonrasi();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => ekran), (_) => false);
  }
}
