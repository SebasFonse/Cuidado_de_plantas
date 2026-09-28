import 'dart:convert';

import 'package:http/http.dart' as http;

/// Error devuelto por la API (formato ResponseApi del backend) o de conexión.
class ApiExcepcion implements Exception {
  const ApiExcepcion(this.status, this.mensaje, [this.detalles = const []]);

  final int status;
  final String mensaje;
  final List<String> detalles;

  factory ApiExcepcion.sinConexion() => const ApiExcepcion(
        0,
        'No se pudo conectar con el servidor. Verifica que el backend esté encendido.',
      );

  factory ApiExcepcion.desdeRespuesta(http.Response respuesta) {
    try {
      final cuerpo = jsonDecode(utf8.decode(respuesta.bodyBytes));
      if (cuerpo is Map<String, dynamic>) {
        final mensaje = (cuerpo['mensaje'] ?? 'Error inesperado').toString();
        final detalles = <String>[];
        final error = cuerpo['error'];
        if (error is Map<String, dynamic> && error['detalles'] is List) {
          for (final detalle in error['detalles'] as List) {
            detalles.add(_sinNombreDeCampo(detalle.toString()));
          }
        }
        return ApiExcepcion(respuesta.statusCode, mensaje, detalles);
      }
    } catch (_) {
      // El cuerpo no era JSON; se usa el mensaje genérico.
    }
    return ApiExcepcion(
      respuesta.statusCode,
      'Error inesperado del servidor (${respuesta.statusCode})',
    );
  }

  /// "nombre: El nombre es requerido" -> "El nombre es requerido"
  static String _sinNombreDeCampo(String detalle) {
    final indice = detalle.indexOf(': ');
    return indice >= 0 ? detalle.substring(indice + 2) : detalle;
  }

  /// Mensaje listo para mostrar en pantalla.
  String get mensajeCompleto {
    final extra = detalles.where((d) => d != mensaje).toList();
    if (extra.isEmpty) return mensaje;
    return '$mensaje\n${extra.map((d) => '• $d').join('\n')}';
  }

  @override
  String toString() => mensajeCompleto;
}
