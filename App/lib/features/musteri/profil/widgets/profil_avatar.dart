import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/config.dart';
import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';

/// Profil başlığı: fotoğraf (yoksa baş harfler), ad ve e-posta. Dokununca fotoğraf seçenekleri açılır.
class ProfilAvatar extends StatelessWidget {
  final String adSoyad;
  final String? eposta;
  final String? fotoUrl;
  final bool yukleniyor;
  final VoidCallback onTap;

  const ProfilAvatar({
    super.key,
    required this.adSoyad,
    required this.onTap,
    this.eposta,
    this.fotoUrl,
    this.yukleniyor = false,
  });

  String get _basHarfler =>
      adSoyad.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();

  Widget _basHarfAvatari() => _basHarfler.isEmpty
      ? const Icon(Icons.person, color: AppTheme.gold, size: 46)
      : Text(_basHarfler,
          style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 32, fontWeight: FontWeight.bold));

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Semantics(
        button: true,
        label: Dil.t.profilFotografi,
        child: GestureDetector(
          key: const ValueKey('profil_avatar'),
          onTap: yukleniyor ? null : onTap,
          child: Stack(alignment: Alignment.center, children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: AppTheme.gold.withValues(alpha: 0.15),
              child: ClipOval(
                child: SizedBox.square(
                  dimension: 92,
                  child: fotoUrl == null
                      ? Center(child: _basHarfAvatari())
                      : CachedNetworkImage(
                          imageUrl: AppConfig.medyaUrl(fotoUrl!),
                          fit: BoxFit.cover,
                          // ağ hatası veya silinmiş dosya: baş harflere düş
                          errorWidget: (_, _, _) => Center(child: _basHarfAvatari()),
                        ),
                ),
              ),
            ),
            if (yukleniyor) const CircularProgressIndicator(color: AppTheme.gold),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppTheme.gold, shape: BoxShape.circle),
                child: const Icon(Icons.photo_camera, size: 16, color: Colors.black),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 10),
      if (adSoyad.isNotEmpty)
        Text(adSoyad, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      if (eposta != null) Text(eposta!, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
    ]);
  }
}
