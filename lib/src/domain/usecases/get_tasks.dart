import 'package:dartz/dartz.dart' as dartz;

import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../core/errors/failures.dart';

/// Caso de uso para obtener todas las tareas
/// Encapsula la lógica de negocio para recuperar tareas del repositorio
class GetTasks {
  final ITaskRepository _repository;

  GetTasks(this._repository);

  /// Ejecutar el caso de uso para obtener todas las tareas
  /// Retorna Either<Failure, List<Task>>
  Future<dartz.Either<Failure, List<Task>>> call() async {
    return await _repository.getAllTasksOrderedByUpdated();
  }
}

/// Caso de uso para obtener tareas completadas
class GetCompletedTasks {
  final ITaskRepository _repository;

  GetCompletedTasks(this._repository);

  /// Ejecutar el caso de uso para obtener tareas completadas
  Future<dartz.Either<Failure, List<Task>>> call() async {
    return await _repository.getCompletedTasks();
  }
}

/// Caso de uso para obtener tareas pendientes
class GetPendingTasks {
  final ITaskRepository _repository;

  GetPendingTasks(this._repository);

  /// Ejecutar el caso de uso para obtener tareas pendientes
  Future<dartz.Either<Failure, List<Task>>> call() async {
    return await _repository.getPendingTasks();
  }
}

/// Caso de uso para obtener una tarea por ID
class GetTaskById {
  final ITaskRepository _repository;

  GetTaskById(this._repository);

  /// Ejecutar el caso de uso para obtener una tarea por ID
  /// [id] - ID de la tarea a buscar
  Future<dartz.Either<Failure, Task?>> call(int id) async {
    if (id <= 0) {
      return dartz.Left(
        const ValidationFailure(
          message: 'El ID debe ser mayor a 0',
          code: 'INVALID_ID',
        ),
      );
    }

    return await _repository.getTaskById(id);
  }
}

/// Caso de uso para buscar tareas por título
class SearchTasks {
  final ITaskRepository _repository;

  SearchTasks(this._repository);

  /// Ejecutar el caso de uso para buscar tareas por título
  /// [query] - Texto de búsqueda
  Future<dartz.Either<Failure, List<Task>>> call(String query) async {
    if (query.trim().isEmpty) {
      return dartz.Left(
        const ValidationFailure(
          message: 'La consulta de búsqueda no puede estar vacía',
          code: 'EMPTY_SEARCH_QUERY',
        ),
      );
    }

    return await _repository.searchTasksByTitle(query);
  }
}
