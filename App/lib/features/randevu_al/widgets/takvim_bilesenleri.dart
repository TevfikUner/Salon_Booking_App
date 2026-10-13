import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';

/// Az yer kaldı uyarısının eşiği (gün içindeki boş başlangıç saati sayısı)
const azYerEsigi = 2;

/// Seçilen gün dolu veya az yerliyse kullanıcıyı saat adımından önce bilgilendirir.
class GunDolulukBilgisi extends StatelessWidget {
  /// O gündeki boş başlangıç sayısı; bilinmiyorsa null (berber seçilmemiş)
  final int? bos;
  const GunDolulukBilgisi({super.key, required this.bos});

  @override
  Widget build(BuildContext context) {
    final b = bos;
    if (b == null || b > azYerEsigi) return const SizedBox.shrink();
    final dolu = b == 0;
    final renk = dolu ? AppTheme.error : Colors.orange;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(dolu ? Icons.event_busy : Icons.hourglass_bottom, color: renk, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            dolu
                ? Dil.t.gunDoluAciklama
                : Dil.t.azYerKaldi(b),
            style: GoogleFonts.inter(color: renk, fontSize: 12),
          ),
        ),
      ]),
    );
  }
}

/// Takvim işaretlerinin açıklaması. [doluluk]: berber seçiliyse az yer/dolu da gösterilir.
class TakvimLejanti extends StatelessWidget {
  final bool doluluk;

  /// Kampanyalı gün işareti ("%") açıklaması gösterilsin mi
  final bool kampanya;
  const TakvimLejanti({super.key, required this.doluluk, this.kampanya = false});

  @override
  Widget build(BuildContext context) {
    return Wrap(alignment: WrapAlignment.center, spacing: 14, runSpacing: 6, children: [
      _Oge(renk: AppTheme.gold, etiket: Dil.t.musait),
      if (doluluk) ...[
        _Oge(renk: Colors.orange, etiket: Dil.t.azYer),
        _Oge(renk: AppTheme.error, etiket: Dil.t.dolu),
      ],
      _Oge(renk: Colors.white.withValues(alpha: 0.18), etiket: Dil.t.kapali),
      if (kampanya)
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text('%', style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Text(Dil.t.kampanyali, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
        ]),
    ]);
  }
}

class _Oge extends StatelessWidget {
  final Color renk;
  final String etiket;
  const _Oge({required this.renk, required this.etiket});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: renk, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(etiket, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
    ]);
  }
}
