import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import 'optimized_task_item.dart';

/// Widget optimizado para mostrar la lista de tareas
/// Implementa buenas prácticas de performance
class OptimizedTaskList extends ConsumerWidget {
  final List<Task> tasks;
  final VoidCallback? onRefresh;
  final void Function(Task)? onTaskTap;
  final void Function(Task)? onToggleCompletion;
  final void Function(Task)? onDeleteTask;
  final bool isLoading;

  const OptimizedTaskList({
    super.key,
    required this.tasks,
    this.onRefresh,
    this.onTaskTap,
    this.onToggleCompletion,
    this.onDeleteTask,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.isEmpty && !isLoading) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: tasks.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          // Mostrar indicador de carga al final
          if (index == tasks.length) {
            return const _LoadingIndicator();
          }

          final task = tasks[index];
          return OptimizedTaskItem(
            key: ValueKey('task_${task.id}'),
            task: task,
            onTap: () => onTaskTap?.call(task),
            onToggleCompletion: () => onToggleCompletion?.call(task),
            onDelete: () => onDeleteTask?.call(task),
          );
        },
      ),
    );
  }
}

/// Widget para el estado vacío
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay tareas',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para agregar tu primera tarea',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget para el indicador de carga
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
