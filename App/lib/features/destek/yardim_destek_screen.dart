import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/features/destek/widgets/bize_ulasin_sekmesi.dart';
import 'package:berber_app_ui/features/destek/widgets/sss_sekmesi.dart';

/// Yardım & Destek: SSS ve Bize Ulaşın.
class YardimDestekScreen extends StatelessWidget {
  final int baslangicSekmesi;
  const YardimDestekScreen({super.key, this.baslangicSekmesi = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: baslangicSekmesi,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Dil.t.yardimDestek),
          bottom: TabBar(
            indicatorColor: AppTheme.gold,
            labelColor: AppTheme.gold,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: [
              Tab(text: Dil.t.sss, icon: Icon(Icons.help_outline, size: 20)),
              Tab(text: Dil.t.bizeUlasin, icon: Icon(Icons.mail_outline, size: 20)),
            ],
          ),
        ),
        body: const TabBarView(children: [SssSekmesi(), BizeUlasinSekmesi()]),
      ),
    );
  }
}
