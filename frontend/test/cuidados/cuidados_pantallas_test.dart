import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plantacert_app/core/sesion.dart';
import 'package:plantacert_app/cuidados/agregar_cuidado_pantalla.dart';
import 'package:plantacert_app/cuidados/cuidado.dart';
import 'package:plantacert_app/cuidados/cuidado_servicio.dart';
import 'package:plantacert_app/plantas/detalle_planta_pantalla.dart';
import 'package:plantacert_app/plantas/planta.dart';

http.Response _json(Object cuerpo, int status) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

const _monstera = Planta(
  id: 5,
  nombre: 'Monstera',
  especie: 'Monstera deliciosa',
  ubicacion: 'Sala',
);

/// Simula el backend guardando los cuidados en memoria.
CuidadoServicio _backendSimulado() {
  final cuidados = <Map<String, dynamic>>[];
  return CuidadoServicio(
    cliente: MockClient((request) async {
      if (request.method == 'POST') {
        final datos = jsonDecode(request.body) as Map<String, dynamic>;
        final cuidado = {
          'id': cuidados.length + 1,
          ...datos,
          'fechaRegistro': '2026-10-24T10:00:00',
          'plantaId': 5,
        };
        cuidados.add(cuidado);
        return _json(cuidado, 201);
      }
      return _json(cuidados, 200);
    }),
  );
}

Future<void> _tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _elegirTipo(WidgetTester tester, String texto) async {
  await _tocar(tester, find.byKey(const Key('cuidado_tipo')));
  await tester.tap(find.text(texto).last);
  await tester.pumpAndSettle();
}

String _ayer() => fechaATexto(DateTime.now().subtract(const Duration(days: 1)));

void main() {
  setUp(() => Sesion.usuarioId = 1);
  tearDown(Sesion.cerrar);

  testWidgets('planta sin cuidados muestra mensaje de ayuda', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DetallePlantaPantalla(planta: _monstera, servicioCuidados: _backendSimulado()),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cuidados_vacio')), findsOneWidget);
    expect(find.byKey(const Key('boton_agregar_cuidado')), findsOneWidget);
  });

  testWidgets('el formulario valida los campos obligatorios', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AgregarCuidadoPantalla(
          plantaId: 5, nombrePlanta: 'Monstera', servicio: _backendSimulado()),
    ));

    await _tocar(tester, find.byKey(const Key('cuidado_guardar')));

    expect(find.text('Selecciona el tipo de cuidado'), findsOneWidget);
    expect(find.text('La frecuencia es requerida'), findsOneWidget);
    expect(find.text('La fecha del último cuidado es requerida'), findsOneWidget);
  });

  testWidgets('no acepta frecuencia 0 ni fecha futura', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AgregarCuidadoPantalla(
          plantaId: 5, nombrePlanta: 'Monstera', servicio: _backendSimulado()),
    ));
    final manana = fechaATexto(DateTime.now().add(const Duration(days: 2)));

    await _elegirTipo(tester, 'Poda');
    await tester.enterText(find.byKey(const Key('cuidado_frecuencia')), '0');
    await tester.enterText(find.byKey(const Key('cuidado_fecha')), manana);
    await _tocar(tester, find.byKey(const Key('cuidado_guardar')));

    expect(find.text('La frecuencia debe ser de al menos 1 día'), findsOneWidget);
    expect(find.textContaining('fecha futura'), findsOneWidget);
  });

  testWidgets('al guardar se cierra el formulario, sale el mensaje y aparece el cuidado',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DetallePlantaPantalla(planta: _monstera, servicioCuidados: _backendSimulado()),
    ));
    await tester.pumpAndSettle();

    await _tocar(tester, find.byKey(const Key('boton_agregar_cuidado')));
    await _elegirTipo(tester, 'Riego');
    await tester.enterText(find.byKey(const Key('cuidado_frecuencia')), '3');
    await tester.enterText(find.byKey(const Key('cuidado_fecha')), _ayer());
    await tester.enterText(find.byKey(const Key('cuidado_notas')), 'Agua reposada');
    await _tocar(tester, find.byKey(const Key('cuidado_guardar')));

    expect(find.byType(AgregarCuidadoPantalla), findsNothing);
    expect(find.textContaining('Cuidado de Riego agregado'), findsOneWidget);
    expect(find.textContaining('Cada 3 días'), findsOneWidget);
    expect(find.text('Agua reposada'), findsOneWidget);
  });

  testWidgets('si la planta no es del usuario muestra el error del servidor',
      (tester) async {
    final servicio = CuidadoServicio(
      cliente: MockClient((_) async => _json({
            'mensaje': 'La planta no existe o no pertenece al usuario',
            'error': {
              'codigo': 'CERT-ERR-C1',
              'detalles': ['La planta no existe o no pertenece al usuario'],
            },
          }, 404)),
    );
    await tester.pumpWidget(MaterialApp(
      home: AgregarCuidadoPantalla(plantaId: 99, nombrePlanta: 'Ajena', servicio: servicio),
    ));

    await _elegirTipo(tester, 'Riego');
    await tester.enterText(find.byKey(const Key('cuidado_frecuencia')), '3');
    await tester.enterText(find.byKey(const Key('cuidado_fecha')), _ayer());
    await _tocar(tester, find.byKey(const Key('cuidado_guardar')));

    expect(find.byKey(const Key('cuidado_error')), findsOneWidget);
    expect(find.textContaining('no pertenece al usuario'), findsOneWidget);
  });
}
