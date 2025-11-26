import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/errors/server_exception.dart';
import '../models/factura_model.dart';

/// Interfaz para la fuente de datos remota de facturas
abstract class IFacturaRemoteDataSource {
  /// Obtiene las facturas de un cliente desde la API con paginación
  Future<PaginatedFacturasResponse> getFacturasByTerceroId({
    required int idTercero,
    int page = 1,
    int pageSize = 100,
  });
}

/// Implementación de la fuente de datos remota para facturas
class FacturaRemoteDataSource implements IFacturaRemoteDataSource {
  FacturaRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();
  final http.Client client;

  @override
  Future<PaginatedFacturasResponse> getFacturasByTerceroId({
    required int idTercero,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      // Construir la URL con los parámetros de paginación
      // El idTercero aquí es el f9740_id del cliente seleccionado
      final uri = Uri.parse('${AppConfig.baseUrl}/api/factura/facturas')
          .replace(
            queryParameters: {
              'id_tercero': idTercero.toString(), // f9740_id del cliente
              'page': page.toString(),
              'pageSize': pageSize.toString(),
            },
          );

      // Debug: imprimir la URL que se está intentando
      debugPrint('🔗 Consultando facturas con id_tercero (f9740_id): $idTercero');
      debugPrint('🔗 URL completa: $uri');

      final response = await client
          .get(uri)
          .timeout(
            const Duration(seconds: AppConfig.httpTimeout),
            onTimeout: () {
              throw ServerException(
                'Tiempo de espera agotado. Verifica que la API esté corriendo en ${AppConfig.baseUrl}',
              );
            },
          );

      debugPrint('📡 Respuesta recibida: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final dynamic decodedBody = json.decode(response.body);

          // La respuesta debe ser un objeto con estructura { success, data, pagination, ... }
          if (decodedBody is Map<String, dynamic>) {
            // Debug: imprimir el JSON recibido para verificar la estructura
            debugPrint('📦 JSON recibido: ${jsonEncode(decodedBody).substring(0, jsonEncode(decodedBody).length > 500 ? 500 : jsonEncode(decodedBody).length)}...');
            
            final paginatedResponse = PaginatedFacturasResponse.fromJson(
              decodedBody,
              page,
              pageSize,
            );

            debugPrint(
              '✅ Facturas cargadas: ${paginatedResponse.facturas.length} (Total: ${paginatedResponse.total}, Página: $page)',
            );
            
            // Debug: imprimir la primera factura para verificar el mapeo
            if (paginatedResponse.facturas.isNotEmpty) {
              final primeraFactura = paginatedResponse.facturas.first;
              debugPrint('📄 Primera factura - Sucursal: ${primeraFactura.sucursal}, Tipo: ${primeraFactura.tipo}, Factura: ${primeraFactura.factura}');
            }
            
            return paginatedResponse;
          } else {
            throw ServerException(
              'Formato de respuesta inesperado: se esperaba un objeto JSON',
            );
          }
        } catch (e) {
          if (e is ServerException) rethrow;
          throw ServerException(
            'Error al parsear la respuesta JSON: ${e.toString()}',
          );
        }
      } else {
        throw ServerException(
          'Error del servidor (${response.statusCode}): ${response.body.isNotEmpty ? response.body.substring(0, response.body.length > 100 ? 100 : response.body.length) : "Sin detalles"}',
          response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Error inesperado al obtener facturas: ${e.toString()}',
      );
    }
  }
}
