import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/client_notifier.dart';
import '../../domain/entities/client.dart';

/// Modal para búsqueda y selección de clientes
class BusquedaClientesModal extends ConsumerStatefulWidget {
  const BusquedaClientesModal({super.key});

  @override
  ConsumerState<BusquedaClientesModal> createState() =>
      _BusquedaClientesModalState();
}

class _BusquedaClientesModalState
    extends ConsumerState<BusquedaClientesModal> {
  final _searchController = TextEditingController();
  Client? _selectedClient;
  Timer? _debounceTimer;
  final ScrollController _scrollController = ScrollController();
  ClientListState? _clientState;

  @override
  void initState() {
    super.initState();
    // Cargar clientes al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(clientListNotifierProvider);
      // Escuchar cambios en el notifier
      notifier.addListener(_onNotifierChanged);
      // Cargar estado inicial
      _clientState = notifier.state;
      // Cargar clientes
      notifier.loadClients();
    });

    // Scroll infinito: cargar más cuando se llega al final
    _scrollController.addListener(_onScroll);
  }

  void _onNotifierChanged() {
    if (mounted) {
      final notifier = ref.read(clientListNotifierProvider);
      final newState = notifier.state;
      debugPrint('🔄 BusquedaClientesModal: Estado actualizado - ${newState.clients.length} clientes, Página: ${newState.currentPage}, Total: ${newState.total}, hasMore: ${newState.hasMore}');
      setState(() {
        _clientState = newState;
      });
      // Scroll al inicio cuando cambia la página
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _onScroll() {
    // Removido el infinite scroll - ahora usamos paginación manual con botones
  }

  /// Calcula el rango de registros mostrados en la página actual
  String _getPageRange(ClientListState clientState) {
    if (clientState.clients.isEmpty) {
      return 'Sin registros';
    }
    
    final pageSize = clientState.pageSize;
    final currentPage = clientState.currentPage;
    final total = clientState.total;
    
    // Calcular el inicio del rango
    final start = ((currentPage - 1) * pageSize) + 1;
    
    // Calcular el fin del rango
    final end = (currentPage * pageSize) > total 
        ? total 
        : (currentPage * pageSize);
    
    return '$start - $end de $total';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    // Remover listener del notifier
    final notifier = ref.read(clientListNotifierProvider);
    notifier.removeListener(_onNotifierChanged);
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Debounce: esperar 500ms antes de buscar
    _debounceTimer?.cancel();
    
    // Solo buscar si tiene mínimo 3 caracteres o está vacío (para mostrar todos)
    if (query.isEmpty || query.length >= 3) {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        final notifier = ref.read(clientListNotifierProvider);
        // Siempre usar searchClients, incluso cuando está vacío, para enviar search vacío al endpoint
        notifier.searchClients(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar el estado local que se actualiza con el listener
    final clientState = _clientState ?? const ClientListState();
    
    // Debug: mostrar información del estado
    debugPrint('📊 Build - Clientes: ${clientState.clients.length}, Página: ${clientState.currentPage}, Total: ${clientState.total}, hasMore: ${clientState.hasMore}');

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seleccionar Cliente',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (clientState.total > 0)
                          Text(
                            'Total: ${clientState.total} | Página: ${clientState.currentPage}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar por NIT o nombre',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            final notifier = ref.read(clientListNotifierProvider);
                            // Ejecutar búsqueda con string vacío para enviar search vacío al endpoint
                            notifier.searchClients('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Tabla de clientes
            Expanded(
              child: _buildClientList(clientState),
            ),

            // Footer con paginación y botones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                children: [
                  // Controles de paginación
                  if (clientState.total > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: clientState.currentPage > 1 &&
                                  !clientState.isLoadingMore
                              ? () {
                                  final notifier =
                                      ref.read(clientListNotifierProvider);
                                  notifier.loadPreviousPage();
                                  _scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              : null,
                          tooltip: 'Página anterior',
                        ),
                        Text(
                          _getPageRange(clientState),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: clientState.hasMore &&
                                  !clientState.isLoadingMore
                              ? () {
                                  final notifier =
                                      ref.read(clientListNotifierProvider);
                                  notifier.loadNextPage();
                                }
                              : null,
                          tooltip: 'Página siguiente',
                        ),
                      ],
                    ),
                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _selectedClient == null
                            ? null
                            : () {
                                Navigator.pop(context, _selectedClient);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Seleccionar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientList(ClientListState clientState) {
    if (clientState.isLoading && clientState.clients.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (clientState.error != null && clientState.clients.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error al cargar clientes',
              style: TextStyle(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              clientState.error!.message,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final notifier = ref.read(clientListNotifierProvider);
                notifier.refresh();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (clientState.clients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          'No se encontraron clientes',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Header de la tabla
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'NIT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Nombre / Razón Social',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Filas de la tabla
            ...List.generate(clientState.clients.length, (index) {
              final client = clientState.clients[index];
              final isSelected = _selectedClient?.id == client.id;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedClient = client;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue[100]
                        : (index % 2 == 0 ? Colors.white : Colors.grey[50]),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          client.nit,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          client.fullName,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // Indicador de carga más
            if (clientState.isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
