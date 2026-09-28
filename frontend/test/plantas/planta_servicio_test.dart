import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plantacert_app/core/api_excepcion.dart';
import 'package:plantacert_app/plantas/planta_servicio.dart';

http.Response _json(Object cuerpo, int status) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

const _monstera = {
  'id': 1,
  'nombre': 'Monstera',
  'especie': 'Monstera deliciosa',
  'ubicacion': 'Sala',
  'descripcion': 'Hojas grandes',
  'imagenUrl': 'https://ejemplo.com/monstera.jpg',
  'fechaRegistro': '2026-09-23T20:39:59.0636091',
  'usuarioId': 1,
};

void main() {
  group('PlantaServicio (RQ4-HU01)', () {
    test('registrar envía POST al catálogo del usuario', () async {
      late http.Request enviada;
      final servicio = PlantaServicio(
        cliente: MockClient((request) async {
          enviada = request;
          return _json(_monstera, 201);
        }),
      );

      final planta = await servicio.registrar(
        usuarioId: 1,
        nombre: 'Monstera',
        especie: 'Monstera deliciosa',
        ubicacion: 'Sala',
        descripcion: 'Hojas grandes',
        imagenUrl: 'https://ejemplo.com/monstera.jpg',
      );

      expect(enviada.method, 'POST');
      expect(enviada.url.path, endsWith('/plantas/usuario/1'));
      expect(jsonDecode(enviada.body)['especie'], 'Monstera deliciosa');
      expect(planta.id, 1);
      expect(planta.usuarioId, 1);
      expect(planta.fechaRegistro, isNotNull);
    });

    test('listar convierte la respuesta en plantas', () async {
      final servicio = PlantaServicio(
        cliente: MockClient((_) async => _json([_monstera], 200)),
      );

      final plantas = await servicio.listar(1);

      expect(plantas, hasLength(1));
      expect(plantas.first.nombre, 'Monstera');
    });

    test('usuario inexistente (404) lanza ApiExcepcion', () async {
      final servicio = PlantaServicio(
        cliente: MockClient((_) async => _json({
              'mensaje': 'El usuario indicado no existe',
              'error': {
                'codigo': 'CERT-ERR-P1',
                'detalles': ['El usuario indicado no existe'],
              },
            }, 404)),
      );

      expect(
        () => servicio.registrar(
            usuarioId: 999, nombre: 'Monstera', especie: 'x', ubicacion: 'Sala'),
        throwsA(isA<ApiExcepcion>().having((e) => e.status, 'status', 404)),
      );
    });
  });
}
