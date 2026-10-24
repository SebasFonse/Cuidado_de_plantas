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
  });

  final int id;
  final String tipo;
  final int frecuenciaDias;
  final DateTime fechaUltimoCuidado;
  final String? notas;
  final int? plantaId;

  String get tipoTexto => tiposCuidado[tipo] ?? tipo;

  factory Cuidado.desdeJson(Map<String, dynamic> json) {
    return Cuidado(
      id: (json['id'] as num).toInt(),
      tipo: json['tipo'] as String,
      frecuenciaDias: (json['frecuenciaDias'] as num).toInt(),
      fechaUltimoCuidado: DateTime.parse(json['fechaUltimoCuidado'] as String),
      notas: json['notas'] as String?,
      plantaId: (json['plantaId'] as num?)?.toInt(),
    );
  }
}
