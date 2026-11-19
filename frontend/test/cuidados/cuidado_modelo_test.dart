import 'package:flutter_test/flutter_test.dart';
import 'package:plantacert_app/core/validadores.dart';
import 'package:plantacert_app/cuidados/cuidado.dart';

Cuidado _cuidado({
  required DateTime ultimo,
  int frecuencia = 3,
  DateTime? inicio,
  DateTime? fin,
}) =>
    Cuidado(
      id: 1,
      tipo: 'RIEGO',
      frecuenciaDias: frecuencia,
      fechaUltimoCuidado: ultimo,
      fechaInicio: inicio,
      fechaFin: fin,
    );

void main() {
  group('Periodo del cuidado', () {
    test('el próximo cuidado es el último más la frecuencia', () {
      final c = _cuidado(ultimo: DateTime(2026, 11, 1));
      expect(c.proximaFecha, DateTime(2026, 11, 4));
      expect(c.diasRestantes(hoy: DateTime(2026, 11, 2)), 2);
      expect(c.diasRestantes(hoy: DateTime(2026, 11, 6)), -2);
    });

    test('si el primer día es futuro, el próximo cuidado es ese día', () {
      final c = _cuidado(
          ultimo: DateTime(2026, 11, 1), inicio: DateTime(2026, 12, 1));
      expect(c.proximaFecha, DateTime(2026, 12, 1));
    });

    test('queda finalizado cuando el próximo cuidado pasa el último día', () {
      final c = _cuidado(
        ultimo: DateTime(2026, 11, 29),
        inicio: DateTime(2026, 11, 1),
        fin: DateTime(2026, 11, 30),
      );
      expect(c.finalizado, isTrue);
      expect(_cuidado(ultimo: DateTime(2026, 11, 1)).finalizado, isFalse);
    });

    test('lee fechaInicio y fechaFin del JSON (y acepta que no vengan)', () {
      final conPeriodo = Cuidado.desdeJson({
        'id': 1,
        'tipo': 'PODA',
        'frecuenciaDias': 7,
        'fechaUltimoCuidado': '2026-11-01',
        'fechaInicio': '2026-11-01',
        'fechaFin': '2026-12-01',
      });
      expect(conPeriodo.fechaInicio, DateTime(2026, 11, 1));
      expect(conPeriodo.fechaFin, DateTime(2026, 12, 1));

      final antiguo = Cuidado.desdeJson({
        'id': 2,
        'tipo': 'PODA',
        'frecuenciaDias': 7,
        'fechaUltimoCuidado': '2026-11-01',
      });
      expect(antiguo.fechaInicio, isNull);
      expect(antiguo.fechaFin, isNull);
    });

    test('fechaLegible', () {
      expect(fechaLegible(DateTime(2026, 11, 9)), '9 nov 2026');
    });
  });

  group('Validadores del periodo', () {
    test('el primer día es obligatorio', () {
      expect(Validadores.fechaInicio(''), 'El primer día es requerido');
      expect(Validadores.fechaInicio('2026-13-01'), contains('AAAA-MM-DD'));
      expect(Validadores.fechaInicio('2030-01-01'), isNull);
    });

    test('el último día es opcional y no puede ser antes del primero', () {
      expect(Validadores.fechaFin('', '2026-11-10'), isNull);
      expect(Validadores.fechaFin('2026-11-10', '2026-11-10'), isNull);
      expect(Validadores.fechaFin('2026-11-01', '2026-11-10'),
          'El último día no puede ser antes del primer día');
    });
  });
}
