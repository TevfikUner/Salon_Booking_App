import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/data/models/salon.dart';

/// Keşfet listesindeki salon satırı.
class SalonKarti extends StatelessWidget {
  final Salon salon;
  final VoidCallback onTap;
  const SalonKarti({super.key, required this.salon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bugunSaat = salon.calismaSaati(DateTime.now().weekday);
    return Semantics(
      button: true,
      label: '${salon.ad}, ${salon.konumMetni}, puan ${salon.puan.toStringAsFixed(1)}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.12)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.content_cut, color: AppTheme.gold, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(salon.ad,
                    style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                if (salon.konumMetni.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _Satir(ikon: Icons.location_on_outlined, metin: salon.konumMetni),
                ],
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  _Etiket(ikon: Icons.star, metin: salon.puan.toStringAsFixed(1)),
                  if (salon.mesafeKm != null) _Etiket(ikon: Icons.near_me, metin: mesafeMetni(salon.mesafeKm!)),
                  _Satir(ikon: Icons.access_time, metin: bugunSaat == null ? 'Bugün kapalı' : 'Bugün $bugunSaat'),
                ]),
              ]),
            ),
            Icon(Icons.arrow_forward_ios, color: AppTheme.gold.withValues(alpha: 0.4), size: 16),
          ]),
        ),
      ),
    );
  }
}

class _Etiket extends StatelessWidget {
  final IconData ikon;
  final String metin;
  const _Etiket({required this.ikon, required this.metin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(ikon, color: AppTheme.gold, size: 13),
        const SizedBox(width: 3),
        Text(metin, style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _Satir extends StatelessWidget {
  final IconData ikon;
  final String metin;
  const _Satir({required this.ikon, required this.metin});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(ikon, color: AppTheme.textSecondary, size: 13),
      const SizedBox(width: 3),
      Flexible(
        child: Text(metin,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
      ),
    ]);
  }
}
