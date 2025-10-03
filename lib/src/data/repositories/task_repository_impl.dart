import 'package:dartz/dartz.dart' as dartz;

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../core/errors/failures.dart';
import '../local/todo_database.dart';
import '../local/task_mapper.dart';

/// Implementación del repositorio de tareas
/// Maneja errores de base de datos y los convierte a errores de dominio
class TaskRepositoryImpl implements ITaskRepository {
  final TodoDatabase _database;

  TaskRepositoryImpl(this._database);

  @override
  Future<dartz.Either<Failure, List<Task>>> getAllTasks() async {
    try {
      final tasks = await _database.tasksDao.getAllTasks();
      return dartz.Right(tasks);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, List<Task>>>
  getAllTasksOrderedByUpdated() async {
    try {
      final tasks = await _database.tasksDao.getAllTasksOrderedByUpdated();
      return dartz.Right(tasks);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, List<Task>>> getCompletedTasks() async {
    try {
      final tasks = await _database.tasksDao.getCompletedTasks();
      return dartz.Right(tasks);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, List<Task>>> getPendingTasks() async {
    try {
      final tasks = await _database.tasksDao.getPendingTasks();
      return dartz.Right(tasks);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, Task?>> getTaskById(int id) async {
    try {
      if (id <= 0) {
        return dartz.Left(
          const ValidationFailure(
            message: 'El ID de la tarea debe ser mayor a 0',
            code: 'INVALID_ID',
          ),
        );
      }

      final task = await _database.tasksDao.getTaskById(id);
      return dartz.Right(task);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, Task>> createTask(Task task) async {
    try {
      if (!TaskMapper.isValidTask(task)) {
        return dartz.Left(
          const ValidationFailure(
            message: 'Los datos de la tarea no son válidos',
            code: 'INVALID_TASK_DATA',
          ),
        );
      }

      final taskId = await _database.tasksDao.insertTask(task);
      final createdTask = task.copyWith(id: taskId);
      return dartz.Right(createdTask);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, Task>> createTaskWithTitle(String title) async {
    try {
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

      final taskId = await _database.tasksDao.insertTaskFromTitle(title);
      final createdTask = Task.create(title: title).copyWith(id: taskId);
      return dartz.Right(createdTask);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, Task>> updateTask(Task task) async {
    try {
      if (!TaskMapper.isValidTask(task)) {
        return dartz.Left(
          const ValidationFailure(
            message: 'Los datos de la tarea no son válidos',
            code: 'INVALID_TASK_DATA',
          ),
        );
      }

      if (task.isNew) {
        return dartz.Left(
          const ValidationFailure(
            message:
                'No se puede actualizar una tarea nueva. Use createTask en su lugar',
            code: 'CANNOT_UPDATE_NEW_TASK',
          ),
        );
      }

      final success = await _database.tasksDao.updateTask(task);
      if (!success) {
        return dartz.Left(
          const NotFoundFailure(
            message: 'No se encontró la tarea para actualizar',
            code: 'TASK_NOT_FOUND',
          ),
        );
      }

      return dartz.Right(task);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, Task>> toggleTaskCompletion(int id) async {
    try {
      if (id <= 0) {
        return dartz.Left(
          const ValidationFailure(
            message: 'El ID de la tarea debe ser mayor a 0',
            code: 'INVALID_ID',
          ),
        );
      }

      final success = await _database.tasksDao.toggleTaskCompletion(id);
      if (!success) {
        return dartz.Left(
          const NotFoundFailure(
            message: 'No se encontró la tarea para cambiar su estado',
            code: 'TASK_NOT_FOUND',
          ),
        );
      }

      // Obtener la tarea actualizada
      final updatedTask = await _database.tasksDao.getTaskById(id);
      if (updatedTask == null) {
        return dartz.Left(
          const ServerFailure(
            message: 'Error al obtener la tarea actualizada',
            code: 'UPDATE_FETCH_ERROR',
          ),
        );
      }

      return dartz.Right(updatedTask);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, Task>> updateTaskTitle(
    int id,
    String newTitle,
  ) async {
    try {
      if (id <= 0) {
        return dartz.Left(
          const ValidationFailure(
            message: 'El ID de la tarea debe ser mayor a 0',
            code: 'INVALID_ID',
          ),
        );
      }

      if (newTitle.trim().isEmpty) {
        return dartz.Left(
          const ValidationFailure(
            message: 'El título de la tarea no puede estar vacío',
            code: 'EMPTY_TITLE',
          ),
        );
      }

      if (newTitle.length > 255) {
        return dartz.Left(
          const ValidationFailure(
            message: 'El título de la tarea no puede exceder 255 caracteres',
            code: 'TITLE_TOO_LONG',
          ),
        );
      }

      final success = await _database.tasksDao.updateTaskTitle(id, newTitle);
      if (!success) {
        return dartz.Left(
          const NotFoundFailure(
            message: 'No se encontró la tarea para actualizar',
            code: 'TASK_NOT_FOUND',
          ),
        );
      }

      // Obtener la tarea actualizada
      final updatedTask = await _database.tasksDao.getTaskById(id);
      if (updatedTask == null) {
        return dartz.Left(
          const ServerFailure(
            message: 'Error al obtener la tarea actualizada',
            code: 'UPDATE_FETCH_ERROR',
          ),
        );
      }

      return dartz.Right(updatedTask);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, bool>> deleteTask(int id) async {
    try {
      if (id <= 0) {
        return dartz.Left(
          const ValidationFailure(
            message: 'El ID de la tarea debe ser mayor a 0',
            code: 'INVALID_ID',
          ),
        );
      }

      final success = await _database.tasksDao.deleteTask(id);
      return dartz.Right(success);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, int>> deleteCompletedTasks() async {
    try {
      final deletedCount = await _database.tasksDao.deleteCompletedTasks();
      return dartz.Right(deletedCount);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, int>> deleteAllTasks() async {
    try {
      final deletedCount = await _database.tasksDao.deleteAllTasks();
      return dartz.Right(deletedCount);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, int>> getTotalTasksCount() async {
    try {
      final count = await _database.tasksDao.getTotalTasksCount();
      return dartz.Right(count);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, int>> getCompletedTasksCount() async {
    try {
      final count = await _database.tasksDao.getCompletedTasksCount();
      return dartz.Right(count);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, int>> getPendingTasksCount() async {
    try {
      final count = await _database.tasksDao.getPendingTasksCount();
      return dartz.Right(count);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, bool>> taskExists(int id) async {
    try {
      if (id <= 0) {
        return dartz.Left(
          const ValidationFailure(
            message: 'El ID de la tarea debe ser mayor a 0',
            code: 'INVALID_ID',
          ),
        );
      }

      final task = await _database.tasksDao.getTaskById(id);
      return dartz.Right(task != null);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<dartz.Either<Failure, List<Task>>> searchTasksByTitle(
    String query,
  ) async {
    try {
      if (query.trim().isEmpty) {
        return dartz.Left(
          const ValidationFailure(
            message: 'La consulta de búsqueda no puede estar vacía',
            code: 'EMPTY_SEARCH_QUERY',
          ),
        );
      }

      // Por ahora, obtenemos todas las tareas y filtramos en memoria
      // En el futuro se puede optimizar con una consulta SQL LIKE
      final allTasks = await _database.tasksDao.getAllTasks();
      final filteredTasks = allTasks
          .where(
            (task) => task.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      return dartz.Right(filteredTasks);
    } catch (e) {
      return dartz.Left(_mapExceptionToFailure(e));
    }
  }

  /// Mapea excepciones de base de datos a errores de dominio
  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception is Exception) {
      final message = exception.toString();

      // Mapear errores específicos de SQLite/Drift
      if (message.contains('UNIQUE constraint failed')) {
        return AlreadyExistsFailure(
          message: 'Ya existe una tarea con estos datos',
          code: 'UNIQUE_CONSTRAINT_FAILED',
        );
      }

      if (message.contains('FOREIGN KEY constraint failed')) {
        return ValidationFailure(
          message: 'Error de integridad referencial',
          code: 'FOREIGN_KEY_CONSTRAINT_FAILED',
        );
      }

      if (message.contains('NOT NULL constraint failed')) {
        return ValidationFailure(
          message: 'Faltan datos requeridos',
          code: 'NOT_NULL_CONSTRAINT_FAILED',
        );
      }

      if (message.contains('no such table')) {
        return ServerFailure(
          message: 'Error en la estructura de la base de datos',
          code: 'TABLE_NOT_FOUND',
        );
      }

      if (message.contains('database is locked')) {
        return ServerFailure(
          message: 'La base de datos está en uso. Intente nuevamente',
          code: 'DATABASE_LOCKED',
        );
      }

      if (message.contains('disk I/O error')) {
        return ServerFailure(
          message: 'Error de almacenamiento. Verifique el espacio disponible',
          code: 'DISK_IO_ERROR',
        );
      }

      // Error genérico de base de datos
      return ServerFailure(
        message: 'Error de base de datos: ${exception.toString()}',
        code: 'DATABASE_ERROR',
      );
    }

    // Error completamente desconocido
    return UnknownFailure(
      message: 'Error inesperado: ${exception.toString()}',
      code: 'UNKNOWN_ERROR',
    );
  }
}
