import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/dil.dart';
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
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => RolSecimScreen()), (_) => false);
  }

  Future<void> _cikis(BuildContext context) async {
    if (!await onayIste(context, Dil.t.cikisYap, Dil.t.cikisEminMisiniz, evet: Dil.t.cikisYap)) return;
    await BildirimServisi.durdur();
    await AuthService.cikisYap();
    if (context.mounted) await _girise(context);
  }

  Future<void> _sil(BuildContext context) async {
    final onay = await onayIste(
      context,
      Dil.t.hesabiSil,
      Dil.t.isletmeHesapSilAciklama,
      evet: Dil.t.kaliciSil,
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
              ? Dil.t.hesapSilindi
              : Dil.t.verilerSilindiOturum);
      await _girise(context);
    } on ApiHata catch (e) {
      if (context.mounted) bilgiGoster(context, Dil.t.hesapSilinemedi(e.mesaj), hata: true);
    } catch (_) {
      if (context.mounted) bilgiGoster(context, Dil.t.hesapSilinemediTekrar, hata: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: Dil.t.hesap,
      icon: Icon(Icons.more_vert),
      onSelected: (secim) => switch (secim) {
        'gizlilik' => Navigator.push(
            context, MaterialPageRoute(builder: (_) => YasalDokumanScreen.belge(YasalMetinler.gizlilik))),
        'kullanim' => Navigator.push(
            context, MaterialPageRoute(builder: (_) => YasalDokumanScreen.belge(YasalMetinler.kullanim))),
        'sil' => _sil(context),
        _ => _cikis(context),
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'gizlilik', child: Text(Dil.t.gizlilikPolitikasi)),
        PopupMenuItem(value: 'kullanim', child: Text(Dil.t.kullanimKosullari)),
        PopupMenuItem(value: 'sil', child: Text(Dil.t.hesabimiSil)),
        PopupMenuItem(value: 'cikis', child: Text(Dil.t.cikisYap)),
      ],
    );
  }
}
