import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/data/models/randevu.dart';

/// Randevularım listesindeki tek randevu: durum, zaman, berber, hizmetler, salon ve duruma göre aksiyon.
class RandevuKarti extends StatelessWidget {
  final Randevu randevu;
  final VoidCallback? onIptal;
  final VoidCallback? onErtele;
  final VoidCallback? onDegerlendir;

  const RandevuKarti({super.key, required this.randevu, this.onIptal, this.onErtele, this.onDegerlendir});

  static (String, Color) durumBilgisi(String durum) => switch (durum) {
        'onaylandi' => ('✓ Onaylandı', AppTheme.success),
        'tamamlandi' => ('✔ Tamamlandı', AppTheme.textSecondary),
        'iptal' => ('✗ İptal', AppTheme.error),
        'gelmedi' => ('Gelinmedi', Colors.orange),
        _ => (durum, AppTheme.gold),
      };

  @override
  Widget build(BuildContext context) {
    final r = randevu;
    final (durumMetni, durumRengi) = durumBilgisi(r.durum);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: durumRengi.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: durumRengi.withValues(alpha: 0.4)),
            ),
            child: Text(durumMetni,
                style: GoogleFonts.inter(color: durumRengi, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          Text(tl(r.toplamFiyat),
              style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        _Satir(Icons.calendar_today, '${tarihGoreli(r.tarih)}  •  ${r.saat}${r.bitis.isNotEmpty ? ' – ${r.bitis}' : ''}',
            vurgu: true),
        _Satir(Icons.person, r.berber),
        _Satir(Icons.content_cut, r.hizmetler.join(', ')),
        if (r.salonAd.isNotEmpty) _Satir(Icons.store_outlined, r.salonAd, renk: AppTheme.gold),
        if (r.durum == 'iptal' && r.iptalEden == 'isletme')
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Salon tarafından iptal edildi.', style: GoogleFonts.inter(color: AppTheme.error, fontSize: 12)),
          ),
        if (onIptal != null || onErtele != null) ...[
          const SizedBox(height: 14),
          Row(children: [
            if (onErtele != null)
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.gold,
                    side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.6)),
                  ),
                  onPressed: onErtele,
                  icon: const Icon(Icons.update, size: 18),
                  label: const Text('Ertele'),
                ),
              ),
            if (onErtele != null && onIptal != null) const SizedBox(width: 10),
            if (onIptal != null)
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: BorderSide(color: AppTheme.error.withValues(alpha: 0.5)),
                  ),
                  onPressed: onIptal,
                  child: const Text('İptal Et'),
                ),
              ),
          ]),
        ],
        if (r.durum == 'tamamlandi') ...[
          const SizedBox(height: 14),
          r.puan != null
              ? _DegerlendirildiEtiketi(puan: r.puan!)
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onDegerlendir,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.star_border),
                    label: const Text('Hizmeti Değerlendir'),
                  ),
                ),
        ],
      ]),
    );
  }
}

class _Satir extends StatelessWidget {
  final IconData ikon;
  final String metin;
  final bool vurgu;
  final Color? renk;
  const _Satir(this.ikon, this.metin, {this.vurgu = false, this.renk});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(ikon, color: renk ?? (vurgu ? AppTheme.gold : AppTheme.textSecondary), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(metin,
              style: GoogleFonts.inter(
                  color: renk ?? (vurgu ? Colors.white : AppTheme.textSecondary),
                  fontSize: vurgu ? 15 : 13,
                  fontWeight: vurgu ? FontWeight.w600 : FontWeight.normal)),
        ),
      ]),
    );
  }
}

class _DegerlendirildiEtiketi extends StatelessWidget {
  final int puan;
  const _DegerlendirildiEtiketi({required this.puan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.check_circle_outline, color: AppTheme.success, size: 20),
        const SizedBox(width: 8),
        Text('Değerlendirildi (${'★' * puan})',
            style: GoogleFonts.inter(color: AppTheme.success, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
