import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../repositories/factura_repository.dart';

/// Caso de uso para obtener facturas de un tercero con paginación
class GetFacturasByCliente {
  final IFacturaRepository repository;

  GetFacturasByCliente(this.repository);

  /// Ejecuta el caso de uso para obtener facturas
  Future<Either<Failure, PaginatedFacturas>> call({
    required int idTercero,
    int page = 1,
    int pageSize = 100,
  }) async {
    return await repository.getFacturasByTerceroId(
      idTercero: idTercero,
      page: page,
      pageSize: pageSize,
    );
  }
}

