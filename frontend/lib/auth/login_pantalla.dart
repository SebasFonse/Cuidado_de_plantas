import 'package:flutter/material.dart';

import '../app/tema.dart';
import '../core/sesion.dart';
import '../inicio/inicio_pantalla.dart';

/// Pantalla de inicio de sesión.
/// El inicio de sesión real (correo + contraseña con JWT) corresponde a RQ-02.
/// Mientras tanto se deja un acceso temporal por ID de usuario para poder
/// probar las historias del sprint.
class LoginPantalla extends StatefulWidget {
  const LoginPantalla({super.key, this.mensajeInicial});

  /// Mensaje opcional a mostrar al llegar (por ejemplo, después de registrarse).
  final String? mensajeInicial;

  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  final _correoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  final _usuarioIdCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final mensaje = widget.mensajeInicial;
    if (mensaje != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje), backgroundColor: verdePlantacert),
        );
      });
    }
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    _usuarioIdCtrl.dispose();
    super.dispose();
  }

  void _iniciarSesion() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('El inicio de sesión se implementará en RQ-02. '
            'Por ahora usa el acceso temporal con tu ID de usuario.'),
      ),
    );
  }

  void _accesoTemporal() {
    final id = int.tryParse(_usuarioIdCtrl.text.trim());
    if (id == null || id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un ID de usuario válido')),
      );
      return;
    }
    Sesion.usuarioId = id;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const InicioPantalla()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.eco, size: 72, color: verdePlantacert),
                const SizedBox(height: 8),
                Text(
                  'Plantacert AI',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: verdePlantacert,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                TextField(
                  key: const Key('login_correo'),
                  controller: _correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('login_contrasena'),
                  controller: _contrasenaCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _iniciarSesion,
                  child: const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 8),
                // ENLACE_REGISTRO: aquí se agrega el enlace de registro (RQ1-HU01)
                const Divider(height: 32),
                Text(
                  'Acceso temporal de desarrollo (hasta RQ-02)',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('login_usuario_id'),
                        controller: _usuarioIdCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'ID de usuario',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _accesoTemporal,
                      child: const Text('Entrar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
