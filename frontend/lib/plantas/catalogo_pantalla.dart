import 'package:flutter/material.dart';

import '../app/tema.dart';
import '../core/api_excepcion.dart';
import '../core/sesion.dart';
import 'agregar_planta_pantalla.dart';
import 'detalle_planta_pantalla.dart';
import 'planta.dart';
import 'planta_servicio.dart';

/// HU04: Como usuario, quiero ver el listado de todas las plantas registradas
/// en mi catálogo con su nombre, especie, ubicación e imagen, para poder
/// consultar rápidamente mi colección y encontrar la planta que necesito.
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
      setState(() => _error = mensajeErrorCatalogo(e));
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
    // La planta nueva aparece de inmediato arriba y luego se sincroniza con el backend
    setState(() {
      _plantas = [nueva, ..._plantas.where((p) => p.id != nueva.id)];
    });
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
    if (_cargando && _plantas.isEmpty) {
      return const Center(
        key: Key('catalogo_cargando'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Cargando tus plantas...'),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        key: const Key('catalogo_error'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text(
                'No se pudo cargar tu catálogo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
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
        key: Key('catalogo_vacio'),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.yard_outlined, size: 56, color: verdePlantacert),
              SizedBox(height: 12),
              Text(
                'Tu catálogo está vacío',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Aún no tienes plantas registradas.\nUsa "Agregar planta" para empezar.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.separated(
        key: const Key('catalogo_lista'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _plantas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => TarjetaPlanta(planta: _plantas[i]),
      ),
    );
  }
}

/// HU04: mensaje contextual según el problema al consultar el catálogo.
String mensajeErrorCatalogo(ApiExcepcion e) {
  if (e.status == 0) {
    return 'No hay conexión con el servidor. Revisa tu internet e inténtalo de nuevo.';
  }
  if (e.status == 404) {
    return 'No encontramos tu cuenta. Cierra sesión y vuelve a ingresar.';
  }
  if (e.status >= 500) {
    return 'El servidor tuvo un problema al consultar tus plantas. Inténtalo más tarde.';
  }
  return e.mensajeCompleto;
}

/// HU04: tarjeta de una planta del catálogo con imagen, nombre, especie y ubicación.
class TarjetaPlanta extends StatelessWidget {
  const TarjetaPlanta({super.key, required this.planta});

  final Planta planta;

  @override
  Widget build(BuildContext context) {
    final imagen = planta.imagenUrl?.trim();
    return Card(
      key: Key('tarjeta_planta_${planta.id}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // HU08: al tocar la planta se abre su información con los cuidados
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetallePlantaPantalla(planta: planta)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: (imagen == null || imagen.isEmpty)
                  ? const ImagenPorDefecto()
                  : Image.network(
                      imagen,
                      fit: BoxFit.cover,
                      // Si el enlace no carga se muestra la imagen por defecto
                      errorBuilder: (_, __, ___) => const ImagenPorDefecto(),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planta.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    _Dato(icono: Icons.eco_outlined, texto: planta.especie),
                    _Dato(icono: Icons.place_outlined, texto: planta.ubicacion),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 4),
        Expanded(
          child: Text(texto, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

/// Imagen que se muestra cuando la planta no tiene foto o el enlace no carga.
class ImagenPorDefecto extends StatelessWidget {
  const ImagenPorDefecto({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('imagen_por_defecto'),
      color: const Color(0xFFE8F5E9),
      alignment: Alignment.center,
      child: const Icon(Icons.local_florist, color: verdePlantacert, size: 40),
    );
  }
}
