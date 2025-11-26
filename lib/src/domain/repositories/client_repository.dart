import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/client.dart';

/// Respuesta paginada de clientes
class PaginatedClients {
  final List<Client> clients;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedClients({
    required this.clients,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });
}

/// Repositorio de dominio para clientes
abstract class IClientRepository {
  /// Obtiene los clientes con paginación
  Future<Either<Failure, PaginatedClients>> getClients({
    int page = 1,
    int pageSize = 100, // Por defecto cargar 100 registros por página
    String? search,
  });
}

