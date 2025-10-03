import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';

/// Widget optimizado para mostrar un elemento individual de tarea
/// Incluye Checkbox, Dismissible y navegación a edición
class TaskItem extends ConsumerWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggleCompleted;

  const TaskItem({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        _handleDelete(ref);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        elevation: task.isCompleted ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: task.isCompleted
                ? Colors.grey.shade300
                : Theme.of(context).colorScheme.primary.withOpacity(0.2),
            width: task.isCompleted ? 1 : 2,
          ),
        ),
        child: InkWell(
          onTap: () => _handleTap(context, ref),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Checkbox para marcar como completado
                _buildCheckbox(context, ref),

                const SizedBox(width: 12),

                // Contenido principal de la tarea
                Expanded(child: _buildTaskContent(context)),

                // Botones de acción
                _buildActionButtons(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget del checkbox con animación
  Widget _buildCheckbox(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Checkbox(
        value: task.isCompleted,
        onChanged: (value) => _handleToggleCompleted(ref),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        activeColor: Theme.of(context).colorScheme.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  /// Widget del contenido principal de la tarea
  Widget _buildTaskContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la tarea
        Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? Colors.grey.shade600
                : Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Información adicional
        Row(
          children: [
            // Estado de la tarea
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: task.isCompleted
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Fecha de creación
            Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              _formatDate(task.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),

        // Indicador de actualización reciente
        if (task.wasRecentlyUpdated) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.update, size: 12, color: Colors.blue.shade600),
              const SizedBox(width: 4),
              Text(
                'Actualizada recientemente',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Widget de los botones de acción
  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón de editar
        IconButton(
          icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
          onPressed: () => _handleEdit(context, ref),
          tooltip: 'Editar tarea',
          visualDensity: VisualDensity.compact,
        ),

        // Botón de eliminar
        IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
          onPressed: () => _showDeleteConfirmation(context).then((confirmed) {
            if (confirmed == true) {
              _handleDelete(ref);
            }
          }),
          tooltip: 'Eliminar tarea',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  /// Manejar tap en la tarea
  void _handleTap(BuildContext context, WidgetRef ref) {
    if (onTap != null) {
      onTap!();
    } else {
      _handleEdit(context, ref);
    }
  }

  /// Manejar toggle del estado completado
  void _handleToggleCompleted(WidgetRef ref) {
    if (onToggleCompleted != null) {
      onToggleCompleted!(!task.isCompleted);
    } else {
      ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
    }
  }

  /// Manejar edición de la tarea
  void _handleEdit(BuildContext context, WidgetRef ref) {
    if (onEdit != null) {
      onEdit!();
    } else {
      Navigator.of(context).pushNamed('/add-edit-task', arguments: task);
    }
  }

  /// Manejar eliminación de la tarea
  void _handleDelete(WidgetRef ref) {
    if (onDelete != null) {
      onDelete!();
    } else {
      ref.read(taskListProvider.notifier).deleteTask(task.id);
    }
  }

  /// Mostrar confirmación de eliminación
  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('Eliminar Tarea'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres eliminar esta tarea?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${task.title}"',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Formatear fecha para mostrar
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
}

/// Widget de placeholder para cuando no hay tareas
class EmptyTasksWidget extends StatelessWidget {
  final VoidCallback? onAddTask;

  const EmptyTasksWidget({super.key, this.onAddTask});

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
            const SizedBox(height: 32),
            if (onAddTask != null)
              ElevatedButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Tarea'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget de loading optimizado
class TasksLoadingWidget extends StatelessWidget {
  const TasksLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando tareas...'),
        ],
      ),
    );
  }
}

/// Widget de error optimizado
class TasksErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const TasksErrorWidget({super.key, this.errorMessage, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar tareas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Ocurrió un error inesperado',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
