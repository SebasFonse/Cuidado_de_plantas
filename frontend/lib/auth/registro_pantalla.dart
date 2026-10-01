import 'package:flutter/material.dart';

import '../app/tema.dart';
import '../core/api_excepcion.dart';
import '../core/validadores.dart';
import 'login_pantalla.dart';
import 'registro_servicio.dart';

/// RQ1-HU01: Como usuario nuevo, quiero registrarme ingresando mi nombre
/// completo, correo electrónico y contraseña desde un enlace accesible en la
/// pantalla de inicio de sesión, para poder crear mi propia cuenta.
class RegistroPantalla extends StatefulWidget {
  const RegistroPantalla({super.key, this.servicio});

  /// Permite inyectar un servicio simulado en las pruebas.
  final RegistroServicio? servicio;

  @override
  State<RegistroPantalla> createState() => _RegistroPantallaState();
}

class _RegistroPantallaState extends State<RegistroPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  late final RegistroServicio _servicio;

  bool _ocultarContrasena = true;
  bool _enviando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _servicio = widget.servicio ?? RegistroServicio();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);
    try {
      final usuario = await _servicio.registrar(
        nombre: _nombreCtrl.text,
        correo: _correoCtrl.text,
        contrasena: _contrasenaCtrl.text,
      );
      if (!mounted) return;
      // Redirige al inicio de sesión mostrando la confirmación.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginPantalla(
            mensajeInicial: '${usuario.mensaje} (tu ID de usuario es ${usuario.id})',
          ),
        ),
        (_) => false,
      );
    } on ApiExcepcion catch (e) {
      setState(() => _error = e.mensajeCompleto);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.person_add_alt_1, size: 56, color: verdePlantacert),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('registro_nombre'),
                    controller: _nombreCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        Validadores.requerido(v, 'El nombre completo es requerido') ??
                        Validadores.maximo(v, 100, 'El nombre no puede superar 100 caracteres'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('registro_correo'),
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: Validadores.correo,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('registro_contrasena'),
                    controller: _contrasenaCtrl,
                    obscureText: _ocultarContrasena,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      helperText: 'Mínimo 8 caracteres',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _ocultarContrasena ? 'Mostrar' : 'Ocultar',
                        icon: Icon(_ocultarContrasena
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _ocultarContrasena = !_ocultarContrasena),
                      ),
                    ),
                    validator: Validadores.contrasena,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('registro_confirmar'),
                    controller: _confirmarCtrl,
                    obscureText: _ocultarContrasena,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (v) => v != _contrasenaCtrl.text
                        ? 'Las contraseñas no coinciden'
                        : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      key: const Key('registro_error'),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const Key('registro_boton'),
                    onPressed: _enviando ? null : _registrar,
                    child: _enviando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Registrarme'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _enviando ? null : () => Navigator.of(context).pop(),
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
