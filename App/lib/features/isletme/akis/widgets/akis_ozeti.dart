import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';

/// Günün özet kartları: randevu sayısı, toplam süre, beklenen ciro, riskli müşteri.
class AkisOzetKartlari extends StatelessWidget {
  final Map<String, dynamic> ozet;
  const AkisOzetKartlari({super.key, required this.ozet});

  @override
  Widget build(BuildContext context) {
    final riskli = ozet['riskli_sayisi'] as int? ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        _Kart(deger: '${ozet['randevu_sayisi']}', etiket: Dil.t.randevuSayisiEtiket, ikon: Icons.event_note),
        _Kart(deger: sureMetni(ozet['toplam_sure_dk'] as int? ?? 0), etiket: Dil.t.toplamSure, ikon: Icons.timer_outlined),
        _Kart(deger: tl(ozet['beklenen_ciro'] as num? ?? 0), etiket: Dil.t.beklenenCiro, ikon: Icons.payments_outlined),
        _Kart(
            deger: '$riskli',
            etiket: Dil.t.riskli,
            ikon: Icons.warning_amber_rounded,
            renk: riskli > 0 ? AppTheme.error : AppTheme.textSecondary),
      ]),
    );
  }
}

class _Kart extends StatelessWidget {
  final String deger;
  final String etiket;
  final IconData ikon;
  final Color renk;
  const _Kart({required this.deger, required this.etiket, required this.ikon, this.renk = AppTheme.gold});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: renk.withValues(alpha: 0.25)),
        ),
        child: Column(children: [
          Icon(ikon, color: renk, size: 18),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(deger, style: GoogleFonts.playfairDisplay(color: renk, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Text(etiket, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 10)),
        ]),
      ),
    );
  }
}

/// "SIRADAKİ" vurgu kartı.
class SiradakiKarti extends StatelessWidget {
  final Map<String, dynamic> randevu;
  const SiradakiKarti({super.key, required this.randevu});

  @override
  Widget build(BuildContext context) {
    final r = randevu;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.gold.withValues(alpha: 0.22), AppTheme.surface]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
      ),
      child: Row(children: [
        const Icon(Icons.play_circle_fill, color: AppTheme.gold, size: 30),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(Dil.t.siradaki,
                style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
            Text('${r['saat']} · ${r['musteri']['ad']}',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${(r['hizmetler'] as List).map((h) => h['ad']).join(', ')} · ${r['berber']['ad']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }
}

/// Personel başına kalan boş saat çipleri.
class DolulukCipleri extends StatelessWidget {
  final List<Map<String, dynamic>> doluluk;
  const DolulukCipleri({super.key, required this.doluluk});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 6, children: [
      for (final b in doluluk)
        Chip(
          backgroundColor: AppTheme.surface,
          side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.15)),
          avatar: const Icon(Icons.person, size: 16, color: AppTheme.gold),
          label: Text(b['kapali_neden'] != null ? '${b['ad']}: ${Dil.t.kapaliKucuk}' : '${b['ad']}: ${Dil.t.bosSaatSayisi(b['bos_slot'] as int)}',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 12)),
        ),
    ]);
  }
}
