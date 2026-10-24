import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../core/api_excepcion.dart';
import 'cuidado.dart';

/// HU08: consume POST y GET /api/cuidados/usuario/{usuarioId}/planta/{plantaId}
class CuidadoServicio {
  CuidadoServicio({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  Uri _url(int usuarioId, int plantaId) =>
      Uri.parse('$apiUrl/cuidados/usuario/$usuarioId/planta/$plantaId');

  Future<Cuidado> registrar({
    required int usuarioId,
    required int plantaId,
    required String tipo,
    required int frecuenciaDias,
    required DateTime fechaUltimoCuidado,
    String? notas,
  }) async {
    final http.Response respuesta;
    try {
      respuesta = await _cliente.post(
        _url(usuarioId, plantaId),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tipo': tipo,
          'frecuenciaDias': frecuenciaDias,
          'fechaUltimoCuidado': fechaATexto(fechaUltimoCuidado),
          'notas': notas?.trim() ?? '',
        }),
      );
    } catch (_) {
      throw ApiExcepcion.sinConexion();
    }

    if (respuesta.statusCode == 201) {
      final json = jsonDecode(utf8.decode(respuesta.bodyBytes));
      return Cuidado.desdeJson(json as Map<String, dynamic>);
    }
    throw ApiExcepcion.desdeRespuesta(respuesta);
  }

  Future<List<Cuidado>> listar(int usuarioId, int plantaId) async {
    final http.Response respuesta;
    try {
      respuesta = await _cliente.get(_url(usuarioId, plantaId));
    } catch (_) {
      throw ApiExcepcion.sinConexion();
    }

    if (respuesta.statusCode == 200) {
      final lista = jsonDecode(utf8.decode(respuesta.bodyBytes)) as List;
      return lista
          .map((item) => Cuidado.desdeJson(item as Map<String, dynamic>))
          .toList();
    }
    throw ApiExcepcion.desdeRespuesta(respuesta);
  }
}
