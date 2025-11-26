import '../../core/errors/failures.dart';
import '../local/todo_database.dart';
import 'task_repository_impl.dart';

/// Ejemplo de uso del repositorio de tareas
/// Este archivo muestra cómo usar el repositorio con manejo de errores
class TaskRepositoryExample {
  final TaskRepositoryImpl _repository;

  TaskRepositoryExample() : _repository = TaskRepositoryImpl(TodoDatabase());

  /// Ejemplo: Crear una nueva tarea
  Future<void> createTaskExample() async {
    final result = await _repository.createTaskWithTitle('Nueva tarea');

    result.fold(
      (failure) {
        // Manejar error
        print('Error al crear tarea: ${failure.message}');
        _handleFailure(failure);
      },
      (task) {
        // Éxito
        print('Tarea creada: ${task.title} (ID: ${task.id})');
      },
    );
  }

  /// Ejemplo: Obtener todas las tareas
  Future<void> getAllTasksExample() async {
    final result = await _repository.getAllTasksOrderedByUpdated();

    result.fold(
      (failure) {
        print('Error al obtener tareas: ${failure.message}');
        _handleFailure(failure);
      },
      (tasks) {
        print('Tareas encontradas: ${tasks.length}');
        for (final task in tasks) {
          print('- ${task.title} (${task.statusText})');
        }
      },
    );
  }

  /// Ejemplo: Marcar tarea como completada
  Future<void> toggleTaskExample(int taskId) async {
    final result = await _repository.toggleTaskCompletion(taskId);

    result.fold(
      (failure) {
        print('Error al cambiar estado: ${failure.message}');
        _handleFailure(failure);
      },
      (updatedTask) {
        print(
          'Tarea actualizada: ${updatedTask.title} - ${updatedTask.statusText}',
        );
      },
    );
  }

  /// Ejemplo: Buscar tareas
  Future<void> searchTasksExample(String query) async {
    final result = await _repository.searchTasksByTitle(query);

    result.fold(
      (failure) {
        print('Error en búsqueda: ${failure.message}');
        _handleFailure(failure);
      },
      (tasks) {
        if (tasks.isEmpty) {
          print('No se encontraron tareas con "$query"');
        } else {
          print('Tareas encontradas:');
          for (final task in tasks) {
            print('- ${task.title}');
          }
        }
      },
    );
  }

  /// Ejemplo: Obtener estadísticas
  Future<void> getStatsExample() async {
    // Obtener conteos en paralelo
    final totalResult = await _repository.getTotalTasksCount();
    final completedResult = await _repository.getCompletedTasksCount();
    final pendingResult = await _repository.getPendingTasksCount();

    // Verificar si hay errores
    if (totalResult.isLeft() ||
        completedResult.isLeft() ||
        pendingResult.isLeft()) {
      print('Error al obtener estadísticas');
      return;
    }

    final total = totalResult.getOrElse(() => 0);
    final completed = completedResult.getOrElse(() => 0);
    final pending = pendingResult.getOrElse(() => 0);

    print('Estadísticas:');
    print('- Total: $total');
    print('- Completadas: $completed');
    print('- Pendientes: $pending');
    print('- Progreso: ${((completed / total) * 100).toStringAsFixed(1)}%');
  }

  /// Ejemplo: Eliminar tareas completadas
  Future<void> cleanupCompletedTasksExample() async {
    final result = await _repository.deleteCompletedTasks();

    result.fold(
      (failure) {
        print('Error al limpiar tareas: ${failure.message}');
        _handleFailure(failure);
      },
      (deletedCount) {
        if (deletedCount > 0) {
          print('Se eliminaron $deletedCount tareas completadas');
        } else {
          print('No había tareas completadas para eliminar');
        }
      },
    );
  }

  /// Manejar diferentes tipos de errores
  void _handleFailure(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure:
        print('Error de validación: ${failure.message}');
        // Mostrar mensaje al usuario sobre datos inválidos
        break;
      case NotFoundFailure:
        print('Recurso no encontrado: ${failure.message}');
        // Mostrar mensaje de "no encontrado"
        break;
      case ServerFailure:
        print('Error del servidor: ${failure.message}');
        // Mostrar mensaje de error técnico
        break;
      case CacheFailure:
        print('Error de caché: ${failure.message}');
        // Intentar recuperar datos de otra fuente
        break;
      default:
        print('Error desconocido: ${failure.message}');
      // Mostrar mensaje genérico de error
    }
  }
}
