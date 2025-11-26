import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/bank_account.dart';

/// Notifier para manejar el estado de las cuentas bancarias usando AsyncNotifier
class BankAccountListNotifier extends AsyncNotifier<List<BankAccount>> {
  @override
  Future<List<BankAccount>> build() async {
    // Cargar cuentas bancarias al inicializar
    return await _loadBankAccounts();
  }

  /// Cargar todas las cuentas bancarias
  Future<List<BankAccount>> _loadBankAccounts() async {
    final getBankAccounts = ref.read(getBankAccountsProvider);
    final result = await getBankAccounts.call();

    return result.fold(
      (failure) => throw _mapFailureToException(failure),
      (accounts) => accounts,
    );
  }

  /// Refrescar la lista de cuentas bancarias
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadBankAccounts());
  }

  /// Mapear errores de dominio a excepciones para AsyncValue
  Exception _mapFailureToException(Failure failure) {
    return Exception(ErrorMapper.mapToUserMessage(failure));
  }
}

/// Provider para el notifier de cuentas bancarias
final bankAccountListNotifierProvider =
    AsyncNotifierProvider<BankAccountListNotifier, List<BankAccount>>(() {
  return BankAccountListNotifier();
});

