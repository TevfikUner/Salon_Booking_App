import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/panel_api.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';

const _aylar = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım',
  'Aralık'];

/// Aylık salon raporu: ciro, randevu, gelmeme oranı, berber bazlı ciro, popüler hizmetler.
class RaporSekmesi extends StatefulWidget {
  const RaporSekmesi({super.key});

  @override
  State<RaporSekmesi> createState() => _RaporSekmesiState();
}

class _RaporSekmesiState extends State<RaporSekmesi> {
  DateTime _ay = DateTime(DateTime.now().year, DateTime.now().month);
  Map<String, dynamic>? _v;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() {
      _v = null;
      _hata = null;
    });
    try {
      final v = await PanelApi.rapor(yil: _ay.year, ay: _ay.month);
      if (mounted) setState(() => _v = v);
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    }
  }

  void _kaydir(int fark) {
    setState(() => _ay = DateTime(_ay.year, _ay.month + fark));
    _yukle();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(tooltip: 'Önceki ay', onPressed: () => _kaydir(-1), icon: const Icon(Icons.chevron_left)),
        Text('${_aylar[_ay.month - 1]} ${_ay.year}',
            style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(tooltip: 'Sonraki ay', onPressed: () => _kaydir(1), icon: const Icon(Icons.chevron_right)),
      ]),
      Expanded(child: _govde()),
    ]);
  }

  Widget _govde() {
    if (_hata != null) return HataGorunumu(mesaj: _hata!, onTekrar: _yukle);
    final v = _v;
    if (v == null) return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
    final berberler = (v['berber_ciro'] as List).cast<Map<String, dynamic>>();
    final enYuksek = berberler.isEmpty ? 1.0 : (berberler.first['ciro'] as num).toDouble().clamp(1, double.infinity);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 32), children: [
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.1,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          _kpi('Ciro', tl(v['toplam_ciro']), Icons.payments_outlined),
          _kpi('Tamamlanan', '${v['tamamlanan']} / ${v['toplam_randevu']}', Icons.check_circle_outline),
          _kpi('Ortalama sepet', tl(v['ortalama_sepet']), Icons.shopping_bag_outlined),
          _kpi('Gelmeme oranı', '%${v['gelmeme_orani']}', Icons.person_off_outlined,
              renk: (v['gelmeme_orani'] as num) > 10 ? AppTheme.error : AppTheme.gold),
          if ((v['indirimli_randevu'] as int? ?? 0) > 0)
            _kpi('Verilen indirim', '${tl(v['toplam_indirim'])} · ${v['indirimli_randevu']} randevu',
                Icons.local_offer_outlined),
        ],
      ),
      const SizedBox(height: 20),
      Text('Personel bazlı ciro', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 17,
          fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      if (berberler.isEmpty)
        Text('Bu ay tamamlanan randevu yok.', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
      for (final b in berberler)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(b['ad'], style: const TextStyle(color: Colors.white))),
              Text(tl(b['ciro']), style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (b['ciro'] as num) / enYuksek,
                minHeight: 8,
                color: AppTheme.gold,
                backgroundColor: AppTheme.surface,
              ),
            ),
          ]),
        ),
      const SizedBox(height: 20),
      Text('En çok tercih edilen hizmetler', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 17,
          fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      for (final h in (v['populer_hizmetler'] as List).cast<Map<String, dynamic>>())
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.content_cut, color: AppTheme.gold, size: 18),
          title: Text(h['ad'], style: const TextStyle(color: Colors.white)),
          trailing: Text('${h['adet']} kez', style: const TextStyle(color: AppTheme.textSecondary)),
        ),
      const SizedBox(height: 8),
      Text('İptal: ${v['iptal']} · Gelmedi: ${v['gelmedi']} · Uygulamadan gelen: ${v['uygulamadan_gelen']}',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
    ]);
  }

  Widget _kpi(String etiket, String deger, IconData ikon, {Color renk = AppTheme.gold}) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: renk.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          Icon(ikon, color: renk),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(child: Text(deger, style: GoogleFonts.playfairDisplay(color: renk, fontSize: 18,
                      fontWeight: FontWeight.bold))),
                  Text(etiket, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
                ]),
          ),
        ]),
      );
}
