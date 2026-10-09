import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/widgets/altin_buton.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/sabit/yasal_metinler.dart';
import 'package:berber_app_ui/features/destek/yasal_dokuman_screen.dart';
import 'package:berber_app_ui/features/giris/giris_screen.dart';
import 'package:berber_app_ui/features/giris/widgets/giris_bilesenleri.dart';
import 'package:berber_app_ui/services/auth_service.dart';
import 'package:berber_app_ui/services/yonlendirme.dart';

const _isletmeRengi = Color(0xFF4A90D9);

/// İşletme sahibi başvurusu. Başarılı olunca kullanıcı "onay bekleniyor" ekranına yönlenir.
class IsletmeKayitScreen extends StatefulWidget {
  const IsletmeKayitScreen({super.key});

  @override
  State<IsletmeKayitScreen> createState() => _IsletmeKayitScreenState();
}

class _IsletmeKayitScreenState extends State<IsletmeKayitScreen> {
  final _form = GlobalKey<FormState>();
  final _isletmeAdi = TextEditingController();
  final _ad = TextEditingController();
  final _soyad = TextEditingController();
  final _telefon = TextEditingController();
  final _eposta = TextEditingController();
  final _sifre = TextEditingController();
  bool _kvkk = false;
  bool _yukleniyor = false;

  @override
  void dispose() {
    for (final c in [_isletmeAdi, _ad, _soyad, _telefon, _eposta, _sifre]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _basvur() async {
    if (!_form.currentState!.validate()) return;
    if (!_kvkk) return bilgiGoster(context, "Devam etmek için KVKK Aydınlatma Metni'ni onaylamalısınız.", hata: true);
    setState(() => _yukleniyor = true);
    try {
      await AuthService.isletmeKayitOl(
        email: _eposta.text.trim(),
        sifre: _sifre.text,
        ad: _ad.text.trim(),
        soyad: _soyad.text.trim(),
        telefon: '0${_telefon.text.trim()}',
        isletmeAdi: _isletmeAdi.text.trim(),
      );
      if (mounted) await Yonlendirme.git(context); // → onay bekleme ekranı
    } catch (e) {
      if (mounted) bilgiGoster(context, 'Başvuru gönderilemedi: ${AuthService.hataMesaji(e)}', hata: true);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GirisIskeleti(children: [
      const GirisBasligi(baslik: 'İşletme Başvurusu', alt: 'Salonunuzu kaydedin, onaylandığında paneliniz açılır',
          renk: _isletmeRengi),
      Form(
        key: _form,
        child: Column(children: [
          Alanlar.metin(_isletmeAdi, 'İşletme / Salon Adı', Icons.storefront_outlined),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Alanlar.metin(_ad, 'Ad', Icons.person_outline)),
            const SizedBox(width: 12),
            Expanded(child: Alanlar.metin(_soyad, 'Soyad', Icons.person_outline)),
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
        metin: "KVKK Aydınlatma Metni'ni okudum, kabul ediyorum. (Zorunlu)",
        metniOku: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => YasalDokumanScreen(baslik: YasalMetinler.kvkk.baslik, icerik: YasalMetinler.kvkk.icerik)),
        ),
      ),
      const SizedBox(height: 20),
      AltinButon(text: 'Başvuruyu Gönder', onPressed: _basvur, loading: _yukleniyor),
      const SizedBox(height: 12),
      AltBaglanti(
        soru: 'İşletme hesabınız var mı?',
        eylem: 'Giriş Yapın',
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GirisScreen())),
      ),
    ]);
  }
}
