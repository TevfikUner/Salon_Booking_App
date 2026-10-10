import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/sabit/yasal_metinler.dart';
import 'package:berber_app_ui/features/destek/yasal_dokuman_screen.dart';
import 'package:berber_app_ui/features/giris/rol_secim_screen.dart';
import 'package:berber_app_ui/services/auth_service.dart';
import 'package:berber_app_ui/services/bildirim_servisi.dart';

/// İşletme/personel hesabı menüsü (panel ve onay bekleme ekranı): yasal metinler, hesabı silme, çıkış.
/// Play Store kuralı: uygulamada açılabilen her hesap türü uygulamadan silinebilmeli.
class HesapMenusu extends StatelessWidget {
  const HesapMenusu({super.key});

  Future<void> _girise(BuildContext context) async {
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const RolSecimScreen()), (_) => false);
  }

  Future<void> _cikis(BuildContext context) async {
    if (!await onayIste(context, 'Çıkış Yap', 'Hesabınızdan çıkış yapılsın mı?', evet: 'Çıkış Yap')) return;
    await BildirimServisi.durdur();
    await AuthService.cikisYap();
    if (context.mounted) await _girise(context);
  }

  Future<void> _sil(BuildContext context) async {
    final onay = await onayIste(
      context,
      'Hesabı Sil',
      'Hesabınıza ait kişisel bilgiler (ad, telefon, e-posta) silinecek ve panel erişiminiz kapanacak. '
          'Salon kaydı ve geçmiş randevular kimliksiz olarak kalır. Bu işlem geri alınamaz.',
      evet: 'Kalıcı Olarak Sil',
      tehlikeli: true,
    );
    if (!onay || !context.mounted) return;
    try {
      await BildirimServisi.durdur();
      final tamamen = await AuthService.hesabiSil();
      if (!context.mounted) return;
      bilgiGoster(
          context,
          tamamen
              ? 'Hesabınız ve kişisel verileriniz silindi.'
              : 'Kişisel verileriniz silindi. Güvenlik nedeniyle oturumunuz kapatıldı.');
      await _girise(context);
    } on ApiHata catch (e) {
      if (context.mounted) bilgiGoster(context, 'Hesap silinemedi: ${e.mesaj}', hata: true);
    } catch (_) {
      if (context.mounted) bilgiGoster(context, 'Hesap silinemedi. Lütfen tekrar deneyin.', hata: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Hesap',
      icon: const Icon(Icons.more_vert),
      onSelected: (secim) => switch (secim) {
        'gizlilik' => Navigator.push(
            context, MaterialPageRoute(builder: (_) => YasalDokumanScreen.belge(YasalMetinler.gizlilik))),
        'kullanim' => Navigator.push(
            context, MaterialPageRoute(builder: (_) => YasalDokumanScreen.belge(YasalMetinler.kullanim))),
        'sil' => _sil(context),
        _ => _cikis(context),
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'gizlilik', child: Text('Gizlilik Politikası')),
        PopupMenuItem(value: 'kullanim', child: Text('Kullanım Koşulları')),
        PopupMenuItem(value: 'sil', child: Text('Hesabımı Sil')),
        PopupMenuItem(value: 'cikis', child: Text('Çıkış Yap')),
      ],
    );
  }
}
