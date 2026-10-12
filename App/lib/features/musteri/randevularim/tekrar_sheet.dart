import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/data/models/randevu.dart';
import 'package:berber_app_ui/features/randevu_al/onay_screen.dart';
import 'package:berber_app_ui/services/analitik.dart';

/// "N hafta sonra aynı saatte tekrar al": aynı berber ve hizmetlerle. Varsayılan hafta müşterinin bu berbere
/// olağan gelme aralığı; aynı saat doluysa o günün en yakın saatleri önerilir. Randevu alınınca sayfa, açan
/// ekranın göstereceği onay sayfasıyla kapanır.
class TekrarSheet extends StatefulWidget {
  final Randevu randevu;
  const TekrarSheet({super.key, required this.randevu});

  @override
  State<TekrarSheet> createState() => _TekrarSheetState();
}

class _TekrarSheetState extends State<TekrarSheet> {
  Json? _oneri;
  int? _hafta;
  Map<String, dynamic>? _secili;
  String? _hata;
  bool _gonderiliyor = false;
  final Map<String, String> _anahtarlar = {};

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle([int? hafta]) async {
    setState(() {
      _hata = null;
      _oneri = null;
      _secili = null;
    });
    try {
      final v = await RandevuApi.tekrarOnerisi(widget.randevu.id, hafta: hafta);
      if (!mounted) return;
      final oneriler = (v['oneriler'] as List).cast<Map<String, dynamic>>();
      setState(() {
        _oneri = v;
        _hafta = v['hafta'] as int;
        _secili = oneriler.isEmpty ? null : oneriler.first;
      });
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    }
  }

  Future<void> _al() async {
    final o = _oneri!, s = _secili!;
    final anahtar = _anahtarlar.putIfAbsent('${s['tarih']} ${s['saat']}', ApiClient.yeniAnahtar);
    setState(() => _gonderiliyor = true);
    try {
      final sonuc = await RandevuApi.olustur(
        berberId: o['berber_id'],
        saat: s['saat'],
        tarih: s['tarih'],
        hizmetIds: List<int>.from(o['hizmet_ids']),
        idempotencyKey: anahtar,
      );
      Analitik.randevuOlusturuldu(
          tutar: sonuc['toplam_fiyat'] as num? ?? 0, hizmetSayisi: (o['hizmet_ids'] as List).length, kaynak: 'tekrar');
      if (!mounted) return;
      Navigator.pop(
        context,
        OnaySayfasi(
          tarih: s['tarih'],
          saat: s['saat'],
          bitis: sonuc['bitis']?.toString(),
          berber: o['berber'],
          salonAd: o['salon_ad'],
          hizmetler: List<String>.from(o['hizmetler']),
          toplamFiyat: (sonuc['toplam_fiyat'] as num).toDouble(),
          indirim: (sonuc['indirim_tutari'] as num? ?? 0).toDouble(),
          indirimAciklama: sonuc['indirim_aciklama'] as String?,
          randevuId: '${sonuc['randevu_id']}',
        ),
      );
    } on ApiHata catch (e) {
      if (!mounted) return;
      bilgiGoster(context, e.mesaj, hata: true);
      if (e.kod == 409) _yukle(_hafta);
    } finally {
      if (mounted) setState(() => _gonderiliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.randevu;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tekrar Randevu Al',
              style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${r.berber} · ${r.hizmetler.join(', ')}',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 14),
          Text('Kaç hafta sonra?', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 6, children: [
            for (final h in const [1, 2, 3, 4, 6, 8])
              ChoiceChip(
                key: ValueKey('tekrar_hafta_$h'),
                label: Text('$h hafta${_oneri?['olagan_hafta'] == h ? ' ★' : ''}'),
                selected: _hafta == h,
                onSelected: _gonderiliyor ? null : (_) => _yukle(h),
                selectedColor: AppTheme.gold,
                showCheckmark: false,
                labelStyle: TextStyle(color: _hafta == h ? AppTheme.black : Colors.white),
              ),
          ]),
          if (_oneri != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('★ her zamanki aralığınız', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
            ),
          const SizedBox(height: 16),
          if (_hata != null)
            HataGorunumu(mesaj: _hata!, onTekrar: () => _yukle(_hafta))
          else if (_oneri == null)
            const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: AppTheme.gold)))
          else
            ..._oneriler(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const ValueKey('tekrar_al'),
              onPressed: _secili == null || _gonderiliyor ? null : _al,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: _gonderiliyor
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.black))
                  : Text(_secili == null
                      ? 'Saat seçin'
                      : '${tarihGoreli(_secili!['tarih'])} ${_secili!['saat']} randevusunu al'),
            ),
          ),
        ]),
      ),
    );
  }

  List<Widget> _oneriler() {
    final o = _oneri!;
    final oneriler = (o['oneriler'] as List).cast<Map<String, dynamic>>();
    final hedef = tarihUzun(o['hedef_tarih']);
    final baslik = o['ayni_saat_bos'] == true
        ? '$hedef, her zamanki saatiniz ${widget.randevu.saat} boş.'
        : o['kapali_neden'] != null
            ? '$hedef: ${o['kapali_neden']} En yakın boş saatler:'
            : '$hedef ${widget.randevu.saat} dolu. O günün en yakın saatleri:';
    return [
      Text(baslik, style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
      const SizedBox(height: 10),
      if (oneriler.isEmpty)
        Text('Önümüzdeki günlerde boş saat bulunamadı.', style: GoogleFonts.inter(color: AppTheme.error, fontSize: 13))
      else
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final s in oneriler)
            ChoiceChip(
              label: Text(s['tarih'] == o['hedef_tarih'] ? s['saat'] : '${tarihGoreli(s['tarih'])} ${s['saat']}'),
              selected: _secili == s,
              onSelected: (_) => setState(() => _secili = s),
              selectedColor: AppTheme.gold,
              showCheckmark: false,
              labelStyle: TextStyle(color: _secili == s ? AppTheme.black : Colors.white),
            ),
        ]),
      const SizedBox(height: 6),
      Text('Liste fiyatı ${tl(o['liste_fiyati'] as num)} · ${sureMetni(o['toplam_sure_dk'] as int)}. '
          'Kampanya veya sadakat indirimi varsa onayda uygulanır.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
    ];
  }
}
