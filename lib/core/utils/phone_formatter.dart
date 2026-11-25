import 'package:flutter/services.dart';

/// Formatação de telefone brasileiro: "(63) 99999-0000" (celular, 11
/// dígitos) ou "(63) 3333-0000" (fixo, 10 dígitos).
class PhoneFormatter {
  PhoneFormatter._();

  static const maxDigits = 11;

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  /// Formata o que houver de dígitos, mesmo incompleto (para a máscara
  /// enquanto digita).
  static String format(String value) {
    final d = digitsOnly(value);
    final digits = d.length > maxDigits ? d.substring(0, maxDigits) : d;
    if (digits.isEmpty) return '';
    if (digits.length <= 2) return '($digits';

    final ddd = digits.substring(0, 2);
    final rest = digits.substring(2);
    // Celular (9 dígitos depois do DDD) separa 5 + 4; fixo, 4 + 4.
    final split = rest.length > 8 ? 5 : 4;
    if (rest.length <= split) return '($ddd) $rest';
    return '($ddd) ${rest.substring(0, split)}-${rest.substring(split)}';
  }
}

/// Máscara de telefone para campos de texto.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = PhoneFormatter.format(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
