import 'package:flutter/material.dart';

import '../app/tema.dart';
import '../core/api_excepcion.dart';
import '../core/sesion.dart';
import 'agregar_planta_pantalla.dart';
import 'planta.dart';
import 'planta_servicio.dart';

/// Catálogo personal de plantas (permite ver la planta recién agregada).
class CatalogoPantalla extends StatefulWidget {
  const CatalogoPantalla({super.key, this.servicio});

  final PlantaServicio? servicio;

  @override
  State<CatalogoPantalla> createState() => _CatalogoPantallaState();
}

class _CatalogoPantallaState extends State<CatalogoPantalla> {
  late final PlantaServicio _servicio;
  List<Planta> _plantas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _servicio = widget.servicio ?? PlantaServicio();
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
      final plantas = await _servicio.listar(usuarioId);
      if (!mounted) return;
      setState(() => _plantas = plantas);
    } on ApiExcepcion catch (e) {
      if (!mounted) return;
      setState(() => _error = e.mensajeCompleto);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _agregar() async {
    final nueva = await Navigator.of(context).push<Planta>(
      MaterialPageRoute(
        builder: (_) => AgregarPlantaPantalla(servicio: _servicio),
      ),
    );
    if (nueva == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Planta "${nueva.nombre}" agregada a tu catálogo'),
        backgroundColor: verdePlantacert,
      ),
    );
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis plantas')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('boton_agregar_planta'),
        onPressed: _agregar,
        icon: const Icon(Icons.add),
        label: const Text('Agregar planta'),
      ),
      body: _contenido(),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _cargar, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }
    if (_plantas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aún no tienes plantas registradas.\nUsa "Agregar planta" para empezar.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _plantas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _TarjetaPlanta(planta: _plantas[i]),
      ),
    );
  }
}

class _TarjetaPlanta extends StatelessWidget {
  const _TarjetaPlanta({required this.planta});

  final Planta planta;

  @override
  Widget build(BuildContext context) {
    final imagen = planta.imagenUrl;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: SizedBox(
          width: 56,
          height: 56,
          child: imagen == null
              ? const Icon(Icons.local_florist, color: verdePlantacert, size: 40)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imagen,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image_outlined, size: 40),
                  ),
                ),
        ),
        title: Text(planta.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${planta.especie} · ${planta.ubicacion}'),
            if (planta.descripcion != null && planta.descripcion!.isNotEmpty)
              Text(planta.descripcion!, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
