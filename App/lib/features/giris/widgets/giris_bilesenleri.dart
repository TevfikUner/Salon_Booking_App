import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/berber_desen.dart';

export 'package:berber_app_ui/core/widgets/form_alanlari.dart';

/// Giriş/kayıt ekranlarının ortak iskeleti: desenli arka plan, güvenli alan, kaydırma, geri düğmesi.
class GirisIskeleti extends StatelessWidget {
  final List<Widget> children;
  final bool geriDugmesi;
  const GirisIskeleti({super.key, required this.children, this.geriDugmesi = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        const BerberDesenWidget(),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (geriDugmesi && Navigator.canPop(context))
                IconButton(
                  tooltip: Dil.t.geri,
                  icon: const Icon(Icons.arrow_back_ios, color: AppTheme.gold),
                  onPressed: () => Navigator.pop(context),
                ),
              ...children,
            ]),
          ),
        ),
      ]),
    );
  }
}

/// Parlayan logo.
class GirisLogosu extends StatelessWidget {
  final double boyut;
  const GirisLogosu({super.key, this.boyut = 150});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: boyut,
        height: boyut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.35), blurRadius: 40, spreadRadius: 8)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain, semanticLabel: Dil.t.logoEtiketi),
        ),
      ),
    );
  }
}

/// Büyük başlık + alt açıklama.
class GirisBasligi extends StatelessWidget {
  final String baslik;
  final String alt;
  final Color renk;
  const GirisBasligi({super.key, required this.baslik, required this.alt, this.renk = AppTheme.gold});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(baslik, style: GoogleFonts.playfairDisplay(color: renk, fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(alt, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
      ]),
    );
  }
}

/// Göster/gizle düğmeli şifre alanı.
class SifreAlani extends StatefulWidget {
  final TextEditingController controller;
  final String? etiket;
  const SifreAlani({super.key, required this.controller, this.etiket});

  @override
  State<SifreAlani> createState() => _SifreAlaniState();
}

class _SifreAlaniState extends State<SifreAlani> {
  bool _gizli = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _gizli,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: widget.etiket ?? Dil.t.sifre,
        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.gold),
        suffixIcon: IconButton(
          tooltip: _gizli ? Dil.t.sifreyiGoster : Dil.t.sifreyiGizle,
          icon: Icon(_gizli ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
          onPressed: () => setState(() => _gizli = !_gizli),
        ),
      ),
      validator: (v) => (v == null || v.length < 6) ? Dil.t.enAz6Karakter : null,
    );
  }
}

/// Açıklamalı onay kutusu (KVKK, ticari ileti).
class OnayKutusu extends StatelessWidget {
  final bool deger;
  final ValueChanged<bool> degisti;
  final String metin;
  final VoidCallback? metniOku;

  const OnayKutusu({super.key, required this.deger, required this.degisti, required this.metin, this.metniOku});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Checkbox(value: deger, onChanged: (v) => degisti(v ?? false), activeColor: AppTheme.gold, checkColor: AppTheme.black),
      Expanded(
        child: GestureDetector(
          onTap: () => degisti(!deger),
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(metin, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
              if (metniOku != null)
                TextButton(
                  onPressed: metniOku,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                  child: Text(Dil.t.metniOku, style: TextStyle(decoration: TextDecoration.underline)),
                ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

/// "Hesabın yok mu? Kayıt ol" tarzı alt bağlantı.
class AltBaglanti extends StatelessWidget {
  final String soru;
  final String eylem;
  final VoidCallback onTap;
  const AltBaglanti({super.key, required this.soru, required this.eylem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        child: Text.rich(TextSpan(
          text: '$soru ',
          style: const TextStyle(color: AppTheme.textSecondary),
          children: [
            TextSpan(text: eylem, style: GoogleFonts.inter(color: AppTheme.gold, fontWeight: FontWeight.bold)),
          ],
        )),
      ),
    );
  }
}
