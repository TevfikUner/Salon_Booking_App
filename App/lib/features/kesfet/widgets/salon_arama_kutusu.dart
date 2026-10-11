import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';

/// Salon adı / ilçe / hizmet araması ve "★ 4.5+" filtresi. Metin değişimi üst bileşende gecikmeli işlenir.
class SalonAramaKutusu extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onDegisti;
  final VoidCallback onTemizle;
  final bool yuksekPuan;
  final ValueChanged<bool> onYuksekPuan;

  const SalonAramaKutusu({
    super.key,
    required this.controller,
    required this.onDegisti,
    required this.onTemizle,
    required this.yuksekPuan,
    required this.onYuksekPuan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onDegisti,
            textInputAction: TextInputAction.search,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Salon, ilçe veya hizmet ara (ör. sakal)',
              prefixIcon: const Icon(Icons.search, color: AppTheme.gold, size: 20),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, v, _) => v.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(tooltip: 'Aramayı temizle', icon: const Icon(Icons.close, size: 18), onPressed: onTemizle),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('★ 4.5+'),
          tooltip: 'Yalnızca 4.5 ve üzeri puanlı salonlar',
          selected: yuksekPuan,
          onSelected: onYuksekPuan,
          selectedColor: AppTheme.gold,
          checkmarkColor: AppTheme.black,
          showCheckmark: false,
          backgroundColor: AppTheme.black,
          labelStyle: TextStyle(color: yuksekPuan ? AppTheme.black : AppTheme.gold, fontWeight: FontWeight.w600),
          side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.35)),
        ),
      ]),
    );
  }
}
