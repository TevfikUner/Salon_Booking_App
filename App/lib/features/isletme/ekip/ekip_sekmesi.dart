import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/panel_api.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';

/// Personel ve hizmet menüsü yönetimi.
class EkipSekmesi extends StatefulWidget {
  const EkipSekmesi({super.key});

  @override
  State<EkipSekmesi> createState() => _EkipSekmesiState();
}

class _EkipSekmesiState extends State<EkipSekmesi> {
  List<Map<String, dynamic>> _personel = [];
  List<Map<String, dynamic>> _hizmetler = [];
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
      final s = await Future.wait([PanelApi.personel(), PanelApi.hizmetler()]);
      if (mounted) {
        setState(() {
          _personel = s[0];
          _hizmetler = s[1];
        });
      }
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _calistir(Future<void> Function() islem, String basari) async {
    try {
      await islem();
      if (mounted) bilgiGoster(context, basari);
      await _yukle();
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    }
  }

  // ── Personel ──
  Future<void> _personelEkle() async {
    final ad = TextEditingController(), soyad = TextEditingController(), unvan = TextEditingController(text: 'Berber'),
        email = TextEditingController();
    final tamam = await _form('Personel Ekle', [
      TextField(controller: ad, textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Ad')),
      TextField(controller: soyad, textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Soyad')),
      TextField(controller: unvan, decoration: const InputDecoration(labelText: 'Unvan (Usta, Kalfa...)')),
      TextField(controller: email, keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'E-posta (isteğe bağlı)',
              helperText: 'Personel bu e-postayla kayıt olursa kendi takvimini görür.', helperMaxLines: 2)),
    ]);
    if (tamam != true || ad.text.trim().isEmpty) return;
    await _calistir(
        () => PanelApi.personelEkle({
              'ad': ad.text.trim(),
              'soyad': soyad.text.trim(),
              'uzmanlik': unvan.text.trim().isEmpty ? 'Berber' : unvan.text.trim(),
              'email': email.text.trim().isEmpty ? null : email.text.trim(),
            }),
        'Personel eklendi.');
  }

  Future<void> _personelCikar(Map<String, dynamic> p) async {
    if (!await onayIste(context, 'Kadrodan çıkar', '${p['ad']} ${p['soyad']} kadrodan çıkarılsın mı? '
        'Geçmiş randevu kayıtları korunur.', evet: 'Çıkar', tehlikeli: true)) {
      return;
    }
    await _calistir(() => PanelApi.personelCikar(p['id']), 'Personel kadrodan çıkarıldı.');
  }

  // ── Hizmet ──
  Future<void> _hizmetFormu([Map<String, dynamic>? h]) async {
    final ad = TextEditingController(text: h?['ad'] ?? '');
    final fiyat = TextEditingController(text: h == null ? '' : (h['fiyat'] as num).toStringAsFixed(0));
    final sure = TextEditingController(text: h == null ? '30' : '${h['sure']}');
    final aciklama = TextEditingController(text: h?['aciklama'] ?? '');
    final tamam = await _form(h == null ? 'Hizmet Ekle' : 'Hizmeti Düzenle', [
      TextField(controller: ad, decoration: const InputDecoration(labelText: 'Hizmet adı')),
      TextField(controller: fiyat, keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Fiyat', suffixText: '₺')),
      TextField(controller: sure, keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Süre', suffixText: 'dk')),
      TextField(controller: aciklama, decoration: const InputDecoration(labelText: 'Açıklama (isteğe bağlı)')),
      if (h != null)
        Text('Fiyat değişikliği mevcut randevuları etkilemez.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
    ]);
    if (tamam != true) return;
    final f = double.tryParse(fiyat.text), s = int.tryParse(sure.text);
    if (ad.text.trim().isEmpty || f == null || s == null || s < 5) {
      if (mounted) bilgiGoster(context, 'Ad, fiyat ve en az 5 dakikalık süre girin.', hata: true);
      return;
    }
    await _calistir(
        () => PanelApi.hizmetKaydet({
              'ad': ad.text.trim(),
              'fiyat': f,
              'sure': s,
              'aciklama': aciklama.text.trim().isEmpty ? null : aciklama.text.trim(),
            }, id: h?['id']),
        h == null ? 'Hizmet eklendi.' : 'Hizmet güncellendi.');
  }

  Future<void> _hizmetKaldir(Map<String, dynamic> h) async {
    if (!await onayIste(context, 'Menüden kaldır', '"${h['ad']}" menüden kaldırılsın mı?',
        evet: 'Kaldır', tehlikeli: true)) {
      return;
    }
    await _calistir(() => PanelApi.hizmetKaldir(h['id']), 'Hizmet kaldırıldı.');
  }

  Future<bool?> _form(String baslik, List<Widget> alanlar) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(baslik, style: GoogleFonts.playfairDisplay(color: AppTheme.gold)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final a in alanlar) Padding(padding: const EdgeInsets.only(bottom: 10), child: a),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
    if (_hata != null) return HataGorunumu(mesaj: _hata!, onTekrar: _yukle);
    return RefreshIndicator(
      color: AppTheme.gold,
      onRefresh: _yukle,
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
        _bolum('Personel', 'Ekle', _personelEkle),
        if (_personel.isEmpty) const BosGorunum(ikon: Icons.groups_outlined, mesaj: 'Henüz personel yok.'),
        for (final p in _personel)
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: AppTheme.card, child: Icon(Icons.person, color: AppTheme.gold)),
              title: Text('${p['ad']} ${p['soyad']}'.trim(), style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                  '${p['uzmanlik']} · ★ ${(p['puan'] as num).toStringAsFixed(1)}'
                  '${p['hesap_bagli'] == true ? ' · hesabı bağlı' : (p['email'] != null ? ' · davet: ${p['email']}' : '')}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              trailing: IconButton(
                  tooltip: 'Kadrodan çıkar',
                  icon: const Icon(Icons.person_remove_outlined, color: AppTheme.error),
                  onPressed: () => _personelCikar(p)),
            ),
          ),
        const SizedBox(height: 16),
        _bolum('Hizmet Menüsü', 'Ekle', () => _hizmetFormu()),
        if (_hizmetler.isEmpty) const BosGorunum(ikon: Icons.content_cut, mesaj: 'Henüz hizmet yok.'),
        for (final h in _hizmetler)
          Card(
            child: ListTile(
              onTap: () => _hizmetFormu(h),
              title: Text(h['ad'], style: const TextStyle(color: Colors.white)),
              subtitle: Text(sureMetni(h['sure']), style: const TextStyle(color: AppTheme.textSecondary)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(tl(h['fiyat']), style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 17,
                    fontWeight: FontWeight.bold)),
                IconButton(
                    tooltip: 'Menüden kaldır',
                    icon: const Icon(Icons.delete_outline, color: AppTheme.textSecondary),
                    onPressed: () => _hizmetKaldir(h)),
              ]),
            ),
          ),
      ]),
    );
  }

  Widget _bolum(String baslik, String buton, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Text(baslik, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton.icon(onPressed: onTap, icon: const Icon(Icons.add, size: 18), label: Text(buton)),
        ]),
      );
}
