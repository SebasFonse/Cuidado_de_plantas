import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../core/api_excepcion.dart';
import 'planta.dart';

/// RQ4-HU01: consume POST y GET /api/plantas/usuario/{usuarioId}
class PlantaServicio {
  PlantaServicio({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  Uri _url(int usuarioId) => Uri.parse('$apiUrl/plantas/usuario/$usuarioId');

  Future<Planta> registrar({
    required int usuarioId,
    required String nombre,
    required String especie,
    required String ubicacion,
    String? descripcion,
    String? imagenUrl,
  }) async {
    final http.Response respuesta;
    try {
      respuesta = await _cliente.post(
        _url(usuarioId),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre.trim(),
          'especie': especie.trim(),
          'ubicacion': ubicacion.trim(),
          'descripcion': descripcion?.trim() ?? '',
          'imagenUrl': imagenUrl?.trim() ?? '',
        }),
      );
    } catch (_) {
      throw ApiExcepcion.sinConexion();
    }

    if (respuesta.statusCode == 201) {
      final json = jsonDecode(utf8.decode(respuesta.bodyBytes));
      return Planta.desdeJson(json as Map<String, dynamic>);
    }
    throw ApiExcepcion.desdeRespuesta(respuesta);
  }

  Future<List<Planta>> listar(int usuarioId) async {
    final http.Response respuesta;
    try {
      respuesta = await _cliente.get(_url(usuarioId));
    } catch (_) {
      throw ApiExcepcion.sinConexion();
    }

    if (respuesta.statusCode == 200) {
      final lista = jsonDecode(utf8.decode(respuesta.bodyBytes)) as List;
      return lista
          .map((item) => Planta.desdeJson(item as Map<String, dynamic>))
          .toList();
    }
    throw ApiExcepcion.desdeRespuesta(respuesta);
  }
}
