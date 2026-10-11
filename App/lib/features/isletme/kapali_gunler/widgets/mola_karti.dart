import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/panel_api.dart';
import 'package:berber_app_ui/features/isletme/kapali_gunler/widgets/saat_secici.dart';

/// Salonun günlük öğle arası: tüm personel için bu saatlerde randevu alınmaz.
class MolaKarti extends StatefulWidget {
  /// `/panel/salon` yanıtı (çalışma saatleri dahil; kayıt tüm alanlarla yapılır)
  final Json salon;
  final ValueChanged<Json> onDegisti;
  const MolaKarti({super.key, required this.salon, required this.onDegisti});

  @override
  State<MolaKarti> createState() => _MolaKartiState();
}

class _MolaKartiState extends State<MolaKarti> {
  bool _kaydediliyor = false;

  Future<void> _kaydet(String? bas, String? bit) async {
    setState(() => _kaydediliyor = true);
    try {
      final s = widget.salon;
      final yeni = await PanelApi.salonGuncelle({
        for (final k in ['ad', 'adres', 'telefon', 'whatsapp', 'instagram_url', 'acilis_saati', 'kapanis_saati',
            'pazar_acilis_saati', 'pazar_kapanis_saati', 'kapali_gunler'])
          k: s[k],
        'mola_baslangic': bas,
        'mola_bitis': bit,
      });
      widget.onDegisti(yeni);
      if (mounted) bilgiGoster(context, bas == null ? 'Öğle arası kaldırıldı.' : 'Öğle arası $bas–$bit olarak kaydedildi.');
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  Future<void> _duzenle() async {
    final aralik = await saatAraligiSec(context,
        bas: widget.salon['mola_baslangic'] ?? '13:00', bit: widget.salon['mola_bitis'] ?? '14:00');
    if (aralik == null) return;
    await _kaydet(aralik.$1, aralik.$2);
  }

  @override
  Widget build(BuildContext context) {
    final bas = widget.salon['mola_baslangic'] as String?;
    final bit = widget.salon['mola_bitis'] as String?;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.free_breakfast_outlined, color: AppTheme.gold),
        title: Text(bas == null ? 'Öğle arası tanımlı değil' : 'Öğle arası: $bas – $bit',
            style: const TextStyle(color: Colors.white)),
        subtitle: Text('Her gün bu saatlerde randevu alınmaz.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: _kaydediliyor
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.gold))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                if (bas != null)
                  IconButton(tooltip: 'Öğle arasını kaldır', icon: const Icon(Icons.close),
                      onPressed: () => _kaydet(null, null)),
                IconButton(tooltip: 'Düzenle', icon: const Icon(Icons.edit_outlined, color: AppTheme.gold),
                    onPressed: _duzenle),
              ]),
      ),
    );
  }
}
