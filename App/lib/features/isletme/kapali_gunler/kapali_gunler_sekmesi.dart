import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/panel_api.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/features/isletme/kapali_gunler/widgets/mola_karti.dart';
import 'package:berber_app_ui/features/isletme/kapali_gunler/widgets/onceden_karti.dart';
import 'package:berber_app_ui/features/isletme/kapali_gunler/widgets/saat_secici.dart';

/// Salonun öğle arası, kapalı günleri (tatil), personel izinleri ve saatlik kapatmaları.
class KapaliGunlerSekmesi extends StatefulWidget {
  const KapaliGunlerSekmesi({super.key});

  @override
  State<KapaliGunlerSekmesi> createState() => _KapaliGunlerSekmesiState();
}

class _KapaliGunlerSekmesiState extends State<KapaliGunlerSekmesi> {
  List<Map<String, dynamic>> _tatiller = [];
  List<Map<String, dynamic>> _izinler = [];
  List<Map<String, dynamic>> _blokeler = [];
  List<Map<String, dynamic>> _personel = [];
  Map<String, dynamic>? _salon;
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
      final s = await Future.wait([PanelApi.kapaliGunler(), PanelApi.personel(), PanelApi.salon()]);
      final g = s[0] as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _tatiller = (g['tatiller'] as List).cast<Map<String, dynamic>>();
          _izinler = (g['izinler'] as List).cast<Map<String, dynamic>>();
          _blokeler = ApiClient.liste(g['blokeler']);
          _personel = (s[1] as List).cast<Map<String, dynamic>>();
          _salon = s[2] as Map<String, dynamic>;
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
        locale: Dil.ingilizce ? const Locale('en') : const Locale('tr', 'TR'),
      );

  Future<String?> _aciklamaSor(String baslik) async {
    final c = TextEditingController();
    final tamam = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(baslik, style: GoogleFonts.playfairDisplay(color: AppTheme.gold)),
        content: TextField(controller: c, decoration: InputDecoration(labelText: Dil.t.aciklamaIstegeBagli)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(Dil.t.vazgec)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(Dil.t.kaydet)),
        ],
      ),
    );
    if (tamam != true) return null;
    return c.text.trim();
  }

  Future<void> _tatilEkle() async {
    final g = await _gunSec();
    if (g == null) return;
    final a = await _aciklamaSor(Dil.t.salonKapaliTarih(tarihUzun(tarihStr(g))));
    if (a == null) return;
    try {
      final v = await PanelApi.tatilEkle(tarihStr(g), a.isEmpty ? null : a);
      if (mounted) bilgiGoster(context, v['uyari'] ?? Dil.t.kapaliGunEklendi, hata: v['uyari'] != null);
      _yukle();
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    }
  }

  Future<Map<String, dynamic>?> _personelSec(String soru) async {
    if (_personel.isEmpty) {
      bilgiGoster(context, Dil.t.oncePersonelEkle, hata: true);
      return null;
    }
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (ctx) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          ListTile(title: Text(soru, style: const TextStyle(color: AppTheme.gold))),
          for (final p in _personel)
            ListTile(
              leading: const Icon(Icons.person, color: AppTheme.gold),
              title: Text('${p['ad']} ${p['soyad']}'.trim()),
              onTap: () => Navigator.pop(ctx, p),
            ),
        ]),
      ),
    );
  }

  /// Personeli bir günün belirli saatlerinde kapatır (ör. 14:00–16:00 dışarıda).
  Future<void> _blokeEkle() async {
    final secilen = await _personelSec(Dil.t.hangiPersonel);
    if (secilen == null || !mounted) return;
    final g = await _gunSec();
    if (g == null || !mounted) return;
    final aralik = await saatAraligiSec(context, bas: '14:00', bit: '15:00');
    if (aralik == null) return;
    final a = await _aciklamaSor('${secilen['ad']} · ${tarihUzun(tarihStr(g))} ${aralik.$1}–${aralik.$2}');
    if (a == null) return;
    try {
      final v = await PanelApi.blokeEkle(
          berberId: secilen['id'], tarih: tarihStr(g), bas: aralik.$1, bit: aralik.$2, aciklama: a.isEmpty ? null : a);
      final etk = v['etkilenen_randevu'] as int? ?? 0;
      if (mounted) {
        bilgiGoster(context, etk > 0 ? Dil.t.saatlerdeRandevuVar(etk)
            : Dil.t.kaydedildi, hata: etk > 0);
      }
      _yukle();
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    }
  }

  Future<void> _izinEkle() async {
    final secilen = await _personelSec(Dil.t.hangiPersonelIzinli);
    if (secilen == null) return;
    final g = await _gunSec();
    if (g == null) return;
    try {
      final v = await PanelApi.izinEkle(secilen['id'], tarihStr(g), null);
      final etk = v['etkilenen_randevu'] as int? ?? 0;
      if (mounted) {
        bilgiGoster(context, etk > 0 ? Dil.t.izinGununderandevuVar(etk)
            : Dil.t.izinEklendi, hata: etk > 0);
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
        Text(Dil.t.kapaliAciklama,
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        if (_salon != null) MolaKarti(salon: _salon!, onDegisti: (s) => setState(() => _salon = s)),
        if (_salon != null) OncedenKarti(salon: _salon!, onDegisti: (s) => setState(() => _salon = s)),
        _baslik(Dil.t.salonKapaliGunler, _tatilEkle),
        if (_tatiller.isEmpty) _bos(Dil.t.kapaliGunYok),
        for (final t in _tatiller)
          Card(
            child: ListTile(
              leading: const Icon(Icons.store_mall_directory_outlined, color: AppTheme.error),
              title: Text(tarihUzun(t['tarih'], yil: true), style: const TextStyle(color: Colors.white)),
              subtitle: t['aciklama'] != null ? Text(t['aciklama']) : null,
              trailing: IconButton(
                  tooltip: Dil.t.kaldir, icon: const Icon(Icons.close),
                  onPressed: () => _sil(() => PanelApi.tatilSil(t['id']))),
            ),
          ),
        const SizedBox(height: 12),
        _baslik(Dil.t.personelIzinleri, _izinEkle),
        if (_izinler.isEmpty) _bos(Dil.t.izinYok),
        for (final i in _izinler)
          Card(
            child: ListTile(
              leading: const Icon(Icons.beach_access_outlined, color: AppTheme.gold),
              title: Text('${i['berber']} · ${tarihUzun(i['tarih'])}', style: const TextStyle(color: Colors.white)),
              subtitle: i['aciklama'] != null ? Text(i['aciklama']) : null,
              trailing: IconButton(
                  tooltip: Dil.t.kaldir, icon: const Icon(Icons.close),
                  onPressed: () => _sil(() => PanelApi.izinSil(i['id']))),
            ),
          ),
        const SizedBox(height: 12),
        _baslik(Dil.t.saatlikKapatmalar, _blokeEkle),
        if (_blokeler.isEmpty) _bos(Dil.t.kapatilmisSaatYok),
        for (final b in _blokeler)
          Card(
            child: ListTile(
              leading: const Icon(Icons.timelapse, color: AppTheme.gold),
              title: Text('${b['berber']} · ${tarihUzun(b['tarih'])}', style: const TextStyle(color: Colors.white)),
              subtitle: Text('${b['bas_saat']}–${b['bit_saat']}${b['aciklama'] != null ? ' · ${b['aciklama']}' : ''}'),
              trailing: IconButton(
                  tooltip: Dil.t.kaldir, icon: const Icon(Icons.close),
                  onPressed: () => _sil(() => PanelApi.blokeSil(b['id']))),
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
          TextButton.icon(onPressed: ekle, icon: const Icon(Icons.add, size: 18), label: Text(Dil.t.ekle)),
        ]),
      );

  Widget _bos(String m) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(m, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
      );
}
