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

  /// HU08: frecuencia en días, número entero entre 1 y 365.
  static String? frecuencia(String? valor) {
    final vacio = requerido(valor, 'La frecuencia es requerida');
    if (vacio != null) return vacio;
    final numero = int.tryParse(valor!.trim());
    if (numero == null) return 'La frecuencia debe ser un número entero de días';
    if (numero < 1) return 'La frecuencia debe ser de al menos 1 día';
    if (numero > 365) return 'La frecuencia no puede superar 365 días';
    return null;
  }

  /// HU08: convierte "AAAA-MM-DD" en fecha, o null si no es una fecha real.
  static DateTime? leerFecha(String? valor) {
    if (valor == null) return null;
    final texto = valor.trim();
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(texto)) return null;
    final fecha = DateTime.tryParse(texto);
    // DateTime acepta 2026-02-30 y lo corre a marzo; eso no es una fecha válida.
    if (fecha == null ||
        fecha.month != int.parse(texto.substring(5, 7)) ||
        fecha.day != int.parse(texto.substring(8, 10))) {
      return null;
    }
    return fecha;
  }

  /// HU08: la fecha del último cuidado es obligatoria y no puede ser futura.
  static String? fechaNoFutura(String? valor, {DateTime? hoy}) {
    final vacio = requerido(valor, 'La fecha del último cuidado es requerida');
    if (vacio != null) return vacio;
    final fecha = leerFecha(valor);
    if (fecha == null) return 'Escribe la fecha con el formato AAAA-MM-DD';
    final ahora = hoy ?? DateTime.now();
    final soloHoy = DateTime(ahora.year, ahora.month, ahora.day);
    if (fecha.isAfter(soloHoy)) {
      return 'La fecha del último cuidado no puede ser una fecha futura';
    }
    return null;
  }
}
