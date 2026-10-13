import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';

/// Ortalama puan, toplam değerlendirme ve 5→1 yıldız dağılım çubukları.
class PuanOzetKarti extends StatelessWidget {
  final Map<String, dynamic> veri;
  const PuanOzetKarti({super.key, required this.veri});

  @override
  Widget build(BuildContext context) {
    final ortalama = (veri['ortalama_puan'] as num?)?.toDouble() ?? 0;
    final toplam = veri['toplam'] as int? ?? 0;
    final dagilim = Map<String, dynamic>.from(veri['dagilim'] ?? const {});
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.12)),
      ),
      child: Row(children: [
        Column(children: [
          Text(ortalama.toStringAsFixed(1),
              style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 36, fontWeight: FontWeight.bold)),
          Yildizlar(puan: ortalama.round()),
          const SizedBox(height: 4),
          Text(Dil.t.degerlendirmeSayisi(toplam), style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
        ]),
        const SizedBox(width: 20),
        Expanded(
          child: Column(children: [
            for (var p = 5; p >= 1; p--)
              _DagilimSatiri(yildiz: p, oran: toplam == 0 ? 0 : (dagilim['$p'] as int? ?? 0) / toplam),
          ]),
        ),
      ]),
    );
  }
}

class _DagilimSatiri extends StatelessWidget {
  final int yildiz;
  final double oran;
  const _DagilimSatiri({required this.yildiz, required this.oran});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(width: 14, child: Text('$yildiz', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: oran,
              minHeight: 6,
              backgroundColor: AppTheme.card,
              valueColor: const AlwaysStoppedAnimation(AppTheme.gold),
            ),
          ),
        ),
      ]),
    );
  }
}

class Yildizlar extends StatelessWidget {
  final int puan;
  final double boyut;
  const Yildizlar({super.key, required this.puan, this.boyut = 14});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: Dil.t.yildizSemantik(puan),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 1; i <= 5; i++)
          Icon(i <= puan ? Icons.star : Icons.star_border, color: AppTheme.gold, size: boyut),
      ]),
    );
  }
}

/// Tek değerlendirme: kısaltılmış ad, yıldız, tarih, berber ve (varsa) yorum metni.
class YorumKarti extends StatelessWidget {
  final Map<String, dynamic> yorum;
  const YorumKarti({super.key, required this.yorum});

  @override
  Widget build(BuildContext context) {
    final metin = (yorum['yorum'] as String?)?.trim() ?? '';
    final berber = yorum['berber'] as String? ?? '';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(yorum['musteri'] ?? Dil.t.anonim,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          Yildizlar(puan: yorum['puan'] as int? ?? 0, boyut: 13),
        ]),
        const SizedBox(height: 2),
        Text([
          if ((yorum['tarih'] as String?)?.isNotEmpty ?? false) tarihUzun(yorum['tarih'], yil: true),
          if (berber.isNotEmpty) berber,
        ].join(' · '), style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
        if (metin.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(metin, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4)),
        ],
      ]),
    );
  }
}
