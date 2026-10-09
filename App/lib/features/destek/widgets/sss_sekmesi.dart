import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/data/sabit/sss_data.dart';

/// Sıkça sorulan sorular (açılır liste).
class SssSekmesi extends StatelessWidget {
  const SssSekmesi({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: SSS.sorular.length,
      itemBuilder: (_, i) {
        final s = SSS.sorular[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.1)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              iconColor: AppTheme.gold,
              collapsedIconColor: AppTheme.textSecondary,
              title: Text(s.soru, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              children: [
                Text(s.cevap, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        );
      },
    );
  }
}
