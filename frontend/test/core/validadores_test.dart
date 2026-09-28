import 'package:flutter_test/flutter_test.dart';
import 'package:plantacert_app/core/validadores.dart';

void main() {
  group('Validadores', () {
    test('requerido rechaza texto vacío o con solo espacios', () {
      expect(Validadores.requerido('', 'x'), 'x');
      expect(Validadores.requerido('   ', 'x'), 'x');
      expect(Validadores.requerido('Monstera', 'x'), isNull);
    });

    test('correo valida el formato', () {
      expect(Validadores.correo(''), isNotNull);
      expect(Validadores.correo('correo-sin-arroba'), isNotNull);
      expect(Validadores.correo('valeria@correo.com'), isNull);
    });

    test('contraseña exige mínimo 8 caracteres', () {
      expect(Validadores.contrasena('123'), isNotNull);
      expect(Validadores.contrasena('clave1234'), isNull);
    });

    test('url opcional acepta vacío o http(s)', () {
      expect(Validadores.urlOpcional(''), isNull);
      expect(Validadores.urlOpcional('https://ejemplo.com/foto.jpg'), isNull);
      expect(Validadores.urlOpcional('foto-helecho'), isNotNull);
      expect(Validadores.urlOpcional('ftp://ejemplo.com/a.jpg'), isNotNull);
    });
  });
}
