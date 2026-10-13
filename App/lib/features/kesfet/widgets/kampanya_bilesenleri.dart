import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/bolum_basligi.dart';
import 'package:berber_app_ui/data/models/salon.dart';

/// Küçük altın zeminli indirim rozeti: "%20" / "20%" (salon kartı, hizmet, saat, takvim).
class IndirimRozeti extends StatelessWidget {
  final int yuzde;
  final String? onEk; // verilirse rozetin tüm metni (ör. "%20'ye varan indirim"), yoksa yalnızca yüzde
  final double yaziBoyu;
  const IndirimRozeti({super.key, required this.yuzde, this.onEk, this.yaziBoyu = 11});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(6)),
      child: Text(onEk ?? Dil.t.yuzde(yuzde),
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
        Text(Dil.t.indirimOnaydaYansir,
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
        Text(Dil.t.sadakatKurali(kart.esik, kart.yuzde),
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 10),
        Semantics(
          label: ziyaret == null ? null : Dil.t.sadakatDamga(kart.esik, ziyaret),
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
              ? Dil.t.sadakatGirisYap
              : kart.siradakiIndirimli
                  ? Dil.t.sadakatSiradaki(kart.yuzde)
                  : Dil.t.sadakatKalan(kart.esik - ziyaret - 1),
          style: GoogleFonts.inter(
              color: kart.siradakiIndirimli ? AppTheme.gold : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: kart.siradakiIndirimli ? FontWeight.w700 : FontWeight.w400),
        ),
      ]),
    );
  }
}
