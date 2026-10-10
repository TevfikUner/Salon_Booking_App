import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/altin_buton.dart';
import 'package:berber_app_ui/core/widgets/form_alanlari.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/hesap_api.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/features/randevu_al/onay_screen.dart';
import 'package:berber_app_ui/features/randevu_al/randevu_provider.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/randevu_ozeti.dart';
import 'package:berber_app_ui/services/analitik.dart';

/// Son adım: özet + iletişim bilgileri (profilden önceden doldurulur) → randevuyu oluştur.
class Adim5Form extends StatefulWidget {
  const Adim5Form({super.key});

  @override
  State<Adim5Form> createState() => _Adim5FormState();
}

class _Adim5FormState extends State<Adim5Form> {
  final _form = GlobalKey<FormState>();
  final _ad = TextEditingController();
  final _soyad = TextEditingController();
  final _telefon = TextEditingController();
  bool _gonderiliyor = false;
  bool _profilYukleniyor = true;
  // Bu ekrandaki onay eylemi için tek anahtar: zaman aşımı sonrası tekrar basılırsa sunucu ikinci randevu açmaz
  final String _anahtar = ApiClient.yeniAnahtar();

  @override
  void initState() {
    super.initState();
    _profiliDoldur();
  }

  @override
  void dispose() {
    _ad.dispose();
    _soyad.dispose();
    _telefon.dispose();
    super.dispose();
  }

  Future<void> _profiliDoldur() async {
    final parcalar = (FirebaseAuth.instance.currentUser?.displayName ?? '').split(' ');
    _ad.text = parcalar.first;
    _soyad.text = parcalar.skip(1).join(' ');
    final p = await HesapApi.profil();
    if (p != null) {
      if ((p['ad'] as String? ?? '').isNotEmpty) _ad.text = p['ad'];
      if ((p['soyad'] as String? ?? '').isNotEmpty) _soyad.text = p['soyad'];
      final tel = p['telefon'] as String? ?? '';
      if (tel.isNotEmpty) _telefon.text = tel.startsWith('0') ? tel.substring(1) : tel;
    }
    if (mounted) setState(() => _profilYukleniyor = false);
  }

  Future<void> _olustur() async {
    if (_gonderiliyor) return; // çift dokunma
    if (!_form.currentState!.validate()) return;
    final p = context.read<RandevuProvider>();
    final berber = p.seciliBerber, tarih = p.seciliTarih, saat = p.seciliSaat;
    if (berber == null || tarih == null || saat == null) {
      return bilgiGoster(context, 'Lütfen tüm adımları tamamlayın.', hata: true);
    }
    setState(() => _gonderiliyor = true);
    try {
      final sonuc = await RandevuApi.olustur(
        berberId: berber.id,
        saat: saat,
        tarih: tarihStr(tarih),
        hizmetIds: p.seciliHizmetler.map((h) => h.id).toList(),
        ad: _ad.text.trim(),
        soyad: _soyad.text.trim(),
        telefon: '0${_telefon.text.trim()}',
        idempotencyKey: _anahtar,
      );
      Analitik.randevuOlusturuldu(
          tutar: sonuc['toplam_fiyat'] as num? ?? p.toplamFiyat, hizmetSayisi: p.seciliHizmetler.length, kaynak: 'akis');
      final onay = OnaySayfasi(
        tarih: tarihStr(tarih),
        saat: saat,
        bitis: sonuc['bitis']?.toString(),
        berber: berber.tamAd,
        salonAd: sonuc['salon_ad']?.toString(),
        hizmetler: p.seciliHizmetler.map((h) => h.ad).toList(),
        toplamFiyat: (sonuc['toplam_fiyat'] as num?)?.toDouble() ?? p.toplamFiyat,
        randevuId: '${sonuc['randevu_id']}',
      );
      p.reset();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => onay), (r) => r.isFirst);
    } on ApiHata catch (e) {
      if (!mounted) return;
      final oneri = e.oneriler.isEmpty ? '' : '\nUygun saatler: ${e.oneriler.take(4).join(', ')}';
      bilgiGoster(context, '${e.mesaj}$oneri', hata: true, sure: const Duration(seconds: 6));
    } finally {
      if (mounted) setState(() => _gonderiliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RandevuProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RandevuOzeti(
            toplam: p.toplamFiyat,
            satirlar: [
              (Icons.person, 'Personel', p.seciliBerber?.tamAd ?? '-'),
              (Icons.calendar_today, 'Tarih', p.seciliTarih == null ? '-' : tarihUzun(tarihStr(p.seciliTarih!), yil: true)),
              (Icons.access_time, 'Saat', p.seciliSaat ?? '-'),
              (Icons.content_cut, 'Hizmetler', p.seciliHizmetler.map((h) => h.ad).join(', ')),
              (Icons.timer_outlined, 'Süre', sureMetni(p.toplamSureDk)),
            ],
          ),
          const SizedBox(height: 24),
          Text('İletişim Bilgileriniz',
              style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_profilYukleniyor)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppTheme.gold)))
          else ...[
            Row(children: [
              Expanded(child: Alanlar.metin(_ad, 'Ad', Icons.person_outline)),
              const SizedBox(width: 12),
              Expanded(child: Alanlar.metin(_soyad, 'Soyad', Icons.person_outline, zorunlu: false)),
            ]),
            const SizedBox(height: 14),
            Alanlar.telefon(_telefon),
          ],
          const SizedBox(height: 28),
          AltinButon(
            text: 'Randevumu Onayla',
            onPressed: _olustur,
            loading: _gonderiliyor,
            icon: const Icon(Icons.check_circle_outline, color: AppTheme.black, size: 20),
          ),
        ]),
      ),
    );
  }
}
