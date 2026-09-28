import 'package:flutter/material.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Bienvenido (usuario #${Sesion.usuarioId ?? '-'})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // RQ4-HU01: catálogo y registro de plantas
          Card(
            child: ListTile(
              key: const Key('menu_mis_plantas'),
              leading: const Icon(Icons.local_florist),
              title: const Text('Mis plantas'),
              subtitle: const Text('Consulta tu catálogo y agrega plantas nuevas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CatalogoPantalla()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
