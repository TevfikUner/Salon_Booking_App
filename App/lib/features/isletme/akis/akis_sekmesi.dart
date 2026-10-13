import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/utils/harici.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/panel_api.dart';
import 'package:berber_app_ui/features/isletme/akis/musteri_karti_sheet.dart';
import 'package:berber_app_ui/features/isletme/akis/randevu_ekle_sheet.dart';
import 'package:berber_app_ui/features/isletme/akis/widgets/akis_ozeti.dart';
import 'package:berber_app_ui/features/isletme/akis/widgets/akis_randevu_karti.dart';
import 'package:berber_app_ui/features/isletme/akis/widgets/gun_takvimi.dart';

/// İmza özellik — "Bugünün Akışı": günün randevuları saat sırasıyla, müşteri/hizmet/süre/ücret,
/// güven skoru ve tek dokunuş WhatsApp onay mesajı.
class AkisSekmesi extends StatefulWidget {
  final bool personel;

  /// Bildirimden açılınca gösterilecek gün (varsayılan bugün).
  final DateTime? baslangicTarihi;
  const AkisSekmesi({super.key, this.personel = false, this.baslangicTarihi});

  @override
  State<AkisSekmesi> createState() => _AkisSekmesiState();
}

class _AkisSekmesiState extends State<AkisSekmesi> {
  late DateTime _gun = widget.baslangicTarihi ?? DateTime.now();
  Map<String, dynamic>? _veri;
  String? _hata;
  final Set<int> _islemde = {};

  /// Liste (varsayılan) veya berber sütunlu gün takvimi; seçim cihazda hatırlanır
  bool _takvim = false;
  static const _gorunumAnahtari = 'akis_gorunumu_takvim';

  @override
  void initState() {
    super.initState();
    _yukle();
    _gorunumuOku();
  }

  Future<void> _gorunumuOku() async {
    try {
      final t = (await SharedPreferences.getInstance()).getBool(_gorunumAnahtari) ?? false;
      if (mounted && t != _takvim) setState(() => _takvim = t);
    } catch (_) {
      // Tercih okunamazsa liste görünümü
    }
  }

  void _gorunumSec(bool takvim) {
    setState(() => _takvim = takvim);
    SharedPreferences.getInstance().then((p) => p.setBool(_gorunumAnahtari, takvim)).ignore();
  }

  Future<void> _yukle() async {
    setState(() => _hata = null);
    try {
      final v = await PanelApi.akis(tarih: tarihStr(_gun));
      if (mounted) setState(() => _veri = v);
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    }
  }

  void _gunDegistir(DateTime g) {
    setState(() {
      _gun = g;
      _veri = null;
    });
    _yukle();
  }

  Future<void> _durum(Map<String, dynamic> r, String durum) async {
    if (durum == 'iptal' &&
        !await onayIste(
          context,
          Dil.t.randevuyuIptalEt,
          Dil.t.panelIptalSoru('${r['musteri']['ad']} — ${r['saat']}'),
          evet: Dil.t.iptalEt,
          tehlikeli: true,
        )) {
      return;
    }
    setState(() => _islemde.add(r['id']));
    try {
      await PanelApi.durumGuncelle(r['id'], durum);
      if (mounted) bilgiGoster(context, Dil.t.randevuGuncellendi);
      await _yukle();
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _islemde.remove(r['id']));
    }
  }

  Future<void> _harici(Future<bool> islem) async {
    if (!await islem && mounted) bilgiGoster(context, Dil.t.uygulamaAcilamadi, hata: true);
  }

  Future<void> _randevuEkle({int? berberId, String? saat}) async {
    final eklendi = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => RandevuEkleSheet(baslangicTarihi: _gun, berberId: berberId, saat: saat),
    );
    if (eklendi == true) _yukle();
  }

  /// Takvimde bırakılan randevu: onay → taşı. Çakışırsa sunucunun önerdiği saatler gösterilir.
  Future<void> _tasi(Map<String, dynamic> r, int berberId, String saat) async {
    final ayniBerber = r['berber']['id'] == berberId;
    if (ayniBerber && r['saat'] == saat) return;
    final hedef = ((_veri?['doluluk'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .where((d) => d['berber_id'] == berberId)
        .map((d) => d['ad'] as String)
        .firstOrNull;
    if (!await onayIste(
      context,
      Dil.t.randevuyuTasi,
      '${r['musteri']['ad']} · ${r['saat']} → $saat${ayniBerber ? '' : ' (${hedef ?? Dil.t.digerPersonel})'}\n'
          '${Dil.t.tasimaAciklama}',
      evet: Dil.t.tasi,
    )) {
      return;
    }
    try {
      await PanelApi.randevuTasi(r['id'], berberId: berberId, tarih: tarihStr(_gun), saat: saat);
      if (mounted) bilgiGoster(context, Dil.t.saatineTasindi(saat));
    } on ApiHata catch (e) {
      if (mounted) {
        bilgiGoster(
          context,
          e.oneriler.isEmpty ? e.mesaj : '${e.mesaj} ${Dil.t.uygunSaatler(e.oneriler.take(4).join(', '))}',
          hata: true,
          sure: const Duration(seconds: 6),
        );
      }
    }
    await _yukle();
  }

  /// Takvimdeki randevuya dokununca: listedeki kartın aynısı (aksiyonlarıyla) alt sayfada.
  Future<void> _randevuDetay(Map<String, dynamic> r) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: AkisRandevuKarti(
            randevu: r,
            islemde: false,
            onDurum: (d) {
              Navigator.pop(ctx);
              _durum(r, d);
            },
            onWhatsapp: () => _harici(Harici.ac(Uri.parse(r['whatsapp_link']))),
            onAra: () => _harici(Harici.ara(r['musteri']['telefon'])),
            onMusteri: () {
              Navigator.pop(ctx);
              _musteriKarti(r);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _musteriKarti(Map<String, dynamic> r) async {
    var degisti = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => MusteriKartiSheet(musteriId: r['musteri']['id'], onNotDegisti: () => degisti = true),
    );
    if (degisti) _yukle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _randevuEkle,
        backgroundColor: AppTheme.gold,
        foregroundColor: AppTheme.black,
        icon: const Icon(Icons.add),
        label: Text(Dil.t.randevuEkle, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _GunSecici(gun: _gun, onSecim: _gunDegistir),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _takvim ? Dil.t.tasimaIpucu : '',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ),
                SegmentedButton<bool>(
                  key: ValueKey('akis_gorunum'),
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                selectedBackgroundColor: AppTheme.gold,
                selectedForegroundColor: AppTheme.black,
                foregroundColor: AppTheme.gold,
                side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.5)),
              ),
                  segments: [
                    ButtonSegment(value: false, icon: Icon(Icons.view_agenda_outlined, size: 18), tooltip: Dil.t.liste),
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.calendar_view_day_outlined, size: 18),
                      tooltip: Dil.t.takvim,
                    ),
                  ],
                  selected: {_takvim},
                  onSelectionChanged: (s) => _gorunumSec(s.first),
                ),
              ],
            ),
          ),
          Expanded(
            child: AsenkronGorunum(
              yukleniyor: _veri == null && _hata == null,
              hata: _hata,
              onTekrar: _yukle,
              builder: (_) => _takvim
                  ? GunTakvimi(
                      veri: _veri!,
                      personel: widget.personel,
                      onRandevu: _randevuDetay,
                      onBosHucre: (b, s) => _randevuEkle(berberId: b, saat: s),
                      onTasi: _tasi,
                    )
                  : _liste(_veri!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _liste(Map<String, dynamic> v) {
    final randevular = (v['randevular'] as List).cast<Map<String, dynamic>>();
    return RefreshIndicator(
      color: AppTheme.gold,
      onRefresh: _yukle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          AkisOzetKartlari(ozet: v['ozet']),
          if (v['siradaki'] != null) SiradakiKarti(randevu: v['siradaki']),
          DolulukCipleri(doluluk: (v['doluluk'] as List).cast<Map<String, dynamic>>()),
          const SizedBox(height: 8),
          if (randevular.isEmpty)
            BosGorunum(
              ikon: Icons.event_available,
              mesaj: Dil.t.buGunRandevuYok,
              altMesaj: Dil.t.randevuEkleIpucu,
            )
          else
            for (final r in randevular)
              AkisRandevuKarti(
                randevu: r,
                islemde: _islemde.contains(r['id']),
                onDurum: (d) => _durum(r, d),
                onWhatsapp: () => _harici(Harici.ac(Uri.parse(r['whatsapp_link']))),
                onAra: () => _harici(Harici.ara(r['musteri']['telefon'])),
                onMusteri: () => _musteriKarti(r),
              ),
        ],
      ),
    );
  }
}

/// Dün / Bugün / Yarın + takvimden tarih.
class _GunSecici extends StatelessWidget {
  final DateTime gun;
  final ValueChanged<DateTime> onSecim;
  const _GunSecici({required this.gun, required this.onSecim});

  @override
  Widget build(BuildContext context) {
    final bugun = DateTime.now();
    final secenekler = [
      (bugun.subtract(const Duration(days: 1)), Dil.t.dun),
      (bugun, Dil.t.bugun),
      (bugun.add(const Duration(days: 1)), Dil.t.yarin),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          // Uzun etiketlerde (İngilizce, büyük yazı) taşmasın: çipler kendi içinde kayar
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final (tarih, etiket) in secenekler)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(etiket),
                      visualDensity: VisualDensity.compact,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      selected: tarihStr(gun) == tarihStr(tarih),
                      onSelected: (_) => onSecim(tarih),
                      selectedColor: AppTheme.gold,
                      showCheckmark: false,
                    ),
                  ),
              ]),
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              final g = await showDatePicker(
                context: context,
                initialDate: gun,
                firstDate: bugun.subtract(const Duration(days: 90)),
                lastDate: bugun.add(const Duration(days: 90)),
              );
              if (g != null) onSecim(g);
            },
            icon: const Icon(Icons.calendar_month, size: 18),
            label: Text(gunAyKisa(gun)),
          ),
        ],
      ),
    );
  }
}
