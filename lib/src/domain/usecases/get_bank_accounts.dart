import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/bank_account.dart';
import '../repositories/bank_account_repository.dart';

/// Caso de uso para obtener todas las cuentas bancarias
class GetBankAccounts {
  final IBankAccountRepository repository;

  GetBankAccounts(this.repository);

  /// Ejecuta el caso de uso para obtener todas las cuentas bancarias
  Future<Either<Failure, List<BankAccount>>> call() async {
    return await repository.getBankAccounts();
  }
}

