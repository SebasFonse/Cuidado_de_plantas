import 'package:flutter_test/flutter_test.dart';
import 'package:plantacert_app/app/plantacert_app.dart';

void main() {
  testWidgets('La app abre en la pantalla de inicio de sesión', (tester) async {
    await tester.pumpWidget(const PlantacertApp());

    expect(find.text('Plantacert AI'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
