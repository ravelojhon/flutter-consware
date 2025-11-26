import 'package:dartz/dartz.dart';

import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_datasource.dart';

/// Implementación del repositorio de clientes
class ClientRepositoryImpl implements IClientRepository {
  final IClientRemoteDataSource remoteDataSource;

  ClientRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PaginatedClients>> getClients({
    int page = 1,
    int pageSize = 100, // Por defecto cargar 100 registros por página
    String? search,
  }) async {
    try {
      final response = await remoteDataSource.getClients(
        page: page,
        pageSize: pageSize,
        search: search,
      );
      
      return Right(PaginatedClients(
        clients: response.clients.map((model) => model.toEntity()).toList(),
        total: response.total,
        page: response.page,
        pageSize: response.pageSize,
        hasMore: response.hasMore,
      ));
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }
}

