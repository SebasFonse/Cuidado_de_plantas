/// HU08: tipos de cuidado (código del backend -> texto para mostrar).
const Map<String, String> tiposCuidado = {
  'RIEGO': 'Riego',
  'FERTILIZACION': 'Fertilización',
  'PODA': 'Poda',
  'EXPOSICION_LUZ': 'Exposición a la luz',
  'TRASPLANTE': 'Trasplante',
  'OTRO': 'Otro',
};

/// Fecha en formato AAAA-MM-DD (el que espera el backend).
String fechaATexto(DateTime fecha) =>
    '${fecha.year.toString().padLeft(4, '0')}-'
    '${fecha.month.toString().padLeft(2, '0')}-'
    '${fecha.day.toString().padLeft(2, '0')}';

/// Cuidado periódico de una planta (CuidadoRespuesta del backend).
class Cuidado {
  const Cuidado({
    required this.id,
    required this.tipo,
    required this.frecuenciaDias,
    required this.fechaUltimoCuidado,
    this.notas,
    this.plantaId,
    this.fechaInicio,
    this.fechaFin,
  });

  final int id;
  final String tipo;
  final int frecuenciaDias;
  final DateTime fechaUltimoCuidado;
  final String? notas;
  final int? plantaId;

  /// Primer día del periodo del cuidado (por ejemplo, desde cuándo se riega).
  final DateTime? fechaInicio;

  /// Último día del periodo. Si es null, el cuidado se repite sin fecha de fin.
  final DateTime? fechaFin;

  String get tipoTexto => tiposCuidado[tipo] ?? tipo;

  /// Fecha del próximo cuidado: último cuidado + frecuencia,
  /// pero nunca antes del primer día del periodo.
  DateTime get proximaFecha {
    final ultimo = _soloFecha(fechaUltimoCuidado);
    final siguiente = ultimo.add(Duration(days: frecuenciaDias));
    final inicio = fechaInicio == null ? null : _soloFecha(fechaInicio!);
    if (inicio != null && siguiente.isBefore(inicio)) return inicio;
    return siguiente;
  }

  /// Días que faltan para el próximo cuidado (negativo si ya pasó la fecha).
  int diasRestantes({DateTime? hoy}) {
    final base = _soloFecha(hoy ?? DateTime.now());
    return proximaFecha.difference(base).inDays;
  }

  /// El periodo terminó: el próximo cuidado caería después del último día.
  bool get finalizado =>
      fechaFin != null && proximaFecha.isAfter(_soloFecha(fechaFin!));

  static DateTime _soloFecha(DateTime f) => DateTime(f.year, f.month, f.day);

  factory Cuidado.desdeJson(Map<String, dynamic> json) {
    return Cuidado(
      id: (json['id'] as num).toInt(),
      tipo: json['tipo'] as String,
      frecuenciaDias: (json['frecuenciaDias'] as num).toInt(),
      fechaUltimoCuidado: DateTime.parse(json['fechaUltimoCuidado'] as String),
      notas: json['notas'] as String?,
      plantaId: (json['plantaId'] as num?)?.toInt(),
      fechaInicio: _leerFecha(json['fechaInicio']),
      fechaFin: _leerFecha(json['fechaFin']),
    );
  }

  static DateTime? _leerFecha(Object? valor) {
    if (valor is! String || valor.isEmpty) return null;
    return DateTime.tryParse(valor);
  }
}

const _meses = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

/// Fecha corta y legible, por ejemplo "9 nov 2026".
String fechaLegible(DateTime fecha) =>
    '${fecha.day} ${_meses[fecha.month - 1]} ${fecha.year}';
