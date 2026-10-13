import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/hesap_api.dart';
import 'package:berber_app_ui/features/musteri/profil/widgets/menu_bolumu.dart';

/// Ad / soyad / telefon — görüntüleme ve düzenleme (doğrulamalı).
class KisiselBilgilerFormu extends StatefulWidget {
  final Map<String, dynamic>? profil;
  final ValueChanged<String> onAdDegisti;
  const KisiselBilgilerFormu({super.key, required this.profil, required this.onAdDegisti});

  @override
  State<KisiselBilgilerFormu> createState() => _KisiselBilgilerFormuState();
}

class _KisiselBilgilerFormuState extends State<KisiselBilgilerFormu> {
  final _form = GlobalKey<FormState>();
  final _ad = TextEditingController();
  final _soyad = TextEditingController();
  final _telefon = TextEditingController();
  bool _duzenle = false;
  bool _kaydediliyor = false;

  @override
  void initState() {
    super.initState();
    _doldur();
  }

  @override
  void didUpdateWidget(covariant KisiselBilgilerFormu eski) {
    super.didUpdateWidget(eski);
    if (eski.profil != widget.profil && !_duzenle) _doldur();
  }

  void _doldur() {
    final p = widget.profil ?? const {};
    _ad.text = p['ad'] ?? '';
    _soyad.text = p['soyad'] ?? '';
    final tel = (p['telefon'] as String?) ?? '';
    _telefon.text = tel.startsWith('0') ? tel.substring(1) : tel;
  }

  @override
  void dispose() {
    _ad.dispose();
    _soyad.dispose();
    _telefon.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _kaydediliyor = true);
    try {
      final tel = _telefon.text.trim();
      await HesapApi.profilGuncelle(ad: _ad.text.trim(), soyad: _soyad.text.trim(), telefon: tel.isEmpty ? '' : '0$tel');
      widget.onAdDegisti('${_ad.text.trim()} ${_soyad.text.trim()}'.trim());
      if (!mounted) return;
      setState(() => _duzenle = false);
      bilgiGoster(context, Dil.t.bilgilerKaydedildi);
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: MenuBolumu(
        baslik: Dil.t.kisiselBilgiler,
        ikon: Icons.person_outline,
        sag: _kaydediliyor
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : TextButton(
                onPressed: _duzenle ? _kaydet : () => setState(() => _duzenle = true),
                child: Text(_duzenle ? Dil.t.kaydet : Dil.t.duzenle,
                    style: GoogleFonts.inter(color: AppTheme.gold, fontWeight: FontWeight.w600)),
              ),
        children: [
          const SizedBox(height: 8),
          _alan(_ad, Dil.t.adiniz, Icons.badge_outlined, zorunlu: true),
          const SizedBox(height: 12),
          _alan(_soyad, Dil.t.soyadiniz, Icons.badge_outlined),
          const SizedBox(height: 12),
          _alan(_telefon, Dil.t.telefon, Icons.phone_outlined, telefon: true),
        ],
      ),
    );
  }

  Widget _alan(TextEditingController c, String etiket, IconData ikon, {bool zorunlu = false, bool telefon = false}) {
    return TextFormField(
      controller: c,
      enabled: _duzenle,
      keyboardType: telefon ? TextInputType.phone : TextInputType.name,
      textCapitalization: telefon ? TextCapitalization.none : TextCapitalization.words,
      maxLength: telefon ? 10 : 60,
      inputFormatters: telefon ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: TextStyle(color: _duzenle ? Colors.white : AppTheme.textSecondary),
      decoration: InputDecoration(
        labelText: etiket,
        prefixIcon: Icon(ikon, color: AppTheme.gold.withValues(alpha: 0.7)),
        prefixText: telefon ? '0 ' : null,
        hintText: telefon ? '5XX XXX XX XX' : null,
        counterText: '',
      ),
      validator: (v) {
        final t = v?.trim() ?? '';
        if (zorunlu && t.isEmpty) return Dil.t.zorunluAlan;
        if (telefon && t.isNotEmpty && (t.length != 10 || !t.startsWith('5'))) return Dil.t.telefonKurali;
        return null;
      },
    );
  }
}
