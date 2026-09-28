import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plantacert_app/app/plantacert_app.dart';
import 'package:plantacert_app/auth/registro_pantalla.dart';
import 'package:plantacert_app/auth/registro_servicio.dart';

Widget _app(RegistroServicio servicio) =>
    MaterialApp(home: RegistroPantalla(servicio: servicio));

RegistroServicio _servicioQueResponde(int status, Map<String, dynamic> cuerpo) =>
    RegistroServicio(
      cliente: MockClient((_) async => http.Response.bytes(
            utf8.encode(jsonEncode(cuerpo)),
            status,
            headers: {'content-type': 'application/json; charset=utf-8'},
          )),
    );

Future<void> _llenar(WidgetTester tester,
    {String nombre = 'Valeria Gómez',
    String correo = 'valeria@correo.com',
    String contrasena = 'clave1234',
    String? confirmar}) async {
  await tester.enterText(find.byKey(const Key('registro_nombre')), nombre);
  await tester.enterText(find.byKey(const Key('registro_correo')), correo);
  await tester.enterText(find.byKey(const Key('registro_contrasena')), contrasena);
  await tester.enterText(
      find.byKey(const Key('registro_confirmar')), confirmar ?? contrasena);
}

Future<void> _enviar(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('registro_boton')));
  await tester.tap(find.byKey(const Key('registro_boton')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el enlace de registro está en la pantalla de inicio de sesión',
      (tester) async {
    await tester.pumpWidget(const PlantacertApp());

    await tester.ensureVisible(find.byKey(const Key('enlace_registro')));
    await tester.tap(find.byKey(const Key('enlace_registro')));
    await tester.pumpAndSettle();

    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('muestra errores si los campos están vacíos', (tester) async {
    await tester.pumpWidget(_app(_servicioQueResponde(201, {})));

    await _enviar(tester);

    expect(find.text('El nombre completo es requerido'), findsOneWidget);
    expect(find.text('El correo electrónico es requerido'), findsOneWidget);
    expect(find.text('La contraseña es requerida'), findsOneWidget);
  });

  testWidgets('valida contraseña corta y contraseñas diferentes', (tester) async {
    await tester.pumpWidget(_app(_servicioQueResponde(201, {})));

    await _llenar(tester, contrasena: '123', confirmar: '1234');
    await _enviar(tester);

    expect(find.text('La contraseña debe tener mínimo 8 caracteres'), findsOneWidget);
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
  });

  testWidgets('registro exitoso redirige al inicio de sesión con confirmación',
      (tester) async {
    await tester.pumpWidget(_app(_servicioQueResponde(201, {
      'id': 1,
      'nombre': 'Valeria Gómez',
      'correo': 'valeria@correo.com',
      'mensaje': 'Registro exitoso. Ahora puedes iniciar sesión.',
    })));

    await _llenar(tester);
    await _enviar(tester);

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.textContaining('Registro exitoso'), findsOneWidget);
  });

  testWidgets('correo ya registrado muestra el mensaje del backend', (tester) async {
    await tester.pumpWidget(_app(_servicioQueResponde(409, {
      'mensaje': 'El correo electrónico ya se encuentra registrado',
      'error': {
        'codigo': 'CERT-ERR-U1',
        'detalles': ['El correo electrónico ya se encuentra registrado'],
      },
    })));

    await _llenar(tester);
    await _enviar(tester);

    expect(find.byKey(const Key('registro_error')), findsOneWidget);
    expect(find.text('El correo electrónico ya se encuentra registrado'), findsOneWidget);
  });
}
