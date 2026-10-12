import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/data/models/randevu.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/saat_slot.dart';

/// Randevuyu aynı berberde başka gün/saate taşır. Açık günler ve saatler backend'den gelir;
/// randevunun kendi eski yeri dolu sayılmaz. Başarıda `true` ile kapanır.
class ErtelemeSheet extends StatefulWidget {
  final Randevu randevu;
  const ErtelemeSheet({super.key, required this.randevu});

  @override
  State<ErtelemeSheet> createState() => _ErtelemeSheetState();
}

class _ErtelemeSheetState extends State<ErtelemeSheet> {
  final String _anahtar = ApiClient.yeniAnahtar();
  List<Json>? _gunler;
  String? _gun;
  List<String> _tum = [];
  Set<String> _musait = {};

  /// Kampanyalı randevuda indirimin korunduğu saatler (null: kampanyasız randevu, uyarı gerekmez)
  Set<String>? _korunan;
  String? _saat;
  bool _saatlerYukleniyor = false;
  bool _gonderiliyor = false;
  String? _hata;

  Randevu get _r => widget.randevu;

  bool get _indirimKalkar => _saat != null && _korunan != null && !_korunan!.contains(_saat);

  @override
  void initState() {
    super.initState();
    _gunleriYukle();
  }

  Future<void> _gunleriYukle() async {
    setState(() => _hata = null);
    try {
      final g = await RandevuApi.musaitTakvim(berberId: _r.berberId);
      if (!mounted) return;
      setState(() => _gunler = g);
      if (g.isNotEmpty) _gunSec(g.any((x) => x['tarih'] == _r.tarih) ? _r.tarih : g.first['tarih']);
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    }
  }

  Future<void> _gunSec(String tarih) async {
    setState(() {
      _gun = tarih;
      _saat = null;
      _saatlerYukleniyor = true;
    });
    try {
      final v = await RandevuApi.musaitSaatler(_r.berberId, tarih, _r.hizmetIds, ertelenenId: _r.id);
      if (!mounted || _gun != tarih) return;
      setState(() {
        _tum = List<String>.from(v['tum_saatler']);
        _musait = Set<String>.from(v['musait_saatler']);
        final k = v['kampanya_korunan_saatler'];
        _korunan = k == null ? null : Set<String>.from(k);
        if (tarih == _r.tarih) _musait.remove(_r.saat); // mevcut saat seçilemez
      });
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _saatlerYukleniyor = false);
    }
  }

  Future<void> _onayla() async {
    setState(() => _gonderiliyor = true);
    try {
      await RandevuApi.ertele(_r.id, tarih: _gun!, saat: _saat!, idempotencyKey: _anahtar);
      if (mounted) Navigator.pop(context, true);
    } on ApiHata catch (e) {
      if (!mounted) return;
      bilgiGoster(context, e.oneriler.isEmpty ? e.mesaj : '${e.mesaj} Öneri: ${e.oneriler.take(3).join(', ')}',
          hata: true);
      if (e.kod == 409) _gunSec(_gun!);
    } finally {
      if (mounted) setState(() => _gonderiliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text('Randevuyu Ertele',
                style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
                'Şu an: ${tarihGoreli(_r.tarih)} ${_r.saat} · ${_r.berber} · ${sureMetni(_r.sureDk)}\n'
                'Kalan erteleme hakkı: ${_r.ertelemeHakki}',
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AsenkronGorunum(
              yukleniyor: _gunler == null && _hata == null,
              hata: _hata,
              onTekrar: _gunleriYukle,
              builder: (_) => _gunler!.isEmpty
                  ? const BosGorunum(ikon: Icons.event_busy, mesaj: 'Önümüzdeki günlerde açık gün yok.')
                  : Column(children: [_gunSecici(), const SizedBox(height: 12), Expanded(child: _saatler())]),
            ),
          ),
          if (_indirimKalkar)
            Padding(
              key: const ValueKey('erteleme_indirim_uyarisi'),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Bu saat "${_r.indirimAciklama ?? 'kampanya'}" kapsamında değil: indirim kalkar, '
                      'tutar ${tl(_r.listeFiyati)} olur. İndirimli saatler işaretli.',
                      style: GoogleFonts.inter(color: Colors.orange, fontSize: 12)),
                ),
              ]),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saat == null || _gonderiliyor ? null : _onayla,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _gonderiliyor
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.black))
                    : Text(_saat == null ? 'Yeni saat seçin' : '${tarihGoreli(_gun!)} $_saat olarak ertele'),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _gunSecici() {
    return SizedBox(
      height: 44,
      child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
        for (final g in _gunler!)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tarihGoreli(g['tarih'])),
              selected: _gun == g['tarih'],
              onSelected: (_) => _gunSec(g['tarih']),
              selectedColor: AppTheme.gold,
              backgroundColor: AppTheme.surface,
              labelStyle: TextStyle(color: _gun == g['tarih'] ? AppTheme.black : Colors.white, fontSize: 13),
            ),
          ),
      ]),
    );
  }

  Widget _saatler() {
    if (_saatlerYukleniyor) return const Yukleniyor();
    if (_musait.isEmpty) {
      return const BosGorunum(ikon: Icons.event_busy, mesaj: 'Bu gün boş saat yok.', altMesaj: 'Başka bir gün seçin.');
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 2.2, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: _tum.length,
      itemBuilder: (_, i) {
        final saat = _tum[i];
        return SaatSlotWidget(
          saat: saat,
          durum: _musait.contains(saat) ? SlotDurumu.musait : SlotDurumu.dolu,
          secili: _saat == saat,
          // Kampanya bu saatte de geçerliyse indirim korunur; etiketle göster
          indirimYuzde: (_korunan?.contains(saat) ?? false) && _r.listeFiyati > 0
              ? (_r.indirimTutari / _r.listeFiyati * 100).round()
              : 0,
          onTap: () => setState(() => _saat = saat),
        );
      },
    );
  }
}
