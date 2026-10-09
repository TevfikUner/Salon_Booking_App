import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import 'package:berber_app_ui/core/config.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/harici.dart';
import 'package:berber_app_ui/core/widgets/altin_buton.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';

/// Destek talebi: konu + mesaj + isteğe bağlı ekler.
/// Ek yoksa doğrudan e-posta uygulaması açılır; ek varsa paylaşım menüsüyle dosyalar e-postaya iliştirilir
/// (mailto bağlantısı dosya taşıyamaz).
class BizeUlasinSekmesi extends StatefulWidget {
  const BizeUlasinSekmesi({super.key});

  @override
  State<BizeUlasinSekmesi> createState() => _BizeUlasinSekmesiState();
}

class _BizeUlasinSekmesiState extends State<BizeUlasinSekmesi> {
  static const _konular = ['Randevu Sorunu', 'Ödeme / Fiyat', 'Hesap Problemi', 'Uygulama Hatası', 'Öneri / İstek', 'Diğer'];

  String? _konu;
  final _mesaj = TextEditingController();
  final List<XFile> _ekler = [];

  @override
  void dispose() {
    _mesaj.dispose();
    super.dispose();
  }

  Future<void> _ekEkle() async {
    final kaynak = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.camera_alt, color: AppTheme.gold), title: const Text('Fotoğraf Çek'),
              onTap: () => Navigator.pop(ctx, 'kamera')),
          ListTile(leading: const Icon(Icons.photo_library, color: AppTheme.gold), title: const Text('Galeriden Seç'),
              onTap: () => Navigator.pop(ctx, 'galeri')),
          ListTile(leading: const Icon(Icons.attach_file, color: AppTheme.gold), title: const Text('Dosya Seç'),
              onTap: () => Navigator.pop(ctx, 'dosya')),
        ]),
      ),
    );
    if (kaynak == null) return;
    XFile? dosya;
    if (kaynak == 'dosya') {
      final sonuc = await FilePicker.platform.pickFiles();
      final yol = sonuc?.files.firstOrNull?.path;
      if (yol != null) dosya = XFile(yol);
    } else {
      dosya = await ImagePicker().pickImage(
        source: kaynak == 'kamera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
    }
    if (dosya != null && mounted) setState(() => _ekler.add(dosya!));
  }

  Future<void> _gonder() async {
    if (_konu == null) return bilgiGoster(context, 'Lütfen bir konu seçin.', hata: true);
    final mesaj = _mesaj.text.trim();
    if (mesaj.isEmpty) return bilgiGoster(context, 'Lütfen mesajınızı yazın.', hata: true);
    final konu = 'Premium Berber - $_konu';

    if (_ekler.isEmpty) {
      if (!await Harici.eposta(AppConfig.destekEposta, konu: konu, govde: mesaj) && mounted) {
        bilgiGoster(context, 'E-posta uygulaması açılamadı. Bize ${AppConfig.destekEposta} adresinden ulaşabilirsiniz.',
            hata: true);
      }
      return;
    }
    await Share.shareXFiles(_ekler, subject: konu, text: 'Alıcı: ${AppConfig.destekEposta}\n\n$mesaj');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('Sorununuzu bize bildirin, en kısa sürede dönüş yapalım.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
      const SizedBox(height: 20),
      DropdownButtonFormField<String>(
        initialValue: _konu,
        dropdownColor: AppTheme.surface,
        decoration: const InputDecoration(labelText: 'Konu'),
        items: [for (final k in _konular) DropdownMenuItem(value: k, child: Text(k))],
        onChanged: (v) => setState(() => _konu = v),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _mesaj,
        maxLines: 6,
        maxLength: 2000,
        decoration: const InputDecoration(labelText: 'Mesajınız', hintText: 'Sorununuzu veya isteğinizi açıklayın…'),
      ),
      OutlinedButton.icon(
        onPressed: _ekEkle,
        icon: const Icon(Icons.attach_file, color: AppTheme.gold),
        label: const Text('Fotoğraf veya dosya ekle', style: TextStyle(color: AppTheme.gold)),
      ),
      for (var i = 0; i < _ekler.length; i++)
        ListTile(
          dense: true,
          leading: const Icon(Icons.insert_drive_file_outlined, color: AppTheme.gold),
          title: Text(_ekler[i].name, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            tooltip: 'Eki kaldır',
            icon: const Icon(Icons.close, color: AppTheme.error),
            onPressed: () => setState(() => _ekler.removeAt(i)),
          ),
        ),
      const SizedBox(height: 20),
      AltinButon(
        text: _ekler.isEmpty ? 'E-posta Gönder' : 'Eklerle Gönder',
        onPressed: _gonder,
        icon: const Icon(Icons.send, color: AppTheme.black, size: 20),
      ),
    ]);
  }
}
