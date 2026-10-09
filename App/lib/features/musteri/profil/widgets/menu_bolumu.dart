import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';

/// Başlıklı profil bölümü kartı.
class MenuBolumu extends StatelessWidget {
  final String baslik;
  final IconData ikon;
  final List<Widget> children;
  final Widget? sag;

  const MenuBolumu({super.key, required this.baslik, required this.ikon, required this.children, this.sag});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(ikon, color: AppTheme.gold, size: 18),
          const SizedBox(width: 8),
          Text(baslik, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          ?sag,
        ]),
        const SizedBox(height: 8),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) Divider(color: AppTheme.gold.withValues(alpha: 0.06), height: 1),
          children[i],
        ],
      ]),
    );
  }
}

/// Bölüm içindeki dokunulabilir satır.
class MenuSatiri extends StatelessWidget {
  final IconData ikon;
  final String etiket;
  final VoidCallback onTap;
  final Color? renk;

  const MenuSatiri({super.key, required this.ikon, required this.etiket, required this.onTap, this.renk});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        child: Row(children: [
          Icon(ikon, color: renk ?? AppTheme.textSecondary, size: 20),
          const SizedBox(width: 14),
          Expanded(child: Text(etiket, style: GoogleFonts.inter(color: renk ?? Colors.white, fontSize: 14))),
          Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary.withValues(alpha: 0.4), size: 14),
        ]),
      ),
    );
  }
}
