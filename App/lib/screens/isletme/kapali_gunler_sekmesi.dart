import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ortak.dart';

/// Salonun kapalı günleri (tatil) ve personel izinleri.
class KapaliGunlerSekmesi extends StatefulWidget {
  const KapaliGunlerSekmesi({super.key});

  @override
  State<KapaliGunlerSekmesi> createState() => _KapaliGunlerSekmesiState();
}

class _KapaliGunlerSekmesiState extends State<KapaliGunlerSekmesi> {
  List<Map<String, dynamic>> _tatiller = [];
  List<Map<String, dynamic>> _izinler = [];
  List<Map<String, dynamic>> _personel = [];
  bool _yukleniyor = true;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _hata = null);
    try {
      final s = await Future.wait([ApiService.panelKapaliGunler(), ApiService.panelPersonel()]);
      final g = s[0] as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _tatiller = (g['tatiller'] as List).cast<Map<String, dynamic>>();
          _izinler = (g['izinler'] as List).cast<Map<String, dynamic>>();
          _personel = (s[1] as List).cast<Map<String, dynamic>>();
        });
      }
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<DateTime?> _gunSec() => showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        locale: const Locale('tr', 'TR'),
      );

  Future<String?> _aciklamaSor(String baslik) async {
    final c = TextEditingController();
    final tamam = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(baslik, style: GoogleFonts.playfairDisplay(color: AppTheme.gold)),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Açıklama (isteğe bağlı)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kaydet')),
        ],
      ),
    );
    if (tamam != true) return null;
    return c.text.trim();
  }

  Future<void> _tatilEkle() async {
    final g = await _gunSec();
    if (g == null) return;
    final a = await _aciklamaSor('Salon kapalı: ${tarihUzun(tarihStr(g))}');
    if (a == null) return;
    try {
      final v = await ApiService.panelTatilEkle(tarihStr(g), a.isEmpty ? null : a);
      if (mounted) bilgiGoster(context, v['uyari'] ?? 'Kapalı gün eklendi.', hata: v['uyari'] != null);
      _yukle();
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    }
  }

  Future<void> _izinEkle() async {
    if (_personel.isEmpty) return;
    final secilen = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (ctx) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          const ListTile(title: Text('Hangi personel izinli?', style: TextStyle(color: AppTheme.gold))),
          for (final p in _personel)
            ListTile(
              leading: const Icon(Icons.person, color: AppTheme.gold),
              title: Text('${p['ad']} ${p['soyad']}'.trim()),
              onTap: () => Navigator.pop(ctx, p),
            ),
        ]),
      ),
    );
    if (secilen == null) return;
    final g = await _gunSec();
    if (g == null) return;
    try {
      final v = await ApiService.panelIzinEkle(secilen['id'], tarihStr(g), null);
      final etk = v['etkilenen_randevu'] as int? ?? 0;
      if (mounted) {
        bilgiGoster(context, etk > 0 ? 'İzin eklendi. Bu günde $etk aktif randevu var; müşterilere haber verin.'
            : 'İzin eklendi.', hata: etk > 0);
      }
      _yukle();
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    }
  }

  Future<void> _sil(Future<void> Function() islem) async {
    try {
      await islem();
      _yukle();
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
    if (_hata != null) return HataGorunumu(mesaj: _hata!, onTekrar: _yukle);
    return RefreshIndicator(
      color: AppTheme.gold,
      onRefresh: _yukle,
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
        Text('Kapalı gün ve izinlerde müşteriler randevu alamaz.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
        _baslik('Salonun kapalı olduğu günler', _tatilEkle),
        if (_tatiller.isEmpty) _bos('Planlanmış kapalı gün yok.'),
        for (final t in _tatiller)
          Card(
            child: ListTile(
              leading: const Icon(Icons.store_mall_directory_outlined, color: AppTheme.error),
              title: Text(tarihUzun(t['tarih'], yil: true), style: const TextStyle(color: Colors.white)),
              subtitle: t['aciklama'] != null ? Text(t['aciklama']) : null,
              trailing: IconButton(
                  tooltip: 'Kaldır', icon: const Icon(Icons.close),
                  onPressed: () => _sil(() => ApiService.panelTatilSil(t['id']))),
            ),
          ),
        const SizedBox(height: 12),
        _baslik('Personel izinleri', _izinEkle),
        if (_izinler.isEmpty) _bos('Planlanmış izin yok.'),
        for (final i in _izinler)
          Card(
            child: ListTile(
              leading: const Icon(Icons.beach_access_outlined, color: AppTheme.gold),
              title: Text('${i['berber']} · ${tarihUzun(i['tarih'])}', style: const TextStyle(color: Colors.white)),
              subtitle: i['aciklama'] != null ? Text(i['aciklama']) : null,
              trailing: IconButton(
                  tooltip: 'Kaldır', icon: const Icon(Icons.close),
                  onPressed: () => _sil(() => ApiService.panelIzinSil(i['id']))),
            ),
          ),
      ]),
    );
  }

  Widget _baslik(String t, VoidCallback ekle) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Row(children: [
          Expanded(child: Text(t, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 17,
              fontWeight: FontWeight.bold))),
          TextButton.icon(onPressed: ekle, icon: const Icon(Icons.add, size: 18), label: const Text('Ekle')),
        ]),
      );

  Widget _bos(String m) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(m, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
      );
}
