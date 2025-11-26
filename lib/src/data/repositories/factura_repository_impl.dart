import 'package:dartz/dartz.dart';

import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/factura.dart';
import '../../domain/repositories/factura_repository.dart';
import '../datasources/factura_remote_datasource.dart';

/// Implementación del repositorio de facturas
class FacturaRepositoryImpl implements IFacturaRepository {
  final IFacturaRemoteDataSource remoteDataSource;

  FacturaRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PaginatedFacturas>> getFacturasByTerceroId({
    required int idTercero,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final response = await remoteDataSource.getFacturasByTerceroId(
        idTercero: idTercero,
        page: page,
        pageSize: pageSize,
      );
      
      final paginatedFacturas = PaginatedFacturas(
        facturas: response.facturas.map((model) => model.toEntity()).toList(),
        total: response.total,
        page: response.page,
        pageSize: response.pageSize,
        hasMore: response.hasMore,
      );
      
      return Right(paginatedFacturas);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }
}

