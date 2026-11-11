import 'package:flutter/material.dart';

import '../app/componentes.dart';
import '../app/tema.dart';
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
  final _inicioCtrl = TextEditingController();
  final _finCtrl = TextEditingController();
  late final CuidadoServicio _servicio;

  String? _tipo;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _servicio = widget.servicio ?? CuidadoServicio();
    // Por defecto el periodo empieza hoy y no tiene fecha de fin
    _inicioCtrl.text = fechaATexto(DateTime.now());
    for (final ctrl in [_frecuenciaCtrl, _inicioCtrl, _finCtrl]) {
      ctrl.addListener(_refrescar);
    }
  }

  void _refrescar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _frecuenciaCtrl.dispose();
    _fechaCtrl.dispose();
    _notasCtrl.dispose();
    _inicioCtrl.dispose();
    _finCtrl.dispose();
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

  /// Primer día del periodo (puede ser pasado o futuro).
  Future<void> _elegirInicio() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: Validadores.leerFecha(_inicioCtrl.text) ?? hoy,
      firstDate: DateTime(hoy.year - 5),
      lastDate: DateTime(hoy.year + 5),
      helpText: 'Primer día del cuidado',
    );
    if (elegida == null) return;
    _inicioCtrl.text = fechaATexto(elegida);
    // Si el último día quedó antes del nuevo primer día, se borra
    final fin = Validadores.leerFecha(_finCtrl.text);
    if (fin != null && fin.isBefore(elegida)) _finCtrl.clear();
  }

  /// Último día del periodo: nunca antes del primer día.
  Future<void> _elegirFin() async {
    final hoy = DateTime.now();
    final inicio = Validadores.leerFecha(_inicioCtrl.text) ?? hoy;
    final actual = Validadores.leerFecha(_finCtrl.text);
    final elegida = await showDatePicker(
      context: context,
      initialDate: (actual != null && !actual.isBefore(inicio))
          ? actual
          : inicio.add(const Duration(days: 30)),
      firstDate: inicio,
      lastDate: DateTime(inicio.year + 5),
      helpText: 'Último día del cuidado',
    );
    if (elegida != null) _finCtrl.text = fechaATexto(elegida);
  }

  /// Atajos para el último día: null = sin fecha de fin.
  void _duracionRapida(int? dias) {
    if (dias == null) {
      _finCtrl.clear();
      return;
    }
    final inicio = Validadores.leerFecha(_inicioCtrl.text) ?? DateTime.now();
    _finCtrl.text = fechaATexto(inicio.add(Duration(days: dias)));
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
        fechaInicio: Validadores.leerFecha(_inicioCtrl.text),
        fechaFin: Validadores.leerFecha(_finCtrl.text),
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
      appBar: AppBar(title: const Text('Nuevo cuidado')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _encabezado(),
                  const SizedBox(height: 20),
                  TarjetaSuave(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const TituloSeccion('QUÉ CUIDADO', icono: Icons.eco_outlined),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          key: const Key('cuidado_tipo'),
                          decoration: InputDecoration(
                            labelText: 'Tipo de cuidado *',
                            prefixIcon: Icon(iconoCuidado(_tipo)),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          items: [
                            for (final tipo in tiposCuidado.entries)
                              DropdownMenuItem(
                                value: tipo.key,
                                child: Text(tipo.value),
                              ),
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
                            suffixText: 'días',
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
                            prefixIcon: const Icon(Icons.history),
                            suffixIcon: IconButton(
                              key: const Key('cuidado_calendario'),
                              tooltip: 'Elegir en el calendario',
                              icon: const Icon(Icons.calendar_month),
                              onPressed: _elegirFecha,
                            ),
                          ),
                          validator: (v) => Validadores.fechaNoFutura(v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TarjetaSuave(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const TituloSeccion('PERIODO DEL CUIDADO',
                            icono: Icons.date_range_outlined),
                        const SizedBox(height: 4),
                        const Text(
                          'Elige desde qué día y hasta qué día se hace este cuidado.',
                          style: TextStyle(color: colorTextoSuave, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        _camposPeriodo(),
                        const SizedBox(height: 12),
                        _atajosDuracion(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TarjetaSuave(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const TituloSeccion('NOTAS', icono: Icons.notes),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _resumen(),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    CajaError(key: const Key('cuidado_error'), mensaje: _error!),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    key: const Key('cuidado_guardar'),
                    onPressed: _guardando ? null : _guardar,
                    icon: _guardando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
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

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: degradadoOscuro,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconoCuidado(_tipo), color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Programa un cuidado para',
                  style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.nombrePlanta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoFecha({
    required Key key,
    required Key botonKey,
    required TextEditingController controller,
    required String etiqueta,
    required IconData icono,
    required VoidCallback onCalendario,
    required String? Function(String?) validator,
    String? ayuda,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: 'AAAA-MM-DD',
        helperText: ayuda,
        prefixIcon: Icon(icono),
        suffixIcon: IconButton(
          key: botonKey,
          tooltip: 'Elegir en el calendario',
          icon: const Icon(Icons.calendar_month),
          onPressed: onCalendario,
        ),
      ),
      validator: validator,
    );
  }

  Widget _camposPeriodo() {
    final inicio = _campoFecha(
      key: const Key('cuidado_fecha_inicio'),
      botonKey: const Key('cuidado_calendario_inicio'),
      controller: _inicioCtrl,
      etiqueta: 'Primer día *',
      icono: Icons.play_circle_outline,
      onCalendario: _elegirInicio,
      validator: Validadores.fechaInicio,
    );
    final fin = _campoFecha(
      key: const Key('cuidado_fecha_fin'),
      botonKey: const Key('cuidado_calendario_fin'),
      controller: _finCtrl,
      etiqueta: 'Último día',
      icono: Icons.stop_circle_outlined,
      onCalendario: _elegirFin,
      validator: (v) => Validadores.fechaFin(v, _inicioCtrl.text),
      ayuda: 'Vacío = sin fecha de fin',
    );
    return LayoutBuilder(
      builder: (context, restricciones) {
        if (restricciones.maxWidth < 420) {
          return Column(children: [inicio, const SizedBox(height: 12), fin]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: inicio),
            const SizedBox(width: 12),
            Expanded(child: fin),
          ],
        );
      },
    );
  }

  Widget _atajosDuracion() {
    const opciones = <String, int?>{
      'Sin fin': null,
      '1 semana': 7,
      '1 mes': 30,
      '3 meses': 90,
    };
    final inicio = Validadores.leerFecha(_inicioCtrl.text);
    final fin = Validadores.leerFecha(_finCtrl.text);
    final duracion =
        (inicio != null && fin != null) ? fin.difference(inicio).inDays : null;
    final finVacio = _finCtrl.text.trim().isEmpty;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final opcion in opciones.entries)
          ChoiceChip(
            label: Text(opcion.key),
            selected: opcion.value == null ? finVacio : duracion == opcion.value,
            selectedColor: verdeSuave,
            side: const BorderSide(color: colorBorde),
            onSelected: (_) => _duracionRapida(opcion.value),
          ),
      ],
    );
  }

  /// Resumen de cómo quedará el cuidado con los datos escritos.
  Widget _resumen() {
    final frecuencia = int.tryParse(_frecuenciaCtrl.text.trim());
    final inicio = Validadores.leerFecha(_inicioCtrl.text);
    final fin = Validadores.leerFecha(_finCtrl.text);
    if (frecuencia == null || frecuencia < 1 || inicio == null) {
      return const SizedBox.shrink();
    }
    final dias = frecuencia == 1 ? 'todos los días' : 'cada $frecuencia días';
    final hasta = fin == null ? 'sin fecha de fin' : 'hasta el ${fechaLegible(fin)}';
    String veces = '';
    if (fin != null && !fin.isBefore(inicio)) {
      final total = fin.difference(inicio).inDays ~/ frecuencia + 1;
      veces = ' · $total ${total == 1 ? 'vez' : 'veces'} en total';
    }
    return Container(
      key: const Key('cuidado_resumen'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: verdeSuave,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_repeat, color: verdePlantacert),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Se hará $dias desde el ${fechaLegible(inicio)} $hasta$veces.',
              style: const TextStyle(color: verdeOscuro, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ícono según el tipo de cuidado.
IconData iconoCuidado(String? tipo) => switch (tipo) {
      'RIEGO' => Icons.water_drop_outlined,
      'FERTILIZACION' => Icons.science_outlined,
      'PODA' => Icons.content_cut,
      'EXPOSICION_LUZ' => Icons.wb_sunny_outlined,
      'TRASPLANTE' => Icons.yard_outlined,
      _ => Icons.eco_outlined,
    };
