import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/harici.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';

/// Takvime eklenecek randevunun özeti.
class TakvimEtkinligi {
  final int randevuId;
  final String tarih; // YYYY-MM-DD
  final String saat; // HH:MM
  final String? bitis; // HH:MM
  final String baslik;
  final String aciklama;

  const TakvimEtkinligi({
    required this.randevuId,
    required this.tarih,
    required this.saat,
    this.bitis,
    required this.baslik,
    required this.aciklama,
  });

  /// Google Takvim "etkinlik oluştur" bağlantısı (uygulama yüklüyse onda, değilse tarayıcıda açılır).
  Uri googleBaglantisi() {
    String zaman(String s) => '${tarih.replaceAll('-', '')}T${s.replaceAll(':', '')}00';
    return Uri.https('calendar.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': baslik,
      'dates': '${zaman(saat)}/${zaman(bitis ?? saat)}',
      'ctz': 'Europe/Istanbul',
      'details': aciklama,
    });
  }
}

/// Randevuyu kullanıcının takvimine ekler: Google Takvim bağlantısı veya .ics dosyası (diğer takvimler).
class TakvimPaylasimi {
  TakvimPaylasimi._();

  static Future<void> secenekleriGoster(BuildContext context, TakvimEtkinligi e) async {
    final secim = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Takvime Ekle',
                style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 19, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.event, color: AppTheme.gold),
            title: const Text('Google Takvim'),
            onTap: () => Navigator.pop(ctx, 'google'),
          ),
          ListTile(
            leading: const Icon(Icons.ios_share, color: AppTheme.gold),
            title: const Text('Diğer takvim uygulaması (.ics)'),
            subtitle: const Text('Samsung Takvim, Outlook, Apple Takvim…'),
            onTap: () => Navigator.pop(ctx, 'ics'),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (secim == null || !context.mounted) return;
    if (secim == 'google') {
      if (!await Harici.ac(e.googleBaglantisi()) && context.mounted) {
        bilgiGoster(context, 'Takvim açılamadı.', hata: true);
      }
      return;
    }
    await _icsPaylas(context, e.randevuId);
  }

  static Future<void> _icsPaylas(BuildContext context, int randevuId) async {
    try {
      final ics = await RandevuApi.takvimDosyasi(randevuId);
      await Share.shareXFiles(
        [XFile.fromData(utf8.encode(ics), mimeType: 'text/calendar')],
        fileNameOverrides: ['randevu-$randevuId.ics'],
        subject: 'Berber randevusu',
      );
    } on ApiHata catch (e) {
      if (context.mounted) bilgiGoster(context, e.mesaj, hata: true);
    }
  }
}
