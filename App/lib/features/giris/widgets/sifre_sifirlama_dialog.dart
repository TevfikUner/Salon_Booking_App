import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/services/auth_service.dart';

/// "Şifremi unuttum": sıfırlama bağlantısı e-postası gönderir.
Future<void> sifreSifirlamaGoster(BuildContext context, {String onDoldurulmus = ''}) {
  return showDialog(context: context, builder: (_) => _SifreSifirlama(eposta: onDoldurulmus));
}

class _SifreSifirlama extends StatefulWidget {
  final String eposta;
  const _SifreSifirlama({required this.eposta});

  @override
  State<_SifreSifirlama> createState() => _SifreSifirlamaState();
}

class _SifreSifirlamaState extends State<_SifreSifirlama> {
  late final _eposta = TextEditingController(text: widget.eposta);
  bool _gonderiliyor = false;

  @override
  void dispose() {
    _eposta.dispose();
    super.dispose();
  }

  Future<void> _gonder() async {
    final e = _eposta.text.trim();
    if (!e.contains('@')) return bilgiGoster(context, Dil.t.gecerliEpostaGirin, hata: true);
    setState(() => _gonderiliyor = true);
    try {
      await AuthService.sifreSifirla(e);
      if (!mounted) return;
      Navigator.pop(context);
      bilgiGoster(context, Dil.t.sifreSifirlamaGonderildi(e));
    } catch (err) {
      if (mounted) {
        setState(() => _gonderiliyor = false);
        bilgiGoster(context, AuthService.hataMesaji(err), hata: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(Dil.t.sifremiUnuttum, style: GoogleFonts.playfairDisplay(color: AppTheme.gold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(Dil.t.sifreSifirlamaAciklama,
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),
        TextField(
          controller: _eposta,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: Dil.t.eposta, prefixIcon: const Icon(Icons.email_outlined)),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(Dil.t.iptal)),
        ElevatedButton(
          onPressed: _gonderiliyor ? null : _gonder,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
          child: _gonderiliyor
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(Dil.t.gonder),
        ),
      ],
    );
  }
}
