import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../core/texto.dart';
import 'especie.dart';

/// Consume GET /api/especies (base de datos de especies).
class EspecieServicio {
  EspecieServicio({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  /// Devuelve la lista de especies. Si la API no responde devuelve una lista
  /// vacía: la especie se puede seguir escribiendo a mano.
  Future<List<Especie>> listar() async {
    try {
      final respuesta = await _cliente.get(Uri.parse('$apiUrl/especies'));
      if (respuesta.statusCode != 200) return [];
      final lista = jsonDecode(utf8.decode(respuesta.bodyBytes)) as List;
      return lista
          .map((item) => Especie.desdeJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

/// Especies cuyo nombre científico o común contiene el texto (sin tildes ni mayúsculas).
List<Especie> filtrarEspecies(List<Especie> especies, String texto) {
  final buscado = normalizarTexto(texto);
  if (buscado.isEmpty) return especies;
  return especies
      .where((e) =>
          normalizarTexto(e.nombreCientifico).contains(buscado) ||
          normalizarTexto(e.nombreComun).contains(buscado))
      .toList();
}
