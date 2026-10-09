import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';

/// Güven skoru rozeti (Güvenilir / Dikkat / Riskli / Yeni)
class GuvenRozeti extends StatelessWidget {
  final Map<String, dynamic> guven;
  const GuvenRozeti({super.key, required this.guven});

  @override
  Widget build(BuildContext context) {
    final etiket = guven['etiket'] as String? ?? 'Yeni';
    final renk = switch (etiket) {
      'Güvenilir' => AppTheme.success,
      'Dikkat' => Colors.orange,
      'Riskli' => AppTheme.error,
      _ => Colors.lightBlueAccent,
    };
    final skor = guven['skor'];
    final aciklama = etiket == 'Yeni'
        ? 'İlk ziyaret — geçmiş kaydı yok'
        : '${guven['tamamlanan']} tamamlanan · ${guven['gelmedi']} gelmedi · ${guven['gec_iptal']} geç iptal';
    return Tooltip(
      message: aciklama,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: renk.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: renk.withValues(alpha: 0.5)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(etiket == 'Riskli' ? Icons.warning_amber_rounded : Icons.verified_user_outlined, size: 12, color: renk),
          const SizedBox(width: 4),
          Text(skor == null ? etiket : '$etiket · $skor',
              style: GoogleFonts.inter(color: renk, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
