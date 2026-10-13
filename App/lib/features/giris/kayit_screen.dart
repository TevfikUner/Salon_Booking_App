import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/widgets/altin_buton.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/sabit/yasal_metinler.dart';
import 'package:berber_app_ui/features/destek/yasal_dokuman_screen.dart';
import 'package:berber_app_ui/features/giris/widgets/giris_bilesenleri.dart';
import 'package:berber_app_ui/services/analitik.dart';
import 'package:berber_app_ui/services/auth_service.dart';
import 'package:berber_app_ui/services/yonlendirme.dart';

/// Müşteri kaydı — KVKK aydınlatma onayı zorunlu, ticari ileti izni isteğe bağlı.
class KayitScreen extends StatefulWidget {
  const KayitScreen({super.key});

  @override
  State<KayitScreen> createState() => _KayitScreenState();
}

class _KayitScreenState extends State<KayitScreen> {
  final _form = GlobalKey<FormState>();
  final _ad = TextEditingController();
  final _soyad = TextEditingController();
  final _telefon = TextEditingController();
  final _eposta = TextEditingController();
  final _sifre = TextEditingController();
  bool _kvkk = false;
  bool _ticari = false;
  bool _yukleniyor = false;

  @override
  void dispose() {
    for (final c in [_ad, _soyad, _telefon, _eposta, _sifre]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _kayitOl() async {
    if (!_form.currentState!.validate()) return;
    if (!_kvkk) return bilgiGoster(context, Dil.t.kvkkOnaylamalisiniz, hata: true);
    setState(() => _yukleniyor = true);
    try {
      await AuthService.kayitOl(
        email: _eposta.text.trim(),
        sifre: _sifre.text,
        ad: _ad.text.trim(),
        soyad: _soyad.text.trim(),
        telefon: '0${_telefon.text.trim()}',
        kvkkOnay: _kvkk,
        ticariIletiIzni: _ticari,
      );
      Analitik.kayit(rol: 'musteri');
      if (mounted) await Yonlendirme.git(context);
    } catch (e) {
      if (mounted) bilgiGoster(context, Dil.t.kayitBasarisiz(AuthService.hataMesaji(e)), hata: true);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GirisIskeleti(children: [
      GirisBasligi(baslik: Dil.t.hesapOlustur, alt: Dil.t.birkacAdimdaRandevu),
      Form(
        key: _form,
        child: Column(children: [
          Row(children: [
            Expanded(child: Alanlar.metin(_ad, Dil.t.ad, Icons.person_outline)),
            const SizedBox(width: 12),
            Expanded(child: Alanlar.metin(_soyad, Dil.t.soyad, Icons.person_outline)),
          ]),
          const SizedBox(height: 14),
          Alanlar.telefon(_telefon),
          const SizedBox(height: 14),
          Alanlar.eposta(_eposta),
          const SizedBox(height: 14),
          SifreAlani(controller: _sifre),
        ]),
      ),
      const SizedBox(height: 12),
      OnayKutusu(
        deger: _kvkk,
        degisti: (v) => setState(() => _kvkk = v),
        metin: Dil.t.kvkkMusteriOnay,
        metniOku: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => YasalDokumanScreen.belge(YasalMetinler.kvkk)),
        ),
      ),
      OnayKutusu(
        deger: _ticari,
        degisti: (v) => setState(() => _ticari = v),
        metin: Dil.t.ticariIletiOnay,
      ),
      const SizedBox(height: 20),
      AltinButon(text: Dil.t.kayitOl, onPressed: _kayitOl, loading: _yukleniyor),
    ]);
  }
}
