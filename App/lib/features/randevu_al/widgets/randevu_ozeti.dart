import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/bolum_basligi.dart';

/// Etiket–değer satırlarından oluşan randevu özeti kartı + altta toplam tutar.
/// Hem onay öncesi (adım 5) hem onay sonrası ekranda kullanılır. İndirim varsa liste fiyatı üstü çizili,
/// indirim açıklamasıyla birlikte toplamdan önce gösterilir.
class RandevuOzeti extends StatelessWidget {
  final List<(IconData, String, String)> satirlar;
  final num toplam;
  final num indirim;
  final String? indirimAciklama;
  const RandevuOzeti(
      {super.key, required this.satirlar, required this.toplam, this.indirim = 0, this.indirimAciklama});

  @override
  Widget build(BuildContext context) {
    return YuzeyKart(
      kenarSaydamlik: 0.2,
      child: Column(children: [
        for (final (ikon, etiket, deger) in satirlar)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(ikon, color: AppTheme.gold, size: 16),
              const SizedBox(width: 10),
              Text('$etiket: ', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
              Expanded(
                child: Text(deger,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ]),
          ),
        Divider(color: AppTheme.gold.withValues(alpha: 0.15), height: 20),
        if (indirim > 0) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Liste fiyatı', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
            Text(tl(toplam + indirim),
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 13, decoration: TextDecoration.lineThrough)),
          ]),
          const SizedBox(height: 4),
          Row(key: const ValueKey('ozet_indirim'), crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.local_offer_outlined, color: AppTheme.gold, size: 15),
            const SizedBox(width: 6),
            Expanded(
              child: Text(indirimAciklama ?? 'İndirim',
                  style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            Text('−${tl(indirim)}',
                style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
        ],
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Toplam', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          Text(tl(toplam),
              style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 22, fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }
}
