import 'package:flutter/material.dart';

import 'failures.dart';
import 'server_exception.dart';

/// Mapeador de errores que convierte excepciones técnicas en mensajes amigables para el usuario
class ErrorMapper {
  /// Mapear cualquier error a un mensaje amigable para el usuario
  static String mapToUserMessage(dynamic error) {
    if (error is Failure) {
      return _mapFailureToMessage(error);
    }

    if (error is Exception) {
      return _mapExceptionToMessage(error);
    }

    if (error is String) {
      return error;
    }

    // Error genérico para casos no manejados
    return 'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.';
  }

  /// Mapear tipos de fallo específicos a mensajes
  static String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Error de conexión. Verifica tu conexión a internet e inténtalo de nuevo.';
      case DatabaseFailure:
        return 'Error de base de datos. Los datos podrían estar corruptos.';
      case ValidationFailure:
        return failure.message; // Los mensajes de validación ya son amigables
      case NetworkFailure:
        return 'Sin conexión a internet. Verifica tu conexión e inténtalo de nuevo.';
      case CacheFailure:
        return 'Error al acceder a los datos almacenados. Intenta reiniciar la aplicación.';
      case TimeoutFailure:
        return 'La operación tardó demasiado. Inténtalo de nuevo.';
      default:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Ha ocurrido un error inesperado.';
    }
  }

  /// Mapear excepciones comunes a mensajes amigables
  static String _mapExceptionToMessage(Exception exception) {
    final message = exception.toString().toLowerCase();

    if (message.contains('database') || message.contains('sqlite')) {
      return 'Error de base de datos. Los datos podrían estar corruptos.';
    }

    if (message.contains('network') || message.contains('connection')) {
      return 'Error de conexión. Verifica tu conexión a internet.';
    }

    if (message.contains('timeout')) {
      return 'La operación tardó demasiado. Inténtalo de nuevo.';
    }

    if (message.contains('permission') || message.contains('access')) {
      return 'No tienes permisos para realizar esta acción.';
    }

    if (message.contains('not found') || message.contains('no existe')) {
      return 'El elemento solicitado no existe.';
    }

    if (message.contains('already exists') || message.contains('ya existe')) {
      return 'Este elemento ya existe.';
    }

    // Mensaje genérico para excepciones no reconocidas
    return 'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.';
  }

  /// Obtener un ícono apropiado para el tipo de error
  static IconData getErrorIcon(dynamic error) {
    if (error is Failure) {
      switch (error.runtimeType) {
        case ServerFailure:
        case NetworkFailure:
          return Icons.wifi_off;
        case DatabaseFailure:
          return Icons.storage;
        case ValidationFailure:
          return Icons.warning;
        case CacheFailure:
          return Icons.cached;
        case TimeoutFailure:
          return Icons.timer_off;
        default:
          return Icons.error_outline;
      }
    }

    final message = error.toString().toLowerCase();
    if (message.contains('network') || message.contains('connection')) {
      return Icons.wifi_off;
    }
    if (message.contains('database')) {
      return Icons.storage;
    }
    if (message.contains('timeout')) {
      return Icons.timer_off;
    }

    return Icons.error_outline;
  }

  /// Obtener un color apropiado para el tipo de error
  static Color getErrorColor(dynamic error) {
    if (error is ValidationFailure) {
      return Colors.orange;
    }
    if (error is NetworkFailure || error is TimeoutFailure) {
      return Colors.blue;
    }
    if (error is DatabaseFailure || error is ServerFailure) {
      return Colors.red;
    }

    return Colors.red;
  }

  /// Determinar si el error es recuperable (si el usuario puede reintentar)
  static bool isRecoverable(dynamic error) {
    if (error is NetworkFailure ||
        error is TimeoutFailure ||
        error is ServerFailure) {
      return true; // Errores de red son recuperables
    }

    if (error is ValidationFailure) {
      return true; // Errores de validación son recuperables
    }

    if (error is DatabaseFailure || error is CacheFailure) {
      return false; // Errores de base de datos pueden no ser recuperables
    }

    // Para errores desconocidos, asumir que son recuperables
    return true;
  }

  /// Mapear excepciones a Failure
  static Failure mapExceptionToFailure(dynamic exception) {
    if (exception is ServerException) {
      if (exception.statusCode != null) {
        if (exception.statusCode == 404) {
          return NotFoundFailure(message: exception.message);
        } else if (exception.statusCode! >= 500) {
          return ServerFailure(message: exception.message);
        } else if (exception.statusCode! >= 400) {
          return ValidationFailure(message: exception.message);
        }
      }
      return ServerFailure(message: exception.message);
    }

    final message = exception.toString().toLowerCase();
    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('socket')) {
      return NetworkFailure(message: exception.toString());
    }

    if (message.contains('timeout')) {
      return TimeoutFailure(message: exception.toString());
    }

    return ServerFailure(message: exception.toString());
  }
}
