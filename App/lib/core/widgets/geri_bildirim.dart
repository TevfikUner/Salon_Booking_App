import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';

/// Kısa bilgi/hata mesajı (SnackBar).
void bilgiGoster(BuildContext context, String mesaj, {bool hata = false, Duration? sure}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(mesaj),
      backgroundColor: hata ? AppTheme.error : AppTheme.success,
      duration: sure ?? const Duration(seconds: 4),
    ));
}

/// Evet/Hayır onayı. Kullanıcı onaylarsa true.
Future<bool> onayIste(BuildContext context, String baslik, String mesaj,
    {String? evet, bool tehlikeli = false}) async {
  final sonuc = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(baslik, style: GoogleFonts.playfairDisplay(color: tehlikeli ? AppTheme.error : AppTheme.gold)),
      content: Text(mesaj, style: const TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(Dil.t.vazgec, style: const TextStyle(color: AppTheme.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(evet ?? Dil.t.evet,
              style: TextStyle(color: tehlikeli ? AppTheme.error : AppTheme.gold, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
  return sonuc == true;
}
