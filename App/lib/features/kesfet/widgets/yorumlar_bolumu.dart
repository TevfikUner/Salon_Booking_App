import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/features/kesfet/widgets/yorum_bilesenleri.dart';
import 'package:berber_app_ui/features/kesfet/yorumlar_screen.dart';

/// Salon detayındaki değerlendirme özeti + son 3 yorum + "Tümünü gör".
/// Yorumlar yüklenemezse sayfanın geri kalanı etkilenmez; yalnızca bu bölüm yeniden denetir.
class YorumlarBolumu extends StatelessWidget {
  final int salonId;
  final String salonAd;
  final Json? veri;
  final bool hata;
  final VoidCallback onTekrar;

  const YorumlarBolumu({
    super.key,
    required this.salonId,
    required this.salonAd,
    required this.veri,
    required this.hata,
    required this.onTekrar,
  });

  @override
  Widget build(BuildContext context) {
    if (hata) {
      return _Bilgi(
        metin: 'Değerlendirmeler yüklenemedi.',
        aksiyon: TextButton.icon(onPressed: onTekrar, icon: const Icon(Icons.refresh), label: const Text('Tekrar')),
      );
    }
    final v = veri;
    if (v == null) {
      return const Padding(
          padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: AppTheme.gold)));
    }
    final toplam = v['toplam'] as int? ?? 0;
    if (toplam == 0) {
      return const _Bilgi(metin: 'Henüz değerlendirme yok. Randevunuzdan sonra ilk yorumu siz yapabilirsiniz.');
    }
    final yorumlar = ApiClient.liste(v['yorumlar']);
    return Column(children: [
      PuanOzetKarti(veri: v),
      for (final y in yorumlar.take(3)) YorumKarti(yorum: y),
      if (toplam > yorumlar.take(3).length)
        TextButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => YorumlarScreen(salonId: salonId, salonAd: salonAd))),
          child: Text('Tümünü gör ($toplam)'),
        ),
    ]);
  }
}

class _Bilgi extends StatelessWidget {
  final String metin;
  final Widget? aksiyon;
  const _Bilgi({required this.metin, this.aksiyon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.rate_review_outlined, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(metin, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13))),
        ?aksiyon,
      ]),
    );
  }
}
