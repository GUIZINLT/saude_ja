import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/core/utils/phone_formatter.dart';

void main() {
  test('celular e fixo completos', () {
    expect(PhoneFormatter.format('63999990000'), '(63) 99999-0000');
    expect(PhoneFormatter.format('6333330000'), '(63) 3333-0000');
  });

  test('formata enquanto digita', () {
    expect(PhoneFormatter.format(''), '');
    expect(PhoneFormatter.format('6'), '(6');
    expect(PhoneFormatter.format('63'), '(63');
    expect(PhoneFormatter.format('639'), '(63) 9');
    expect(PhoneFormatter.format('639999'), '(63) 9999');
    expect(PhoneFormatter.format('6399999'), '(63) 9999-9');
  });

  test('ignora pontuação e corta no 11º dígito', () {
    expect(PhoneFormatter.format('(63) 99999-0000'), '(63) 99999-0000');
    expect(PhoneFormatter.format('639999900001234'), '(63) 99999-0000');
  });

  test('máscara do campo coloca o cursor no fim', () {
    final result = PhoneInputFormatter().formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '63999990000'),
    );
    expect(result.text, '(63) 99999-0000');
    expect(result.selection.baseOffset, result.text.length);
  });
}
