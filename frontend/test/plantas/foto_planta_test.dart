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
import 'package:plantacert_app/plantas/tipo_planta.dart';

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

  group('tipo de planta según nombre y especie', () {
    String emoji({String? nombre, String? especie}) =>
        tipoDePlanta(nombre: nombre, especie: especie).emoji;

    test('cactus y suculentas, aunque se escriba "Captus"', () {
      expect(emoji(nombre: 'Captus'), '🌵');
      expect(emoji(especie: 'Aloe vera'), '🌵');
      expect(emoji(nombre: 'Árbol de jade', especie: 'Crassula ovata'), '🌵');
    });

    test('orquídea, con o sin tilde', () {
      expect(emoji(nombre: 'Orquidia'), '🌸');
      expect(emoji(especie: 'Phalaenopsis amabilis'), '🌸');
      expect(emoji(nombre: 'Orquídea mariposa'), '🌸');
    });

    test('la especie manda sobre el nombre', () {
      expect(emoji(nombre: 'Mi planta', especie: 'Rosa chinensis'), '🌹');
      expect(emoji(nombre: 'Rosita', especie: 'Ficus lyrata'), '🌳');
    });

    test('otras especies de la base de datos', () {
      expect(emoji(especie: 'Helianthus annuus'), '🌻');
      expect(emoji(especie: 'Ocimum basilicum'), '🌿');
      expect(emoji(especie: 'Citrus limon'), '🍋');
      expect(emoji(especie: 'Dypsis lutescens'), '🌴');
    });

    test('si no se reconoce, se usa la planta en maceta', () {
      expect(emoji(nombre: 'Monstera', especie: 'Monstera deliciosa'), '🪴');
      expect(emoji(), '🪴');
    });
  });

  testWidgets('sin foto, el ícono corresponde al tipo de planta',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: FotoPlanta(imagenUrl: null, nombre: 'Captus', ancho: 100, alto: 100),
      ),
    ));

    expect(find.text('🌵'), findsOneWidget);
  });
}
