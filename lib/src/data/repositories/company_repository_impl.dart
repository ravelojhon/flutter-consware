import 'package:dartz/dartz.dart';

import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_datasource.dart';

/// Implementación del repositorio de compañías
class CompanyRepositoryImpl implements ICompanyRepository {
  final ICompanyRemoteDataSource remoteDataSource;

  CompanyRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Company>>> getCompanies() async {
    try {
      final companies = await remoteDataSource.getCompanies();
      return Right(companies.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }
}

