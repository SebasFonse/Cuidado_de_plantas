import 'package:flutter/material.dart';

import '../app/componentes.dart';
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              children: [
                _Encabezado(planta: planta),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.water_drop_outlined, color: verdeMedio),
                    const SizedBox(width: 8),
                    const Text(
                      'Cuidados',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: verdeOscuro,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!_cargando && _error == null)
                      Insignia(
                        texto: '${_cuidados.length}',
                        fondo: verdeSuave,
                        colorTexto: verdeOscuro,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._seccionCuidados(),
              ],
            ),
          ),
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
        CajaError(key: const Key('cuidados_error'), mensaje: _error!),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(onPressed: _cargar, child: const Text('Reintentar')),
        ),
      ];
    }
    if (_cuidados.isEmpty) {
      return const [
        TarjetaSuave(
          child: Row(
            children: [
              Icon(Icons.spa_outlined, size: 36, color: verdeClaro),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Esta planta aún no tiene cuidados.\nUsa "Agregar cuidado" para registrar el primero.',
                  key: Key('cuidados_vacio'),
                  style: TextStyle(color: colorTextoSuave),
                ),
              ),
            ],
          ),
        ),
      ];
    }
    return [
      for (final cuidado in _cuidados)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TarjetaCuidado(cuidado: cuidado),
        ),
    ];
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.planta});

  final Planta planta;

  @override
  Widget build(BuildContext context) {
    final imagen = planta.imagenUrl?.trim();
    final portadaPorDefecto = Container(
      decoration: const BoxDecoration(gradient: degradadoHoja),
      alignment: Alignment.center,
      child: const Icon(Icons.local_florist, size: 72, color: verdePlantacert),
    );
    return TarjetaSuave(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 220,
              child: (imagen == null || imagen.isEmpty)
                  ? portadaPorDefecto
                  : Image.network(
                      imagen,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => portadaPorDefecto,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planta.especie,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: colorTextoSuave,
                  ),
                ),
                const SizedBox(height: 10),
                Insignia(texto: planta.ubicacion, icono: Icons.place_outlined),
                if (planta.descripcion != null && planta.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(planta.descripcion!, style: const TextStyle(color: colorTexto)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaCuidado extends StatelessWidget {
  const _TarjetaCuidado({required this.cuidado});

  final Cuidado cuidado;

  /// Texto y colores del estado según los días que faltan.
  Insignia _estado() {
    if (cuidado.finalizado) {
      return const Insignia(
        texto: 'Periodo terminado',
        icono: Icons.flag_outlined,
        fondo: Insignia.fondoGris,
        colorTexto: Insignia.textoGris,
      );
    }
    final dias = cuidado.diasRestantes();
    if (dias < 0) {
      return Insignia(
        texto: 'Atrasado ${-dias} ${dias == -1 ? 'día' : 'días'}',
        icono: Icons.warning_amber_rounded,
        fondo: Insignia.fondoRojo,
        colorTexto: Insignia.textoRojo,
      );
    }
    if (dias == 0) {
      return const Insignia(
        texto: 'Toca hoy',
        icono: Icons.notifications_active_outlined,
        fondo: Insignia.fondoAmarillo,
        colorTexto: Insignia.textoAmarillo,
      );
    }
    return Insignia(
      texto: 'En $dias ${dias == 1 ? 'día' : 'días'}',
      icono: Icons.schedule,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dias = cuidado.frecuenciaDias == 1 ? 'día' : 'días';
    final inicio = cuidado.fechaInicio;
    final fin = cuidado.fechaFin;
    return TarjetaSuave(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: verdeSuave,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconoCuidado(cuidado.tipo), color: verdePlantacert),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      cuidado.tipoTexto,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: verdeOscuro,
                      ),
                    ),
                    _estado(),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Cada ${cuidado.frecuenciaDias} $dias · '
                  'Último: ${fechaATexto(cuidado.fechaUltimoCuidado)}',
                  style: const TextStyle(color: colorTextoSuave),
                ),
                if (inicio != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.date_range_outlined,
                          size: 15, color: verdeMedio),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          fin == null
                              ? 'Desde ${fechaLegible(inicio)} · sin fecha de fin'
                              : 'Del ${fechaLegible(inicio)} al ${fechaLegible(fin)}',
                          style: const TextStyle(color: colorTextoSuave, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
                if (!cuidado.finalizado) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Próximo: ${fechaLegible(cuidado.proximaFecha)}',
                    style: const TextStyle(color: colorTextoSuave, fontSize: 13),
                  ),
                ],
                if (cuidado.notas != null && cuidado.notas!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    cuidado.notas!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontStyle: FontStyle.italic, color: colorTexto),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
