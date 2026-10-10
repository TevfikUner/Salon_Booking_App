import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:berber_app_ui/data/api/panel_api.dart';
import 'package:berber_app_ui/features/isletme/isletme_panel_screen.dart';

import 'yardimci.dart';

/// İşletme akışı: giriş → Bugünün Akışı → saati gelmiş randevuyu "Tamamlandı" işaretle.
///
///   bash backend/yuk/yigin.sh entegrasyon
///   flutter test integration_test/isletme_akisi_test.dart --dart-define=API_URL=http://10.0.2.2:8020
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('işletme: bugünün randevuları → tamamlandı', (tester) async {
    await hazirla('entegrasyon-isletme');
    final once = await PanelApi.akis();
    final hedef = (once['randevular'] as List).cast<Map<String, dynamic>>().firstWhere(
      (r) => r['durum'] == 'onaylandi',
    );

    await uygulamayiAc(tester, const IsletmePanelScreen(salonAd: 'Entegrasyon Salonu'));
    await dokun(tester, find.text('Tamamlandı'));

    // Sunucu durumu: randevu tamamlandı
    final son = DateTime.now().add(const Duration(seconds: 15));
    String? durum;
    while (DateTime.now().isBefore(son)) {
      await tester.pump(const Duration(milliseconds: 300));
      final akis = await PanelApi.akis();
      durum =
          (akis['randevular'] as List).cast<Map<String, dynamic>>().firstWhere((r) => r['id'] == hedef['id'])['durum']
              as String?;
      if (durum == 'tamamlandi') break;
    }
    expect(durum, 'tamamlandi');
  });
}
