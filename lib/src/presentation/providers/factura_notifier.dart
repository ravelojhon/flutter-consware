import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/factura.dart';
import '../../domain/usecases/get_facturas_by_cliente.dart';

/// Estado de la lista de facturas con paginación
class FacturaListState {
  final List<Factura> facturas;
  final int currentPage;
  final int pageSize;
  final int total;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final Failure? error;
  final int? idTercero;

  const FacturaListState({
    this.facturas = const [],
    this.currentPage = 1,
    this.pageSize = 100, // Cargar 100 registros por página
    this.total = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.idTercero,
  });

  FacturaListState copyWith({
    List<Factura>? facturas,
    int? currentPage,
    int? pageSize,
    int? total,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Failure? error,
    int? idTercero,
    bool clearFacturas = false,
  }) {
    return FacturaListState(
      facturas: clearFacturas ? (facturas ?? []) : (facturas ?? this.facturas),
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      idTercero: idTercero ?? this.idTercero,
    );
  }
}

/// Notifier para manejar el estado de las facturas con paginación
class FacturaListNotifier extends ChangeNotifier {
  final GetFacturasByCliente getFacturas;
  FacturaListState _state = const FacturaListState();

  FacturaListNotifier(this.getFacturas);

  FacturaListState get state => _state;

  void _updateState(FacturaListState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Cargar la primera página de facturas para un tercero
  Future<void> loadFacturas({required int idTercero}) async {
    debugPrint('🔄 FacturaListNotifier: Iniciando carga de facturas (idTercero: $idTercero, page: 1, pageSize: ${_state.pageSize})');
    
    _updateState(_state.copyWith(
      isLoading: true,
      error: null,
      currentPage: 1,
      idTercero: idTercero,
      clearFacturas: true,
    ));

    final result = await getFacturas.call(
      idTercero: idTercero,
      page: 1,
      pageSize: _state.pageSize,
    );

    result.fold(
      (Failure failure) {
        debugPrint('❌ FacturaListNotifier: Error al cargar facturas - ${failure.message}');
        _updateState(_state.copyWith(
          isLoading: false,
          error: failure,
        ));
      },
      (paginatedFacturas) {
        debugPrint('✅ FacturaListNotifier: Facturas cargadas exitosamente - ${paginatedFacturas.facturas.length} facturas (Total: ${paginatedFacturas.total})');
        _updateState(_state.copyWith(
          facturas: paginatedFacturas.facturas,
          total: paginatedFacturas.total,
          hasMore: paginatedFacturas.hasMore,
          isLoading: false,
          error: null,
        ));
      },
    );
  }

  /// Cargar la siguiente página
  Future<void> loadNextPage() async {
    if (_state.isLoadingMore || !_state.hasMore || _state.idTercero == null) {
      debugPrint('⚠️ FacturaListNotifier: No se puede cargar siguiente página (hasMore: ${_state.hasMore}, isLoadingMore: ${_state.isLoadingMore}, idTercero: ${_state.idTercero})');
      return;
    }

    debugPrint('🔄 FacturaListNotifier: Cargando siguiente página (de ${_state.currentPage} a ${_state.currentPage + 1})');
    _updateState(_state.copyWith(isLoadingMore: true));

    final nextPage = _state.currentPage + 1;
    final result = await getFacturas.call(
      idTercero: _state.idTercero!,
      page: nextPage,
      pageSize: _state.pageSize,
    );

    result.fold(
      (Failure failure) {
        debugPrint('❌ FacturaListNotifier: Error al cargar siguiente página - ${failure.message}');
        _updateState(_state.copyWith(
          isLoadingMore: false,
          error: failure,
        ));
      },
      (paginatedFacturas) {
        debugPrint('✅ FacturaListNotifier: Siguiente página cargada - ${paginatedFacturas.facturas.length} facturas (Página: $nextPage)');
        // Reemplazar las facturas en lugar de agregarlas (paginación tradicional)
        _updateState(_state.copyWith(
          facturas: paginatedFacturas.facturas,
          currentPage: nextPage,
          hasMore: paginatedFacturas.hasMore,
          isLoadingMore: false,
          error: null,
        ));
      },
    );
  }

  /// Cargar la página anterior
  Future<void> loadPreviousPage() async {
    if (_state.currentPage <= 1 || _state.isLoadingMore || _state.idTercero == null) {
      debugPrint('⚠️ FacturaListNotifier: No se puede cargar página anterior (currentPage: ${_state.currentPage}, isLoadingMore: ${_state.isLoadingMore}, idTercero: ${_state.idTercero})');
      return;
    }

    debugPrint('🔄 FacturaListNotifier: Cargando página anterior (de ${_state.currentPage} a ${_state.currentPage - 1})');
    _updateState(_state.copyWith(isLoadingMore: true));

    final previousPage = _state.currentPage - 1;
    final result = await getFacturas.call(
      idTercero: _state.idTercero!,
      page: previousPage,
      pageSize: _state.pageSize,
    );

    result.fold(
      (Failure failure) {
        debugPrint('❌ FacturaListNotifier: Error al cargar página anterior - ${failure.message}');
        _updateState(_state.copyWith(
          isLoadingMore: false,
          error: failure,
        ));
      },
      (paginatedFacturas) {
        debugPrint('✅ FacturaListNotifier: Página anterior cargada - ${paginatedFacturas.facturas.length} facturas (Página: $previousPage)');
        _updateState(_state.copyWith(
          facturas: paginatedFacturas.facturas,
          currentPage: previousPage,
          hasMore: paginatedFacturas.hasMore,
          isLoadingMore: false,
          error: null,
        ));
      },
    );
  }

  /// Refrescar la lista
  Future<void> refresh() async {
    if (_state.idTercero != null) {
      await loadFacturas(idTercero: _state.idTercero!);
    }
  }

  /// Limpiar el estado
  void clear() {
    _updateState(const FacturaListState());
  }
}

/// Provider para el notifier de facturas
final facturaListNotifierProvider = Provider<FacturaListNotifier>((ref) {
  final getFacturas = ref.watch(getFacturasByClienteProvider);
  final notifier = FacturaListNotifier(getFacturas);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Provider público para acceder al estado
/// Este provider devuelve el estado actual del notifier
/// Para que se actualice cuando el notifier notifica cambios, el widget debe
/// escuchar el notifier directamente usando addListener
final facturaListStateProvider = Provider<FacturaListState>((ref) {
  final notifier = ref.watch(facturaListNotifierProvider);
  return notifier.state;
});

