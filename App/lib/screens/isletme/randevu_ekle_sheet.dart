import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/altin_buton.dart';
import '../../widgets/ortak.dart';

/// İşletmenin telefonla/kapıdan gelen müşteri için randevu eklemesi.
/// Saatler müşteri uygulamasıyla aynı kurallarla backend'den gelir (çift rezervasyon olmaz).
class RandevuEkleSheet extends StatefulWidget {
  final DateTime baslangicTarihi;
  const RandevuEkleSheet({super.key, required this.baslangicTarihi});

  @override
  State<RandevuEkleSheet> createState() => _RandevuEkleSheetState();
}

class _RandevuEkleSheetState extends State<RandevuEkleSheet> {
  List<Map<String, dynamic>> _personel = [];
  List<Map<String, dynamic>> _hizmetler = [];
  int? _berberId;
  final Set<int> _secili = {};
  late DateTime _tarih;
  List<String> _saatler = [];
  String? _kapaliNeden;
  String? _saat;
  bool _yukleniyor = true;
  bool _saatYukleniyor = false;
  bool _kaydediliyor = false;
  final _adCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _notCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final b = DateTime.now();
    _tarih = widget.baslangicTarihi.isBefore(DateTime(b.year, b.month, b.day)) ? b : widget.baslangicTarihi;
    _yukle();
  }

  @override
  void dispose() {
    _adCtrl.dispose();
    _telCtrl.dispose();
    _notCtrl.dispose();
    super.dispose();
  }

  Future<void> _yukle() async {
    try {
      final sonuc = await Future.wait([ApiService.panelPersonel(), ApiService.panelHizmetler()]);
      if (!mounted) return;
      setState(() {
        _personel = sonuc[0];
        _hizmetler = sonuc[1];
        _berberId = _personel.isNotEmpty ? _personel.first['id'] : null;
        _yukleniyor = false;
      });
    } on ApiHata catch (e) {
      if (mounted) {
        Navigator.pop(context);
        bilgiGoster(context, e.mesaj, hata: true);
      }
    }
  }

  Future<void> _saatleriGetir() async {
    setState(() {
      _saat = null;
      _saatler = [];
      _kapaliNeden = null;
    });
    if (_berberId == null || _secili.isEmpty) return;
    setState(() => _saatYukleniyor = true);
    try {
      final v = await ApiService.panelMusaitSaatler(_berberId!, tarihStr(_tarih), _secili.toList());
      if (mounted) {
        setState(() {
          _saatler = List<String>.from(v['musait_saatler']);
          _kapaliNeden = v['kapali_neden'];
        });
      }
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _saatYukleniyor = false);
    }
  }

  Future<void> _tarihSec() async {
    final g = await showDatePicker(
      context: context,
      initialDate: _tarih,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('tr', 'TR'),
    );
    if (g != null) {
      setState(() => _tarih = g);
      _saatleriGetir();
    }
  }

  Future<void> _kaydet() async {
    if (_adCtrl.text.trim().isEmpty) {
      bilgiGoster(context, 'Müşteri adını girin.', hata: true);
      return;
    }
    setState(() => _kaydediliyor = true);
    try {
      await ApiService.panelRandevuEkle(
        berberId: _berberId!,
        tarih: tarihStr(_tarih),
        saat: _saat!,
        hizmetIds: _secili.toList(),
        musteriAd: _adCtrl.text.trim(),
        musteriTelefon: _telCtrl.text.trim().isEmpty ? '' : '0${_telCtrl.text.trim()}',
        notlar: _notCtrl.text.trim().isEmpty ? null : _notCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      bilgiGoster(context, 'Randevu eklendi.');
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
      _saatleriGetir();
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final toplamSure = _hizmetler.where((h) => _secili.contains(h['id'])).fold<int>(0, (s, h) => s + (h['sure'] as int));
    final toplamFiyat =
        _hizmetler.where((h) => _secili.contains(h['id'])).fold<num>(0, (s, h) => s + (h['fiyat'] as num));
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        builder: (_, ctrl) => _yukleniyor
            ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
            : ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 12),
                Text('Randevu Ekle', style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 22,
                    fontWeight: FontWeight.bold)),
                Text('Telefonla veya kapıdan gelen müşteri için', style: GoogleFonts.inter(color: AppTheme.textSecondary,
                    fontSize: 12)),
                const SizedBox(height: 16),
                _baslik('Personel'),
                Wrap(spacing: 8, children: [
                  for (final p in _personel)
                    ChoiceChip(
                      label: Text('${p['ad']} ${p['soyad']}'.trim()),
                      selected: _berberId == p['id'],
                      onSelected: (_) {
                        setState(() => _berberId = p['id']);
                        _saatleriGetir();
                      },
                      selectedColor: AppTheme.gold,
                      showCheckmark: false,
                    ),
                ]),
                _baslik('Hizmetler'),
                Wrap(spacing: 8, runSpacing: 4, children: [
                  for (final h in _hizmetler)
                    FilterChip(
                      label: Text('${h['ad']} · ${tl(h['fiyat'])}'),
                      selected: _secili.contains(h['id']),
                      onSelected: (s) {
                        setState(() => s ? _secili.add(h['id']) : _secili.remove(h['id']));
                        _saatleriGetir();
                      },
                      selectedColor: AppTheme.gold.withValues(alpha: 0.3),
                      checkmarkColor: AppTheme.gold,
                    ),
                ]),
                if (_secili.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('${sureMetni(toplamSure)} · ${tl(toplamFiyat)}',
                        style: GoogleFonts.inter(color: AppTheme.gold, fontWeight: FontWeight.w600)),
                  ),
                _baslik('Tarih & Saat'),
                OutlinedButton.icon(
                  onPressed: _tarihSec,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(tarihUzun(tarihStr(_tarih), yil: true)),
                ),
                const SizedBox(height: 8),
                if (_secili.isEmpty)
                  Text('Saatleri görmek için hizmet seçin.', style: GoogleFonts.inter(color: AppTheme.textSecondary))
                else if (_saatYukleniyor)
                  const LinearProgressIndicator(color: AppTheme.gold)
                else if (_kapaliNeden != null)
                  Text(_kapaliNeden!, style: GoogleFonts.inter(color: AppTheme.error))
                else if (_saatler.isEmpty)
                  Text('Bu gün için uygun saat kalmadı.', style: GoogleFonts.inter(color: AppTheme.error))
                else
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    for (final s in _saatler)
                      ChoiceChip(
                        label: Text(s),
                        selected: _saat == s,
                        onSelected: (_) => setState(() => _saat = s),
                        selectedColor: AppTheme.gold,
                        showCheckmark: false,
                      ),
                  ]),
                _baslik('Müşteri'),
                TextField(controller: _adCtrl, textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Ad Soyad', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 10),
                TextField(
                  controller: _telCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Telefon (isteğe bağlı)', prefixText: '0 ',
                      counterText: '', hintText: '5XX XXX XX XX', prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(controller: _notCtrl,
                    decoration: const InputDecoration(labelText: 'Not (isteğe bağlı)', prefixIcon: Icon(Icons.notes))),
                const SizedBox(height: 20),
                AltinButon(
                  text: 'Randevuyu Kaydet',
                  loading: _kaydediliyor,
                  onPressed: (_berberId != null && _secili.isNotEmpty && _saat != null) ? _kaydet : null,
                ),
              ]),
      ),
    );
  }

  Widget _baslik(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(t, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
      );
}
