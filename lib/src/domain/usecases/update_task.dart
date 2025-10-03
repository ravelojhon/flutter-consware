import 'package:dartz/dartz.dart' as dartz;

import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../core/errors/failures.dart';

/// Caso de uso para actualizar una tarea
/// Encapsula la lógica de negocio para modificar tareas existentes
class UpdateTask {
  final ITaskRepository _repository;

  UpdateTask(this._repository);

  /// Ejecutar el caso de uso para actualizar una tarea completa
  /// [task] - Tarea con los datos actualizados
  Future<dartz.Either<Failure, Task>> call(Task task) async {
    // Validaciones de negocio
    if (task.isNew) {
      return dartz.Left(
        const ValidationFailure(
          message:
              'No se puede actualizar una tarea nueva. Use AddTask en su lugar',
          code: 'CANNOT_UPDATE_NEW_TASK',
        ),
      );
    }

    // Validar datos de la tarea
    final validationResult = _validateTask(task);
    if (validationResult.isLeft()) {
      return validationResult;
    }

    // Delegar al repositorio
    return await _repository.updateTask(task);
  }

  /// Ejecutar el caso de uso para actualizar solo el título de una tarea
  /// [id] - ID de la tarea a actualizar
  /// [newTitle] - Nuevo título para la tarea
  Future<dartz.Either<Failure, Task>> updateTitle(
    int id,
    String newTitle,
  ) async {
    // Validaciones de negocio
    if (id <= 0) {
      return dartz.Left(
        const ValidationFailure(
          message: 'El ID de la tarea debe ser mayor a 0',
          code: 'INVALID_ID',
        ),
      );
    }

    final titleValidation = _validateTitle(newTitle);
    if (titleValidation.isLeft()) {
      return dartz.Left(
        titleValidation.fold(
          (failure) => failure,
          (title) => throw Exception('Unexpected error'),
        ),
      );
    }

    // Delegar al repositorio
    return await _repository.updateTaskTitle(id, newTitle);
  }

  /// Ejecutar el caso de uso para alternar el estado de completado
  /// [id] - ID de la tarea a actualizar
  Future<dartz.Either<Failure, Task>> toggleCompletion(int id) async {
    // Validaciones de negocio
    if (id <= 0) {
      return dartz.Left(
        const ValidationFailure(
          message: 'El ID de la tarea debe ser mayor a 0',
          code: 'INVALID_ID',
        ),
      );
    }

    // Delegar al repositorio
    return await _repository.toggleTaskCompletion(id);
  }

  /// Validar el título de una tarea
  dartz.Either<Failure, String> _validateTitle(String title) {
    if (title.trim().isEmpty) {
      return dartz.Left(
        const ValidationFailure(
          message: 'El título de la tarea no puede estar vacío',
          code: 'EMPTY_TITLE',
        ),
      );
    }

    if (title.length > 255) {
      return dartz.Left(
        const ValidationFailure(
          message: 'El título de la tarea no puede exceder 255 caracteres',
          code: 'TITLE_TOO_LONG',
        ),
      );
    }

    return dartz.Right(title.trim());
  }

  /// Validar una tarea completa
  dartz.Either<Failure, Task> _validateTask(Task task) {
    final titleValidation = _validateTitle(task.title);
    if (titleValidation.isLeft()) {
      return dartz.Left(
        titleValidation.fold(
          (failure) => failure,
          (title) => throw Exception('Unexpected error'),
        ),
      );
    }

    // Validar fechas
    if (task.createdAt.isAfter(DateTime.now())) {
      return dartz.Left(
        const ValidationFailure(
          message: 'La fecha de creación no puede ser futura',
          code: 'INVALID_CREATION_DATE',
        ),
      );
    }

    if (task.updatedAt.isBefore(task.createdAt)) {
      return dartz.Left(
        const ValidationFailure(
          message:
              'La fecha de actualización no puede ser anterior a la creación',
          code: 'INVALID_UPDATE_DATE',
        ),
      );
    }

    return dartz.Right(task);
  }
}

/// Caso de uso para marcar una tarea como completada
class MarkTaskAsCompleted {
  final ITaskRepository _repository;

  MarkTaskAsCompleted(this._repository);

  /// Ejecutar el caso de uso para marcar una tarea como completada
  /// [id] - ID de la tarea a marcar como completada
  Future<dartz.Either<Failure, Task>> call(int id) async {
    if (id <= 0) {
      return dartz.Left(
        const ValidationFailure(
          message: 'El ID de la tarea debe ser mayor a 0',
          code: 'INVALID_ID',
        ),
      );
    }

    // Obtener la tarea actual
    final getTaskResult = await _repository.getTaskById(id);

    return getTaskResult.fold((failure) => dartz.Left(failure), (task) async {
      if (task == null) {
        return dartz.Left(
          const NotFoundFailure(
            message: 'No se encontró la tarea para marcar como completada',
            code: 'TASK_NOT_FOUND',
          ),
        );
      }

      if (task.isCompleted) {
        return dartz.Right(task); // Ya está completada
      }

      // Crear tarea actualizada
      final updatedTask = task.markAsCompleted();
      return await _repository.updateTask(updatedTask);
    });
  }
}

/// Caso de uso para marcar una tarea como pendiente
class MarkTaskAsPending {
  final ITaskRepository _repository;

  MarkTaskAsPending(this._repository);

  /// Ejecutar el caso de uso para marcar una tarea como pendiente
  /// [id] - ID de la tarea a marcar como pendiente
  Future<dartz.Either<Failure, Task>> call(int id) async {
    if (id <= 0) {
      return dartz.Left(
        const ValidationFailure(
          message: 'El ID de la tarea debe ser mayor a 0',
          code: 'INVALID_ID',
        ),
      );
    }

    // Obtener la tarea actual
    final getTaskResult = await _repository.getTaskById(id);

    return getTaskResult.fold((failure) => dartz.Left(failure), (task) async {
      if (task == null) {
        return dartz.Left(
          const NotFoundFailure(
            message: 'No se encontró la tarea para marcar como pendiente',
            code: 'TASK_NOT_FOUND',
          ),
        );
      }

      if (!task.isCompleted) {
        return dartz.Right(task); // Ya está pendiente
      }

      // Crear tarea actualizada
      final updatedTask = task.markAsPending();
      return await _repository.updateTask(updatedTask);
    });
  }
}
