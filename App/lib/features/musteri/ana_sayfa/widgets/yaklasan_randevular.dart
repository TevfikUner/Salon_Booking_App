import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/data/models/randevu.dart';

/// Yatay kaydırılan yaklaşan randevu kartları.
class YaklasanRandevular extends StatelessWidget {
  final List<Randevu> randevular;
  final VoidCallback? onTap;
  const YaklasanRandevular({super.key, required this.randevular, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: randevular.length,
        itemBuilder: (_, i) => _Kart(randevu: randevular[i], onTap: onTap),
      ),
    );
  }
}

class _Kart extends StatelessWidget {
  final Randevu randevu;
  final VoidCallback? onTap;
  const _Kart({required this.randevu, this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = randevu;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(r.saat, style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(tarihGoreli(r.tarih),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 10),
          Text(r.berber, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          if (r.salonAd.isNotEmpty)
            Text(r.salonAd, style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 11)),
          const Spacer(),
          Text(r.hizmetler.join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
        ]),
      ),
    );
  }
}
