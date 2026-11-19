import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plantacert_app/especies/especie.dart';
import 'package:plantacert_app/especies/especie_servicio.dart';
import 'package:plantacert_app/plantas/agregar_planta_pantalla.dart';
import 'package:plantacert_app/plantas/planta_servicio.dart';

const _especiesJson = [
  {'id': 1, 'nombreCientifico': 'Monstera deliciosa', 'nombreComun': 'Costilla de Adán'},
  {'id': 2, 'nombreCientifico': 'Epipremnum aureum', 'nombreComun': 'Potus'},
  {'id': 3, 'nombreCientifico': 'Aloe vera', 'nombreComun': 'Sábila'},
];

EspecieServicio _servicioEspecies({int status = 200}) => EspecieServicio(
      cliente: MockClient((request) async {
        expect(request.url.path, endsWith('/especies'));
        return http.Response.bytes(
          utf8.encode(jsonEncode(_especiesJson)),
          status,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

void main() {
  group('EspecieServicio', () {
    test('convierte la respuesta en especies', () async {
      final especies = await _servicioEspecies().listar();
      expect(especies.length, 3);
      expect(especies.first.nombreComun, 'Costilla de Adán');
    });

    test('si la API falla devuelve una lista vacía', () async {
      expect(await _servicioEspecies(status: 500).listar(), isEmpty);
      final sinConexion = EspecieServicio(
        cliente: MockClient((_) async => throw Exception('sin red')),
      );
      expect(await sinConexion.listar(), isEmpty);
    });

    test('filtrarEspecies busca por nombre común o científico sin tildes', () {
      final especies = [
        for (final json in _especiesJson) Especie.desdeJson(json),
      ];
      expect(filtrarEspecies(especies, 'sabila').single.nombreCientifico, 'Aloe vera');
      expect(filtrarEspecies(especies, 'EPIPREM').single.nombreComun, 'Potus');
      expect(filtrarEspecies(especies, ''), especies);
    });
  });

  testWidgets('al registrar una planta se elige la especie de la lista',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AgregarPlantaPantalla(
        servicio: PlantaServicio(cliente: MockClient((_) async => http.Response('', 500))),
        servicioEspecies: _servicioEspecies(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('3 especies registradas'), findsOneWidget);

    await tester.tap(find.byKey(const Key('planta_especie')));
    await tester.enterText(find.byKey(const Key('planta_especie')), 'costilla');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('planta_especie_opciones')), findsOneWidget);
    await tester.tap(find.text('Costilla de Adán'));
    await tester.pumpAndSettle();

    final campo = tester.widget<TextFormField>(find.byKey(const Key('planta_especie')));
    expect(campo.controller!.text, 'Monstera deliciosa');
  });
}
