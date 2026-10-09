import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';

/// Doğrulamalı form alanları.
class Alanlar {
  Alanlar._();

  static Widget metin(TextEditingController c, String etiket, IconData ikon,
          {bool zorunlu = true, TextInputType? klavye, TextCapitalization buyukHarf = TextCapitalization.words}) =>
      TextFormField(
        controller: c,
        keyboardType: klavye,
        textCapitalization: buyukHarf,
        decoration: InputDecoration(labelText: etiket, prefixIcon: Icon(ikon, color: AppTheme.gold)),
        validator: (v) => zorunlu && (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null,
      );

  static Widget eposta(TextEditingController c) => TextFormField(
        controller: c,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email_outlined, color: AppTheme.gold)),
        validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '') ? null : 'Geçerli bir e-posta girin',
      );

  /// 10 haneli, 5 ile başlayan cep telefonu; başında sabit "0".
  static Widget telefon(TextEditingController c) => TextFormField(
        controller: c,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          labelText: 'Cep Telefonu',
          prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.gold),
          prefixText: '0 ',
          counterText: '',
          hintText: '5XX XXX XX XX',
        ),
        validator: (v) {
          final t = v?.trim() ?? '';
          return t.length == 10 && t.startsWith('5') ? null : '5 ile başlayan 10 rakam girin';
        },
      );
}
