/// Especie de la base de datos de especies (GET /api/especies).
class Especie {
  const Especie({
    required this.id,
    required this.nombreCientifico,
    required this.nombreComun,
  });

  final int id;
  final String nombreCientifico;
  final String nombreComun;

  factory Especie.desdeJson(Map<String, dynamic> json) => Especie(
        id: (json['id'] as num).toInt(),
        nombreCientifico: json['nombreCientifico'] as String,
        nombreComun: json['nombreComun'] as String,
      );
}
