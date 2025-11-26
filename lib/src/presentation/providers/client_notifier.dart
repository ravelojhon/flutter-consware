import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/client.dart';
import '../../domain/usecases/get_clients.dart';

/// Estado de la lista de clientes con paginación
class ClientListState {
  final List<Client> clients;
  final int currentPage;
  final int pageSize;
  final int total;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final Failure? error;
  final String? searchQuery;

  const ClientListState({
    this.clients = const [],
    this.currentPage = 1,
    this.pageSize = 100, // Cargar 100 registros por página
    this.total = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.searchQuery,
  });

  ClientListState copyWith({
    List<Client>? clients,
    int? currentPage,
    int? pageSize,
    int? total,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Failure? error,
    String? searchQuery,
    bool clearClients = false,
  }) {
    return ClientListState(
      clients: clearClients ? (clients ?? []) : (clients ?? this.clients),
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier para manejar el estado de los clientes con paginación
class ClientListNotifier extends ChangeNotifier {
  final GetClients getClients;
  ClientListState _state = const ClientListState();

  ClientListNotifier(this.getClients);

  ClientListState get state => _state;

  void _updateState(ClientListState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Cargar la primera página de clientes
  Future<void> loadClients({String? search}) async {
    debugPrint('🔄 ClientListNotifier: Iniciando carga de clientes (page: 1, pageSize: ${_state.pageSize}, search: $search)');
    
    _updateState(_state.copyWith(
      isLoading: true,
      error: null,
      currentPage: 1,
      searchQuery: search,
      clearClients: true,
    ));

    final result = await getClients.call(
      page: 1,
      pageSize: _state.pageSize,
      search: search,
    );

    result.fold(
      (Failure failure) {
        debugPrint('❌ ClientListNotifier: Error al cargar clientes - ${failure.message}');
        _updateState(_state.copyWith(
          isLoading: false,
          error: failure,
        ));
      },
      (paginatedClients) {
        debugPrint('✅ ClientListNotifier: Clientes cargados exitosamente - ${paginatedClients.clients.length} clientes (Total: ${paginatedClients.total})');
        _updateState(_state.copyWith(
          clients: paginatedClients.clients,
          total: paginatedClients.total,
          hasMore: paginatedClients.hasMore,
          isLoading: false,
          error: null,
        ));
      },
    );
  }

  /// Cargar la siguiente página
  Future<void> loadNextPage() async {
    if (_state.isLoadingMore || !_state.hasMore) {
      debugPrint('⚠️ ClientListNotifier: No se puede cargar siguiente página (hasMore: ${_state.hasMore}, isLoadingMore: ${_state.isLoadingMore})');
      return;
    }

    debugPrint('🔄 ClientListNotifier: Cargando siguiente página (de ${_state.currentPage} a ${_state.currentPage + 1})');
    _updateState(_state.copyWith(isLoadingMore: true));

    final nextPage = _state.currentPage + 1;
    final result = await getClients.call(
      page: nextPage,
      pageSize: _state.pageSize,
      search: _state.searchQuery,
    );

    result.fold(
      (Failure failure) {
        debugPrint('❌ ClientListNotifier: Error al cargar siguiente página - ${failure.message}');
        _updateState(_state.copyWith(
          isLoadingMore: false,
          error: failure,
        ));
      },
      (paginatedClients) {
        debugPrint('✅ ClientListNotifier: Siguiente página cargada - ${paginatedClients.clients.length} clientes (Página: $nextPage)');
        // Reemplazar los clientes en lugar de agregarlos (paginación tradicional)
        _updateState(_state.copyWith(
          clients: paginatedClients.clients,
          currentPage: nextPage,
          hasMore: paginatedClients.hasMore,
          isLoadingMore: false,
          error: null,
        ));
      },
    );
  }

  /// Cargar la página anterior
  Future<void> loadPreviousPage() async {
    if (_state.currentPage <= 1 || _state.isLoadingMore) {
      debugPrint('⚠️ ClientListNotifier: No se puede cargar página anterior (currentPage: ${_state.currentPage}, isLoadingMore: ${_state.isLoadingMore})');
      return;
    }

    debugPrint('🔄 ClientListNotifier: Cargando página anterior (de ${_state.currentPage} a ${_state.currentPage - 1})');
    _updateState(_state.copyWith(isLoadingMore: true));

    final previousPage = _state.currentPage - 1;
    final result = await getClients.call(
      page: previousPage,
      pageSize: _state.pageSize,
      search: _state.searchQuery,
    );

    result.fold(
      (Failure failure) {
        debugPrint('❌ ClientListNotifier: Error al cargar página anterior - ${failure.message}');
        _updateState(_state.copyWith(
          isLoadingMore: false,
          error: failure,
        ));
      },
      (paginatedClients) {
        debugPrint('✅ ClientListNotifier: Página anterior cargada - ${paginatedClients.clients.length} clientes (Página: $previousPage)');
        _updateState(_state.copyWith(
          clients: paginatedClients.clients,
          currentPage: previousPage,
          hasMore: paginatedClients.hasMore,
          isLoadingMore: false,
          error: null,
        ));
      },
    );
  }

  /// Buscar clientes
  Future<void> searchClients(String query) async {
    // Si está vacío, enviar string vacío para que el endpoint reciba search vacío
    await loadClients(search: query.isEmpty ? '' : query);
  }

  /// Refrescar la lista
  Future<void> refresh() async {
    await loadClients(search: _state.searchQuery);
  }
}

/// Provider para el notifier de clientes
final clientListNotifierProvider = Provider<ClientListNotifier>((ref) {
  final getClients = ref.watch(getClientsProvider);
  final notifier = ClientListNotifier(getClients);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider público para acceder al estado
final clientListStateProvider = Provider<ClientListState>((ref) {
  final notifier = ref.watch(clientListNotifierProvider);
  // Observar cambios en el notifier usando un listener
  ref.listen<ClientListNotifier>(
    clientListNotifierProvider,
    (previous, next) {
      // Forzar actualización cuando el notifier cambia
      ref.invalidateSelf();
    },
  );
  return notifier.state;
});
