import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/bolum_basligi.dart';
import 'package:berber_app_ui/data/models/salon.dart';

/// Küçük altın zeminli indirim rozeti: "%20" (salon kartı, hizmet, saat, takvim).
class IndirimRozeti extends StatelessWidget {
  final int yuzde;
  final String? onEk; // yüzdeye bitişik ek: "'ye varan indirim" → "%20'ye varan indirim"
  final double yaziBoyu;
  const IndirimRozeti({super.key, required this.yuzde, this.onEk, this.yaziBoyu = 11});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(6)),
      child: Text('%$yuzde${onEk ?? ''}',
          style: GoogleFonts.inter(color: AppTheme.black, fontSize: yaziBoyu, fontWeight: FontWeight.bold)),
    );
  }
}

/// Salon detayında aktif kampanyalar: ad, yüzde ve koşul ("Salı · 10:00–14:00 · Saç Kesimi").
class KampanyalarKarti extends StatelessWidget {
  final List<Kampanya> kampanyalar;
  const KampanyalarKarti({super.key, required this.kampanyalar});

  @override
  Widget build(BuildContext context) {
    return YuzeyKart(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      kenarSaydamlik: 0.3,
      child: Column(children: [
        for (final (i, k) in kampanyalar.indexed) ...[
          if (i > 0) Divider(color: AppTheme.gold.withValues(alpha: 0.12), height: 18),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IndirimRozeti(yuzde: k.yuzde, yaziBoyu: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(k.ad, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(k.kosul, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
              ]),
            ),
          ]),
        ],
        const SizedBox(height: 10),
        Text('İndirim, uygun gün ve saati seçtiğinizde onay ekranında tutara yansır.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
      ]),
    );
  }
}

/// Sadakat kartı: her N. ziyarette indirim; oturum varsa doldurulmuş damgalarla.
class SadakatKartiWidget extends StatelessWidget {
  final SadakatKarti kart;
  const SadakatKartiWidget({super.key, required this.kart});

  @override
  Widget build(BuildContext context) {
    final ziyaret = kart.ziyaret;
    return YuzeyKart(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      kenarSaydamlik: 0.3,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Her ${kart.esik}. ziyaretiniz %${kart.yuzde} indirimli',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 10),
        Semantics(
          label: ziyaret == null ? null : '${kart.esik} ziyaretten $ziyaret tanesi tamam',
          child: Wrap(spacing: 6, runSpacing: 6, children: [
            for (var i = 1; i <= kart.esik; i++)
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ziyaret != null && i <= ziyaret ? AppTheme.goldGradient : null,
                  border: Border.all(color: AppTheme.gold.withValues(alpha: i == kart.esik ? 1 : 0.4)),
                ),
                child: Icon(i == kart.esik ? Icons.card_giftcard : Icons.content_cut,
                    size: 13,
                    color: ziyaret != null && i <= ziyaret ? AppTheme.black : AppTheme.gold.withValues(alpha: 0.7)),
              ),
          ]),
        ),
        const SizedBox(height: 10),
        Text(
          ziyaret == null
              ? 'Giriş yaptığınızda ziyaretleriniz burada sayılır.'
              : kart.siradakiIndirimli
                  ? 'Sıradaki randevunuz %${kart.yuzde} indirimli! 🎉'
                  : '${kart.esik - ziyaret - 1} ziyaret sonra indirim kazanırsınız.',
          style: GoogleFonts.inter(
              color: kart.siradakiIndirimli ? AppTheme.gold : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: kart.siradakiIndirimli ? FontWeight.w700 : FontWeight.w400),
        ),
      ]),
    );
  }
}
