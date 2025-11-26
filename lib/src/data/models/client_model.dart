import '../../domain/entities/client.dart';

/// Modelo de datos que representa un cliente desde la API
class ClientModel extends Client {
  const ClientModel({
    required super.id,
    required super.nit,
    required super.razonSocial,
    required super.nombre,
    super.email,
    super.celular,
    super.direccion1,
  });

  /// Crea un ClientModel desde un JSON
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['f9740_id'] as int? ?? 0,
      nit: (json['f9740_nit'] as String?)?.trim() ?? '',
      razonSocial: (json['f9740_razon_social'] as String?)?.trim() ?? '',
      nombre: (json['f9740_nombre'] as String?)?.trim() ?? '',
      email: (json['f9740_email'] as String?)?.trim(),
      celular: (json['f9740_celular'] as String?)?.trim(),
      direccion1: (json['f9740_direccion1'] as String?)?.trim(),
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'f9740_id': id,
      'f9740_nit': nit,
      'f9740_razon_social': razonSocial,
      'f9740_nombre': nombre,
      'f9740_email': email,
      'f9740_celular': celular,
      'f9740_direccion1': direccion1,
    };
  }

  /// Convierte el modelo a entidad de dominio
  Client toEntity() {
    return Client(
      id: id,
      nit: nit,
      razonSocial: razonSocial,
      nombre: nombre,
      email: email,
      celular: celular,
      direccion1: direccion1,
    );
  }
}

/// Modelo para la respuesta paginada de clientes
class PaginatedClientsResponse {
  final List<ClientModel> clients;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedClientsResponse({
    required this.clients,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  /// Crea un PaginatedClientsResponse desde un JSON
  factory PaginatedClientsResponse.fromJson(
    Map<String, dynamic> json,
    int currentPage,
    int currentPageSize,
  ) {
    List<dynamic> clientsList = [];
    
    // Intentar obtener la lista de clientes de diferentes formas
    if (json['data'] is List) {
      clientsList = json['data'] as List<dynamic>;
    } else if (json['clients'] is List) {
      clientsList = json['clients'] as List<dynamic>;
    }
    
    final clients = clientsList
        .map((json) => ClientModel.fromJson(json as Map<String, dynamic>))
        .toList();

    // Obtener información de paginación del objeto pagination si existe
    final pagination = json['pagination'] as Map<String, dynamic>?;
    final total = pagination?['total'] as int? ?? 
                  json['total'] as int? ?? 
                  json['count'] as int? ?? 
                  clients.length;
    
    // Obtener totalPages del objeto pagination
    final totalPages = pagination?['totalPages'] as int?;
    final hasMore = totalPages != null 
        ? (currentPage < totalPages)
        : (json['hasMore'] as bool? ??
           json['has_more'] as bool? ??
           (clients.length >= currentPageSize));

    return PaginatedClientsResponse(
      clients: clients,
      total: total,
      page: currentPage,
      pageSize: currentPageSize,
      hasMore: hasMore,
    );
  }
}

