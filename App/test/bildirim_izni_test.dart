import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:berber_app_ui/features/randevu_al/widgets/bildirim_izni_karti.dart';
import 'package:berber_app_ui/services/bildirim_servisi.dart';

/// Randevu onayındaki bildirim izni kartı: ne zaman görünür, "Şimdi değil" kalıcı mı, red durumu.
void main() {
  Future<void> ciz(WidgetTester t, BildirimIzni? durum, {bool izinSonucu = true, List<int>? istekSayaci}) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BildirimIzniKarti(
          durumGetir: () async => durum,
          izinIste: () async {
            istekSayaci?.add(1);
            return izinSonucu;
          },
        ),
      ),
    ));
    await t.pumpAndSettle();
  }

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('sorulmamışsa görünür; izin verilince kaybolur', (t) async {
    final istek = <int>[];
    await ciz(t, BildirimIzni.sorulmadi, istekSayaci: istek);
    expect(find.text('Randevunuza 1 saat kala hatırlatalım mı?'), findsOneWidget);
    await t.tap(find.text('Evet, hatırlat'));
    await t.pumpAndSettle();
    expect(istek, [1]);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('izin reddedilirse ayarlardan açma yolu gösterilir', (t) async {
    await ciz(t, BildirimIzni.sorulmadi, izinSonucu: false);
    await t.tap(find.text('Evet, hatırlat'));
    await t.pumpAndSettle();
    expect(find.text('Bildirimler kapalı'), findsOneWidget);
    expect(find.textContaining('Telefon Ayarları'), findsOneWidget);
  });

  testWidgets('"Şimdi değil" kalıcıdır: bir daha gösterilmez', (t) async {
    await ciz(t, BildirimIzni.sorulmadi);
    await t.tap(find.text('Şimdi değil'));
    await t.pumpAndSettle();
    expect(find.byType(Text), findsNothing);
    expect((await SharedPreferences.getInstance()).getBool(bildirimIzniErtelendiAnahtari), isTrue);
    await t.pumpWidget(const SizedBox());
    await ciz(t, BildirimIzni.sorulmadi);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('izin verilmişse veya durum bilinmiyorsa görünmez', (t) async {
    await ciz(t, BildirimIzni.verildi);
    expect(find.byType(Text), findsNothing);
    await t.pumpWidget(const SizedBox());
    await ciz(t, null);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('360 dp ve 1,3× yazıda taşmaz', (t) async {
    t.view.devicePixelRatio = 3;
    t.view.physicalSize = const Size(360 * 3, 690 * 3);
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      builder: (c, child) =>
          MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.3)), child: child!),
      home: Scaffold(
        body: ListView(padding: const EdgeInsets.all(16), children: [
          BildirimIzniKarti(durumGetir: () async => BildirimIzni.sorulmadi, izinIste: () async => true),
          BildirimIzniKarti(durumGetir: () async => BildirimIzni.reddedildi, izinIste: () async => false),
        ]),
      ),
    ));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.text('Bildirimler kapalı'), findsOneWidget);
  });
}
