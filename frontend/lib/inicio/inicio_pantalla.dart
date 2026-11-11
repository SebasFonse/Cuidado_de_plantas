import 'package:flutter/material.dart';

import '../app/componentes.dart';
import '../app/tema.dart';
import '../auth/login_pantalla.dart';
import '../core/sesion.dart';
import '../plantas/catalogo_pantalla.dart';

/// Pantalla principal después de ingresar.
/// Cada historia de usuario agrega aquí su opción de menú.
class InicioPantalla extends StatelessWidget {
  const InicioPantalla({super.key});

  void _cerrarSesion(BuildContext context) {
    Sesion.cerrar();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPantalla()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantacert AI'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: degradadoOscuro,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bienvenido 🌿',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Usuario #${Sesion.usuarioId ?? '-'} · '
                            'Organiza y cuida tu colección de plantas',
                            style: const TextStyle(color: Color(0xB3FFFFFF)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.eco, size: 56, color: Color(0x5974C69D)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const TituloSeccion('MENÚ', icono: Icons.grid_view_rounded),
              const SizedBox(height: 12),
              // RQ4-HU01: catálogo y registro de plantas
              _OpcionMenu(
                key: const Key('menu_mis_plantas'),
                icono: Icons.local_florist,
                titulo: 'Mis plantas',
                descripcion: 'Consulta tu catálogo, busca y agrega plantas nuevas',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CatalogoPantalla()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpcionMenu extends StatelessWidget {
  const _OpcionMenu({
    super.key,
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TarjetaSuave(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: degradadoHoja,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icono, color: verdePlantacert, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: verdeOscuro,
                  ),
                ),
                const SizedBox(height: 2),
                Text(descripcion, style: const TextStyle(color: colorTextoSuave)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: verdeMedio),
        ],
      ),
    );
  }
}
