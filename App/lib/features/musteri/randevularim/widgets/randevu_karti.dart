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
  final VoidCallback? onTakvim;

  /// Tamamlanan randevuyu "N hafta sonra aynı saatte" tekrar almak
  final VoidCallback? onTekrarla;

  const RandevuKarti(
      {super.key,
      required this.randevu,
      this.onIptal,
      this.onErtele,
      this.onDegerlendir,
      this.onTakvim,
      this.onTekrarla});

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
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(tl(r.toplamFiyat),
                style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 18, fontWeight: FontWeight.bold)),
            if (r.indirimTutari > 0)
              Text(tl(r.listeFiyati),
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 11, decoration: TextDecoration.lineThrough)),
          ]),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: _Satir(Icons.calendar_today,
                '${tarihGoreli(r.tarih)}  •  ${r.saat}${r.bitis.isNotEmpty ? ' – ${r.bitis}' : ''}', vurgu: true),
          ),
          if (onTakvim != null)
            InkWell(
              onTap: onTakvim,
              borderRadius: BorderRadius.circular(8),
              child: const Tooltip(
                message: 'Takvime ekle',
                child: Padding(padding: EdgeInsets.all(4), child: Icon(Icons.event_available, color: AppTheme.gold, size: 20)),
              ),
            ),
        ]),
        _Satir(Icons.person, r.berber),
        _Satir(Icons.content_cut, r.hizmetler.join(', ')),
        if (r.salonAd.isNotEmpty) _Satir(Icons.store_outlined, r.salonAd, renk: AppTheme.gold),
        if (r.indirimTutari > 0)
          _Satir(Icons.local_offer_outlined, '${r.indirimAciklama ?? 'İndirim'} · −${tl(r.indirimTutari)}',
              renk: AppTheme.gold),
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
          if (onTekrarla != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: ValueKey('tekrarla_${r.id}'),
                onPressed: onTekrarla,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.gold,
                  side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.replay, size: 18),
                label: const Text('Aynısını Tekrar Al'),
              ),
            ),
          ],
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
