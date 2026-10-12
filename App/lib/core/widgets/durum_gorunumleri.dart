import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';

/// Ortalanmış yükleme göstergesi.
class Yukleniyor extends StatelessWidget {
  const Yukleniyor({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator(color: AppTheme.gold));
}

/// Yükleme hatası + yeniden dene.
class HataGorunumu extends StatelessWidget {
  final String mesaj;
  final VoidCallback onTekrar;
  const HataGorunumu({super.key, required this.mesaj, required this.onTekrar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off, color: AppTheme.error, size: 48),
          const SizedBox(height: 12),
          Text(mesaj, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onTekrar,
            icon: const Icon(Icons.refresh),
            label: Text(Dil.t.yenidenDene),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          ),
        ]),
      ),
    );
  }
}

/// Boş liste durumu.
class BosGorunum extends StatelessWidget {
  final IconData ikon;
  final String mesaj;
  final String? altMesaj;
  const BosGorunum({super.key, required this.ikon, required this.mesaj, this.altMesaj});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(ikon, color: AppTheme.gold.withValues(alpha: 0.35), size: 56),
          const SizedBox(height: 12),
          Text(mesaj,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14, height: 1.4)),
          if (altMesaj != null) ...[
            const SizedBox(height: 6),
            Text(altMesaj!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppTheme.textSecondary.withValues(alpha: 0.6), fontSize: 12)),
          ],
        ]),
      ),
    );
  }
}

/// Yükleniyor / hata / içerik üçlüsünü tek yerde toplar.
class AsenkronGorunum extends StatelessWidget {
  final bool yukleniyor;
  final String? hata;
  final VoidCallback onTekrar;
  final WidgetBuilder builder;

  const AsenkronGorunum({
    super.key,
    required this.yukleniyor,
    required this.hata,
    required this.onTekrar,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (yukleniyor) return const Yukleniyor();
    if (hata != null) return HataGorunumu(mesaj: hata!, onTekrar: onTekrar);
    return builder(context);
  }
}
