import 'package:dartz/dartz.dart' as dartz;

import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../core/errors/failures.dart';

/// Caso de uso para eliminar una tarea
/// Encapsula la lógica de negocio para eliminar tareas
class DeleteTask {
  final ITaskRepository _repository;

  DeleteTask(this._repository);

  /// Ejecutar el caso de uso para eliminar una tarea por ID
  /// [id] - ID de la tarea a eliminar
  Future<dartz.Either<Failure, bool>> call(int id) async {
    // Validaciones de negocio
    if (id <= 0) {
      return dartz.Left(
        const ValidationFailure(
          message: 'El ID de la tarea debe ser mayor a 0',
          code: 'INVALID_ID',
        ),
      );
    }

    // Verificar que la tarea existe antes de eliminar
    final existsResult = await _repository.taskExists(id);

    return existsResult.fold((failure) => dartz.Left(failure), (exists) async {
      if (!exists) {
        return dartz.Left(
          const NotFoundFailure(
            message: 'No se encontró la tarea para eliminar',
            code: 'TASK_NOT_FOUND',
          ),
        );
      }

      // Delegar al repositorio
      return await _repository.deleteTask(id);
    });
  }

  /// Ejecutar el caso de uso para eliminar una tarea (versión con entidad)
  /// [task] - Tarea a eliminar
  Future<dartz.Either<Failure, bool>> callWithTask(Task task) async {
    return await call(task.id);
  }
}

/// Caso de uso para eliminar todas las tareas completadas
class DeleteCompletedTasks {
  final ITaskRepository _repository;

  DeleteCompletedTasks(this._repository);

  /// Ejecutar el caso de uso para eliminar todas las tareas completadas
  Future<dartz.Either<Failure, int>> call() async {
    // Obtener tareas completadas para verificar si hay alguna
    final completedTasksResult = await _repository.getCompletedTasks();

    return completedTasksResult.fold((failure) => dartz.Left(failure), (
      completedTasks,
    ) async {
      if (completedTasks.isEmpty) {
        return dartz.Right(0); // No hay tareas completadas para eliminar
      }

      // Delegar al repositorio
      return await _repository.deleteCompletedTasks();
    });
  }
}

/// Caso de uso para eliminar todas las tareas
class DeleteAllTasks {
  final ITaskRepository _repository;

  DeleteAllTasks(this._repository);

  /// Ejecutar el caso de uso para eliminar todas las tareas
  /// [confirm] - Confirmación requerida para evitar eliminaciones accidentales
  Future<dartz.Either<Failure, int>> call({bool confirm = false}) async {
    if (!confirm) {
      return dartz.Left(
        const ValidationFailure(
          message: 'Se requiere confirmación para eliminar todas las tareas',
          code: 'CONFIRMATION_REQUIRED',
        ),
      );
    }

    // Obtener todas las tareas para verificar si hay alguna
    final allTasksResult = await _repository.getAllTasks();

    return allTasksResult.fold((failure) => dartz.Left(failure), (
      allTasks,
    ) async {
      if (allTasks.isEmpty) {
        return dartz.Right(0); // No hay tareas para eliminar
      }

      // Delegar al repositorio
      return await _repository.deleteAllTasks();
    });
  }
}

/// Caso de uso para eliminar tareas por criterios específicos
class DeleteTasksByCriteria {
  final ITaskRepository _repository;

  DeleteTasksByCriteria(this._repository);

  /// Ejecutar el caso de uso para eliminar tareas que coincidan con un criterio
  /// [criteria] - Criterio de búsqueda para las tareas a eliminar
  /// [confirm] - Confirmación requerida
  Future<dartz.Either<Failure, int>> call({
    required TaskCriteria criteria,
    bool confirm = false,
  }) async {
    if (!confirm) {
      return dartz.Left(
        const ValidationFailure(
          message: 'Se requiere confirmación para eliminar tareas',
          code: 'CONFIRMATION_REQUIRED',
        ),
      );
    }

    // Obtener tareas que coincidan con el criterio
    final tasksResult = await _getTasksByCriteria(criteria);

    return tasksResult.fold((failure) => dartz.Left(failure), (
      tasksToDelete,
    ) async {
      if (tasksToDelete.isEmpty) {
        return dartz.Right(0); // No hay tareas que coincidan
      }

      // Eliminar cada tarea individualmente
      int deletedCount = 0;
      for (final task in tasksToDelete) {
        final deleteResult = await _repository.deleteTask(task.id);
        deleteResult.fold(
          (failure) => {}, // Ignorar errores individuales
          (success) => deletedCount++,
        );
      }

      return dartz.Right(deletedCount);
    });
  }

  /// Obtener tareas según criterios
  Future<dartz.Either<Failure, List<Task>>> _getTasksByCriteria(
    TaskCriteria criteria,
  ) async {
    switch (criteria.type) {
      case TaskCriteriaType.completed:
        return await _repository.getCompletedTasks();
      case TaskCriteriaType.pending:
        return await _repository.getPendingTasks();
      case TaskCriteriaType.titleContains:
        return await _repository.searchTasksByTitle(criteria.value);
      case TaskCriteriaType.olderThan:
        final allTasksResult = await _repository.getAllTasks();
        return allTasksResult.fold((failure) => dartz.Left(failure), (
          allTasks,
        ) {
          final cutoffDate = DateTime.now().subtract(
            Duration(days: criteria.days!),
          );
          final filteredTasks = allTasks
              .where((task) => task.createdAt.isBefore(cutoffDate))
              .toList();
          return dartz.Right(filteredTasks);
        });
    }
  }
}

/// Criterio para seleccionar tareas a eliminar
class TaskCriteria {
  final TaskCriteriaType type;
  final String value;
  final int? days;

  const TaskCriteria({required this.type, required this.value, this.days});

  /// Crear criterio para tareas completadas
  static TaskCriteria completed() =>
      const TaskCriteria(type: TaskCriteriaType.completed, value: 'completed');

  /// Crear criterio para tareas pendientes
  static TaskCriteria pending() =>
      const TaskCriteria(type: TaskCriteriaType.pending, value: 'pending');

  /// Crear criterio para tareas que contengan texto en el título
  static TaskCriteria titleContains(String text) =>
      TaskCriteria(type: TaskCriteriaType.titleContains, value: text);

  /// Crear criterio para tareas más antiguas que X días
  static TaskCriteria olderThan(int days) => TaskCriteria(
    type: TaskCriteriaType.olderThan,
    value: 'older_than',
    days: days,
  );
}

/// Tipos de criterios para seleccionar tareas
enum TaskCriteriaType { completed, pending, titleContains, olderThan }
