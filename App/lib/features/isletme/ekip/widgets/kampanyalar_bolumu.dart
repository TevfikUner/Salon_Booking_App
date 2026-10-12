import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/panel_api.dart';
import 'package:berber_app_ui/features/isletme/kapali_gunler/widgets/saat_secici.dart';
import 'package:berber_app_ui/features/kesfet/widgets/kampanya_bilesenleri.dart';

/// Ekip & Menü sekmesinde: kampanyalar (gün/saat/tarih/hizmet koşullu yüzde indirim) ve sadakat kartı.
/// İndirim randevu anında hesaplanıp mühürlenir; değişiklikler yalnızca yeni randevulara uygulanır.
class KampanyalarBolumu extends StatefulWidget {
  /// Menü (kampanya formunda hizmet seçimi için)
  final List<Json> hizmetler;
  const KampanyalarBolumu({super.key, required this.hizmetler});

  @override
  State<KampanyalarBolumu> createState() => _KampanyalarBolumuState();
}

class _KampanyalarBolumuState extends State<KampanyalarBolumu> {
  List<Json>? _kampanyalar;
  Json? _salon;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _hata = null);
    try {
      final s = await Future.wait([PanelApi.kampanyalar(), PanelApi.salon()]);
      if (mounted) {
        setState(() {
          _kampanyalar = s[0] as List<Json>;
          _salon = s[1] as Json;
        });
      }
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    }
  }

  Future<void> _kampanyaFormu([Json? k]) async {
    final veri = await showModalBottomSheet<Json>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _KampanyaFormu(mevcut: k, hizmetler: widget.hizmetler),
    );
    if (veri == null || !mounted) return;
    try {
      await PanelApi.kampanyaKaydet(veri, id: k?['id']);
      if (mounted) bilgiGoster(context, k == null ? 'Kampanya eklendi.' : 'Kampanya güncellendi.');
      await _yukle();
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    }
  }

  Future<void> _sil(Json k) async {
    if (!await onayIste(context, 'Kampanyayı kaldır',
        '"${k['ad']}" kaldırılsın mı? Bu kampanyayla alınmış randevuların indirimi korunur.',
        evet: 'Kaldır', tehlikeli: true)) {
      return;
    }
    try {
      await PanelApi.kampanyaSil(k['id']);
      await _yukle();
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    }
  }

  Future<void> _sadakat() async {
    final esik = TextEditingController(text: '${_salon?['sadakat_esik'] ?? 10}');
    final yuzde = TextEditingController(text: '${_salon?['sadakat_yuzde'] ?? 50}');
    final acik = _salon?['sadakat_esik'] != null;
    final sonuc = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Sadakat kartı', style: GoogleFonts.playfairDisplay(color: AppTheme.gold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Müşterinin bu salondaki her N. randevusu indirimli olur. Tamamlanan ve alınmış randevular sayılır; '
              'gelinmeyen ve iptal edilenler sayılmaz.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          TextField(
            controller: esik,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Kaçıncı ziyaret (2–50)', suffixText: '. ziyaret'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: yuzde,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'İndirim (5–100)', suffixText: '%'),
          ),
        ]),
        actions: [
          if (acik) TextButton(onPressed: () => Navigator.pop(ctx, 'kapat'), child: const Text('Kapat')),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, 'kaydet'), child: const Text('Kaydet')),
        ],
      ),
    );
    if (sonuc == null || !mounted) return;
    final e = int.tryParse(esik.text), y = int.tryParse(yuzde.text);
    if (sonuc == 'kaydet' && (e == null || e < 2 || e > 50 || y == null || y < 5 || y > 100)) {
      bilgiGoster(context, 'Ziyaret 2–50, indirim 5–100 arasında olmalı.', hata: true);
      return;
    }
    try {
      await PanelApi.sadakatAyarla(esik: sonuc == 'kaydet' ? e : null, yuzde: sonuc == 'kaydet' ? y : null);
      if (mounted) bilgiGoster(context, sonuc == 'kaydet' ? 'Sadakat kartı: her $e. ziyaret %$y.' : 'Sadakat kartı kapatıldı.');
      await _yukle();
    } on ApiHata catch (err) {
      if (mounted) bilgiGoster(context, err.mesaj, hata: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baslik = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text('Kampanyalar',
            style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const Spacer(),
        TextButton.icon(
            key: const ValueKey('kampanya_ekle'),
            onPressed: _kampanyalar == null ? null : () => _kampanyaFormu(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Ekle')),
      ]),
    );
    if (_hata != null) return Column(children: [baslik, HataGorunumu(mesaj: _hata!, onTekrar: _yukle)]);
    if (_kampanyalar == null) {
      return Column(children: [baslik, const Padding(padding: EdgeInsets.all(16), child: Yukleniyor())]);
    }
    final esik = _salon?['sadakat_esik'], yuzde = _salon?['sadakat_yuzde'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      baslik,
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text('Boş günleri doldurmak için: ör. "Salı %20" veya "Hafta içi 10:00–14:00 sakal %30". '
            'İndirimler üst üste binmez; müşteriye en yüksek olanı uygulanır.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
      ),
      if (_kampanyalar!.isEmpty) const BosGorunum(ikon: Icons.local_offer_outlined, mesaj: 'Henüz kampanya yok.'),
      for (final k in _kampanyalar!)
        Card(
          child: ListTile(
            onTap: () => _kampanyaFormu(k),
            leading: IndirimRozeti(yuzde: k['yuzde'], yaziBoyu: 13),
            title: Text(k['ad'], style: const TextStyle(color: Colors.white)),
            subtitle: Text(
                '${k['kosul']}${_durum(k)}'
                '${(k['randevu_sayisi'] as int? ?? 0) > 0 ? '\n${k['randevu_sayisi']} randevuda kullanıldı' : ''}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            trailing: IconButton(
                tooltip: 'Kaldır',
                icon: const Icon(Icons.delete_outline, color: AppTheme.textSecondary),
                onPressed: () => _sil(k)),
          ),
        ),
      const SizedBox(height: 8),
      Card(
        child: ListTile(
          key: const ValueKey('sadakat_ayari'),
          onTap: _sadakat,
          leading: const Icon(Icons.card_giftcard, color: AppTheme.gold),
          title: const Text('Sadakat kartı', style: TextStyle(color: Colors.white)),
          subtitle: Text(esik == null ? 'Kapalı · açmak için dokunun' : 'Her $esik. ziyaret %$yuzde indirimli',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        ),
      ),
    ]);
  }

  String _durum(Json k) {
    if (k['aktif'] != true) return ' · Duraklatıldı';
    if (k['suresi_doldu'] == true) return ' · Süresi doldu';
    return '';
  }
}

/// Kampanya ekleme/düzenleme formu. Kaydedilirse API gövdesini döner.
class _KampanyaFormu extends StatefulWidget {
  final Json? mevcut;
  final List<Json> hizmetler;
  const _KampanyaFormu({required this.mevcut, required this.hizmetler});

  @override
  State<_KampanyaFormu> createState() => _KampanyaFormuState();
}

class _KampanyaFormuState extends State<_KampanyaFormu> {
  late final _ad = TextEditingController(text: widget.mevcut?['ad'] ?? '');
  late final _yuzde = TextEditingController(text: '${widget.mevcut?['yuzde'] ?? 20}');
  late Set<int> _gunler = gunListesi(widget.mevcut?['gunler']);
  late String? _basSaat = widget.mevcut?['bas_saat'], _bitSaat = widget.mevcut?['bit_saat'];
  late String? _basTarih = widget.mevcut?['bas_tarih'], _bitTarih = widget.mevcut?['bit_tarih'];
  late final Set<int> _hizmetler = {...List<int>.from(widget.mevcut?['hizmet_idler'] ?? const [])};
  late bool _aktif = widget.mevcut?['aktif'] ?? true;

  @override
  void dispose() {
    _ad.dispose();
    _yuzde.dispose();
    super.dispose();
  }

  Future<void> _tarihSec(bool bas) async {
    final simdi = DateTime.now();
    final ilk = DateTime.tryParse((bas ? _basTarih : _bitTarih) ?? '') ?? simdi;
    final g = await showDatePicker(
      context: context,
      initialDate: ilk.isBefore(simdi) ? simdi : ilk,
      firstDate: DateTime(simdi.year, simdi.month, simdi.day),
      lastDate: simdi.add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );
    if (g != null) setState(() => bas ? _basTarih = tarihStr(g) : _bitTarih = tarihStr(g));
  }

  void _kaydet() {
    final y = int.tryParse(_yuzde.text);
    if (_ad.text.trim().isEmpty || y == null || y < 5 || y > 90) {
      bilgiGoster(context, 'Ad girin; indirim %5 ile %90 arasında olmalı.', hata: true);
      return;
    }
    if (_basTarih != null && _bitTarih != null && _bitTarih!.compareTo(_basTarih!) < 0) {
      bilgiGoster(context, 'Bitiş tarihi başlangıçtan önce olamaz.', hata: true);
      return;
    }
    Navigator.pop(context, {
      'ad': _ad.text.trim(),
      'yuzde': y,
      'gunler': gunListesiMetni(_gunler),
      'bas_saat': _basSaat,
      'bit_saat': _bitSaat,
      'bas_tarih': _basTarih,
      'bit_tarih': _bitTarih,
      'hizmet_idler': _hizmetler.toList(),
      'aktif': _aktif,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        builder: (_, ctrl) => ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20, 20, 20, 24), children: [
          Text(widget.mevcut == null ? 'Yeni Kampanya' : 'Kampanyayı Düzenle',
              style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Boş bıraktığınız koşul kısıt koymaz. Değişiklik yalnızca bundan sonraki randevulara uygulanır.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              flex: 3,
              child: TextField(
                  key: const ValueKey('kampanya_ad'),
                  controller: _ad,
                  maxLength: 60,
                  decoration: const InputDecoration(labelText: 'Kampanya adı', hintText: 'Salı İndirimi', counterText: '')),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextField(
                  key: const ValueKey('kampanya_yuzde'),
                  controller: _yuzde,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'İndirim', suffixText: '%')),
            ),
          ]),
          _baslik('Günler', _gunler.isEmpty ? 'Her gün' : null),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (var g = 0; g < 7; g++)
              FilterChip(
                label: Text(gunKisaAdlari[g]),
                selected: _gunler.contains(g),
                onSelected: (s) => setState(() => _gunler = s ? ({..._gunler, g}) : (_gunler.difference({g}))),
                selectedColor: AppTheme.gold,
                checkmarkColor: AppTheme.black,
                labelStyle: TextStyle(color: _gunler.contains(g) ? AppTheme.black : Colors.white),
              ),
          ]),
          _baslik('Saat aralığı', _basSaat == null ? 'Gün boyu' : null),
          Row(children: [
            OutlinedButton.icon(
              onPressed: () async {
                final a = await saatAraligiSec(context, bas: _basSaat ?? '10:00', bit: _bitSaat ?? '14:00');
                if (a != null) {
                  setState(() {
                    _basSaat = a.$1;
                    _bitSaat = a.$2;
                  });
                }
              },
              icon: const Icon(Icons.schedule, size: 16),
              label: Text(_basSaat == null ? 'Saat aralığı seç' : '$_basSaat – $_bitSaat'),
            ),
            if (_basSaat != null)
              IconButton(
                  tooltip: 'Gün boyu',
                  onPressed: () => setState(() => _basSaat = _bitSaat = null),
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary)),
          ]),
          _baslik('Tarih aralığı', _basTarih == null && _bitTarih == null ? 'Süresiz' : null),
          Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
            OutlinedButton(
                onPressed: () => _tarihSec(true),
                child: Text(_basTarih == null ? 'Başlangıç: hemen' : 'Başlangıç: ${tarihUzun(_basTarih!)}')),
            OutlinedButton(
                onPressed: () => _tarihSec(false),
                child: Text(_bitTarih == null ? 'Bitiş: yok' : 'Bitiş: ${tarihUzun(_bitTarih!)}')),
            if (_basTarih != null || _bitTarih != null)
              TextButton(onPressed: () => setState(() => _basTarih = _bitTarih = null), child: const Text('Temizle')),
          ]),
          _baslik('Hizmetler', _hizmetler.isEmpty ? 'Tüm hizmetler' : null),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final h in widget.hizmetler)
              FilterChip(
                label: Text(h['ad']),
                selected: _hizmetler.contains(h['id']),
                onSelected: (s) => setState(() => s ? _hizmetler.add(h['id']) : _hizmetler.remove(h['id'])),
                selectedColor: AppTheme.gold.withValues(alpha: 0.3),
                checkmarkColor: AppTheme.gold,
              ),
          ]),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _aktif,
            onChanged: (v) => setState(() => _aktif = v),
            activeThumbColor: AppTheme.gold,
            title: const Text('Kampanya açık', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Kapatırsanız silinmez, duraklatılır.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(key: const ValueKey('kampanya_kaydet'), onPressed: _kaydet, child: const Text('Kaydet')),
        ]),
      ),
    );
  }

  Widget _baslik(String metin, String? varsayilan) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(children: [
          Text(metin, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          if (varsayilan != null) ...[
            const SizedBox(width: 8),
            Text('($varsayilan)', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ]),
      );
}
