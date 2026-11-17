import 'package:flutter/material.dart';

import '../app/tema.dart';

/// Etiqueta del Hero que conecta la foto de una planta entre pantallas.
String etiquetaFotoPlanta(int plantaId) => 'foto_planta_$plantaId';

/// Foto de una planta, igual en todos los módulos (catálogo, detalle,
/// cuidados, inicio). Si no tiene enlace o no carga, muestra la imagen
/// por defecto. Con [plantaId] la foto "viaja" animada entre pantallas.
class FotoPlanta extends StatelessWidget {
  const FotoPlanta({
    super.key,
    required this.imagenUrl,
    this.plantaId,
    this.radio = 12,
    this.tamanoIcono = 48,
    this.ancho,
    this.alto,
  });

  final String? imagenUrl;
  final int? plantaId;
  final double radio;
  final double tamanoIcono;
  final double? ancho;
  final double? alto;

  @override
  Widget build(BuildContext context) {
    final url = imagenUrl?.trim();
    final porDefecto = ImagenPorDefecto(tamanoIcono: tamanoIcono);
    Widget foto = ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: SizedBox(
        width: ancho,
        height: alto,
        child: (url == null || url.isEmpty)
            ? porDefecto
            : Image.network(
                url,
                fit: BoxFit.cover,
                // Si el enlace no carga se muestra la imagen por defecto
                errorBuilder: (_, __, ___) => porDefecto,
                loadingBuilder: (context, child, progreso) => progreso == null
                    ? child
                    : Container(
                        decoration: const BoxDecoration(gradient: degradadoHoja),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
              ),
      ),
    );
    final id = plantaId;
    if (id != null) {
      foto = Hero(tag: etiquetaFotoPlanta(id), child: foto);
    }
    return foto;
  }
}

/// Imagen que se muestra cuando la planta no tiene foto o el enlace no carga.
class ImagenPorDefecto extends StatelessWidget {
  const ImagenPorDefecto({super.key, this.tamanoIcono = 48});

  final double tamanoIcono;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('imagen_por_defecto'),
      decoration: const BoxDecoration(gradient: degradadoHoja),
      alignment: Alignment.center,
      child: Icon(Icons.local_florist, color: verdePlantacert, size: tamanoIcono),
    );
  }
}
