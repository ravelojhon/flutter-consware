import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/errors/server_exception.dart';
import '../models/client_model.dart';

/// Fuente de datos remota para clientes
abstract class IClientRemoteDataSource {
  /// Obtiene los clientes desde la API con paginación
  Future<PaginatedClientsResponse> getClients({
    int page = 1,
    int pageSize = 100, // Por defecto cargar 100 registros por página
    String? search,
  });
}

/// Implementación de la fuente de datos remota para clientes
class ClientRemoteDataSource implements IClientRemoteDataSource {
  final http.Client client;

  ClientRemoteDataSource({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<PaginatedClientsResponse> getClients({
    int page = 1,
    int pageSize = 100, // Por defecto cargar 100 registros por página
    String? search,
  }) async {
    try {
      // Construir la URL con parámetros de paginación
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(), // Usar pageSize en lugar de limit
      };
      
      // Incluir search siempre, incluso si está vacío
      if (search != null) {
        queryParams['search'] = search;
      }
      
      final uri = Uri.parse('${AppConfig.baseUrl}/api/clients').replace(
        queryParameters: queryParams,
      );
      
      // Debug: imprimir la URL que se está intentando
      print('🔗 Intentando conectar a: $uri');
      
      final response = await client
          .get(uri)
          .timeout(
            Duration(seconds: AppConfig.httpTimeout),
            onTimeout: () {
              throw ServerException(
                'Tiempo de espera agotado. Verifica que la API esté corriendo en ${AppConfig.baseUrl}',
              );
            },
          );

      print('📡 Respuesta recibida: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final dynamic decodedBody = json.decode(response.body);
          
          // Si la respuesta es una lista directamente
          if (decodedBody is List) {
            final clients = decodedBody
                .map((json) => ClientModel.fromJson(json as Map<String, dynamic>))
                .toList();
            print('✅ Clientes cargados: ${clients.length}');
            return PaginatedClientsResponse(
              clients: clients,
              total: clients.length,
              page: page,
              pageSize: pageSize,
              hasMore: clients.length >= pageSize,
            );
          } 
          // Si es un objeto con estructura de paginación
          else if (decodedBody is Map<String, dynamic>) {
            final response = PaginatedClientsResponse.fromJson(
              decodedBody,
              page,
              pageSize,
            );
            print('✅ Clientes cargados: ${response.clients.length} (Total: ${response.total}, Página: $page)');
            return response;
          }
          
          throw ServerException('Formato de respuesta inesperado de la API');
        } catch (e) {
          if (e is ServerException) rethrow;
          throw ServerException('Error al parsear la respuesta JSON: ${e.toString()}');
        }
      } else {
        throw ServerException(
          'Error del servidor (${response.statusCode}): ${response.body.isNotEmpty ? response.body.substring(0, response.body.length > 100 ? 100 : response.body.length) : "Sin detalles"}',
          response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on http.ClientException catch (e) {
      print('❌ Error de conexión: ${e.message}');
      throw ServerException(
        'No se pudo conectar al servidor. Verifica:\n'
        '1. Que la API esté corriendo en ${AppConfig.baseUrl}\n'
        '2. Que tu dispositivo/emulador tenga acceso a la red\n'
        '3. Que la IP configurada sea correcta\n'
        'Error: ${e.message}',
      );
    } on FormatException catch (e) {
      throw ServerException('Error al procesar la respuesta: ${e.message}');
    } catch (e) {
      print('❌ Error inesperado: $e');
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }
}

