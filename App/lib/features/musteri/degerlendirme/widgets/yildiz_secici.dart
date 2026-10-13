import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';

/// 1–5 yıldız seçici.
class YildizSecici extends StatelessWidget {
  final int secili;
  final ValueChanged<int> onSecim;
  const YildizSecici({super.key, required this.secili, required this.onSecim});

  static String metin(int puan) => ['', Dil.t.puanKotu, Dil.t.puanFenaDegil, Dil.t.puanIyi, Dil.t.puanCokIyi, Dil.t.puanMukemmel][puan];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            tooltip: Dil.t.yildizSayisi(i),
            iconSize: 44,
            onPressed: () => onSecim(i),
            icon: AnimatedScale(
              scale: i <= secili ? 1.1 : 1,
              duration: const Duration(milliseconds: 150),
              child: Icon(i <= secili ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: i <= secili ? AppTheme.gold : AppTheme.textSecondary),
            ),
          ),
      ],
    );
  }
}
