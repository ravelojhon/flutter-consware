import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/errors/server_exception.dart';
import '../models/company_model.dart';

/// Fuente de datos remota para compañías
abstract class ICompanyRemoteDataSource {
  /// Obtiene todas las compañías desde la API
  Future<List<CompanyModel>> getCompanies();
}

/// Implementación de la fuente de datos remota para compañías
class CompanyRemoteDataSource implements ICompanyRemoteDataSource {
  final http.Client client;

  CompanyRemoteDataSource({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<List<CompanyModel>> getCompanies() async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/api/companies');
      
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
          
          // Verificar si la respuesta es una lista directamente
          if (decodedBody is List) {
            final companies = decodedBody
                .map((json) => CompanyModel.fromJson(json as Map<String, dynamic>))
                .toList();
            print('✅ Compañías cargadas: ${companies.length}');
            return companies;
          } else if (decodedBody is Map<String, dynamic>) {
            // Si es un objeto, intentar obtener una propiedad 'data' o similar
            if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
              final List<dynamic> jsonList = decodedBody['data'] as List<dynamic>;
              final companies = jsonList
                  .map((json) => CompanyModel.fromJson(json as Map<String, dynamic>))
                  .toList();
              print('✅ Compañías cargadas: ${companies.length}');
              return companies;
            }
          }
          
          throw ServerException('Formato de respuesta inesperado de la API. Se esperaba una lista o un objeto con propiedad "data"');
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

