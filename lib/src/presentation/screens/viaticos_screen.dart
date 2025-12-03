import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/viatico_notifier.dart';
import 'aprobar_viatico_modal.dart';
import 'crear_viatico_screen.dart';

/// Pantalla principal de viáticos
class ViaticosScreen extends ConsumerStatefulWidget {
  const ViaticosScreen({super.key});

  @override
  ConsumerState<ViaticosScreen> createState() => _ViaticosScreenState();
}

class _ViaticosScreenState extends ConsumerState<ViaticosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filtroBusqueda = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viaticos = ref.watch(viaticoListNotifierProvider);
    final totalAprobados = ref
        .read(viaticoListNotifierProvider.notifier)
        .calcularTotalAprobados();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text(
          'Viáticos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Pendientes'),
            Tab(text: 'Aprobados'),
            Tab(text: 'Rechazados'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Estadísticas rápidas
          _buildStatsSection(totalAprobados, viaticos),

          // Barra de búsqueda
          _buildSearchBar(),

          // Lista de viáticos
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildViaticosList(viaticos, null),
                _buildViaticosList(viaticos, EstadoViatico.pendiente),
                _buildViaticosList(viaticos, EstadoViatico.aprobado),
                _buildViaticosList(viaticos, EstadoViatico.rechazado),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const CrearViaticoScreen(),
            ),
          ).then((_) {
            // Refrescar lista si se creó un viático
            setState(() {});
          });
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo Viático',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Construir sección de estadísticas
  Widget _buildStatsSection(double totalAprobados, List<Viatico> viaticos) {
    final pendientes = viaticos
        .where((v) => v.estado == EstadoViatico.pendiente)
        .length;
    final aprobados = viaticos
        .where((v) => v.estado == EstadoViatico.aprobado)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pendientes',
              pendientes.toString(),
              Colors.orange,
              Icons.pending,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Aprobados',
              aprobados.toString(),
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total',
              _formatCurrency(totalAprobados),
              Colors.blue,
              Icons.attach_money,
            ),
          ),
        ],
      ),
    );
  }

  /// Construir tarjeta de estadística
  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );

  /// Construir barra de búsqueda
  Widget _buildSearchBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: Colors.white,
    child: TextField(
      onChanged: (value) {
        setState(() {
          _filtroBusqueda = value.toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Buscar por concepto, usuario, orden...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _filtroBusqueda.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _filtroBusqueda = '';
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
  );

  /// Construir lista de viáticos
  Widget _buildViaticosList(
    List<Viatico> viaticos,
    EstadoViatico? estadoFiltro,
  ) {
    var viaticosFiltrados = estadoFiltro != null
        ? viaticos.where((v) => v.estado == estadoFiltro).toList()
        : viaticos;

    // Aplicar filtro de búsqueda
    if (_filtroBusqueda.isNotEmpty) {
      viaticosFiltrados = viaticosFiltrados
          .where(
            (v) =>
                v.concepto.toLowerCase().contains(_filtroBusqueda) ||
                v.usuarioNombre.toLowerCase().contains(_filtroBusqueda) ||
                (v.ordenId?.toLowerCase().contains(_filtroBusqueda) ?? false),
          )
          .toList();
    }

    // Ordenar por fecha (más recientes primero)
    viaticosFiltrados.sort((a, b) => b.fechaCreado.compareTo(a.fechaCreado));

    if (viaticosFiltrados.isEmpty) {
      return _buildEmptyState(estadoFiltro);
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viaticosFiltrados.length,
        itemBuilder: (context, index) {
          final viatico = viaticosFiltrados[index];
          return _buildViaticoCard(viatico);
        },
      ),
    );
  }

  /// Construir estado vacío
  Widget _buildEmptyState(EstadoViatico? estadoFiltro) {
    String mensaje;
    IconData icono;

    switch (estadoFiltro) {
      case EstadoViatico.pendiente:
        mensaje = 'No hay viáticos pendientes';
        icono = Icons.pending_outlined;
        break;
      case EstadoViatico.aprobado:
        mensaje = 'No hay viáticos aprobados';
        icono = Icons.check_circle_outline;
        break;
      case EstadoViatico.rechazado:
        mensaje = 'No hay viáticos rechazados';
        icono = Icons.cancel_outlined;
        break;
      default:
        mensaje = 'No hay viáticos registrados';
        icono = Icons.card_travel_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para crear uno nuevo',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Construir tarjeta de viático
  Widget _buildViaticoCard(Viatico viatico) => Card(
    elevation: 2,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: () => _mostrarDetalleViatico(viatico),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado y acciones
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildEstadoChip(viatico.estado),
                          const SizedBox(width: 8),
                          if (viatico.tipo == TipoViatico.automatico)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Text(
                                'AUTO',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(viatico.fechaCreado),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Botones de acción
                if (viatico.estado == EstadoViatico.pendiente)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(
                        icon: Icons.check,
                        color: Colors.green,
                        tooltip: 'Aprobar',
                        onPressed: () => _aprobarViatico(viatico),
                      ),
                      const SizedBox(width: 4),
                      _buildActionButton(
                        icon: Icons.close,
                        color: Colors.red,
                        tooltip: 'Rechazar',
                        onPressed: () => _rechazarViatico(viatico),
                      ),
                    ],
                  )
                else
                  _buildActionButton(
                    icon: Icons.delete_outline,
                    color: Colors.grey,
                    tooltip: 'Eliminar',
                    onPressed: () => _eliminarViatico(viatico),
                  ),
              ],
            ),
            const Divider(height: 24),

            // Información del usuario
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    viatico.usuarioNombre,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Concepto
            Text(
              viatico.concepto,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Información adicional
            Row(
              children: [
                if (viatico.ordenId != null) ...[
                  Icon(
                    Icons.receipt_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Orden: ${viatico.ordenId}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                ],
                if (viatico.distanciaKm != null) ...[
                  Icon(Icons.straighten, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${viatico.distanciaKm!.toStringAsFixed(1)} km',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Monto
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Monto',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    _formatCurrency(viatico.monto),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),

            // Información de aprobación/rechazo
            if (viatico.fechaAprobado != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    viatico.estado == EstadoViatico.aprobado
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 14,
                    color: viatico.estado == EstadoViatico.aprobado
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${viatico.estado == EstadoViatico.aprobado ? "Aprobado" : "Rechazado"} por ${viatico.aprobadoPor ?? "Sistema"} - ${_formatDate(viatico.fechaAprobado!)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              if (viatico.observaciones != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Obs: ${viatico.observaciones}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    ),
  );

  /// Construir chip de estado
  Widget _buildEstadoChip(EstadoViatico estado) {
    Color color;
    String texto;
    IconData icono;

    switch (estado) {
      case EstadoViatico.pendiente:
        color = Colors.orange;
        texto = 'Pendiente';
        icono = Icons.pending;
        break;
      case EstadoViatico.aprobado:
        color = Colors.green;
        texto = 'Aprobado';
        icono = Icons.check_circle;
        break;
      case EstadoViatico.rechazado:
        color = Colors.red;
        texto = 'Rechazado';
        icono = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Construir botón de acción
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    ),
  );

  /// Mostrar detalle del viático
  void _mostrarDetalleViatico(Viatico viatico) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ViaticoDetailSheet(viatico: viatico),
    );
  }

  /// Aprobar viático
  void _aprobarViatico(Viatico viatico) {
    showDialog<void>(
      context: context,
      builder: (context) =>
          AprobarViaticoModal(viatico: viatico, esAprobacion: true),
    );
  }

  /// Rechazar viático
  void _rechazarViatico(Viatico viatico) {
    showDialog<void>(
      context: context,
      builder: (context) =>
          AprobarViaticoModal(viatico: viatico, esAprobacion: false),
    );
  }

  /// Eliminar viático
  void _eliminarViatico(Viatico viatico) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar viático?'),
        content: Text(
          '¿Está seguro de eliminar el viático de ${viatico.usuarioNombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(viaticoListNotifierProvider.notifier)
                  .eliminarViatico(viatico.id);
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Viático eliminado'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Formatear moneda
  String _formatCurrency(double value) =>
      '\$${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  /// Formatear fecha
  String _formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date);
}

/// Sheet de detalle de viático
class _ViaticoDetailSheet extends StatelessWidget {
  const _ViaticoDetailSheet({required this.viatico});
  final Viatico viatico;

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.7,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    builder: (context, scrollController) => DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Contenido
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Título
                const Text(
                  'Detalle del Viático',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                // Información general
                _buildDetailRow('Estado', _getEstadoText(viatico.estado)),
                _buildDetailRow(
                  'Tipo',
                  viatico.tipo == TipoViatico.automatico
                      ? 'Automático'
                      : 'Manual',
                ),
                _buildDetailRow('Usuario', viatico.usuarioNombre),
                _buildDetailRow('Concepto', viatico.concepto),
                if (viatico.ordenId != null)
                  _buildDetailRow('Orden', viatico.ordenId!),
                if (viatico.distanciaKm != null)
                  _buildDetailRow(
                    'Distancia',
                    '${viatico.distanciaKm!.toStringAsFixed(1)} km',
                  ),
                _buildDetailRow('Monto', _formatCurrency(viatico.monto)),
                _buildDetailRow(
                  'Fecha Creación',
                  _formatDate(viatico.fechaCreado),
                ),
                if (viatico.fechaAprobado != null) ...[
                  _buildDetailRow(
                    'Fecha ${viatico.estado == EstadoViatico.aprobado ? "Aprobación" : "Rechazo"}',
                    _formatDate(viatico.fechaAprobado!),
                  ),
                  if (viatico.aprobadoPor != null)
                    _buildDetailRow('Aprobado por', viatico.aprobadoPor!),
                  if (viatico.observaciones != null)
                    _buildDetailRow('Observaciones', viatico.observaciones!),
                ],
                if (viatico.evidenciaUrl != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Evidencia',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Imagen de evidencia',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildDetailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  String _getEstadoText(EstadoViatico estado) {
    switch (estado) {
      case EstadoViatico.pendiente:
        return 'Pendiente';
      case EstadoViatico.aprobado:
        return 'Aprobado';
      case EstadoViatico.rechazado:
        return 'Rechazado';
    }
  }

  String _formatCurrency(double value) =>
      '\$${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String _formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date);
}
