import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/main.dart';

/// Entegrasyon testleri gerçek backend'e karşı koşar (AUTH_MODE=dev, veri: backend/yuk/entegrasyon_veri.py).
/// Kimlik: Firebase hesabı açılmaz; istekler `dev:<uid>` jetonu taşır.
Future<void> hazirla(String uid) async {
  ApiClient.testJetonu = () async => 'dev:$uid';
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
  await initializeDateFormatting('tr_TR', null);
}

/// Önce boş ağaç: global navigatorKey yüzünden Navigator durumuyla taşınır, önceki sayfa yığını üstte kalırdı.
Future<void> uygulamayiAc(WidgetTester tester, Widget ilkEkran) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(BerberApp(ilkEkran: ilkEkran));
  await tester.pump();
}

/// Ağ yanıtı beklenen yerlerde: bulucu görünene kadar kare kare ilerler (pumpAndSettle,
/// dönen yükleme göstergesi yüzünden hiç durulmaz).
Future<void> bekle(WidgetTester tester, Finder bulucu, {Duration sure = const Duration(seconds: 25)}) async {
  final son = DateTime.now().add(sure);
  while (DateTime.now().isBefore(son)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (bulucu.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Süre doldu, bulunamadı: $bulucu');
}

Future<void> dokun(WidgetTester tester, Finder bulucu) async {
  await bekle(tester, bulucu);
  await tester.ensureVisible(bulucu.first);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(bulucu.first);
  await tester.pump(const Duration(milliseconds: 500));
}

/// Anahtarı verilen önekle başlayan widget'lar (ör. 'hizmet_' → hizmet kartları).
Finder anahtarOneki(String onek) =>
    find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key as ValueKey<String>).value.startsWith(onek));
