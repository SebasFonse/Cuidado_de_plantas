import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plantacert_app/core/sesion.dart';
import 'package:plantacert_app/cuidados/agregar_cuidado_pantalla.dart';
import 'package:plantacert_app/inicio/inicio_pantalla.dart';
import 'package:plantacert_app/plantas/foto_planta.dart';
import 'package:plantacert_app/plantas/planta_servicio.dart';

http.Response _json(Object cuerpo, int status) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  setUp(() => Sesion.usuarioId = 1);
  tearDown(Sesion.cerrar);

  testWidgets('sin enlace la foto muestra la imagen por defecto', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: FotoPlanta(imagenUrl: '  ', ancho: 100, alto: 100)),
    ));

    expect(find.byKey(const Key('imagen_por_defecto')), findsOneWidget);
  });

  testWidgets('con plantaId la foto viaja entre pantallas (Hero)', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: FotoPlanta(imagenUrl: null, plantaId: 7)),
    ));

    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, etiquetaFotoPlanta(7));
  });

  testWidgets('el formulario de cuidados muestra la foto de la planta',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AgregarCuidadoPantalla(plantaId: 5, nombrePlanta: 'Monstera'),
    ));

    expect(find.byType(FotoPlanta), findsOneWidget);
    expect(find.text('Monstera'), findsOneWidget);
  });

  testWidgets('el inicio muestra las fotos de las plantas del usuario',
      (tester) async {
    final servicio = PlantaServicio(
      cliente: MockClient((_) async => _json([
            {
              'id': 1,
              'nombre': 'Monstera',
              'especie': 'Monstera deliciosa',
              'ubicacion': 'Sala',
              'imagenUrl': null,
              'usuarioId': 1,
            },
            {
              'id': 2,
              'nombre': 'Helecho',
              'especie': 'Nephrolepis exaltata',
              'ubicacion': 'Balcón',
              'imagenUrl': null,
              'usuarioId': 1,
            },
          ], 200)),
    );
    await tester.pumpWidget(MaterialApp(home: InicioPantalla(servicio: servicio)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inicio_fotos_plantas')), findsOneWidget);
    expect(find.text('Monstera'), findsOneWidget);
    expect(find.text('Helecho'), findsOneWidget);
  });
}
