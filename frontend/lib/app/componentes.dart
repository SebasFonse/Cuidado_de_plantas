import 'package:flutter/material.dart';

import 'tema.dart';

/// Tarjeta blanca con borde suave y esquinas redondeadas (estilo Plantacert).
class TarjetaSuave extends StatelessWidget {
  const TarjetaSuave({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorSuperficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: colorBorde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Etiqueta redondeada de color (ubicación, estado de un cuidado, etc.).
class Insignia extends StatelessWidget {
  const Insignia({
    super.key,
    required this.texto,
    this.icono,
    this.fondo = const Color(0xFFD1FAE5),
    this.colorTexto = const Color(0xFF065F46),
  });

  final String texto;
  final IconData? icono;
  final Color fondo;
  final Color colorTexto;

  /// Colores para estados de urgencia.
  static const Color fondoAmarillo = Color(0xFFFEF9C3);
  static const Color textoAmarillo = Color(0xFF854D0E);
  static const Color fondoRojo = Color(0xFFFEE2E2);
  static const Color textoRojo = Color(0xFF991B1B);
  static const Color fondoGris = Color(0xFFEEF2EF);
  static const Color textoGris = colorTextoSuave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 13, color: colorTexto),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorTexto,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Título de sección dentro de un formulario o pantalla.
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {super.key, this.icono});

  final String texto;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icono != null) ...[
          Icon(icono, size: 18, color: verdeMedio),
          const SizedBox(width: 6),
        ],
        Text(
          texto,
          style: const TextStyle(
            color: colorTextoSuave,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

/// Caja de mensaje de error usada en los formularios.
class CajaError extends StatelessWidget {
  const CajaError({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Insignia.fondoRojo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Insignia.textoRojo, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(mensaje, style: const TextStyle(color: Insignia.textoRojo)),
          ),
        ],
      ),
    );
  }
}
