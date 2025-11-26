import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/company.dart';

/// Notifier para manejar el estado de las compañías usando AsyncNotifier
class CompanyListNotifier extends AsyncNotifier<List<Company>> {
  @override
  Future<List<Company>> build() async {
    // Cargar compañías al inicializar
    return await _loadCompanies();
  }

  /// Cargar todas las compañías
  Future<List<Company>> _loadCompanies() async {
    final getCompanies = ref.read(getCompaniesProvider);
    final result = await getCompanies.call();

    return result.fold(
      (failure) => throw _mapFailureToException(failure),
      (companies) => companies,
    );
  }

  /// Refrescar la lista de compañías
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadCompanies());
  }

  /// Mapear errores de dominio a excepciones para AsyncValue
  Exception _mapFailureToException(Failure failure) {
    return Exception(ErrorMapper.mapToUserMessage(failure));
  }
}

/// Provider para el notifier de compañías
final companyListNotifierProvider =
    AsyncNotifierProvider<CompanyListNotifier, List<Company>>(() {
  return CompanyListNotifier();
});

