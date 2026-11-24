import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/core/utils/date_formatter.dart';

void main() {
  test('formata como no protótipo', () {
    expect(DateFormatter.shortDate(DateTime(2026, 11, 26)), 'Qui, 26 nov 2026');
    expect(DateFormatter.shortDate(DateTime(2026, 11, 30)), 'Seg, 30 nov 2026');
    expect(DateFormatter.shortDate(DateTime(2027, 3, 7)), 'Dom, 7 mar 2027');
  });
}
