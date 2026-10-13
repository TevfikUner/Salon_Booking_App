import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:berber_app_ui/core/dil.dart';
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

  /// Sunucunun hesapladığı tutar (kampanya / sadakat indirimi dahil); gelene kadar yerel toplam gösterilir
  Json? _teklif;
  // Bu ekrandaki onay eylemi için tek anahtar: zaman aşımı sonrası tekrar basılırsa sunucu ikinci randevu açmaz
  final String _anahtar = ApiClient.yeniAnahtar();

  @override
  void initState() {
    super.initState();
    _profiliDoldur();
    _fiyatGetir();
  }

  Future<void> _fiyatGetir() async {
    final p = context.read<RandevuProvider>();
    final berber = p.seciliBerber, tarih = p.seciliTarih, saat = p.seciliSaat;
    if (berber == null || tarih == null || saat == null) return;
    try {
      final t = await RandevuApi.fiyatTeklifi(berber.id, tarihStr(tarih), saat, p.seciliHizmetler.map((h) => h.id).toList());
      if (mounted) setState(() => _teklif = t);
    } on ApiHata {
      // Teklif alınamazsa yerel toplam gösterilir; kesin tutar onayda sunucudan gelir
    }
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
      return bilgiGoster(context, Dil.t.tumAdimlariTamamlayin, hata: true);
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
        indirim: (sonuc['indirim_tutari'] as num? ?? 0).toDouble(),
        indirimAciklama: sonuc['indirim_aciklama'] as String?,
        randevuId: '${sonuc['randevu_id']}',
      );
      p.reset();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => onay), (r) => r.isFirst);
    } on ApiHata catch (e) {
      if (!mounted) return;
      final oneri = e.oneriler.isEmpty ? '' : '\n${Dil.t.uygunSaatler(e.oneriler.take(4).join(', '))}';
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
            toplam: (_teklif?['toplam_fiyat'] as num?) ?? p.toplamFiyat,
            indirim: (_teklif?['indirim_tutari'] as num?) ?? 0,
            indirimAciklama: _teklif?['indirim_aciklama'] as String?,
            satirlar: [
              (Icons.person, Dil.t.personel, p.seciliBerber?.tamAd ?? '-'),
              (Icons.calendar_today, Dil.t.tarih, p.seciliTarih == null ? '-' : tarihUzun(tarihStr(p.seciliTarih!), yil: true)),
              (Icons.access_time, Dil.t.saat, p.seciliSaat ?? '-'),
              (Icons.content_cut, Dil.t.hizmetler, p.seciliHizmetler.map((h) => h.ad).join(', ')),
              (Icons.timer_outlined, Dil.t.sure, sureMetni(p.toplamSureDk)),
            ],
          ),
          const SizedBox(height: 24),
          Text(Dil.t.iletisimBilgileriniz,
              style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_profilYukleniyor)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppTheme.gold)))
          else ...[
            Row(children: [
              Expanded(child: Alanlar.metin(_ad, Dil.t.ad, Icons.person_outline)),
              const SizedBox(width: 12),
              Expanded(child: Alanlar.metin(_soyad, Dil.t.soyad, Icons.person_outline, zorunlu: false)),
            ]),
            const SizedBox(height: 14),
            Alanlar.telefon(_telefon),
          ],
          const SizedBox(height: 28),
          AltinButon(
            text: Dil.t.randevumuOnayla,
            onPressed: _olustur,
            loading: _gonderiliyor,
            icon: const Icon(Icons.check_circle_outline, color: AppTheme.black, size: 20),
          ),
        ]),
      ),
    );
  }
}
