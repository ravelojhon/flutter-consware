import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';
import '../widgets/task_item.dart';

/// Pantalla optimizada para mostrar la lista de tareas
/// Usa ConsumerWidget y ListView.builder para mejor performance
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cargar tareas al inicializar
    ref.listen(taskListProvider, (previous, next) {
      // Escuchar cambios de estado para mostrar mensajes
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: () {
                  ref.read(taskListProvider.notifier).refresh();
                },
              ),
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: Column(
        children: [
          // Widget de estadísticas
          _buildStatsSection(context, ref),

          // Widget para agregar tareas rápidas
          _buildQuickAddSection(context, ref),

          // Lista de tareas
          Expanded(child: _buildTasksList(context, ref)),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// Construir AppBar con acciones
  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('Lista de Tareas'),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      actions: [
        // Botón de filtros
        _buildFilterButton(context, ref),

        // Botón de ordenar
        _buildSortButton(context, ref),

        // Botón de recargar
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.read(taskListProvider.notifier).refresh();
          },
          tooltip: 'Recargar tareas',
        ),

        // Botón de limpiar errores
        Consumer(
          builder: (context, ref, child) {
            final hasError = ref.watch(hasErrorProvider);
            if (hasError) {
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  ref.read(taskListProvider.notifier).clearError();
                },
                tooltip: 'Limpiar errores',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// Construir sección de estadísticas
  Widget _buildStatsSection(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final stats = ref.watch(taskStatsProvider);

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  stats.total.toString(),
                  Icons.list_alt,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Completadas',
                  stats.completed.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Pendientes',
                  stats.pending.toString(),
                  Icons.radio_button_unchecked,
                  Colors.orange,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Progreso',
                  '${stats.completionPercentage.toStringAsFixed(0)}%',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construir widget de estadística individual
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
        ),
      ],
    );
  }

  /// Construir sección para agregar tareas rápidas
  Widget _buildQuickAddSection(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Agregar tarea rápida...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (value) => _addQuickTask(ref, value),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showAddEditScreen(context),
            icon: const Icon(Icons.add),
            tooltip: 'Agregar tarea',
          ),
        ],
      ),
    );
  }

  /// Construir lista de tareas con ListView.builder
  Widget _buildTasksList(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final taskListState = ref.watch(taskListProvider);

        return taskListState.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return const EmptyTasksWidget();
            }

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(taskListProvider.notifier).refresh();
              },
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskItem(key: ValueKey(task.id), task: task);
                },
                // Optimizaciones de performance
                cacheExtent: 200,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                addSemanticIndexes: false,
              ),
            );
          },
          loading: () => const TasksLoadingWidget(),
          error: (error, stackTrace) => TasksErrorWidget(
            errorMessage: error.toString(),
            onRetry: () {
              ref.read(taskListProvider.notifier).refresh();
            },
          ),
        );
      },
    );
  }

  /// Construir botón flotante de acción
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddEditScreen(context),
      icon: const Icon(Icons.add),
      label: const Text('Nueva Tarea'),
      tooltip: 'Agregar nueva tarea',
    );
  }

  /// Construir botón de filtros
  Widget _buildFilterButton(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<TaskStatus>(
      icon: const Icon(Icons.filter_list),
      tooltip: 'Filtrar tareas',
      onSelected: (status) {
        // TODO: Implementar filtros
        _showFilterDialog(context, status);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: TaskStatus.all,
          child: Row(
            children: [Icon(Icons.list), SizedBox(width: 8), Text('Todas')],
          ),
        ),
        const PopupMenuItem(
          value: TaskStatus.completed,
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Completadas'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: TaskStatus.pending,
          child: Row(
            children: [
              Icon(Icons.radio_button_unchecked, color: Colors.orange),
              SizedBox(width: 8),
              Text('Pendientes'),
            ],
          ),
        ),
      ],
    );
  }

  /// Construir botón de ordenar
  Widget _buildSortButton(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      tooltip: 'Ordenar tareas',
      onSelected: (sortType) {
        // TODO: Implementar ordenamiento
        _showSortDialog(context, sortType);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'created',
          child: Row(
            children: [
              Icon(Icons.access_time),
              SizedBox(width: 8),
              Text('Por fecha de creación'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'updated',
          child: Row(
            children: [
              Icon(Icons.update),
              SizedBox(width: 8),
              Text('Por fecha de actualización'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'title',
          child: Row(
            children: [
              Icon(Icons.title),
              SizedBox(width: 8),
              Text('Por título'),
            ],
          ),
        ),
      ],
    );
  }

  /// Agregar tarea rápida
  void _addQuickTask(WidgetRef ref, String title) {
    if (title.trim().isNotEmpty) {
      ref.read(taskListProvider.notifier).addTask(title: title.trim());
    }
  }

  /// Mostrar pantalla de agregar/editar tarea
  void _showAddEditScreen(BuildContext context, [Task? task]) {
    Navigator.of(context).pushNamed('/add-edit-task', arguments: task);
  }

  /// Mostrar diálogo de filtros
  void _showFilterDialog(BuildContext context, TaskStatus status) {
    // TODO: Implementar lógica de filtros
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtro seleccionado: ${status.displayName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Mostrar diálogo de ordenamiento
  void _showSortDialog(BuildContext context, String sortType) {
    // TODO: Implementar lógica de ordenamiento
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ordenamiento seleccionado: $sortType'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Widget para mostrar cuando no hay tareas
class EmptyTasksWidget extends StatelessWidget {
  const EmptyTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'No hay tareas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Agrega tu primera tarea usando el botón de abajo',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
