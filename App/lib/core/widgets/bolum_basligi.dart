import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';

/// Altın çizgili bölüm başlığı (ana sayfa, salon detayı vb.).
class BolumBasligi extends StatelessWidget {
  final String baslik;
  final IconData ikon;
  final Widget? sag;
  final EdgeInsets padding;

  const BolumBasligi({
    super.key,
    required this.baslik,
    required this.ikon,
    this.sag,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 10),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Icon(ikon, color: AppTheme.gold, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(baslik,
              style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ?sag,
      ]),
    );
  }
}

/// Alt sayfaların (bottom sheet) üstündeki tutamak çizgisi.
class SheetTutamagi extends StatelessWidget {
  const SheetTutamagi({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.textSecondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Kenarlıklı yüzey kartı — ekranlarda tekrarlanan Container+BoxDecoration kalıbı.
class YuzeyKart extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double kenarSaydamlik;

  const YuzeyKart({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.kenarSaydamlik = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: kenarSaydamlik)),
      ),
      child: child,
    );
  }
}
