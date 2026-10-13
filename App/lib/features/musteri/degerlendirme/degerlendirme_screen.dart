import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/config.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/altin_buton.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/features/musteri/degerlendirme/widgets/yildiz_secici.dart';

/// Tamamlanan randevuyu puanlama (yıldız + isteğe bağlı yorum).
/// Randevularım'dan veya "Sıhhatler olsun" bildiriminden açılır. Gönderilirse `true` ile kapanır.
class DegerlendirmeEkrani extends StatefulWidget {
  final int randevuId;
  final String berberAdi;
  final String? berberFotoUrl;

  const DegerlendirmeEkrani({super.key, required this.randevuId, required this.berberAdi, this.berberFotoUrl});

  @override
  State<DegerlendirmeEkrani> createState() => _DegerlendirmeEkraniState();
}

class _DegerlendirmeEkraniState extends State<DegerlendirmeEkrani> {
  int _puan = 5;
  final _yorum = TextEditingController();
  bool _gonderiliyor = false;
  bool _tamamlandi = false;

  @override
  void dispose() {
    _yorum.dispose();
    super.dispose();
  }

  Future<void> _gonder() async {
    setState(() => _gonderiliyor = true);
    try {
      await RandevuApi.degerlendir(randevuId: widget.randevuId, puan: _puan, yorum: _yorum.text.trim());
      if (!mounted) return;
      setState(() => _tamamlandi = true);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context, true);
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _gonderiliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            tooltip: Dil.t.kapat, icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context, false)),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _tamamlandi ? const _Tesekkur() : _form(),
      ),
    );
  }

  Widget _form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Column(children: [
        _Avatar(fotoUrl: widget.berberFotoUrl),
        const SizedBox(height: 20),
        Text(widget.berberAdi,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(Dil.t.randevunuzuNasilBuldunuz, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
        const SizedBox(height: 24),
        YildizSecici(secili: _puan, onSecim: (v) => setState(() => _puan = v)),
        Text(YildizSecici.metin(_puan),
            style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        TextField(
          controller: _yorum,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(hintText: Dil.t.yorumunuz),
        ),
        const SizedBox(height: 16),
        AltinButon(
          text: Dil.t.degerlendir,
          onPressed: _gonder,
          loading: _gonderiliyor,
          icon: const Icon(Icons.star, color: AppTheme.black, size: 20),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(Dil.t.simdiDegil, style: TextStyle(color: AppTheme.textSecondary)),
        ),
      ]),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? fotoUrl;
  const _Avatar({this.fotoUrl});

  @override
  Widget build(BuildContext context) {
    const yedek = Icon(Icons.person, color: AppTheme.gold, size: 48);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.25), blurRadius: 40, spreadRadius: 6)],
      ),
      child: CircleAvatar(
        radius: 52,
        backgroundColor: AppTheme.surface,
        child: (fotoUrl ?? '').isEmpty
            ? yedek
            : ClipOval(
                child: CachedNetworkImage(
                  imageUrl: AppConfig.medyaUrl(fotoUrl!),
                  width: 104,
                  height: 104,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => yedek,
                ),
              ),
      ),
    );
  }
}

class _Tesekkur extends StatelessWidget {
  const _Tesekkur();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle, color: AppTheme.gold, size: 72),
        const SizedBox(height: 20),
        Text(Dil.t.tesekkurler,
            style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(Dil.t.degerlendirmeKaydedildi, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
      ]),
    );
  }
}
