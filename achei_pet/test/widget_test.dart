import 'package:flutter_test/flutter_test.dart';

import 'package:achei_pet/main.dart';

void main() {
  testWidgets('mostra tela inicial de login', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Cadastre-se'), findsOneWidget);
  });
}
