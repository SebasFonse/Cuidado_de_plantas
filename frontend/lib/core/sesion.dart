/// Datos del usuario en la sesión actual.
/// Temporal: cuando se implemente el inicio de sesión con JWT (RQ-02)
/// aquí se guardará también el token.
class Sesion {
  Sesion._();

  static int? usuarioId;

  static bool get activa => usuarioId != null;

  static void cerrar() {
    usuarioId = null;
  }
}
