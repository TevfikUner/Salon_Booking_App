import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/bolum_basligi.dart';
import 'package:berber_app_ui/data/models/berber.dart';

/// "Randevu Al" seçimi: favori berberlerden biri ya da yeni salon keşfi. Sayfa kapatılırsa null.
sealed class RandevuBaslatSecim {}

class FavoriSecildi extends RandevuBaslatSecim {
  final Berber berber;
  FavoriSecildi(this.berber);
}

class KesfetSecildi extends RandevuBaslatSecim {}

Future<RandevuBaslatSecim?> randevuBaslatSor(BuildContext context, List<Berber> favoriler) {
  return showModalBottomSheet<RandevuBaslatSecim>(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SheetTutamagi(),
          Text('Randevu Al',
              style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Nasıl devam etmek istersiniz?', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          for (final b in favoriler.take(3))
            _Secenek(
              ikon: Icons.person,
              baslik: b.tamAd,
              alt: b.salonAd ?? '',
              vurgulu: true,
              onTap: () => Navigator.pop(ctx, FavoriSecildi(b)),
            ),
          _Secenek(
            ikon: Icons.explore,
            baslik: 'Yeni Bir Salon Keşfet',
            alt: 'Farklı salonları keşfet',
            onTap: () => Navigator.pop(ctx, KesfetSecildi()),
          ),
        ]),
      ),
    ),
  );
}

class _Secenek extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String alt;
  final bool vurgulu;
  final VoidCallback onTap;

  const _Secenek({required this.ikon, required this.baslik, required this.alt, required this.onTap, this.vurgulu = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: vurgulu ? AppTheme.gold.withValues(alpha: 0.06) : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.gold.withValues(alpha: vurgulu ? 0.15 : 0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: AppTheme.gold.withValues(alpha: 0.12), child: Icon(ikon, color: AppTheme.gold)),
        title: Text(baslik, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(alt, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.gold, size: 16),
      ),
    );
  }
}
