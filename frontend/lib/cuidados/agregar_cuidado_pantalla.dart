import 'package:flutter/material.dart';

import '../core/api_excepcion.dart';
import '../core/sesion.dart';
import '../core/validadores.dart';
import 'cuidado.dart';
import 'cuidado_servicio.dart';

/// HU08: Como usuario, quiero agregar a mi planta un cuidado indicando su tipo,
/// frecuencia en días, última fecha realizada y notas opcionales, para poder
/// llevar el control de los cuidados periódicos que necesita.
///
/// Al guardar, devuelve el [Cuidado] creado con Navigator.pop.
class AgregarCuidadoPantalla extends StatefulWidget {
  const AgregarCuidadoPantalla({
    super.key,
    required this.plantaId,
    required this.nombrePlanta,
    this.servicio,
  });

  final int plantaId;
  final String nombrePlanta;
  final CuidadoServicio? servicio;

  @override
  State<AgregarCuidadoPantalla> createState() => _AgregarCuidadoPantallaState();
}

class _AgregarCuidadoPantallaState extends State<AgregarCuidadoPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _frecuenciaCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  late final CuidadoServicio _servicio;

  String? _tipo;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _servicio = widget.servicio ?? CuidadoServicio();
  }

  @override
  void dispose() {
    _frecuenciaCtrl.dispose();
    _fechaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  /// Calendario que no deja escoger fechas futuras.
  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: Validadores.leerFecha(_fechaCtrl.text) ?? hoy,
      firstDate: DateTime(hoy.year - 5),
      lastDate: hoy,
      helpText: 'Fecha del último cuidado',
    );
    if (elegida != null) {
      _fechaCtrl.text = fechaATexto(elegida);
    }
  }

  Future<void> _guardar() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    final usuarioId = Sesion.usuarioId;
    if (usuarioId == null) {
      setState(() => _error = 'No hay una sesión activa. Vuelve a ingresar.');
      return;
    }

    setState(() => _guardando = true);
    try {
      final Cuidado cuidado = await _servicio.registrar(
        usuarioId: usuarioId,
        plantaId: widget.plantaId,
        tipo: _tipo!,
        frecuenciaDias: int.parse(_frecuenciaCtrl.text.trim()),
        fechaUltimoCuidado: Validadores.leerFecha(_fechaCtrl.text)!,
        notas: _notasCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(cuidado);
    } on ApiExcepcion catch (e) {
      setState(() => _error = e.mensajeCompleto);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nuevo cuidado · ${widget.nombrePlanta}')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    key: const Key('cuidado_tipo'),
                    decoration: const InputDecoration(
                      labelText: 'Tipo de cuidado *',
                      prefixIcon: Icon(Icons.eco_outlined),
                    ),
                    items: [
                      for (final tipo in tiposCuidado.entries)
                        DropdownMenuItem(value: tipo.key, child: Text(tipo.value)),
                    ],
                    onChanged: (valor) => setState(() => _tipo = valor),
                    validator: (valor) =>
                        valor == null ? 'Selecciona el tipo de cuidado' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('cuidado_frecuencia'),
                    controller: _frecuenciaCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Frecuencia en días *',
                      hintText: 'Ej: 3 (cada 3 días)',
                      prefixIcon: Icon(Icons.repeat),
                    ),
                    validator: Validadores.frecuencia,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('cuidado_fecha'),
                    controller: _fechaCtrl,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: 'Fecha del último cuidado *',
                      hintText: 'AAAA-MM-DD',
                      prefixIcon: const Icon(Icons.event_outlined),
                      suffixIcon: IconButton(
                        key: const Key('cuidado_calendario'),
                        tooltip: 'Elegir en el calendario',
                        icon: const Icon(Icons.calendar_month),
                        onPressed: _elegirFecha,
                      ),
                    ),
                    validator: (v) => Validadores.fechaNoFutura(v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('cuidado_notas'),
                    controller: _notasCtrl,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Notas (opcional)',
                      hintText: 'Ej: regar con agua reposada',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => Validadores.maximo(
                        v, 500, 'Las notas no pueden superar 500 caracteres'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      key: const Key('cuidado_error'),
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
                  FilledButton.icon(
                    key: const Key('cuidado_guardar'),
                    onPressed: _guardando ? null : _guardar,
                    icon: _guardando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Guardar cuidado'),
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
