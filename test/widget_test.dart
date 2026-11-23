
import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/main.dart';

void main() {
  testWidgets('SaudeJaApp inicia corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const SaudeJaApp());

    expect(find.text('SaúdeJá | Design System'), findsOneWidget);
    expect(find.text('Bem-vindo ao SaúdeJá!'), findsOneWidget);
  });
}
