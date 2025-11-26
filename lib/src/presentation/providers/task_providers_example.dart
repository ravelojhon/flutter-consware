import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_providers.dart';

/// Ejemplo de uso de los providers de tareas
/// Este archivo muestra cómo usar los providers en widgets Flutter
class TaskProvidersExample {
  /// Ejemplo de widget que muestra la lista de tareas
  static Widget buildTaskListWidget() {
    return Consumer(
      builder: (context, ref, child) {
        final taskListState = ref.watch(taskListProvider);
        final isLoading = ref.watch(isLoadingProvider);
        final hasError = ref.watch(hasErrorProvider);
        final errorMessage = ref.watch(errorMessageProvider);

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $errorMessage'),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(taskListProvider.notifier).refresh(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        return taskListState.when(
          data: (tasks) => ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.statusText),
                trailing: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    ref
                        .read(taskListProvider.notifier)
                        .toggleTaskCompletion(task.id);
                  },
                ),
                onTap: () {
                  // Navegar a detalles de la tarea
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        );
      },
    );
  }

  /// Ejemplo de widget que muestra estadísticas
  static Widget buildStatsWidget() {
    return Consumer(
      builder: (context, ref, child) {
        final stats = ref.watch(taskStatsProvider);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estadísticas de Tareas',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total', stats.total.toString()),
                    _buildStatItem('Completadas', stats.completed.toString()),
                    _buildStatItem('Pendientes', stats.pending.toString()),
                    _buildStatItem(
                      'Progreso',
                      '${stats.completionPercentage.toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Ejemplo de widget para agregar una nueva tarea
  static Widget buildAddTaskWidget() {
    return Consumer(
      builder: (context, ref, child) {
        final textController = TextEditingController();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Nueva tarea...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final title = textController.text.trim();
                  if (title.isNotEmpty) {
                    ref.read(taskListProvider.notifier).addTask(title: title);
                    textController.clear();
                  }
                },
                child: const Text('Agregar'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Ejemplo de widget que muestra tareas filtradas
  static Widget buildFilteredTasksWidget() {
    return Consumer(
      builder: (context, ref, child) {
        final textController = TextEditingController();
        String searchQuery = '';

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'Buscar tareas...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  searchQuery = value;
                  // El provider se actualiza automáticamente
                },
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final filteredTasks = ref.watch(
                    filteredTasksProvider(searchQuery),
                  );

                  if (filteredTasks.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron tareas'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return ListTile(
                        title: Text(task.title),
                        subtitle: Text(task.statusText),
                        trailing: IconButton(
                          icon: Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: task.isCompleted
                                ? Colors.green
                                : Colors.grey,
                          ),
                          onPressed: () {
                            ref
                                .read(taskListProvider.notifier)
                                .toggleTaskCompletion(task.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Ejemplo de widget que muestra tareas por estado
  static Widget buildTasksByStatusWidget() {
    return Consumer(
      builder: (context, ref, child) {
        TaskStatus selectedStatus = TaskStatus.all;

        return Column(
          children: [
            // Selector de estado
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusButton(ref, TaskStatus.all, 'Todas'),
                  _buildStatusButton(ref, TaskStatus.completed, 'Completadas'),
                  _buildStatusButton(ref, TaskStatus.pending, 'Pendientes'),
                ],
              ),
            ),
            // Lista de tareas filtradas
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final tasks = ref.watch(
                    tasksByStatusProvider(selectedStatus),
                  );

                  if (tasks.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay tareas ${selectedStatus.displayName.toLowerCase()}',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        title: Text(task.title),
                        subtitle: Text(
                          'Creada: ${_formatDate(task.createdAt)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              task.isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: task.isCompleted
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                ref
                                    .read(taskListProvider.notifier)
                                    .deleteTask(task.id);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          ref
                              .read(taskListProvider.notifier)
                              .toggleTaskCompletion(task.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Ejemplo de uso de providers en un método
  static void demonstrateProviderUsage(WidgetRef ref) {
    // Obtener el notifier para realizar operaciones
    final notifier = ref.read(taskListProvider.notifier);

    // Agregar una nueva tarea
    notifier.addTask(title: 'Nueva tarea desde código');

    // Obtener estadísticas
    final stats = ref.read(taskStatsProvider);
    print('Estadísticas: $stats');

    // Obtener una tarea específica
    final task = ref.read(taskByIdProvider(1));
    if (task != null) {
      print('Tarea encontrada: ${task.title}');
    }

    // Verificar si hay tareas
    final hasTasks = ref.read(hasTasksProvider);
    print('Hay tareas: $hasTasks');

    // Obtener tareas completadas
    final completedTasks = ref.read(completedTasksProvider);
    print('Tareas completadas: ${completedTasks.length}');

    // Filtrar tareas
    final filteredTasks = ref.read(filteredTasksProvider('importante'));
    print('Tareas filtradas: ${filteredTasks.length}');

    // Obtener tareas por estado
    final pendingTasks = ref.read(tasksByStatusProvider(TaskStatus.pending));
    print('Tareas pendientes: ${pendingTasks.length}');

    // Verificar estado de carga
    final isLoading = ref.read(isLoadingProvider);
    print('Cargando: $isLoading');

    // Verificar errores
    final hasError = ref.read(hasErrorProvider);
    if (hasError) {
      final errorMessage = ref.read(errorMessageProvider);
      print('Error: $errorMessage');
    }
  }

  // Métodos auxiliares
  static Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  static Widget _buildStatusButton(
    WidgetRef ref,
    TaskStatus status,
    String label,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        // Aquí se implementaría la lógica para cambiar el estado seleccionado
        return ElevatedButton(
          onPressed: () {
            // Cambiar el estado seleccionado
          },
          child: Text(label),
        );
      },
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
