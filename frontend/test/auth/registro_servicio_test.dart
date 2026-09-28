import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plantacert_app/auth/registro_servicio.dart';
import 'package:plantacert_app/core/api_excepcion.dart';

http.Response _json(Object cuerpo, int status) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  group('RegistroServicio (RQ1-HU01)', () {
    test('envía los datos al endpoint de registro y devuelve el usuario', () async {
      late http.Request enviada;
      final servicio = RegistroServicio(
        cliente: MockClient((request) async {
          enviada = request;
          return _json({
            'id': 1,
            'nombre': 'Valeria Gómez',
            'correo': 'valeria@correo.com',
            'mensaje': 'Registro exitoso. Ahora puedes iniciar sesión.',
          }, 201);
        }),
      );

      final usuario = await servicio.registrar(
        nombre: ' Valeria Gómez ',
        correo: 'valeria@correo.com',
        contrasena: 'clave1234',
      );

      expect(enviada.method, 'POST');
      expect(enviada.url.path, endsWith('/usuarios/registro'));
      expect(jsonDecode(enviada.body)['nombre'], 'Valeria Gómez');
      expect(usuario.id, 1);
      expect(usuario.mensaje, contains('Registro exitoso'));
    });

    test('correo duplicado (409) lanza ApiExcepcion con el mensaje del backend', () async {
      final servicio = RegistroServicio(
        cliente: MockClient((_) async => _json({
              'status': 409,
              'mensaje': 'El correo electrónico ya se encuentra registrado',
              'error': {
                'codigo': 'CERT-ERR-U1',
                'detalles': ['El correo electrónico ya se encuentra registrado'],
              },
            }, 409)),
      );

      expect(
        () => servicio.registrar(
            nombre: 'Valeria', correo: 'valeria@correo.com', contrasena: 'clave1234'),
        throwsA(isA<ApiExcepcion>()
            .having((e) => e.status, 'status', 409)
            .having((e) => e.mensaje, 'mensaje', contains('ya se encuentra registrado'))),
      );
    });

    test('sin conexión lanza ApiExcepcion con status 0', () async {
      final servicio = RegistroServicio(
        cliente: MockClient((_) async => throw Exception('sin red')),
      );

      expect(
        () => servicio.registrar(
            nombre: 'Valeria', correo: 'valeria@correo.com', contrasena: 'clave1234'),
        throwsA(isA<ApiExcepcion>().having((e) => e.status, 'status', 0)),
      );
    });
  });
}
