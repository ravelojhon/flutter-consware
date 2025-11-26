import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/bank_account.dart';

/// Repositorio de dominio para cuentas bancarias
abstract class IBankAccountRepository {
  /// Obtiene todas las cuentas bancarias
  Future<Either<Failure, List<BankAccount>>> getBankAccounts();
}

