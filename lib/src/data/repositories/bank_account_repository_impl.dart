import 'package:dartz/dartz.dart';

import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/repositories/bank_account_repository.dart';
import '../datasources/bank_account_remote_datasource.dart';

/// Implementación del repositorio de cuentas bancarias
class BankAccountRepositoryImpl implements IBankAccountRepository {
  final IBankAccountRemoteDataSource remoteDataSource;

  BankAccountRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<BankAccount>>> getBankAccounts() async {
    try {
      final accounts = await remoteDataSource.getBankAccounts();
      return Right(accounts.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }
}

