import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../repositories/client_repository.dart';

/// Caso de uso para obtener clientes con paginación
class GetClients {
  final IClientRepository repository;

  GetClients(this.repository);

  /// Ejecuta el caso de uso para obtener clientes
  Future<Either<Failure, PaginatedClients>> call({
    int page = 1,
    int pageSize = 100, // Por defecto cargar 100 registros por página
    String? search,
  }) async {
    return await repository.getClients(
      page: page,
      pageSize: pageSize,
      search: search,
    );
  }
}

