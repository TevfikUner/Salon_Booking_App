import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/utils/harici.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/panel_api.dart';
import 'package:berber_app_ui/features/isletme/akis/randevu_ekle_sheet.dart';
import 'package:berber_app_ui/features/isletme/akis/widgets/akis_ozeti.dart';
import 'package:berber_app_ui/features/isletme/akis/widgets/akis_randevu_karti.dart';

/// İmza özellik — "Bugünün Akışı": günün randevuları saat sırasıyla, müşteri/hizmet/süre/ücret,
/// güven skoru ve tek dokunuş WhatsApp onay mesajı.
class AkisSekmesi extends StatefulWidget {
  final bool personel;
  const AkisSekmesi({super.key, this.personel = false});

  @override
  State<AkisSekmesi> createState() => _AkisSekmesiState();
}

class _AkisSekmesiState extends State<AkisSekmesi> {
  DateTime _gun = DateTime.now();
  Map<String, dynamic>? _veri;
  String? _hata;
  final Set<int> _islemde = {};

  @override
  void initState() {
    super.initState();
    _yukle();
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
        !await onayIste(context, 'Randevuyu iptal et',
            '${r['musteri']['ad']} — ${r['saat']} randevusu iptal edilsin mi? Müşteriye bildirim gönderilir.',
            evet: 'İptal Et', tehlikeli: true)) {
      return;
    }
    setState(() => _islemde.add(r['id']));
    try {
      await PanelApi.durumGuncelle(r['id'], durum);
      if (mounted) bilgiGoster(context, 'Randevu güncellendi.');
      await _yukle();
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _islemde.remove(r['id']));
    }
  }

  Future<void> _harici(Future<bool> islem) async {
    if (!await islem && mounted) bilgiGoster(context, 'Uygulama açılamadı.', hata: true);
  }

  Future<void> _randevuEkle() async {
    final eklendi = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => RandevuEkleSheet(baslangicTarihi: _gun),
    );
    if (eklendi == true) _yukle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _randevuEkle,
        backgroundColor: AppTheme.gold,
        foregroundColor: AppTheme.black,
        icon: const Icon(Icons.add),
        label: const Text('Randevu Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(children: [
        _GunSecici(gun: _gun, onSecim: _gunDegistir),
        Expanded(
          child: AsenkronGorunum(
            yukleniyor: _veri == null && _hata == null,
            hata: _hata,
            onTekrar: _yukle,
            builder: (_) => _liste(_veri!),
          ),
        ),
      ]),
    );
  }

  Widget _liste(Map<String, dynamic> v) {
    final randevular = (v['randevular'] as List).cast<Map<String, dynamic>>();
    return RefreshIndicator(
      color: AppTheme.gold,
      onRefresh: _yukle,
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 96), children: [
        AkisOzetKartlari(ozet: v['ozet']),
        if (v['siradaki'] != null) SiradakiKarti(randevu: v['siradaki']),
        DolulukCipleri(doluluk: (v['doluluk'] as List).cast<Map<String, dynamic>>()),
        const SizedBox(height: 8),
        if (randevular.isEmpty)
          const BosGorunum(
              ikon: Icons.event_available,
              mesaj: 'Bu gün için randevu yok.',
              altMesaj: '"Randevu Ekle" ile telefonla gelen müşteriyi ekleyebilirsiniz.')
        else
          for (final r in randevular)
            AkisRandevuKarti(
              randevu: r,
              islemde: _islemde.contains(r['id']),
              onDurum: (d) => _durum(r, d),
              onWhatsapp: () => _harici(Harici.ac(Uri.parse(r['whatsapp_link']))),
              onAra: () => _harici(Harici.ara(r['musteri']['telefon'])),
            ),
      ]),
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
      (bugun.subtract(const Duration(days: 1)), 'Dün'),
      (bugun, 'Bugün'),
      (bugun.add(const Duration(days: 1)), 'Yarın'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        for (final (tarih, etiket) in secenekler)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(etiket),
              selected: tarihStr(gun) == tarihStr(tarih),
              onSelected: (_) => onSecim(tarih),
              selectedColor: AppTheme.gold,
              showCheckmark: false,
            ),
          ),
        const Spacer(),
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
          label: Text(tarihUzun(tarihStr(gun)).split(' ').take(2).join(' ')),
        ),
      ]),
    );
  }
}
