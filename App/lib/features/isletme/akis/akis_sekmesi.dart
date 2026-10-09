import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/panel_api.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/features/isletme/widgets/guven_rozeti.dart';
import 'package:berber_app_ui/features/isletme/akis/randevu_ekle_sheet.dart';

/// "Bugünün Akışı": günün randevuları saat sırasıyla, müşteri/hizmet/süre/ücret,
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
  bool _yukleniyor = true;
  final Set<int> _islemde = {};

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = _veri == null;
      _hata = null;
    });
    try {
      final v = await PanelApi.akis(tarih: tarihStr(_gun));
      if (mounted) setState(() => _veri = v);
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  void _gunDegistir(DateTime g) {
    setState(() {
      _gun = g;
      _veri = null;
    });
    _yukle();
  }

  Future<void> _tarihSec() async {
    final g = await showDatePicker(
      context: context,
      initialDate: _gun,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('tr', 'TR'),
    );
    if (g != null) _gunDegistir(g);
  }

  Future<void> _durum(Map<String, dynamic> r, String durum) async {
    final metin = {'tamamlandi': 'tamamlandı', 'gelmedi': 'gelmedi', 'iptal': 'iptal'}[durum];
    if (durum == 'iptal' &&
        !await onayIste(context, 'Randevuyu iptal et',
            '${r['musteri']['ad']} — ${r['saat']} randevusu iptal edilsin mi? Müşteriye bildirim gönderilir.',
            evet: 'İptal Et', tehlikeli: true)) {
      return;
    }
    setState(() => _islemde.add(r['id']));
    try {
      await PanelApi.durumGuncelle(r['id'], durum);
      if (mounted) bilgiGoster(context, 'Randevu "$metin" olarak işaretlendi.');
      await _yukle();
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _islemde.remove(r['id']));
    }
  }

  Future<void> _ac(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      bilgiGoster(context, 'Uygulama açılamadı.', hata: true);
    }
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
        _gunSecici(),
        Expanded(child: _govde()),
      ]),
    );
  }

  Widget _gunSecici() {
    final bugun = DateTime.now();
    final secenekler = [
      (bugun.subtract(const Duration(days: 1)), 'Dün'),
      (bugun, 'Bugün'),
      (bugun.add(const Duration(days: 1)), 'Yarın'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        for (final s in secenekler)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(s.$2),
              selected: tarihStr(_gun) == tarihStr(s.$1),
              onSelected: (_) => _gunDegistir(s.$1),
              selectedColor: AppTheme.gold,
              labelStyle: TextStyle(
                  color: tarihStr(_gun) == tarihStr(s.$1) ? AppTheme.black : Colors.white,
                  fontWeight: FontWeight.w600),
              backgroundColor: AppTheme.surface,
              showCheckmark: false,
            ),
          ),
        const Spacer(),
        TextButton.icon(
          onPressed: _tarihSec,
          icon: const Icon(Icons.calendar_month, size: 18),
          label: Text(tarihUzun(tarihStr(_gun)).split(' ').take(2).join(' ')),
        ),
      ]),
    );
  }

  Widget _govde() {
    if (_yukleniyor) return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
    if (_hata != null) return HataGorunumu(mesaj: _hata!, onTekrar: _yukle);
    final v = _veri!;
    final ozet = v['ozet'] as Map<String, dynamic>;
    final randevular = (v['randevular'] as List).cast<Map<String, dynamic>>();
    return RefreshIndicator(
      color: AppTheme.gold,
      onRefresh: _yukle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          _ozetKartlari(ozet),
          if (v['siradaki'] != null) _siradaki(v['siradaki']),
          _doluluk((v['doluluk'] as List).cast<Map<String, dynamic>>()),
          const SizedBox(height: 8),
          if (randevular.isEmpty)
            const BosGorunum(ikon: Icons.event_available, mesaj: 'Bu gün için randevu yok.\n"Randevu Ekle" ile telefonla gelen müşteriyi ekleyebilirsiniz.')
          else
            ...randevular.map(_randevuKarti),
        ],
      ),
    );
  }

  Widget _ozetKartlari(Map<String, dynamic> o) {
    Widget kart(String deger, String etiket, IconData ikon, {Color renk = AppTheme.gold}) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: renk.withValues(alpha: 0.25)),
            ),
            child: Column(children: [
              Icon(ikon, color: renk, size: 18),
              const SizedBox(height: 4),
              FittedBox(
                  child: Text(deger,
                      style: GoogleFonts.playfairDisplay(color: renk, fontSize: 18, fontWeight: FontWeight.bold))),
              Text(etiket, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 10)),
            ]),
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        kart('${o['randevu_sayisi']}', 'Randevu', Icons.event_note),
        kart(sureMetni(o['toplam_sure_dk']), 'Toplam süre', Icons.timer_outlined),
        kart(tl(o['beklenen_ciro']), 'Beklenen ciro', Icons.payments_outlined),
        kart('${o['riskli_sayisi']}', 'Riskli', Icons.warning_amber_rounded,
            renk: (o['riskli_sayisi'] as int) > 0 ? AppTheme.error : AppTheme.textSecondary),
      ]),
    );
  }

  Widget _siradaki(Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.gold.withValues(alpha: 0.22), AppTheme.surface]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
      ),
      child: Row(children: [
        const Icon(Icons.play_circle_fill, color: AppTheme.gold, size: 30),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SIRADAKİ', style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 11, letterSpacing: 1.5,
                fontWeight: FontWeight.w700)),
            Text('${r['saat']} · ${r['musteri']['ad']}',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${(r['hizmetler'] as List).map((h) => h['ad']).join(', ')} · ${r['berber']['ad']}',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _doluluk(List<Map<String, dynamic>> liste) {
    if (liste.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 6, children: [
      for (final b in liste)
        Chip(
          backgroundColor: AppTheme.surface,
          side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.15)),
          avatar: const Icon(Icons.person, size: 16, color: AppTheme.gold),
          label: Text(
            b['kapali_neden'] != null ? '${b['ad']}: kapalı' : '${b['ad']}: ${b['bos_slot']} boş saat',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
          ),
        ),
    ]);
  }

  Widget _randevuKarti(Map<String, dynamic> r) {
    final durum = r['durum'] as String;
    final aktif = durum == 'onaylandi';
    final soluk = durum == 'iptal' || durum == 'gelmedi';
    final hizmetler = (r['hizmetler'] as List).cast<Map<String, dynamic>>();
    final tel = (r['musteri']['telefon'] as String?) ?? '';
    final baslamis = DateTime.tryParse('${r['tarih']}T${r['saat']}:00')?.isBefore(DateTime.now()) ?? false;
    final islemde = _islemde.contains(r['id']);

    return Opacity(
      opacity: soluk ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: r['guven']['etiket'] == 'Riskli' && aktif
                ? AppTheme.error.withValues(alpha: 0.6)
                : AppTheme.gold.withValues(alpha: 0.15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Saat sütunu
              SizedBox(
                width: 64,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['saat'], style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 20,
                      fontWeight: FontWeight.bold)),
                  Text('– ${r['bitis']}', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                  Text(sureMetni(r['sure_dk']), style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
                ]),
              ),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(
                      child: Text(r['musteri']['ad'], overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 6),
                    GuvenRozeti(guven: r['guven']),
                  ]),
                  const SizedBox(height: 2),
                  Text('${r['berber']['ad']}${r['kaynak'] == 'panel' ? ' · panelden eklendi' : ''}',
                      style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 6),
                  for (final h in hizmetler)
                    Row(children: [
                      const Icon(Icons.content_cut, size: 12, color: AppTheme.gold),
                      const SizedBox(width: 6),
                      Expanded(child: Text('${h['ad']} (${h['sure']} dk)',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13))),
                      Text(tl(h['fiyat']), style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                    ]),
                  if ((r['notlar'] as String?)?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Not: ${r['notlar']}',
                          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12,
                              fontStyle: FontStyle.italic)),
                    ),
                ]),
              ),
            ]),
            Divider(color: AppTheme.gold.withValues(alpha: 0.1), height: 20),
            Row(children: [
              _durumEtiketi(durum),
              const Spacer(),
              Text('Toplam ', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
              Text(tl(r['toplam_fiyat']),
                  style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            if (aktif) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                if (r['whatsapp_link'] != null)
                  _aksiyon(Icons.chat, 'WhatsApp onay', const Color(0xFF25D366),
                      () => _ac(Uri.parse(r['whatsapp_link']))),
                if (tel.isNotEmpty)
                  _aksiyon(Icons.call, 'Ara', AppTheme.gold, () => _ac(Uri(scheme: 'tel', path: tel))),
                // "Tamamlandı/Gelmedi" yalnızca randevu saati geldikten sonra anlamlı (backend de doğrular)
                if (baslamis) ...[
                  _aksiyon(Icons.check_circle, 'Tamamlandı', AppTheme.success,
                      islemde ? null : () => _durum(r, 'tamamlandi')),
                  _aksiyon(Icons.person_off, 'Gelmedi', Colors.orange,
                      islemde ? null : () => _durum(r, 'gelmedi')),
                ],
                _aksiyon(Icons.cancel_outlined, 'İptal', AppTheme.error, islemde ? null : () => _durum(r, 'iptal')),
              ]),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _durumEtiketi(String durum) {
    final (metin, renk) = switch (durum) {
      'onaylandi' => ('Bekleniyor', AppTheme.gold),
      'tamamlandi' => ('Tamamlandı', AppTheme.success),
      'gelmedi' => ('Gelmedi', Colors.orange),
      'iptal' => ('İptal', AppTheme.error),
      _ => (durum, AppTheme.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: renk.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(metin, style: GoogleFonts.inter(color: renk, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _aksiyon(IconData ikon, String etiket, Color renk, VoidCallback? onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(ikon, size: 16, color: renk),
      label: Text(etiket, style: GoogleFonts.inter(color: renk, fontSize: 12, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: renk.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(0, 34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
