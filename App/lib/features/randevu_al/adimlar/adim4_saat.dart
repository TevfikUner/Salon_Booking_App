import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:berber_app_ui/features/randevu_al/randevu_provider.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/saat_slot.dart';

/// Saat seçimi. Müsaitlik tamamen backend'de hesaplanır (salon saatleri, tatil, izin, çakışma, geçmiş saat);
/// istemci yalnızca gösterir. Gün doluysa bekleme listesi ve en yakın boş slotlar önerilir.
class Adim4Saat extends StatefulWidget {
  const Adim4Saat({super.key});

  @override
  State<Adim4Saat> createState() => _Adim4SaatState();
}

class _Adim4SaatState extends State<Adim4Saat> {
  List<String> _tum = [];
  Set<String> _musait = {};
  String? _kapaliNeden;
  List<Map<String, dynamic>> _enYakin = [];
  bool _yukleniyor = true;
  bool _beklemeGonderiliyor = false;
  bool _beklemede = false;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final p = context.read<RandevuProvider>();
    final berber = p.seciliBerber, tarih = p.seciliTarih;
    if (berber == null || tarih == null || p.seciliHizmetler.isEmpty) {
      setState(() => _yukleniyor = false);
      return;
    }
    setState(() {
      _yukleniyor = true;
      _hata = null;
      _enYakin = [];
    });
    final ids = p.seciliHizmetler.map((h) => h.id).toList();
    try {
      final v = await RandevuApi.musaitSaatler(berber.id, tarihStr(tarih), ids);
      final musait = Set<String>.from(v['musait_saatler']);
      List<Map<String, dynamic>> enYakin = [];
      if (musait.isEmpty) {
        enYakin = await RandevuApi.enYakinSlotlar(berber.id, ids, adet: 4);
      }
      if (!mounted) return;
      setState(() {
        _tum = List<String>.from(v['tum_saatler']);
        _musait = musait;
        _kapaliNeden = v['kapali_neden'];
        _enYakin = enYakin;
      });
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _beklemeyeEkle() async {
    final p = context.read<RandevuProvider>();
    setState(() => _beklemeGonderiliyor = true);
    try {
      await RandevuApi.beklemeListesineEkle(
          p.seciliBerber!.id, tarihStr(p.seciliTarih!), p.seciliHizmetler.map((h) => h.id).toList());
      if (!mounted) return;
      setState(() => _beklemede = true);
      bilgiGoster(context, 'Bu günde yer açılırsa size hemen bildirim göndereceğiz.');
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _beklemeGonderiliyor = false);
    }
  }

  void _oneriSec(Map<String, dynamic> s) {
    final p = context.read<RandevuProvider>();
    p.tarihSec(DateTime.parse(s['tarih']));
    p.saatSec(s['saat']);
    _yukle();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RandevuProvider>();
    final tarih = provider.seciliTarih;
    if (tarih == null) {
      return const BosGorunum(ikon: Icons.calendar_today, mesaj: 'Lütfen önce bir tarih seçin.');
    }
    if (_yukleniyor) return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
    if (_hata != null) return HataGorunumu(mesaj: _hata!, onTekrar: _yukle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tarihUzun(tarihStr(tarih), yil: true),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 8),
            const _Lejant(color: AppTheme.success, label: 'Müsait'),
            const SizedBox(width: 10),
            const _Lejant(color: AppTheme.error, label: 'Dolu'),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Toplam süre: ${sureMetni(provider.toplamSureDk)} — yalnızca hizmetin tamamının sığdığı saatler açıktır.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: _musait.isEmpty ? _doluGun() : _izgara(provider)),
      ],
    );
  }

  Widget _izgara(RandevuProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _tum.length,
      itemBuilder: (_, i) {
        final saat = _tum[i];
        return SaatSlotWidget(
          saat: saat,
          durum: _musait.contains(saat) ? SlotDurumu.musait : SlotDurumu.dolu,
          secili: provider.seciliSaat == saat,
          onTap: () => provider.saatSec(saat),
        );
      },
    );
  }

  Widget _doluGun() {
    return ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
      const SizedBox(height: 12),
      Icon(Icons.event_busy, color: AppTheme.gold.withValues(alpha: 0.5), size: 52),
      const SizedBox(height: 12),
      Text(_kapaliNeden ?? 'Bu gün seçtiğiniz hizmetler için boş saat kalmadı.',
          textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white, fontSize: 15)),
      const SizedBox(height: 20),
      if (_kapaliNeden == null)
        OutlinedButton.icon(
          onPressed: _beklemede || _beklemeGonderiliyor ? null : _beklemeyeEkle,
          icon: Icon(_beklemede ? Icons.notifications_active : Icons.notifications_none, color: AppTheme.gold),
          label: Text(_beklemede ? 'Bekleme listesindesiniz' : 'Yer açılırsa haber ver',
              style: const TextStyle(color: AppTheme.gold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.gold),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      if (_enYakin.isNotEmpty) ...[
        const SizedBox(height: 24),
        Text('En yakın boş saatler', style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 17,
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final s in _enYakin)
            ActionChip(
              onPressed: () => _oneriSec(s),
              backgroundColor: AppTheme.surface,
              side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.4)),
              avatar: const Icon(Icons.bolt, color: AppTheme.gold, size: 16),
              label: Text('${tarihGoreli(s['tarih'])} ${s['saat']}', style: const TextStyle(color: Colors.white)),
            ),
        ]),
      ],
    ]);
  }
}

class _Lejant extends StatelessWidget {
  final Color color;
  final String label;
  const _Lejant({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
    ]);
  }
}
