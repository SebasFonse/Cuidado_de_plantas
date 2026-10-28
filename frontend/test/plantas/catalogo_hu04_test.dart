import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plantacert_app/core/api_excepcion.dart';
import 'package:plantacert_app/core/sesion.dart';
import 'package:plantacert_app/plantas/catalogo_pantalla.dart';
import 'package:plantacert_app/plantas/planta_servicio.dart';

http.Response _json(Object cuerpo, int status) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

Map<String, dynamic> _planta(int id, String nombre, {String? imagenUrl}) => {
      'id': id,
      'nombre': nombre,
      'especie': 'Especie $id',
      'ubicacion': 'Ubicación $id',
      'descripcion': null,
      'imagenUrl': imagenUrl,
      'fechaRegistro': '2026-10-2${id}T10:00:00',
      'usuarioId': 1,
    };

PlantaServicio _servicioQueResponde(Object cuerpo, [int status = 200]) =>
    PlantaServicio(cliente: MockClient((_) async => _json(cuerpo, status)));

Future<void> _abrirCatalogo(WidgetTester tester, PlantaServicio servicio) async {
  await tester.pumpWidget(MaterialApp(home: CatalogoPantalla(servicio: servicio)));
  await tester.pumpAndSettle();
}

/// HU04: Ver listado de plantas del catálogo
void main() {
  setUp(() => Sesion.usuarioId = 1);
  tearDown(Sesion.cerrar);

  testWidgets('consulta solo las plantas del usuario de la sesión', (tester) async {
    Sesion.usuarioId = 7;
    Uri? consultada;
    final servicio = PlantaServicio(
      cliente: MockClient((request) async {
        consultada = request.url;
        return _json([], 200);
      }),
    );

    await _abrirCatalogo(tester, servicio);

    expect(consultada!.path, endsWith('/plantas/usuario/7'));
  });

  testWidgets('muestra un indicador mientras carga', (tester) async {
    final respuesta = Completer<http.Response>();
    final servicio =
        PlantaServicio(cliente: MockClient((_) => respuesta.future));

    await tester.pumpWidget(MaterialApp(home: CatalogoPantalla(servicio: servicio)));
    await tester.pump();

    expect(find.byKey(const Key('catalogo_cargando')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Cargando tus plantas...'), findsOneWidget);

    respuesta.complete(_json([], 200));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('catalogo_cargando')), findsNothing);
  });

  testWidgets('cada tarjeta muestra nombre, especie, ubicación e imagen',
      (tester) async {
    await _abrirCatalogo(tester, _servicioQueResponde([_planta(1, 'Helecho')]));

    final tarjeta = find.byKey(const Key('tarjeta_planta_1'));
    expect(tarjeta, findsOneWidget);
    expect(find.descendant(of: tarjeta, matching: find.text('Helecho')), findsOneWidget);
    expect(find.descendant(of: tarjeta, matching: find.text('Especie 1')), findsOneWidget);
    expect(find.descendant(of: tarjeta, matching: find.text('Ubicación 1')),
        findsOneWidget);
    // Sin enlace de foto se usa la imagen por defecto
    expect(
        find.descendant(
            of: tarjeta, matching: find.byKey(const Key('imagen_por_defecto'))),
        findsOneWidget);
  });

  testWidgets('si el enlace de la imagen no carga muestra la imagen por defecto',
      (tester) async {
    await _abrirCatalogo(
      tester,
      _servicioQueResponde(
          [_planta(1, 'Helecho', imagenUrl: 'https://no-existe.invalid/foto.jpg')]),
    );
    // En las pruebas las peticiones de imágenes fallan; se espera el errorBuilder
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('imagen_por_defecto')), findsOneWidget);
  });

  testWidgets('respeta el orden del backend: la más reciente primero',
      (tester) async {
    await _abrirCatalogo(
      tester,
      _servicioQueResponde([_planta(3, 'Tercera'), _planta(2, 'Segunda')]),
    );

    final arriba = tester.getTopLeft(find.text('Tercera')).dy;
    final abajo = tester.getTopLeft(find.text('Segunda')).dy;
    expect(arriba, lessThan(abajo));
  });

  testWidgets('catálogo vacío indica que está vacío', (tester) async {
    await _abrirCatalogo(tester, _servicioQueResponde([]));

    expect(find.byKey(const Key('catalogo_vacio')), findsOneWidget);
    expect(find.text('Tu catálogo está vacío'), findsOneWidget);
  });

  testWidgets('el botón para agregar planta está visible', (tester) async {
    await _abrirCatalogo(tester, _servicioQueResponde([_planta(1, 'Helecho')]));

    expect(find.byKey(const Key('boton_agregar_planta')), findsOneWidget);
    expect(find.text('Agregar planta'), findsOneWidget);
  });

  testWidgets('sin conexión muestra un mensaje contextual y permite reintentar',
      (tester) async {
    var intentos = 0;
    final servicio = PlantaServicio(
      cliente: MockClient((_) async {
        intentos++;
        if (intentos == 1) throw http.ClientException('sin red');
        return _json([_planta(1, 'Helecho')], 200);
      }),
    );

    await _abrirCatalogo(tester, servicio);

    expect(find.byKey(const Key('catalogo_error')), findsOneWidget);
    expect(find.text('No se pudo cargar tu catálogo'), findsOneWidget);
    expect(find.textContaining('No hay conexión con el servidor'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Helecho'), findsOneWidget);
  });

  testWidgets('error del servidor muestra un mensaje contextual', (tester) async {
    await _abrirCatalogo(
        tester, _servicioQueResponde({'mensaje': 'Error interno'}, 500));

    expect(find.textContaining('El servidor tuvo un problema'), findsOneWidget);
  });

  group('mensajeErrorCatalogo', () {
    test('usuario inexistente', () {
      expect(mensajeErrorCatalogo(const ApiExcepcion(404, 'El usuario indicado no existe')),
          contains('No encontramos tu cuenta'));
    });

    test('otros errores usan el mensaje del backend', () {
      expect(mensajeErrorCatalogo(const ApiExcepcion(400, 'Solicitud inválida')),
          'Solicitud inválida');
    });
  });
}
