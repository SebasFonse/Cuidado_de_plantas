import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plantacert_app/core/api_excepcion.dart';
import 'package:plantacert_app/core/validadores.dart';
import 'package:plantacert_app/cuidados/cuidado_servicio.dart';

http.Response _json(Object cuerpo, int status) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

const _riego = {
  'id': 1,
  'tipo': 'RIEGO',
  'frecuenciaDias': 3,
  'fechaUltimoCuidado': '2026-10-23',
  'notas': 'Agua reposada',
  'fechaRegistro': '2026-10-24T10:00:00',
  'plantaId': 5,
};

void main() {
  group('CuidadoServicio (HU08)', () {
    test('registrar envía POST con los datos del cuidado', () async {
      late http.Request enviada;
      final servicio = CuidadoServicio(
        cliente: MockClient((request) async {
          enviada = request;
          return _json(_riego, 201);
        }),
      );

      final cuidado = await servicio.registrar(
        usuarioId: 1,
        plantaId: 5,
        tipo: 'RIEGO',
        frecuenciaDias: 3,
        fechaUltimoCuidado: DateTime(2026, 10, 23),
        notas: ' Agua reposada ',
      );

      final cuerpo = jsonDecode(enviada.body);
      expect(enviada.method, 'POST');
      expect(enviada.url.path, endsWith('/cuidados/usuario/1/planta/5'));
      expect(cuerpo['fechaUltimoCuidado'], '2026-10-23');
      expect(cuerpo['notas'], 'Agua reposada');
      expect(cuidado.tipoTexto, 'Riego');
      expect(cuidado.plantaId, 5);
    });

    test('listar convierte la respuesta en cuidados', () async {
      final servicio = CuidadoServicio(
        cliente: MockClient((_) async => _json([_riego], 200)),
      );

      final cuidados = await servicio.listar(1, 5);

      expect(cuidados, hasLength(1));
      expect(cuidados.first.frecuenciaDias, 3);
      expect(cuidados.first.fechaUltimoCuidado, DateTime(2026, 10, 23));
    });

    test('planta ajena o inexistente (404) lanza ApiExcepcion', () async {
      final servicio = CuidadoServicio(
        cliente: MockClient((_) async => _json({
              'mensaje': 'La planta no existe o no pertenece al usuario',
              'error': {
                'codigo': 'CERT-ERR-C1',
                'detalles': ['La planta no existe o no pertenece al usuario'],
              },
            }, 404)),
      );

      expect(
        () => servicio.registrar(
          usuarioId: 1,
          plantaId: 99,
          tipo: 'PODA',
          frecuenciaDias: 30,
          fechaUltimoCuidado: DateTime(2026, 10, 1),
        ),
        throwsA(isA<ApiExcepcion>().having((e) => e.status, 'status', 404)),
      );
    });
  });

  group('Validadores de cuidado (HU08)', () {
    test('frecuencia entre 1 y 365', () {
      expect(Validadores.frecuencia(''), 'La frecuencia es requerida');
      expect(Validadores.frecuencia('abc'), contains('número entero'));
      expect(Validadores.frecuencia('0'), contains('al menos 1 día'));
      expect(Validadores.frecuencia('366'), contains('365'));
      expect(Validadores.frecuencia('7'), isNull);
    });

    test('fecha obligatoria, válida y no futura', () {
      final hoy = DateTime(2026, 10, 24);
      expect(Validadores.fechaNoFutura('', hoy: hoy),
          'La fecha del último cuidado es requerida');
      expect(Validadores.fechaNoFutura('24/10/2026', hoy: hoy), contains('AAAA-MM-DD'));
      expect(Validadores.fechaNoFutura('2026-02-30', hoy: hoy), contains('AAAA-MM-DD'));
      expect(Validadores.fechaNoFutura('2026-10-25', hoy: hoy), contains('fecha futura'));
      expect(Validadores.fechaNoFutura('2026-10-24', hoy: hoy), isNull);
      expect(Validadores.fechaNoFutura('2026-01-15', hoy: hoy), isNull);
    });
  });
}
