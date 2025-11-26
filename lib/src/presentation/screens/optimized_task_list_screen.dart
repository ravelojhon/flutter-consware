import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../providers/task_list_notifier.dart';
import '../widgets/optimized_task_list.dart';

/// Pantalla optimizada para mostrar la lista de tareas
/// Implementa buenas prácticas de performance
class OptimizedTaskListScreen extends ConsumerWidget {
  const OptimizedTaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListState = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas Optimizadas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Botón para limpiar tareas completadas
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _showClearCompletedDialog(context, ref),
            tooltip: 'Limpiar completadas',
          ),
          // Botón para agregar tarea
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddTask(context),
            tooltip: 'Agregar tarea',
          ),
        ],
      ),
      body: taskListState.when(
        data: (tasks) => OptimizedTaskList(
          tasks: tasks,
          onRefresh: () => ref.read(taskListProvider.notifier).refresh(),
          onTaskTap: (task) => _navigateToEditTask(context, task),
          onToggleCompletion: (task) => _toggleTaskCompletion(ref, task),
          onDeleteTask: (task) => _deleteTask(ref, task),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(
          error: error,
          onRetry: () => ref.read(taskListProvider.notifier).refresh(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(context),
        tooltip: 'Agregar nueva tarea',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Navegar a la pantalla de agregar tarea
  void _navigateToAddTask(BuildContext context) {
    Navigator.pushNamed(context, '/add-task');
  }

  /// Navegar a la pantalla de editar tarea
  void _navigateToEditTask(BuildContext context, Task task) {
    Navigator.pushNamed(context, '/edit-task', arguments: task);
  }

  /// Alternar el estado de completado de una tarea
  void _toggleTaskCompletion(WidgetRef ref, Task task) {
    ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
  }

  /// Eliminar una tarea
  void _deleteTask(WidgetRef ref, Task task) {
    ref.read(taskListProvider.notifier).deleteTask(task.id);
  }

  /// Mostrar diálogo para limpiar tareas completadas
  void _showClearCompletedDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limpiar Tareas Completadas'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar todas las tareas completadas?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(taskListProvider.notifier).deleteCompletedTasks();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Limpiar'),
            ),
          ],
        );
      },
    );
  }
}

/// Widget para mostrar el estado de error
class _ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error al cargar las tareas',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.red[600]),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
