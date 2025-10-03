import 'package:dartz/dartz.dart' as dartz;

import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../core/errors/failures.dart';

/// Caso de uso para agregar una nueva tarea
/// Encapsula la lógica de negocio para crear tareas
class AddTask {
  final ITaskRepository _repository;

  AddTask(this._repository);

  /// Ejecutar el caso de uso para agregar una nueva tarea
  /// [title] - Título de la tarea a crear
  /// [description] - Descripción de la tarea (opcional)
  /// [isCompleted] - Estado inicial de la tarea (opcional, por defecto false)
  Future<dartz.Either<Failure, Task>> call({
    required String title,
    String? description,
    bool isCompleted = false,
  }) async {
    // Validaciones de negocio
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

    // Crear la entidad Task
    final task = Task.create(
      title: title.trim(),
      description: description?.trim(),
      isCompleted: isCompleted,
    );

    // Delegar al repositorio
    return await _repository.createTask(task);
  }

  /// Ejecutar el caso de uso para agregar una nueva tarea con solo el título
  /// [title] - Título de la tarea a crear
  Future<dartz.Either<Failure, Task>> callWithTitle(String title) async {
    return await call(title: title);
  }
}

/// Caso de uso para agregar múltiples tareas
class AddMultipleTasks {
  final ITaskRepository _repository;

  AddMultipleTasks(this._repository);

  /// Ejecutar el caso de uso para agregar múltiples tareas
  /// [titles] - Lista de títulos de tareas a crear
  Future<dartz.Either<Failure, List<Task>>> call(List<String> titles) async {
    if (titles.isEmpty) {
      return dartz.Left(
        const ValidationFailure(
          message: 'La lista de tareas no puede estar vacía',
          code: 'EMPTY_TASK_LIST',
        ),
      );
    }

    final List<Task> createdTasks = [];
    final List<Failure> failures = [];

    // Procesar cada título
    for (final title in titles) {
      final result = await AddTask(_repository).call(title: title);

      result.fold(
        (failure) => failures.add(failure),
        (task) => createdTasks.add(task),
      );
    }

    // Si hay errores, retornar el primero
    if (failures.isNotEmpty) {
      return dartz.Left(failures.first);
    }

    return dartz.Right(createdTasks);
  }
}

/// Caso de uso para validar datos de una tarea antes de crearla
class ValidateTaskData {
  /// Validar el título de una tarea
  /// [title] - Título a validar
  static dartz.Either<Failure, String> validateTitle(String title) {
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

  /// Validar una entidad Task completa
  /// [task] - Tarea a validar
  static dartz.Either<Failure, Task> validateTask(Task task) {
    final titleValidation = validateTitle(task.title);

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
