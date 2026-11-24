import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/core/utils/date_formatter.dart';

void main() {
  test('formata como no protótipo', () {
    expect(DateFormatter.shortDate(DateTime(2026, 11, 26)), 'Qui, 26 nov 2026');
    expect(DateFormatter.shortDate(DateTime(2026, 11, 30)), 'Seg, 30 nov 2026');
    expect(DateFormatter.shortDate(DateTime(2027, 3, 7)), 'Dom, 7 mar 2027');
  });

  test('dia da semana e mês por extenso', () {
    expect(DateFormatter.weekdayShort(DateTime(2026, 11, 24)), 'Ter');
    expect(DateFormatter.monthYear(DateTime(2026, 11, 24)), 'Novembro 2026');
    expect(DateFormatter.monthYear(DateTime(2027, 3, 1)), 'Março 2027');
  });
}
