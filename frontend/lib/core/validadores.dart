/// Validaciones de formularios. Coinciden con las del backend Quarkus.
class Validadores {
  Validadores._();

  static String? requerido(String? valor, String mensaje) {
    if (valor == null || valor.trim().isEmpty) return mensaje;
    return null;
  }

  static String? maximo(String? valor, int maximo, String mensaje) {
    if (valor != null && valor.trim().length > maximo) return mensaje;
    return null;
  }

  static String? correo(String? valor) {
    final vacio = requerido(valor, 'El correo electrónico es requerido');
    if (vacio != null) return vacio;
    final valido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(valor!.trim());
    return valido ? null : 'El correo electrónico no tiene un formato válido';
  }

  static String? contrasena(String? valor) {
    if (valor == null || valor.isEmpty) return 'La contraseña es requerida';
    if (valor.length < 8) return 'La contraseña debe tener mínimo 8 caracteres';
    return null;
  }

  /// El enlace es opcional, pero si se escribe debe empezar por http:// o https://
  static String? urlOpcional(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    final uri = Uri.tryParse(valor.trim());
    final valido = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return valido
        ? null
        : 'La imagen debe ser un enlace válido que empiece por http:// o https://';
  }
}
