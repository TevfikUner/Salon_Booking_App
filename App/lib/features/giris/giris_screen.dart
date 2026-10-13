import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/widgets/altin_buton.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/features/giris/kayit_screen.dart';
import 'package:berber_app_ui/features/giris/widgets/giris_bilesenleri.dart';
import 'package:berber_app_ui/features/giris/widgets/sifre_sifirlama_dialog.dart';
import 'package:berber_app_ui/services/auth_service.dart';
import 'package:berber_app_ui/services/yonlendirme.dart';

/// E-posta/şifre ile giriş. Müşteri, işletme ve personel aynı ekranı kullanır; rol girişten sonra belirlenir.
class GirisScreen extends StatefulWidget {
  const GirisScreen({super.key});

  @override
  State<GirisScreen> createState() => _GirisScreenState();
}

class _GirisScreenState extends State<GirisScreen> {
  final _form = GlobalKey<FormState>();
  final _eposta = TextEditingController();
  final _sifre = TextEditingController();
  bool _yukleniyor = false;

  @override
  void dispose() {
    _eposta.dispose();
    _sifre.dispose();
    super.dispose();
  }

  Future<void> _girisYap() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _yukleniyor = true);
    try {
      await AuthService.girisYap(_eposta.text.trim(), _sifre.text);
      if (mounted) await Yonlendirme.git(context);
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } catch (e) {
      if (mounted) bilgiGoster(context, Dil.t.girisBasarisiz(AuthService.hataMesaji(e)), hata: true);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GirisIskeleti(children: [
      const GirisLogosu(),
      GirisBasligi(baslik: Dil.t.hosGeldiniz, alt: Dil.t.randevunuzSiziBekliyor),
      Form(
        key: _form,
        child: AutofillGroup(
          child: Column(children: [
            Alanlar.eposta(_eposta),
            const SizedBox(height: 16),
            SifreAlani(controller: _sifre),
          ]),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => sifreSifirlamaGoster(context, onDoldurulmus: _eposta.text.trim()),
          child: Text(Dil.t.sifremiUnuttum),
        ),
      ),
      const SizedBox(height: 8),
      AltinButon(text: Dil.t.girisYap, onPressed: _girisYap, loading: _yukleniyor),
      const SizedBox(height: 16),
      AltBaglanti(
        soru: Dil.t.hesabinizYokMu,
        eylem: Dil.t.kayitOlun,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KayitScreen())),
      ),
    ]);
  }
}
