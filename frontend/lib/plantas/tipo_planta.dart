import 'package:flutter/material.dart';

/// Tipo visual de una planta: el emoji y los colores con que se muestra
/// cuando no tiene foto. Se deduce del nombre y la especie.
class TipoPlanta {
  const TipoPlanta(this.etiqueta, this.emoji, this.colorClaro, this.colorFuerte);

  final String etiqueta;
  final String emoji;
  final Color colorClaro;
  final Color colorFuerte;

  LinearGradient get degradado => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colorClaro, colorFuerte],
      );
}

const tipoGenerico =
    TipoPlanta('Planta', '🪴', Color(0xFFE6F4EA), Color(0xFFBFE3CB));

/// Reglas en orden: gana la primera cuyo prefijo coincida con alguna
/// palabra del nombre o de la especie (sin tildes ni mayúsculas).
/// Cubre las especies de la base de datos (EspecieServicio) y nombres comunes.
const List<(TipoPlanta, List<String>)> _reglas = [
  (
    TipoPlanta('Cactus o suculenta', '🌵', Color(0xFFF5EFD6), Color(0xFFCFE3B0)),
    ['cactus', 'cacto', 'capt', 'nopal', 'opuntia', 'suculent', 'echeveria',
      'aloe', 'sabila', 'crassula', 'jade', 'haworthia', 'agave'],
  ),
  (
    TipoPlanta('Orquídea', '🌸', Color(0xFFFCE7F3), Color(0xFFE9D5FF)),
    ['orquid', 'orchid', 'phalaenopsis'],
  ),
  (
    TipoPlanta('Rosa', '🌹', Color(0xFFFFE4E6), Color(0xFFFECDD3)),
    ['rosa', 'rosal'],
  ),
  (
    TipoPlanta('Girasol', '🌻', Color(0xFFFEF9C3), Color(0xFFFDE68A)),
    ['girasol', 'helianthus'],
  ),
  (
    TipoPlanta('Tulipán', '🌷', Color(0xFFFFE4E6), Color(0xFFFBCFE8)),
    ['tulip'],
  ),
  (
    TipoPlanta('Lavanda', '🪻', Color(0xFFF3E8FF), Color(0xFFDDD6FE)),
    ['lavand'],
  ),
  (
    TipoPlanta('Planta con flor', '🌼', Color(0xFFFFF7ED), Color(0xFFFED7AA)),
    ['flor', 'margarita', 'violeta', 'saintpaulia', 'begonia', 'geranio',
      'pelargonium', 'hortensia', 'hydrangea', 'anturio', 'anthurium',
      'bromelia', 'guzmania', 'petunia', 'clavel', 'lirio', 'hibisc',
      'jazmin', 'azalea', 'camelia', 'dalia', 'crisantemo'],
  ),
  (
    TipoPlanta('Aromática', '🌿', Color(0xFFECFDF5), Color(0xFFA7F3D0)),
    ['albahaca', 'ocimum', 'menta', 'mentha', 'hierbabuena', 'romero',
      'rosmarinus', 'cilantro', 'coriandrum', 'tomillo', 'oregano',
      'perejil', 'laurel', 'aromatic'],
  ),
  (
    TipoPlanta('Helecho', '🍃', Color(0xFFE8F5E9), Color(0xFFB9E4C9)),
    ['helecho', 'nephrolepis'],
  ),
  (
    TipoPlanta('Palma', '🌴', Color(0xFFECFCCB), Color(0xFFBEF264)),
    ['palma', 'palmera', 'dypsis', 'areca', 'coco'],
  ),
  (
    TipoPlanta('Conífera', '🌲', Color(0xFFE0F2F1), Color(0xFFA7D7C5)),
    ['pino', 'junip', 'cipres', 'abeto'],
  ),
  (
    TipoPlanta('Árbol', '🌳', Color(0xFFE8F5E9), Color(0xFFA5D6A7)),
    ['arbol', 'ficus', 'roble', 'bonsai', 'guayac', 'eucalipto'],
  ),
  (
    TipoPlanta('Cítrico', '🍋', Color(0xFFFEFCE8), Color(0xFFFEF08A)),
    ['limon', 'citrus', 'naranj', 'mandarin'],
  ),
  (
    TipoPlanta('Tomate', '🍅', Color(0xFFFEE2E2), Color(0xFFFCA5A5)),
    ['tomate', 'lycopersicum'],
  ),
  (
    TipoPlanta('Fresa', '🍓', Color(0xFFFFE4E6), Color(0xFFFDA4AF)),
    ['fresa', 'fragaria'],
  ),
  (
    TipoPlanta('Pimentón o ají', '🌶️', Color(0xFFFFEDD5), Color(0xFFFDBA74)),
    ['piment', 'capsicum', 'aji', 'chile'],
  ),
  (
    TipoPlanta('Café', '☕', Color(0xFFF5EBE0), Color(0xFFE3CBB0)),
    ['cafe', 'coffea'],
  ),
  (
    TipoPlanta('Trébol', '🍀', Color(0xFFECFDF5), Color(0xFF86EFAC)),
    ['trebol'],
  ),
  (
    TipoPlanta('Bambú', '🎋', Color(0xFFF0FDF4), Color(0xFFBBF7D0)),
    ['bambu'],
  ),
  (
    TipoPlanta('Germinado', '🌱', Color(0xFFF0FDF4), Color(0xFFBBF7D0)),
    ['semilla', 'germin', 'brote', 'plantula'],
  ),
];

String _sinTildes(String texto) {
  const con = 'áéíóúüñ';
  const sin = 'aeiouun';
  final b = StringBuffer();
  for (final c in texto.toLowerCase().split('')) {
    final i = con.indexOf(c);
    b.write(i >= 0 ? sin[i] : c);
  }
  return b.toString();
}

/// Deduce el tipo de planta a partir de su nombre y su especie.
/// Primero mira la especie (es más precisa) y luego el nombre.
TipoPlanta tipoDePlanta({String? nombre, String? especie}) {
  for (final texto in [especie, nombre]) {
    if (texto == null || texto.trim().isEmpty) continue;
    final palabras = _sinTildes(texto)
        .split(RegExp(r'[^a-z]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    for (final (tipo, prefijos) in _reglas) {
      if (palabras.any((p) => prefijos.any(p.startsWith))) return tipo;
    }
  }
  return tipoGenerico;
}
