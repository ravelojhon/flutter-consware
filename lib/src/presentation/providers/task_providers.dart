import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../providers/task_list_notifier.dart';

/// Provider principal para la lista de tareas
/// Expone el estado y métodos para CRUD
final taskListProvider = AsyncNotifierProvider<TaskListNotifier, List<Task>>(
  () {
    return TaskListNotifier();
  },
);

/// Provider para tareas completadas (computado)
final completedTasksProvider = Provider<List<Task>>((ref) {
  final taskListState = ref.watch(taskListProvider);
  return taskListState.whenOrNull(
        data: (tasks) => tasks.where((task) => task.isCompleted).toList(),
      ) ??
      [];
});

/// Provider para tareas pendientes (computado)
final pendingTasksProvider = Provider<List<Task>>((ref) {
  final taskListState = ref.watch(taskListProvider);
  return taskListState.whenOrNull(
        data: (tasks) => tasks.where((task) => !task.isCompleted).toList(),
      ) ??
      [];
});

/// Provider para estadísticas de tareas (computado)
final taskStatsProvider = Provider<TaskStats>((ref) {
  final taskListState = ref.watch(taskListProvider);
  return taskListState.whenOrNull(
        data: (tasks) {
          final completed = tasks.where((task) => task.isCompleted).length;
          final pending = tasks.length - completed;
          return TaskStats(
            total: tasks.length,
            completed: completed,
            pending: pending,
          );
        },
      ) ??
      const TaskStats(total: 0, completed: 0, pending: 0);
});

/// Provider para una tarea específica por ID
final taskByIdProvider = Provider.family<Task?, int>((ref, id) {
  final taskListState = ref.watch(taskListProvider);
  return taskListState.whenOrNull(
    data: (tasks) {
      try {
        return tasks.firstWhere((task) => task.id == id);
      } catch (e) {
        return null;
      }
    },
  );
});

/// Provider para verificar si una tarea existe
final taskExistsProvider = Provider.family<bool, int>((ref, id) {
  final task = ref.watch(taskByIdProvider(id));
  return task != null;
});

/// Provider para tareas filtradas por texto
final filteredTasksProvider = Provider.family<List<Task>, String>((ref, query) {
  if (query.trim().isEmpty) {
    return ref.watch(taskListProvider).whenOrNull(data: (tasks) => tasks) ?? [];
  }

  final taskListState = ref.watch(taskListProvider);
  return taskListState.whenOrNull(
        data: (tasks) {
          final lowercaseQuery = query.toLowerCase();
          return tasks.where((task) {
            return task.title.toLowerCase().contains(lowercaseQuery);
          }).toList();
        },
      ) ??
      [];
});

/// Provider para tareas filtradas por estado
final tasksByStatusProvider = Provider.family<List<Task>, TaskStatus>((
  ref,
  status,
) {
  final taskListState = ref.watch(taskListProvider);
  return taskListState.whenOrNull(
        data: (tasks) {
          switch (status) {
            case TaskStatus.all:
              return tasks;
            case TaskStatus.completed:
              return tasks.where((task) => task.isCompleted).toList();
            case TaskStatus.pending:
              return tasks.where((task) => !task.isCompleted).toList();
          }
        },
      ) ??
      [];
});

/// Provider para el estado de carga
final isLoadingProvider = Provider<bool>((ref) {
  final taskListState = ref.watch(taskListProvider);
  return taskListState.isLoading;
});

/// Provider para el estado de error
final hasErrorProvider = Provider<bool>((ref) {
  final taskListState = ref.watch(taskListProvider);
  return taskListState.hasError;
});

/// Provider para el mensaje de error
final errorMessageProvider = Provider<String?>((ref) {
  final taskListState = ref.watch(taskListProvider);
  return taskListState.whenOrNull(
    error: (error, stackTrace) => error.toString(),
  );
});

/// Provider para verificar si hay tareas
final hasTasksProvider = Provider<bool>((ref) {
  final taskListState = ref.watch(taskListProvider);
  return taskListState.whenOrNull(data: (tasks) => tasks.isNotEmpty) ?? false;
});

/// Provider para verificar si todas las tareas están completadas
final allTasksCompletedProvider = Provider<bool>((ref) {
  final stats = ref.watch(taskStatsProvider);
  return stats.total > 0 && stats.allCompleted;
});

/// Provider para verificar si no hay tareas pendientes
final noPendingTasksProvider = Provider<bool>((ref) {
  final stats = ref.watch(taskStatsProvider);
  return stats.noPending;
});

/// Enumeración para estados de tareas
enum TaskStatus { all, completed, pending }

/// Extension para obtener el texto del estado
extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.all:
        return 'Todas';
      case TaskStatus.completed:
        return 'Completadas';
      case TaskStatus.pending:
        return 'Pendientes';
    }
  }
}
