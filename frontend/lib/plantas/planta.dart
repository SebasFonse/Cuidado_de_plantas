/// Planta del catálogo del usuario (PlantaRespuesta del backend).
class Planta {
  const Planta({
    required this.id,
    required this.nombre,
    required this.especie,
    required this.ubicacion,
    this.descripcion,
    this.imagenUrl,
    this.fechaRegistro,
    this.usuarioId,
  });

  final int id;
  final String nombre;
  final String especie;
  final String ubicacion;
  final String? descripcion;
  final String? imagenUrl;
  final DateTime? fechaRegistro;
  final int? usuarioId;

  factory Planta.desdeJson(Map<String, dynamic> json) {
    return Planta(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String,
      especie: json['especie'] as String,
      ubicacion: json['ubicacion'] as String,
      descripcion: json['descripcion'] as String?,
      imagenUrl: json['imagenUrl'] as String?,
      fechaRegistro: json['fechaRegistro'] == null
          ? null
          : DateTime.tryParse(json['fechaRegistro'] as String),
      usuarioId: (json['usuarioId'] as num?)?.toInt(),
    );
  }
}
