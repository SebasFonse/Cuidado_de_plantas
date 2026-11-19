import 'package:flutter/material.dart';

import '../app/componentes.dart';
import '../app/tema.dart';
import '../core/api_excepcion.dart';
import '../core/sesion.dart';
import '../core/validadores.dart';
import '../especies/especie.dart';
import '../especies/especie_servicio.dart';
import 'foto_planta.dart';
import 'planta.dart';
import 'planta_servicio.dart';
import 'tipo_planta.dart';

/// RQ4-HU01: Como usuario, quiero agregar una planta nueva a mi catálogo
/// ingresando su nombre, especie, ubicación, descripción y una foto mediante
/// enlace, para poder llevar un registro personal de mis plantas.
///
/// Al guardar, devuelve la [Planta] creada con Navigator.pop.
class AgregarPlantaPantalla extends StatefulWidget {
  const AgregarPlantaPantalla({super.key, this.servicio, this.servicioEspecies});

  final PlantaServicio? servicio;
  final EspecieServicio? servicioEspecies;

  @override
  State<AgregarPlantaPantalla> createState() => _AgregarPlantaPantallaState();
}

class _AgregarPlantaPantallaState extends State<AgregarPlantaPantalla> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _especieCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _imagenCtrl = TextEditingController();
  final _especieFoco = FocusNode();
  late final PlantaServicio _servicio;

  /// Base de datos de especies para sugerir mientras se escribe.
  List<Especie> _especies = [];

  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _servicio = widget.servicio ?? PlantaServicio();
    _imagenCtrl.addListener(() => setState(() {}));
    // El ícono de la vista previa cambia según el nombre y la especie
    _nombreCtrl.addListener(() => setState(() {}));
    _especieCtrl.addListener(() => setState(() {}));
    _cargarEspecies();
  }

  Future<void> _cargarEspecies() async {
    final especies = await (widget.servicioEspecies ?? EspecieServicio()).listar();
    if (mounted) setState(() => _especies = especies);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _especieCtrl.dispose();
    _ubicacionCtrl.dispose();
    _descripcionCtrl.dispose();
    _imagenCtrl.dispose();
    _especieFoco.dispose();
    super.dispose();
  }

  bool get _hayVistaPrevia =>
      _imagenCtrl.text.trim().isNotEmpty &&
      Validadores.urlOpcional(_imagenCtrl.text) == null;

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
      final Planta planta = await _servicio.registrar(
        usuarioId: usuarioId,
        nombre: _nombreCtrl.text,
        especie: _especieCtrl.text,
        ubicacion: _ubicacionCtrl.text,
        descripcion: _descripcionCtrl.text,
        imagenUrl: _imagenCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(planta);
    } on ApiExcepcion catch (e) {
      setState(() => _error = e.mensajeCompleto);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar planta')),
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
                  const TituloSeccion('DATOS DE LA PLANTA', icono: Icons.eco_outlined),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('planta_nombre'),
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      hintText: 'Ej: Monstera',
                      prefixIcon: Icon(Icons.local_florist_outlined),
                    ),
                    validator: (v) =>
                        Validadores.requerido(v, 'El nombre de la planta es requerido') ??
                        Validadores.maximo(v, 100, 'El nombre no puede superar 100 caracteres'),
                  ),
                  const SizedBox(height: 12),
                  // Base de datos de especies: sugerencias mientras se escribe
                  RawAutocomplete<Especie>(
                    textEditingController: _especieCtrl,
                    focusNode: _especieFoco,
                    displayStringForOption: (e) => e.nombreCientifico,
                    optionsBuilder: (valor) =>
                        filtrarEspecies(_especies, valor.text).take(8),
                    fieldViewBuilder: (context, controller, foco, alEnviar) =>
                        TextFormField(
                      key: const Key('planta_especie'),
                      controller: controller,
                      focusNode: foco,
                      onFieldSubmitted: (_) => alEnviar(),
                      decoration: InputDecoration(
                        labelText: 'Especie *',
                        hintText: 'Ej: Monstera deliciosa',
                        prefixIcon: const Icon(Icons.spa_outlined),
                        helperText: _especies.isEmpty
                            ? null
                            : 'Escribe y elige de ${_especies.length} especies registradas',
                      ),
                      validator: (v) =>
                          Validadores.requerido(v, 'La especie es requerida') ??
                          Validadores.maximo(v, 100, 'La especie no puede superar 100 caracteres'),
                    ),
                    optionsViewBuilder: (context, alElegir, opciones) => Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxHeight: 260, maxWidth: 480),
                          child: ListView(
                            key: const Key('planta_especie_opciones'),
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            children: [
                              for (final especie in opciones)
                                ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.eco_outlined),
                                  title: Text(
                                    especie.nombreCientifico,
                                    style: const TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                  subtitle: Text(especie.nombreComun),
                                  onTap: () => alElegir(especie),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('planta_ubicacion'),
                    controller: _ubicacionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación *',
                      hintText: 'Ej: Sala, balcón, jardín',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                    validator: (v) =>
                        Validadores.requerido(v, 'La ubicación es requerida') ??
                        Validadores.maximo(v, 100, 'La ubicación no puede superar 100 caracteres'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('planta_descripcion'),
                    controller: _descripcionCtrl,
                    maxLines: 3,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      alignLabelWithHint: true,
                    ),
                  ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TarjetaSuave(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                  const TituloSeccion('FOTO', icono: Icons.photo_camera_outlined),
                  const SizedBox(height: 4),
                  const Text(
                    'Esta foto te acompaña en el catálogo, en la página de la planta y en sus cuidados.',
                    style: TextStyle(color: colorTextoSuave, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('planta_imagen'),
                    controller: _imagenCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Enlace de la foto (opcional)',
                      hintText: 'https://...',
                      prefixIcon: Icon(Icons.link),
                    ),
                    validator: Validadores.urlOpcional,
                  ),
                  const SizedBox(height: 12),
                  // Vista previa: así se verá la planta en todos los módulos
                  FotoPlanta(
                    key: const Key('planta_vista_previa'),
                    imagenUrl: _hayVistaPrevia ? _imagenCtrl.text : null,
                    nombre: _nombreCtrl.text,
                    especie: _especieCtrl.text,
                    ancho: double.infinity,
                    alto: 180,
                    tamanoIcono: 56,
                  ),
                  if (!_hayVistaPrevia) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Sin foto se mostrará el ícono de: '
                      '${tipoDePlanta(nombre: _nombreCtrl.text, especie: _especieCtrl.text).etiqueta.toLowerCase()}',
                      key: const Key('planta_tipo_detectado'),
                      style: const TextStyle(color: colorTextoSuave, fontSize: 12),
                    ),
                  ],
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    CajaError(key: const Key('planta_error'), mensaje: _error!),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    key: const Key('planta_guardar'),
                    onPressed: _guardando ? null : _guardar,
                    icon: _guardando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Guardar planta'),
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
            child: const Icon(Icons.local_florist, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nueva planta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Agrégala a tu catálogo con su foto y ubicación',
                  style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
