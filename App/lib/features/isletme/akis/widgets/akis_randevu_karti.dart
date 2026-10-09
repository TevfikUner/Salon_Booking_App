import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/features/isletme/widgets/guven_rozeti.dart';

/// Akıştaki tek randevu: saat aralığı, müşteri + güven rozeti, hizmetler, toplam ve aksiyonlar.
class AkisRandevuKarti extends StatelessWidget {
  final Map<String, dynamic> randevu;
  final bool islemde;
  final void Function(String durum) onDurum;
  final VoidCallback onWhatsapp;
  final VoidCallback onAra;

  const AkisRandevuKarti({
    super.key,
    required this.randevu,
    required this.islemde,
    required this.onDurum,
    required this.onWhatsapp,
    required this.onAra,
  });

  @override
  Widget build(BuildContext context) {
    final r = randevu;
    final durum = r['durum'] as String;
    final aktif = durum == 'onaylandi';
    final riskli = aktif && r['guven']['etiket'] == 'Riskli';
    final hizmetler = (r['hizmetler'] as List).cast<Map<String, dynamic>>();
    final tel = (r['musteri']['telefon'] as String?) ?? '';
    // "Tamamlandı/Gelmedi" yalnızca randevu saati geldikten sonra anlamlı (backend de doğrular)
    final basladi = DateTime.tryParse('${r['tarih']}T${r['saat']}:00')?.isBefore(DateTime.now()) ?? false;

    return Opacity(
      opacity: durum == 'iptal' || durum == 'gelmedi' ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: riskli ? AppTheme.error.withValues(alpha: 0.6) : AppTheme.gold.withValues(alpha: 0.15)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SaatSutunu(randevu: r),
            Expanded(child: _Detay(randevu: r, hizmetler: hizmetler)),
          ]),
          Divider(color: AppTheme.gold.withValues(alpha: 0.1), height: 20),
          Row(children: [
            _DurumEtiketi(durum: durum),
            const Spacer(),
            Text('Toplam ', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
            Text(tl(r['toplam_fiyat'] as num? ?? 0),
                style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          if (aktif) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              if (r['whatsapp_link'] != null)
                _Aksiyon(ikon: Icons.chat, etiket: 'WhatsApp onay', renk: const Color(0xFF25D366), onTap: onWhatsapp),
              if (tel.isNotEmpty) _Aksiyon(ikon: Icons.call, etiket: 'Ara', renk: AppTheme.gold, onTap: onAra),
              if (basladi) ...[
                _Aksiyon(ikon: Icons.check_circle, etiket: 'Tamamlandı', renk: AppTheme.success,
                    onTap: islemde ? null : () => onDurum('tamamlandi')),
                _Aksiyon(ikon: Icons.person_off, etiket: 'Gelmedi', renk: Colors.orange,
                    onTap: islemde ? null : () => onDurum('gelmedi')),
              ],
              _Aksiyon(ikon: Icons.cancel_outlined, etiket: 'İptal', renk: AppTheme.error,
                  onTap: islemde ? null : () => onDurum('iptal')),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _SaatSutunu extends StatelessWidget {
  final Map<String, dynamic> randevu;
  const _SaatSutunu({required this.randevu});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(randevu['saat'],
            style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 20, fontWeight: FontWeight.bold)),
        Text('– ${randevu['bitis']}', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
        Text(sureMetni(randevu['sure_dk'] as int? ?? 0),
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
      ]),
    );
  }
}

class _Detay extends StatelessWidget {
  final Map<String, dynamic> randevu;
  final List<Map<String, dynamic>> hizmetler;
  const _Detay({required this.randevu, required this.hizmetler});

  @override
  Widget build(BuildContext context) {
    final r = randevu;
    final notlar = r['notlar'] as String?;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Flexible(
          child: Text(r['musteri']['ad'],
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 6),
        GuvenRozeti(guven: r['guven']),
      ]),
      const SizedBox(height: 2),
      Text('${r['berber']['ad']}${r['kaynak'] == 'panel' ? ' · panelden eklendi' : ''}',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
      const SizedBox(height: 6),
      for (final h in hizmetler)
        Row(children: [
          const Icon(Icons.content_cut, size: 12, color: AppTheme.gold),
          const SizedBox(width: 6),
          Expanded(
            child: Text('${h['ad']} (${h['sure']} dk)', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
          ),
          Text(tl(h['fiyat'] as num), style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
        ]),
      if (notlar != null && notlar.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('Not: $notlar',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
        ),
    ]);
  }
}

class _DurumEtiketi extends StatelessWidget {
  final String durum;
  const _DurumEtiketi({required this.durum});

  @override
  Widget build(BuildContext context) {
    final (metin, renk) = switch (durum) {
      'onaylandi' => ('Bekleniyor', AppTheme.gold),
      'tamamlandi' => ('Tamamlandı', AppTheme.success),
      'gelmedi' => ('Gelmedi', Colors.orange),
      'iptal' => ('İptal', AppTheme.error),
      _ => (durum, AppTheme.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: renk.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(metin, style: GoogleFonts.inter(color: renk, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _Aksiyon extends StatelessWidget {
  final IconData ikon;
  final String etiket;
  final Color renk;
  final VoidCallback? onTap;
  const _Aksiyon({required this.ikon, required this.etiket, required this.renk, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(ikon, size: 16, color: renk),
      label: Text(etiket, style: GoogleFonts.inter(color: renk, fontSize: 12, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: renk.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(0, 34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
