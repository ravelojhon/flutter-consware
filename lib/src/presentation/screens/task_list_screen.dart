import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/task_providers.dart';
import '../../domain/entities/task.dart';

/// Pantalla principal que muestra la lista de tareas
/// Utiliza Riverpod para el manejo de estado sin setState
class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar tareas al inicializar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
        actions: [
          // Botón para recargar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(taskListProvider.notifier).refresh();
            },
          ),
          // Botón para limpiar errores
          Consumer(
            builder: (context, ref, child) {
              final hasError = ref.watch(hasErrorProvider);
              if (hasError) {
                return IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    ref.read(taskListProvider.notifier).clearError();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Widget para agregar nueva tarea
          _buildAddTaskWidget(),

          // Widget de estadísticas
          _buildStatsWidget(),

          // Lista de tareas
          Expanded(child: _buildTaskList()),
        ],
      ),
    );
  }

  /// Widget para agregar una nueva tarea
  Widget _buildAddTaskWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Nueva tarea...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _addTask(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _addTask, child: const Text('Agregar')),
        ],
      ),
    );
  }

  /// Widget que muestra estadísticas de tareas
  Widget _buildStatsWidget() {
    return Consumer(
      builder: (context, ref, child) {
        final stats = ref.watch(taskStatsProvider);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
          ),
        );
      },
    );
  }

  /// Widget que muestra la lista de tareas
  Widget _buildTaskList() {
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
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar tareas',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage ?? 'Error desconocido',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(taskListProvider.notifier).refresh();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        return taskListState.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay tareas',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Agrega tu primera tarea usando el campo de texto arriba',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskItem(task);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        );
      },
    );
  }

  /// Widget que representa un elemento individual de tarea
  Widget _buildTaskItem(Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.statusText),
            Text(
              'Creada: ${_formatDate(task.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                task.isCompleted ? Icons.undo : Icons.check,
                color: task.isCompleted ? Colors.orange : Colors.green,
              ),
              onPressed: () {
                ref
                    .read(taskListProvider.notifier)
                    .toggleTaskCompletion(task.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(task),
            ),
          ],
        ),
        onTap: () => _showTaskDetails(task),
      ),
    );
  }

  /// Widget auxiliar para mostrar estadísticas individuales
  Widget _buildStatItem(String label, String value) {
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

  /// Método para agregar una nueva tarea
  void _addTask() {
    final title = _textController.text.trim();
    if (title.isNotEmpty) {
      ref.read(taskListProvider.notifier).addTask(title: title);
      _textController.clear();
    }
  }

  /// Método para mostrar confirmación de eliminación
  void _showDeleteConfirmation(Task task) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tarea'),
        content: Text('¿Estás seguro de que quieres eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(taskListProvider.notifier).deleteTask(task.id);
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Método para mostrar detalles de la tarea
  void _showTaskDetails(Task task) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: ${task.statusText}'),
            Text('Creada: ${_formatDate(task.createdAt)}'),
            Text('Actualizada: ${_formatDate(task.updatedAt)}'),
            Text('Duración: ${_formatDuration(task.durationSinceCreation)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
              Navigator.of(context).pop();
            },
            child: Text(
              task.isCompleted ? 'Marcar Pendiente' : 'Marcar Completada',
            ),
          ),
        ],
      ),
    );
  }

  /// Método auxiliar para formatear fechas
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Método auxiliar para formatear duraciones
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} días';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} horas';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutos';
    } else {
      return '${duration.inSeconds} segundos';
    }
  }
}
