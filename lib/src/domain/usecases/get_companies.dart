import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/company.dart';
import '../repositories/company_repository.dart';

/// Caso de uso para obtener todas las compañías
class GetCompanies {
  final ICompanyRepository repository;

  GetCompanies(this.repository);

  /// Ejecuta el caso de uso para obtener todas las compañías
  Future<Either<Failure, List<Company>>> call() async {
    return await repository.getCompanies();
  }
}

