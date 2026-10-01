import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../core/api_excepcion.dart';

/// Respuesta del backend al registrarse (nunca incluye la contraseña).
class UsuarioRegistrado {
  const UsuarioRegistrado({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.mensaje,
  });

  final int id;
  final String nombre;
  final String correo;
  final String mensaje;

  factory UsuarioRegistrado.desdeJson(Map<String, dynamic> json) {
    return UsuarioRegistrado(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      mensaje: (json['mensaje'] ?? 'Registro exitoso') as String,
    );
  }
}

/// RQ1-HU01: consume POST /api/usuarios/registro
class RegistroServicio {
  RegistroServicio({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  Future<UsuarioRegistrado> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    final http.Response respuesta;
    try {
      respuesta = await _cliente.post(
        Uri.parse('$apiUrl/usuarios/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre.trim(),
          'correo': correo.trim(),
          'contrasena': contrasena,
        }),
      );
    } catch (_) {
      throw ApiExcepcion.sinConexion();
    }

    if (respuesta.statusCode == 201) {
      final json = jsonDecode(utf8.decode(respuesta.bodyBytes));
      return UsuarioRegistrado.desdeJson(json as Map<String, dynamic>);
    }
    throw ApiExcepcion.desdeRespuesta(respuesta);
  }
}
