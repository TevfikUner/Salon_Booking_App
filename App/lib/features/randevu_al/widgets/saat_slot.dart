import 'package:flutter/material.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';

/// 30 dakikalık saat slotu — yeşil=müsait, kırmızı=dolu, gri=kapsam dışı
class SaatSlotWidget extends StatelessWidget {
  final String saat;
  final SlotDurumu durum;
  final bool secili;
  final VoidCallback? onTap;

  /// Bu saatte geçerli kampanya indirimi (yüzde); 0 = yok
  final int indirimYuzde;

  const SaatSlotWidget({
    super.key,
    required this.saat,
    required this.durum,
    this.secili = false,
    this.onTap,
    this.indirimYuzde = 0,
  });

  bool get _indirimli => indirimYuzde > 0 && durum == SlotDurumu.musait;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final Color borderColor;

    if (secili) {
      bgColor = AppTheme.gold;
      textColor = AppTheme.black;
      borderColor = AppTheme.gold;
    } else {
      switch (durum) {
        case SlotDurumu.musait:
          bgColor = AppTheme.slotGreen.withValues(alpha: 0.18);
          textColor = AppTheme.success;
          borderColor = AppTheme.slotGreen;
          break;
        case SlotDurumu.dolu:
          bgColor = AppTheme.slotRed.withValues(alpha: 0.18);
          textColor = AppTheme.error;
          borderColor = AppTheme.slotRed;
          break;
        case SlotDurumu.kapsamDisi:
          bgColor = AppTheme.surface;
          textColor = AppTheme.textSecondary;
          borderColor = Colors.transparent;
          break;
      }
    }

    return GestureDetector(
      onTap: durum == SlotDurumu.musait ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: _indirimli ? 4 : 12, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: secili ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          // Büyük yazı ölçeğinde iki satır hücreye sığmazsa küçülür (taşma yok)
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  saat,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: secili ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (_indirimli)
                  Text(
                    '%$indirimYuzde indirim',
                    style: TextStyle(
                      color: secili ? AppTheme.black : AppTheme.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum SlotDurumu { musait, dolu, kapsamDisi }
