import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/panel_api.dart';

/// Personelin verdiği hizmetler ve kendine özel fiyat/süre. Boş alan = menüdeki değer.
/// Kaydedilirse true döner. Personel (salt okuma) için düzenleme kapalıdır.
Future<bool?> personelHizmetleriDuzenle(BuildContext context, {required int berberId, required String ad}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _PersonelHizmetleri(berberId: berberId, ad: ad),
  );
}

class _Satir {
  final int hizmetId;
  final String ad;
  final num menuFiyat;
  final int menuSure;
  bool veriyor;
  final TextEditingController fiyat;
  final TextEditingController sure;

  _Satir(Json j)
      : hizmetId = j['hizmet_id'],
        ad = j['ad'],
        menuFiyat = j['menu_fiyat'],
        menuSure = j['menu_sure'],
        veriyor = j['veriyor'] == true,
        fiyat = TextEditingController(text: j['fiyat'] == null ? '' : (j['fiyat'] as num).toStringAsFixed(0)),
        sure = TextEditingController(text: j['sure'] == null ? '' : '${j['sure']}');

  Json json() => {
        'hizmet_id': hizmetId,
        'veriyor': veriyor,
        'fiyat': veriyor ? double.tryParse(fiyat.text) : null,
        'sure': veriyor ? int.tryParse(sure.text) : null,
      };
}

class _PersonelHizmetleri extends StatefulWidget {
  final int berberId;
  final String ad;
  const _PersonelHizmetleri({required this.berberId, required this.ad});

  @override
  State<_PersonelHizmetleri> createState() => _PersonelHizmetleriState();
}

class _PersonelHizmetleriState extends State<_PersonelHizmetleri> {
  List<_Satir>? _satirlar;
  String? _hata;
  bool _kaydediliyor = false;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  @override
  void dispose() {
    for (final s in _satirlar ?? const <_Satir>[]) {
      s.fiyat.dispose();
      s.sure.dispose();
    }
    super.dispose();
  }

  Future<void> _yukle() async {
    setState(() => _hata = null);
    try {
      final v = await PanelApi.personelHizmetleri(widget.berberId);
      if (mounted) setState(() => _satirlar = v.map(_Satir.new).toList());
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    }
  }

  Future<void> _kaydet() async {
    final satirlar = _satirlar!;
    if (!satirlar.any((s) => s.veriyor)) {
      bilgiGoster(context, 'Personel en az bir hizmet vermeli.', hata: true);
      return;
    }
    final kisa = satirlar.where((s) => s.veriyor && (int.tryParse(s.sure.text) ?? 5) < 5);
    if (kisa.isNotEmpty) {
      bilgiGoster(context, '${kisa.first.ad}: süre en az 5 dakika olmalı.', hata: true);
      return;
    }
    setState(() => _kaydediliyor = true);
    try {
      await PanelApi.personelHizmetleriKaydet(widget.berberId, satirlar.map((s) => s.json()).toList());
      if (mounted) Navigator.pop(context, true);
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${widget.ad} · Hizmetler',
                  style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Kapalı hizmetler bu personelden alınamaz. Fiyat ve süre boşsa menüdeki geçerli; '
                  'değişiklik mevcut randevuları etkilemez.',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
            ]),
          ),
          Expanded(
            child: _hata != null
                ? HataGorunumu(mesaj: _hata!, onTekrar: _yukle)
                : _satirlar == null
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
                    : _satirlar!.isEmpty
                        ? const BosGorunum(ikon: Icons.content_cut, mesaj: 'Menüde hizmet yok.')
                        : ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), children: [
                            for (final s in _satirlar!) _satir(s),
                          ]),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _satirlar == null || _kaydediliyor ? null : _kaydet,
                  child: _kaydediliyor
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.black))
                      : const Text('Kaydet'),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _satir(_Satir s) => Card(
        key: ValueKey('personel_hizmet_${s.hizmetId}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 8, 10),
          child: Column(children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: s.veriyor,
              onChanged: (v) => setState(() => s.veriyor = v),
              activeThumbColor: AppTheme.gold,
              title: Text(s.ad, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              subtitle: Text('Menü: ${tl(s.menuFiyat)} · ${sureMetni(s.menuSure)}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ),
            if (s.veriyor)
              Row(children: [
                Expanded(child: _alan(s.fiyat, 'Özel fiyat', s.menuFiyat.toStringAsFixed(0), '₺')),
                const SizedBox(width: 10),
                Expanded(child: _alan(s.sure, 'Özel süre', '${s.menuSure}', 'dk')),
              ]),
          ]),
        ),
      );

  Widget _alan(TextEditingController c, String etiket, String ipucu, String ek) => TextField(
        controller: c,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: etiket, hintText: ipucu, suffixText: ek, isDense: true),
      );
}
