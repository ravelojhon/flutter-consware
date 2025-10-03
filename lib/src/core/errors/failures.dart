import 'package:equatable/equatable.dart';

/// Clase base abstracta para todos los errores de la aplicación
/// Usa Equatable para comparaciones de igualdad
abstract class Failure extends Equatable {
  /// Mensaje descriptivo del error
  final String message;

  /// Código de error opcional
  final String? code;

  /// Stack trace opcional para debugging
  final StackTrace? stackTrace;

  const Failure({required this.message, this.code, this.stackTrace});

  @override
  List<Object?> get props => [message, code, stackTrace];
}

/// Error de servidor/base de datos
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code, super.stackTrace});
}

/// Error de conexión de red
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code, super.stackTrace});
}

/// Error de caché local
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code, super.stackTrace});
}

/// Error de validación de datos
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Error cuando no se encuentra un recurso
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code, super.stackTrace});
}

/// Error cuando ya existe un recurso
class AlreadyExistsFailure extends Failure {
  const AlreadyExistsFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Error de permisos o autorización
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Error de base de datos
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code, super.stackTrace});
}

/// Error de timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message, super.code, super.stackTrace});
}

/// Error genérico no clasificado
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code, super.stackTrace});
}
