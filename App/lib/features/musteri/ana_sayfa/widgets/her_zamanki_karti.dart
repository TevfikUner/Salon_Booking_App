import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/features/randevu_al/onay_screen.dart';
import 'package:berber_app_ui/data/api/api_service.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/ortak.dart';

/// İmza özellik — "Her Zamanki": müdavimin en sık aldığı berber + hizmet kombinasyonu,
/// en yakın boş slotlarla birlikte. Tek dokunuş + onay = randevu.
class HerZamankiKarti extends StatefulWidget {
  final Map<String, dynamic> veri;
  final VoidCallback? onDegisti;
  const HerZamankiKarti({super.key, required this.veri, this.onDegisti});

  @override
  State<HerZamankiKarti> createState() => _HerZamankiKartiState();
}

class _HerZamankiKartiState extends State<HerZamankiKarti> {
  String? _gonderilen;

  Future<void> _al(Map<String, dynamic> slot) async {
    final v = widget.veri;
    final berber = v['berber'] as Map<String, dynamic>;
    final hizmetler = (v['hizmetler'] as List).cast<Map<String, dynamic>>();
    final berberAd = '${berber['ad']} ${berber['soyad']}'.trim();
    final onay = await onayIste(
      context,
      'Her zamanki randevu',
      '${tarihGoreli(slot['tarih'])} ${slot['saat']}\n$berberAd · ${v['salon']['ad']}\n'
          '${hizmetler.map((h) => h['ad']).join(', ')}\nToplam: ${tl(v['toplam_fiyat'])}',
      evet: 'Randevuyu Al',
    );
    if (!onay || !mounted) return;
    final anahtar = '${slot['tarih']} ${slot['saat']}';
    setState(() => _gonderilen = anahtar);
    try {
      final sonuc = await ApiService.randevuOlustur(
        berberId: berber['id'],
        saat: slot['saat'],
        tarih: slot['tarih'],
        hizmetIds: hizmetler.map<int>((h) => h['id'] as int).toList(),
      );
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => OnaySayfasi(
          tarih: slot['tarih'],
          saat: slot['saat'],
          bitis: sonuc['bitis']?.toString(),
          berber: berberAd,
          salonAd: v['salon']['ad'],
          hizmetler: hizmetler.map<String>((h) => h['ad'] as String).toList(),
          toplamFiyat: (sonuc['toplam_fiyat'] as num).toDouble(),
          randevuId: sonuc['randevu_id'].toString(),
        ),
      ));
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
      widget.onDegisti?.call(); // slotlar değişmiş olabilir
    } finally {
      if (mounted) setState(() => _gonderilen = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.veri;
    final berber = v['berber'] as Map<String, dynamic>;
    final hizmetler = (v['hizmetler'] as List).cast<Map<String, dynamic>>();
    final slotlar = (v['en_yakin_slotlar'] as List).cast<Map<String, dynamic>>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.gold.withValues(alpha: 0.20), AppTheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.55)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.bolt, color: AppTheme.gold),
          const SizedBox(width: 6),
          Text('Her Zamanki', style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 20,
              fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('${v['kac_kez']} kez aldınız', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
        ]),
        const SizedBox(height: 8),
        Text('${'${berber['ad']} ${berber['soyad']}'.trim()} · ${v['salon']['ad']}',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text('${hizmetler.map((h) => h['ad']).join(' + ')} · ${sureMetni(v['toplam_sure_dk'])} · ${tl(v['toplam_fiyat'])}',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 12),
        if (slotlar.isEmpty)
          Text('Yakın tarihte boş saat yok.', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12))
        else ...[
          Text('En yakın boş saatler — dokun, onayla, bitti:',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in slotlar)
              ActionChip(
                onPressed: _gonderilen == null ? () => _al(s) : null,
                backgroundColor: AppTheme.black,
                side: const BorderSide(color: AppTheme.gold),
                avatar: _gonderilen == '${s['tarih']} ${s['saat']}'
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.access_time, size: 16, color: AppTheme.gold),
                label: Text('${tarihGoreli(s['tarih'])} ${s['saat']}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
          ]),
        ],
      ]),
    );
  }
}
