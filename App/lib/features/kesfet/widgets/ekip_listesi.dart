import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/config.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/data/models/berber.dart';

/// Salonun personeli: favori kalbi ve "bu berberle randevu al".
class EkipListesi extends StatelessWidget {
  final List<Berber> berberler;
  final ValueChanged<Berber> onFavori;
  final ValueChanged<Berber> onRandevu;

  const EkipListesi({super.key, required this.berberler, required this.onFavori, required this.onRandevu});

  @override
  Widget build(BuildContext context) {
    return Column(children: [for (final b in berberler) _BerberSatiri(berber: b, onFavori: onFavori, onRandevu: onRandevu)]);
  }
}

class _BerberSatiri extends StatelessWidget {
  final Berber berber;
  final ValueChanged<Berber> onFavori;
  final ValueChanged<Berber> onRandevu;

  const _BerberSatiri({required this.berber, required this.onFavori, required this.onRandevu});

  @override
  Widget build(BuildContext context) {
    final b = berber;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.1)),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppTheme.gold.withValues(alpha: 0.1),
          child: b.fotoUrl == null
              ? const Icon(Icons.person, color: AppTheme.gold)
              : ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: AppConfig.medyaUrl(b.fotoUrl!),
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const Icon(Icons.person, color: AppTheme.gold),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.tamAd, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
            Text(
                [
                  if (b.uzmanlik.isNotEmpty) b.uzmanlik,
                  b.degerlendirmeSayisi > 0
                      ? '★ ${b.puan.toStringAsFixed(1)} (${b.degerlendirmeSayisi})'
                      : Dil.t.yeni,
                  if (b.tamamlanan > 0) Dil.t.trasSayisi(b.tamamlanan),
                ].join(' · '),
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ),
        IconButton(
          tooltip: b.favori ? Dil.t.favorilerdenCikar : Dil.t.favorilereEkle,
          onPressed: () => onFavori(b),
          icon: Icon(b.favori ? Icons.favorite : Icons.favorite_border,
              color: b.favori ? Colors.redAccent : AppTheme.textSecondary),
        ),
        TextButton(onPressed: () => onRandevu(b), child: Text(Dil.t.randevu)),
      ]),
    );
  }
}
