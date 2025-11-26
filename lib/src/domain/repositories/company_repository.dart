import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/company.dart';

/// Repositorio de dominio para compañías
abstract class ICompanyRepository {
  /// Obtiene todas las compañías
  Future<Either<Failure, List<Company>>> getCompanies();
}

