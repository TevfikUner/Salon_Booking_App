import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/data/models/berber.dart';

/// Favori berberler yatay şeridi; boşsa Keşfet'e yönlendiren kart.
class FavoriBerberSeridi extends StatelessWidget {
  final List<Berber> favoriler;
  final ValueChanged<Berber> onSec;
  final VoidCallback onKesfet;

  const FavoriBerberSeridi({super.key, required this.favoriler, required this.onSec, required this.onKesfet});

  @override
  Widget build(BuildContext context) {
    if (favoriler.isEmpty) return _BosKart(onTap: onKesfet);
    return SizedBox(
      height: 112,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: favoriler.length,
        itemBuilder: (_, i) => _Cip(berber: favoriler[i], onTap: () => onSec(favoriler[i])),
      ),
    );
  }
}

class _Cip extends StatelessWidget {
  final Berber berber;
  final VoidCallback onTap;
  const _Cip({required this.berber, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.gold.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppTheme.gold, size: 22),
          ),
          const SizedBox(height: 8),
          Text(berber.tamAd,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(berber.salonAd ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 10)),
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.star, color: AppTheme.gold, size: 12),
            const SizedBox(width: 2),
            Text(berber.puan.toStringAsFixed(1),
                style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.bold)),
          ]),
        ]),
      ),
    );
  }
}

class _BosKart extends StatelessWidget {
  final VoidCallback onTap;
  const _BosKart({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.1)),
          ),
          child: Row(children: [
            Icon(Icons.favorite_border, color: AppTheme.gold.withValues(alpha: 0.6)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(Dil.t.favoriYok,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(Dil.t.favoriNasil,
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
              ]),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.gold, size: 16),
          ]),
        ),
      ),
    );
  }
}
