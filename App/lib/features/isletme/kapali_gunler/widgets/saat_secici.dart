import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';

/// 24 saat biçimli saat seçici; "HH:MM" döner (vazgeçilirse null).
Future<String?> saatSec(BuildContext context, {required String baslik, String? ilk}) async {
  final parca = (ilk ?? '').split(':');
  final t = await showTimePicker(
    context: context,
    helpText: baslik,
    initialTime: parca.length == 2
        ? TimeOfDay(hour: int.tryParse(parca[0]) ?? 12, minute: int.tryParse(parca[1]) ?? 0)
        : const TimeOfDay(hour: 12, minute: 0),
    builder: (ctx, child) =>
        MediaQuery(data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true), child: child!),
  );
  if (t == null) return null;
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

/// Başlangıç ve bitiş saatini art arda sorar. Vazgeçilirse null; bitiş başlangıçtan önceyse uyarı gösterip null.
Future<(String, String)?> saatAraligiSec(BuildContext context, {String? bas, String? bit}) async {
  final b = await saatSec(context, baslik: Dil.t.baslangicSaati, ilk: bas);
  if (b == null || !context.mounted) return null;
  final e = await saatSec(context, baslik: Dil.t.bitisSaati, ilk: bit ?? b);
  if (e == null) return null;
  if (e.compareTo(b) <= 0) {
    if (context.mounted) bilgiGoster(context, Dil.t.bitisSonraOlmali, hata: true);
    return null;
  }
  return (b, e);
}
