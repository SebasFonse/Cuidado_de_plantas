import 'package:flutter/material.dart';

import 'tipo_planta.dart';

/// Etiqueta del Hero que conecta la foto de una planta entre pantallas.
String etiquetaFotoPlanta(int plantaId) => 'foto_planta_$plantaId';

/// Foto de una planta, igual en todos los módulos (catálogo, detalle,
/// cuidados, inicio). Si no tiene enlace o no carga, muestra un ícono según
/// el tipo de planta (cactus, orquídea, árbol...). Con [plantaId] la foto
/// "viaja" animada entre pantallas.
class FotoPlanta extends StatelessWidget {
  const FotoPlanta({
    super.key,
    required this.imagenUrl,
    this.plantaId,
    this.nombre,
    this.especie,
    this.radio = 12,
    this.tamanoIcono = 48,
    this.ancho,
    this.alto,
  });

  final String? imagenUrl;
  final int? plantaId;

  /// Nombre y especie: sirven para elegir el ícono cuando no hay foto.
  final String? nombre;
  final String? especie;
  final double radio;
  final double tamanoIcono;
  final double? ancho;
  final double? alto;

  @override
  Widget build(BuildContext context) {
    final url = imagenUrl?.trim();
    final porDefecto = ImagenPorDefecto(
      nombre: nombre,
      especie: especie,
      tamanoIcono: tamanoIcono,
    );
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
                // En la web muchas páginas no permiten leer sus imágenes
                // (CORS); con esto se muestran igual con una etiqueta <img>.
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                // Si el enlace no carga se muestra la imagen por defecto
                errorBuilder: (_, __, ___) => porDefecto,
                loadingBuilder: (context, child, progreso) => progreso == null
                    ? child
                    : Container(
                        decoration: BoxDecoration(
                          gradient: tipoDePlanta(nombre: nombre, especie: especie)
                              .degradado,
                        ),
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

/// Imagen que se muestra cuando la planta no tiene foto o el enlace no carga:
/// un ícono y colores según el tipo de planta.
class ImagenPorDefecto extends StatelessWidget {
  const ImagenPorDefecto({
    super.key,
    this.nombre,
    this.especie,
    this.tamanoIcono = 48,
  });

  final String? nombre;
  final String? especie;
  final double tamanoIcono;

  @override
  Widget build(BuildContext context) {
    final tipo = tipoDePlanta(nombre: nombre, especie: especie);
    return Container(
      key: const Key('imagen_por_defecto'),
      decoration: BoxDecoration(gradient: tipo.degradado),
      alignment: Alignment.center,
      child: Semantics(
        label: tipo.etiqueta,
        child: Text(
          tipo.emoji,
          key: const Key('icono_tipo_planta'),
          style: TextStyle(fontSize: tamanoIcono, height: 1),
        ),
      ),
    );
  }
}
