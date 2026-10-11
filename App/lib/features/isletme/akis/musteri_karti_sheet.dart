import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/panel_api.dart';
import 'package:berber_app_ui/features/isletme/widgets/guven_rozeti.dart';

/// Müşteri kartı: bu salondaki ziyaretleri, harcaması, en sık berber/hizmeti, güven skoru ve kalıcı işletme notu.
/// Not kaydedilir/silinirse [onNotDegisti] çağrılır (akış "not var" işaretini yeniler).
class MusteriKartiSheet extends StatefulWidget {
  final int musteriId;
  final VoidCallback? onNotDegisti;

  /// Yalnızca testte: API çağırmadan bu veriyle çizilir.
  @visibleForTesting
  final Json? testVerisi;
  const MusteriKartiSheet({super.key, required this.musteriId, this.onNotDegisti, this.testVerisi});

  @override
  State<MusteriKartiSheet> createState() => _MusteriKartiSheetState();
}

class _MusteriKartiSheetState extends State<MusteriKartiSheet> {
  final _not = TextEditingController();
  Json? _veri;
  String? _hata;
  bool _kaydediliyor = false;

  @override
  void initState() {
    super.initState();
    if (widget.testVerisi != null) {
      _veri = widget.testVerisi;
      _not.text = _veri!['not']?['metin'] ?? '';
    } else {
      _yukle();
    }
  }

  @override
  void dispose() {
    _not.dispose();
    super.dispose();
  }

  Future<void> _yukle() async {
    setState(() => _hata = null);
    try {
      final v = await PanelApi.musteriKarti(widget.musteriId);
      if (!mounted) return;
      setState(() => _veri = v);
      _not.text = v['not']?['metin'] ?? '';
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    }
  }

  Future<void> _kaydet() async {
    FocusScope.of(context).unfocus();
    setState(() => _kaydediliyor = true);
    try {
      final v = await PanelApi.musteriNotuKaydet(widget.musteriId, _not.text);
      widget.onNotDegisti?.call();
      if (!mounted) return;
      setState(() => _veri = {..._veri!, 'not': v['not']});
      bilgiGoster(context, v['mesaj'] ?? 'Not kaydedildi.');
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: AsenkronGorunum(
          yukleniyor: _veri == null && _hata == null,
          hata: _hata,
          onTekrar: _yukle,
          builder: (_) => _icerik(_veri!),
        ),
      ),
    );
  }

  Widget _icerik(Json v) {
    final m = v['musteri'] as Json;
    final o = v['ozet'] as Json;
    final not = v['not'] as Json?;
    final randevular = ApiClient.liste(v['son_randevular']);
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      children: [
        Row(children: [
          Expanded(
            child: Text(m['ad'] ?? '',
                style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 21, fontWeight: FontWeight.bold)),
          ),
          GuvenRozeti(guven: v['guven']),
        ]),
        if ((m['telefon'] as String? ?? '').isNotEmpty)
          Text(telefonBicimli(m['telefon']), style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _Kutu('Ziyaret', '${o['ziyaret']}'),
          _Kutu('Harcama', tl(o['toplam_harcama'] as num? ?? 0)),
          _Kutu('Son ziyaret', o['son_ziyaret'] == null ? '—' : tarihUzun(o['son_ziyaret']).split(' ').take(2).join(' ')),
          if ((o['gelmedi'] as int? ?? 0) > 0) _Kutu('Gelmedi', '${o['gelmedi']}', uyari: true),
        ]),
        if (o['en_sik_berber'] != null || (o['en_sik_hizmetler'] as List).isNotEmpty) ...[
          const SizedBox(height: 12),
          Text([
            if (o['en_sik_berber'] != null) 'Genelde: ${o['en_sik_berber']}',
            if ((o['en_sik_hizmetler'] as List).isNotEmpty) (o['en_sik_hizmetler'] as List).join(', '),
          ].join(' · '), style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
        ],
        const SizedBox(height: 18),
        Text('İşletme notu', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: _not,
          maxLength: 500,
          maxLines: 3,
          minLines: 2,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
              hintText: 'Ör: Yanlar 1 numara, üstü makas, ense düz.',
              helperText: 'Sağlık bilgisi gibi özel nitelikli veri yazmayın.',
              helperMaxLines: 2),
        ),
        Row(children: [
          Expanded(
            child: Text(
                not == null ? 'Not yalnızca salonunuzda görünür.' : 'Son: ${not['guncelleyen'] ?? ''} · ${not['guncelleme']}'
                    .replaceFirst('T', ' '),
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
          ),
          ElevatedButton(
            onPressed: _kaydediliyor ? null : _kaydet,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
            child: Text(_not.text.trim().isEmpty && not != null ? 'Notu Sil' : 'Kaydet'),
          ),
        ]),
        const SizedBox(height: 18),
        Text('Son randevular', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        for (final r in randevular)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              SizedBox(
                width: 92,
                child: Text('${tarihUzun(r['tarih']).split(' ').take(2).join(' ')} ${r['saat']}',
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
              ),
              Expanded(
                child: Text('${(r['hizmetler'] as List).join(', ')} · ${r['berber']}',
                    overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
              ),
              Text(_durum(r['durum']), style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
            ]),
          ),
      ],
    );
  }

  static String _durum(String d) => switch (d) {
        'tamamlandi' => '✔',
        'gelmedi' => 'gelmedi',
        'iptal' => 'iptal',
        _ => 'bekliyor',
      };
}

class _Kutu extends StatelessWidget {
  final String etiket;
  final String deger;
  final bool uyari;
  const _Kutu(this.etiket, this.deger, {this.uyari = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: (uyari ? Colors.orange : AppTheme.gold).withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(deger, style: GoogleFonts.inter(color: uyari ? Colors.orange : Colors.white, fontWeight: FontWeight.w700)),
        Text(etiket, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
      ]),
    );
  }
}
