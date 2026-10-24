import 'package:flutter/material.dart';

import '../app/tema.dart';
import '../core/api_excepcion.dart';
import '../core/sesion.dart';
import '../cuidados/agregar_cuidado_pantalla.dart';
import '../cuidados/cuidado.dart';
import '../cuidados/cuidado_servicio.dart';
import 'planta.dart';

/// Información de una planta con sus cuidados periódicos (HU08).
class DetallePlantaPantalla extends StatefulWidget {
  const DetallePlantaPantalla({
    super.key,
    required this.planta,
    this.servicioCuidados,
  });

  final Planta planta;
  final CuidadoServicio? servicioCuidados;

  @override
  State<DetallePlantaPantalla> createState() => _DetallePlantaPantallaState();
}

class _DetallePlantaPantallaState extends State<DetallePlantaPantalla> {
  late final CuidadoServicio _servicio;
  List<Cuidado> _cuidados = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _servicio = widget.servicioCuidados ?? CuidadoServicio();
    _cargar();
  }

  Future<void> _cargar() async {
    final usuarioId = Sesion.usuarioId;
    if (usuarioId == null) {
      setState(() {
        _cargando = false;
        _error = 'No hay una sesión activa. Vuelve a ingresar.';
      });
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final cuidados = await _servicio.listar(usuarioId, widget.planta.id);
      if (!mounted) return;
      setState(() => _cuidados = cuidados);
    } on ApiExcepcion catch (e) {
      if (!mounted) return;
      setState(() => _error = e.mensajeCompleto);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _agregarCuidado() async {
    final nuevo = await Navigator.of(context).push<Cuidado>(
      MaterialPageRoute(
        builder: (_) => AgregarCuidadoPantalla(
          plantaId: widget.planta.id,
          nombrePlanta: widget.planta.nombre,
          servicio: _servicio,
        ),
      ),
    );
    if (nuevo == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cuidado de ${nuevo.tipoTexto} agregado a ${widget.planta.nombre}'),
        backgroundColor: verdePlantacert,
      ),
    );
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final planta = widget.planta;
    return Scaffold(
      appBar: AppBar(title: Text(planta.nombre)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('boton_agregar_cuidado'),
        onPressed: _agregarCuidado,
        icon: const Icon(Icons.add),
        label: const Text('Agregar cuidado'),
      ),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _Encabezado(planta: planta),
            const SizedBox(height: 24),
            Text('Cuidados', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ..._seccionCuidados(),
          ],
        ),
      ),
    );
  }

  List<Widget> _seccionCuidados() {
    if (_cargando) {
      return const [
        Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null) {
      return [
        Text(_error!, key: const Key('cuidados_error')),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(onPressed: _cargar, child: const Text('Reintentar')),
        ),
      ];
    }
    if (_cuidados.isEmpty) {
      return const [
        Text(
          'Esta planta aún no tiene cuidados.\nUsa "Agregar cuidado" para registrar el primero.',
          key: Key('cuidados_vacio'),
        ),
      ];
    }
    return [
      for (final cuidado in _cuidados) _TarjetaCuidado(cuidado: cuidado),
    ];
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.planta});

  final Planta planta;

  @override
  Widget build(BuildContext context) {
    final imagen = planta.imagenUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (imagen != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imagen,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 80,
                child: Icon(Icons.broken_image_outlined, size: 48),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Text(planta.nombre, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('${planta.especie} · ${planta.ubicacion}'),
        if (planta.descripcion != null && planta.descripcion!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(planta.descripcion!),
        ],
      ],
    );
  }
}

class _TarjetaCuidado extends StatelessWidget {
  const _TarjetaCuidado({required this.cuidado});

  final Cuidado cuidado;

  IconData get _icono => switch (cuidado.tipo) {
        'RIEGO' => Icons.water_drop_outlined,
        'FERTILIZACION' => Icons.science_outlined,
        'PODA' => Icons.content_cut,
        'EXPOSICION_LUZ' => Icons.wb_sunny_outlined,
        'TRASPLANTE' => Icons.yard_outlined,
        _ => Icons.eco_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final dias = cuidado.frecuenciaDias == 1 ? 'día' : 'días';
    return Card(
      child: ListTile(
        leading: Icon(_icono, color: verdePlantacert),
        title: Text(cuidado.tipoTexto,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cada ${cuidado.frecuenciaDias} $dias · '
                'Último: ${fechaATexto(cuidado.fechaUltimoCuidado)}'),
            if (cuidado.notas != null && cuidado.notas!.isNotEmpty)
              Text(cuidado.notas!, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
