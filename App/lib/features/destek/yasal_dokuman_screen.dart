import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';

/// Yasal dokümanları uygulama içinden gösteren ekran
class YasalDokumanScreen extends StatelessWidget {
  final String baslik;
  final String icerik;

  const YasalDokumanScreen({super.key, required this.baslik, required this.icerik});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: AppTheme.black,
        leading: const BackButton(color: AppTheme.gold),
        title: Text(baslik,
            style: GoogleFonts.playfairDisplay(
                color: AppTheme.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          icerik,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 14,
            height: 1.7,
          ),
        ),
      ),
    );
  }

}
