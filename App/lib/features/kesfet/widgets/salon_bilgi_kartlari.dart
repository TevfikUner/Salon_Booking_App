import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/bolum_basligi.dart';
import 'package:berber_app_ui/data/models/salon.dart';

/// Salon adı, adres ve puan.
class SalonBaslikKarti extends StatelessWidget {
  final Salon salon;
  const SalonBaslikKarti({super.key, required this.salon});

  @override
  Widget build(BuildContext context) {
    return YuzeyKart(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      kenarSaydamlik: 0.2,
      child: Column(children: [
        const Icon(Icons.content_cut, color: AppTheme.gold, size: 40),
        const SizedBox(height: 12),
        Text(salon.ad,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.star, color: AppTheme.gold, size: 16),
          const SizedBox(width: 4),
          Text(salon.puanMetni, style: GoogleFonts.inter(color: AppTheme.gold, fontWeight: FontWeight.w700)),
        ]),
        if ((salon.adres ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(salon.adres!,
              textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ]),
    );
  }
}

/// Bugünkü randevu sayısı, boş kontenjan ve doluluk oranı.
class BugunDurumuKarti extends StatelessWidget {
  final Map<String, dynamic> istatistik;
  const BugunDurumuKarti({super.key, required this.istatistik});

  @override
  Widget build(BuildContext context) {
    final randevu = istatistik['bugunku_randevu'] as int? ?? 0;
    final bos = istatistik['musait_slot_sayisi'] as int? ?? 0;
    final toplam = istatistik['toplam_slot'] as int? ?? 0;
    final oran = toplam > 0 ? (toplam - bos) / toplam : 0.0;
    final dolu = toplam > 0 && bos == 0;
    return YuzeyKart(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        Row(children: [
          Expanded(child: _Sayac(deger: randevu, etiket: 'Bugünkü\nRandevu', renk: AppTheme.gold, ikon: Icons.people_alt_outlined)),
          const SizedBox(width: 12),
          Expanded(
            child: _Sayac(
                deger: bos,
                etiket: 'Boş\nKontenjan',
                renk: dolu ? AppTheme.error : AppTheme.success,
                ikon: Icons.event_available),
          ),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Doluluk', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
          Text('%${(oran * 100).round()}',
              style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: oran,
            minHeight: 8,
            backgroundColor: AppTheme.gold.withValues(alpha: 0.1),
            color: dolu ? AppTheme.error : AppTheme.gold,
          ),
        ),
        if (toplam == 0) ...[
          const SizedBox(height: 8),
          Text('Salon bugün kapalı veya günün saatleri doldu.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ]),
    );
  }
}

class _Sayac extends StatelessWidget {
  final int deger;
  final String etiket;
  final Color renk;
  final IconData ikon;
  const _Sayac({required this.deger, required this.etiket, required this.renk, required this.ikon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: renk.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(ikon, color: renk, size: 26),
        const SizedBox(height: 6),
        Text('$deger', style: GoogleFonts.playfairDisplay(color: renk, fontSize: 26, fontWeight: FontWeight.bold)),
        Text(etiket,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11, height: 1.4)),
      ]),
    );
  }
}

/// Haftanın günleri — salonun gerçek hafta içi / Pazar saatleri ve kapalı günleriyle.
class CalismaSaatleriKarti extends StatelessWidget {
  final Salon salon;
  const CalismaSaatleriKarti({super.key, required this.salon});

  @override
  Widget build(BuildContext context) {
    final bugun = DateTime.now().weekday;
    return YuzeyKart(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.zero,
      kenarSaydamlik: 0.1,
      child: Column(children: [
        for (var g = 1; g <= 7; g++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: g == bugun ? AppTheme.gold.withValues(alpha: 0.08) : null,
            child: Row(children: [
              SizedBox(width: 16, child: g == bugun ? const Icon(Icons.circle, color: AppTheme.gold, size: 8) : null),
              Expanded(
                child: Text(gunAdlari[g],
                    style: GoogleFonts.inter(
                        color: g == bugun ? AppTheme.gold : Colors.white,
                        fontWeight: g == bugun ? FontWeight.bold : FontWeight.normal)),
              ),
              Text(salon.calismaSaati(g) ?? 'Kapalı',
                  style: GoogleFonts.inter(
                      color: salon.calismaSaati(g) == null
                          ? AppTheme.error
                          : (g == bugun ? AppTheme.gold : AppTheme.textSecondary),
                      fontWeight: g == bugun ? FontWeight.bold : FontWeight.normal)),
            ]),
          ),
      ]),
    );
  }
}
