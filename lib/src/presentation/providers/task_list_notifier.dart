import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../../core/errors/error_mapper.dart';
import '../../domain/entities/task.dart';
import '../../core/di/dependency_injection.dart';

/// Estado de la lista de tareas usando AsyncNotifier para manejar loading, error y data
class TaskListNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    // Cargar tareas al inicializar
    return await _loadTasks();
  }

  /// Cargar todas las tareas
  Future<List<Task>> _loadTasks() async {
    final getTasks = ref.read(getTasksProvider);
    final result = await getTasks.call();

    return result.fold(
      (failure) => throw _mapFailureToException(failure),
      (tasks) => tasks,
    );
  }

  /// Recargar las tareas desde el repositorio
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadTasks());
  }

  /// Agregar una nueva tarea
  Future<void> addTask({
    required String title,
    String? description,
    bool isCompleted = false,
  }) async {
    final addTaskUseCase = ref.read(addTaskProvider);
    final result = await addTaskUseCase.call(
      title: title,
      description: description,
      isCompleted: isCompleted,
    );

    result.fold((failure) => throw _mapFailureToException(failure), (newTask) {
      // Actualizar el estado agregando la nueva tarea
      final currentTasks = state.value ?? [];
      final updatedTasks = [newTask, ...currentTasks];
      state = AsyncValue.data(updatedTasks);
    });
  }

  /// Actualizar una tarea existente
  Future<void> updateTask(Task task) async {
    final updateTaskUseCase = ref.read(updateTaskProvider);
    final result = await updateTaskUseCase.call(task);

    result.fold((failure) => throw _mapFailureToException(failure), (
      updatedTask,
    ) {
      // Actualizar el estado reemplazando la tarea
      final currentTasks = state.value ?? [];
      final updatedTasks = currentTasks
          .map((t) => t.id == updatedTask.id ? updatedTask : t)
          .toList();
      state = AsyncValue.data(updatedTasks);
    });
  }

  /// Actualizar solo el título de una tarea
  Future<void> updateTaskTitle(int id, String newTitle) async {
    final updateTaskUseCase = ref.read(updateTaskProvider);
    final result = await updateTaskUseCase.updateTitle(id, newTitle);

    result.fold((failure) => throw _mapFailureToException(failure), (
      updatedTask,
    ) {
      // Actualizar el estado reemplazando la tarea
      final currentTasks = state.value ?? [];
      final updatedTasks = currentTasks
          .map((t) => t.id == updatedTask.id ? updatedTask : t)
          .toList();
      state = AsyncValue.data(updatedTasks);
    });
  }

  /// Marcar una tarea como completada
  Future<void> markTaskAsCompleted(int id) async {
    final markCompletedUseCase = ref.read(markTaskAsCompletedProvider);
    final result = await markCompletedUseCase.call(id);

    result.fold((failure) => throw _mapFailureToException(failure), (
      updatedTask,
    ) {
      // Actualizar el estado reemplazando la tarea
      final currentTasks = state.value ?? [];
      final updatedTasks = currentTasks
          .map((t) => t.id == updatedTask.id ? updatedTask : t)
          .toList();
      state = AsyncValue.data(updatedTasks);
    });
  }

  /// Marcar una tarea como pendiente
  Future<void> markTaskAsPending(int id) async {
    final markPendingUseCase = ref.read(markTaskAsPendingProvider);
    final result = await markPendingUseCase.call(id);

    result.fold((failure) => throw _mapFailureToException(failure), (
      updatedTask,
    ) {
      // Actualizar el estado reemplazando la tarea
      final currentTasks = state.value ?? [];
      final updatedTasks = currentTasks
          .map((t) => t.id == updatedTask.id ? updatedTask : t)
          .toList();
      state = AsyncValue.data(updatedTasks);
    });
  }

  /// Alternar el estado de completado de una tarea
  Future<void> toggleTaskCompletion(int id) async {
    try {
      final currentTasks = state.value ?? [];
      if (currentTasks.isEmpty) return;

      final taskIndex = currentTasks.indexWhere((t) => t.id == id);
      if (taskIndex == -1) return;

      final task = currentTasks[taskIndex];
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        updatedAt: DateTime.now(),
      );

      // Actualizar inmediatamente en el estado local manteniendo la posición
      final updatedTasks = [...currentTasks];
      updatedTasks[taskIndex] = updatedTask;
      state = AsyncValue.data(updatedTasks);

      // Luego actualizar en el repositorio
      final updateTaskUseCase = ref.read(updateTaskProvider);
      final result = await updateTaskUseCase.call(updatedTask);

      result.fold(
        (failure) {
          // Si falla, revertir el estado local
          state = AsyncValue.data(currentTasks);
          throw _mapFailureToException(failure);
        },
        (_) {
          // Confirmar que la actualización fue exitosa
          // El estado ya está actualizado arriba
        },
      );
    } catch (e) {
      // En caso de error, refrescar desde el repositorio
      await refresh();
      rethrow;
    }
  }

  /// Eliminar una tarea
  Future<void> deleteTask(int id) async {
    try {
      // No cambiar a loading para evitar reorganización visual
      final currentTasks = state.value ?? [];
      if (currentTasks.isEmpty) return;

      // Actualizar inmediatamente en el estado local
      final updatedTasks = currentTasks.where((t) => t.id != id).toList();
      state = AsyncValue.data(updatedTasks);

      // Luego eliminar del repositorio
      final deleteTaskUseCase = ref.read(deleteTaskProvider);
      final result = await deleteTaskUseCase.call(id);

      result.fold(
        (failure) {
          // Si falla, revertir el estado local
          state = AsyncValue.data(currentTasks);
          throw _mapFailureToException(failure);
        },
        (success) {
          // Confirmar que la eliminación fue exitosa
          // El estado ya está actualizado arriba
        },
      );
    } catch (e) {
      // En caso de error, refrescar desde el repositorio
      await refresh();
      rethrow;
    }
  }

  /// Eliminar todas las tareas completadas
  Future<void> deleteCompletedTasks() async {
    final deleteCompletedTasksUseCase = ref.read(deleteCompletedTasksProvider);
    final result = await deleteCompletedTasksUseCase.call();

    result.fold((failure) => throw _mapFailureToException(failure), (
      deletedCount,
    ) {
      // Actualizar el estado removiendo las tareas completadas
      final currentTasks = state.value ?? [];
      final updatedTasks = currentTasks.where((t) => !t.isCompleted).toList();
      state = AsyncValue.data(updatedTasks);
    });
  }

  /// Limpiar el estado de error
  void clearError() {
    if (state.hasError) {
      state = AsyncValue.data(state.value ?? []);
    }
  }

  /// Obtener una tarea por ID del estado actual
  Task? getTaskById(int id) {
    final currentTasks = state.value ?? [];
    try {
      return currentTasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener tareas completadas del estado actual
  List<Task> get completedTasks {
    final currentTasks = state.value ?? [];
    return currentTasks.where((task) => task.isCompleted).toList();
  }

  /// Obtener tareas pendientes del estado actual
  List<Task> get pendingTasks {
    final currentTasks = state.value ?? [];
    return currentTasks.where((task) => !task.isCompleted).toList();
  }

  /// Obtener estadísticas del estado actual
  TaskStats get stats {
    final currentTasks = state.value ?? [];
    final completed = currentTasks.where((task) => task.isCompleted).length;
    final pending = currentTasks.length - completed;
    return TaskStats(
      total: currentTasks.length,
      completed: completed,
      pending: pending,
    );
  }

  /// Mapear errores de dominio a excepciones para AsyncValue
  Exception _mapFailureToException(Failure failure) {
    return Exception(ErrorMapper.mapToUserMessage(failure));
  }

}

/// Estadísticas de tareas
class TaskStats {
  final int total;
  final int completed;
  final int pending;

  const TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
  });

  /// Porcentaje de tareas completadas
  double get completionPercentage {
    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }

  /// Verificar si todas las tareas están completadas
  bool get allCompleted => total > 0 && completed == total;

  /// Verificar si no hay tareas pendientes
  bool get noPending => pending == 0;

  /// Crear estadísticas desde una lista de tareas
  factory TaskStats.fromTasks(List<Task> tasks) {
    final completed = tasks.where((task) => task.isCompleted).length;
    final pending = tasks.length - completed;
    return TaskStats(
      total: tasks.length,
      completed: completed,
      pending: pending,
    );
  }

  @override
  String toString() {
    return 'TaskStats(total: $total, completed: $completed, pending: $pending, completion: ${completionPercentage.toStringAsFixed(1)}%)';
  }
}

/// Provider para el notifier de la lista de tareas
final taskListProvider = AsyncNotifierProvider<TaskListNotifier, List<Task>>(
  () {
    return TaskListNotifier();
  },
);
