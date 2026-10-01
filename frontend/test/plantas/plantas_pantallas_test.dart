import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plantacert_app/core/sesion.dart';
import 'package:plantacert_app/inicio/inicio_pantalla.dart';
import 'package:plantacert_app/plantas/agregar_planta_pantalla.dart';
import 'package:plantacert_app/plantas/catalogo_pantalla.dart';
import 'package:plantacert_app/plantas/planta_servicio.dart';

http.Response _json(Object cuerpo, int status) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

/// Simula el backend guardando las plantas en memoria.
PlantaServicio _backendSimulado() {
  final plantas = <Map<String, dynamic>>[];
  return PlantaServicio(
    cliente: MockClient((request) async {
      if (request.method == 'POST') {
        final datos = jsonDecode(request.body) as Map<String, dynamic>;
        final planta = {
          'id': plantas.length + 1,
          'nombre': datos['nombre'],
          'especie': datos['especie'],
          'ubicacion': datos['ubicacion'],
          'descripcion': datos['descripcion'],
          // En las pruebas no se cargan imágenes reales
          'imagenUrl': null,
          'fechaRegistro': '2026-09-26T10:00:00',
          'usuarioId': 1,
        };
        plantas.add(planta);
        return _json(planta, 201);
      }
      return _json(plantas, 200);
    }),
  );
}

Future<void> _tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => Sesion.usuarioId = 1);
  tearDown(Sesion.cerrar);

  testWidgets('el inicio muestra la opción Mis plantas', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InicioPantalla()));

    expect(find.byKey(const Key('menu_mis_plantas')), findsOneWidget);
  });

  testWidgets('catálogo vacío muestra mensaje de ayuda', (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: CatalogoPantalla(servicio: _backendSimulado())));
    await tester.pumpAndSettle();

    expect(find.textContaining('Aún no tienes plantas'), findsOneWidget);
  });

  testWidgets('el formulario valida campos obligatorios y URL', (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: AgregarPlantaPantalla(servicio: _backendSimulado())));

    await tester.enterText(find.byKey(const Key('planta_imagen')), 'foto-helecho');
    await _tocar(tester, find.byKey(const Key('planta_guardar')));

    expect(find.text('El nombre de la planta es requerido'), findsOneWidget);
    expect(find.text('La especie es requerida'), findsOneWidget);
    expect(find.text('La ubicación es requerida'), findsOneWidget);
    expect(find.textContaining('enlace válido'), findsOneWidget);
  });

  testWidgets('agregar planta la muestra en el catálogo', (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: CatalogoPantalla(servicio: _backendSimulado())));
    await tester.pumpAndSettle();

    await _tocar(tester, find.byKey(const Key('boton_agregar_planta')));
    await tester.enterText(find.byKey(const Key('planta_nombre')), 'Monstera');
    await tester.enterText(
        find.byKey(const Key('planta_especie')), 'Monstera deliciosa');
    await tester.enterText(find.byKey(const Key('planta_ubicacion')), 'Sala');
    await tester.enterText(
        find.byKey(const Key('planta_descripcion')), 'Hojas grandes');
    await _tocar(tester, find.byKey(const Key('planta_guardar')));

    expect(find.text('Mis plantas'), findsOneWidget);
    expect(find.text('Monstera'), findsOneWidget);
    expect(find.text('Monstera deliciosa · Sala'), findsOneWidget);
    expect(find.textContaining('agregada a tu catálogo'), findsOneWidget);
  });

  testWidgets('muestra el error del backend al guardar', (tester) async {
    final servicio = PlantaServicio(
      cliente: MockClient((_) async => _json({
            'mensaje': 'El usuario indicado no existe',
            'error': {
              'codigo': 'CERT-ERR-P1',
              'detalles': ['El usuario indicado no existe'],
            },
          }, 404)),
    );
    await tester.pumpWidget(
        MaterialApp(home: AgregarPlantaPantalla(servicio: servicio)));

    await tester.enterText(find.byKey(const Key('planta_nombre')), 'Monstera');
    await tester.enterText(find.byKey(const Key('planta_especie')), 'Monstera');
    await tester.enterText(find.byKey(const Key('planta_ubicacion')), 'Sala');
    await _tocar(tester, find.byKey(const Key('planta_guardar')));

    expect(find.byKey(const Key('planta_error')), findsOneWidget);
    expect(find.text('El usuario indicado no existe'), findsOneWidget);
  });
}
