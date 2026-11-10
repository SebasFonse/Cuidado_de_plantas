import 'package:flutter/material.dart';

import '../app/componentes.dart';
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
  final _busquedaCtrl = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

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
      return Center(
        key: const Key('catalogo_vacio'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  gradient: degradadoHoja,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.yard_outlined, size: 48, color: verdePlantacert),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tu catálogo está vacío',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, color: verdeOscuro),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aún no tienes plantas registradas.\nUsa "Agregar planta" para empezar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorTextoSuave),
              ),
            ],
          ),
        ),
      );
    }

    final filtradas = filtrarPlantas(_plantas, _busqueda);
    final total = _plantas.length;
    return RefreshIndicator(
      onRefresh: _cargar,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            key: const Key('catalogo_lista'),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            children: [
              Text(
                '$total ${total == 1 ? 'planta registrada' : 'plantas registradas'}',
                style: const TextStyle(color: colorTextoSuave, fontSize: 13),
              ),
              const SizedBox(height: 12),
              _barraBusqueda(),
              if (_busqueda.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Mostrando ${filtradas.length} de $total',
                  key: const Key('catalogo_conteo_busqueda'),
                  style: const TextStyle(color: colorTextoSuave, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              if (filtradas.isEmpty)
                _sinResultados()
              else
                LayoutBuilder(
                  builder: (context, restricciones) {
                    const espacio = 14.0;
                    final ancho = restricciones.maxWidth;
                    final columnas = (ancho / 230).floor().clamp(1, 4).toInt();
                    final anchoTarjeta =
                        (ancho - espacio * (columnas - 1)) / columnas;
                    return Wrap(
                      spacing: espacio,
                      runSpacing: espacio,
                      children: [
                        for (final planta in filtradas)
                          SizedBox(
                            width: anchoTarjeta,
                            child: TarjetaPlanta(planta: planta),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Barra de búsqueda por nombre o especie (RQ-17).
  Widget _barraBusqueda() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        key: const Key('catalogo_buscar'),
        controller: _busquedaCtrl,
        onChanged: (valor) => setState(() => _busqueda = valor),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o especie...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _busqueda.isEmpty
              ? null
              : IconButton(
                  key: const Key('catalogo_limpiar_busqueda'),
                  tooltip: 'Limpiar búsqueda',
                  icon: const Icon(Icons.close),
                  onPressed: _limpiarBusqueda,
                ),
          border: _bordeBusqueda(colorBorde),
          enabledBorder: _bordeBusqueda(colorBorde),
          focusedBorder: _bordeBusqueda(verdePlantacert),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  static OutlineInputBorder _bordeBusqueda(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: color, width: 1.5),
      );

  void _limpiarBusqueda() {
    _busquedaCtrl.clear();
    setState(() => _busqueda = '');
  }

  Widget _sinResultados() {
    return Padding(
      key: const Key('catalogo_sin_resultados'),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: verdeClaro),
          const SizedBox(height: 12),
          Text(
            'Ninguna planta coincide con "${_busqueda.trim()}"',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: verdeOscuro),
          ),
          const SizedBox(height: 6),
          const Text(
            'Prueba con otra parte del nombre o de la especie.',
            style: TextStyle(color: colorTextoSuave),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _limpiarBusqueda,
            icon: const Icon(Icons.close),
            label: const Text('Limpiar búsqueda'),
          ),
        ],
      ),
    );
  }
}

/// RQ-17: filtra por una parte del nombre o de la especie,
/// sin importar mayúsculas ni tildes. Conserva el orden original.
List<Planta> filtrarPlantas(List<Planta> plantas, String busqueda) {
  final texto = normalizarTexto(busqueda);
  if (texto.isEmpty) return plantas;
  return plantas
      .where((p) =>
          normalizarTexto(p.nombre).contains(texto) ||
          normalizarTexto(p.especie).contains(texto))
      .toList();
}

/// Pasa a minúsculas y quita tildes para comparar textos.
String normalizarTexto(String valor) {
  const conTilde = 'áàäâéèëêíìïîóòöôúùüûñ';
  const sinTilde = 'aaaaeeeeiiiioooouuuun';
  final buffer = StringBuffer();
  for (final letra in valor.trim().toLowerCase().split('')) {
    final i = conTilde.indexOf(letra);
    buffer.write(i >= 0 ? sinTilde[i] : letra);
  }
  return buffer.toString();
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
    return Material(
      key: Key('tarjeta_planta_${planta.id}'),
      color: colorSuperficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: colorBorde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // HU08: al tocar la planta se abre su información con los cuidados
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetallePlantaPantalla(planta: planta)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: (imagen == null || imagen.isEmpty)
                      ? const ImagenPorDefecto()
                      : Image.network(
                          imagen,
                          fit: BoxFit.cover,
                          // Si el enlace no carga se muestra la imagen por defecto
                          errorBuilder: (_, __, ___) => const ImagenPorDefecto(),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                planta.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: verdeOscuro,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                planta.especie,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: colorTextoSuave,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: Insignia(
                      texto: planta.ubicacion,
                      icono: Icons.place_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Spacer(),
                  const Icon(Icons.arrow_forward, size: 18, color: verdeMedio),
                ],
              ),
            ],
          ),
        ),
      ),
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
      decoration: const BoxDecoration(gradient: degradadoHoja),
      alignment: Alignment.center,
      child: const Icon(Icons.local_florist, color: verdePlantacert, size: 48),
    );
  }
}
