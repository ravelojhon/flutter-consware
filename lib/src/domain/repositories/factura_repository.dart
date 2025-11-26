import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/factura.dart';

/// Modelo para la respuesta paginada de facturas en el dominio
class PaginatedFacturas {
  final List<Factura> facturas;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedFacturas({
    required this.facturas,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });
}

/// Repositorio de dominio para facturas
abstract class IFacturaRepository {
  /// Obtiene las facturas de un tercero con paginación
  Future<Either<Failure, PaginatedFacturas>> getFacturasByTerceroId({
    required int idTercero,
    int page = 1,
    int pageSize = 100,
  });
}

