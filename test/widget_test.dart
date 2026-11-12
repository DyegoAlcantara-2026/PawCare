
import 'package:flutter_test/flutter_test.dart';
import 'package:pawcare/main.dart';

void main() {
  testWidgets('PawCare abre corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const PawCareApp());

    expect(find.text('PawCare'), findsOneWidget);
    expect(find.text('Bem-vindo ao PawCare'), findsOneWidget);
    expect(find.text('Acesso rápido'), findsOneWidget);
  });
}
