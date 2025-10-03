import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';

/// Widget optimizado para mostrar una tarea individual
/// Implementa buenas prácticas de performance
class OptimizedTaskItem extends ConsumerWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleCompletion;
  final VoidCallback? onDelete;

  const OptimizedTaskItem({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleCompletion,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      background: const _DeleteBackground(),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      child: _TaskCard(
        task: task,
        onTap: onTap,
        onToggleCompletion: onToggleCompletion,
      ),
    );
  }

  /// Mostrar diálogo de confirmación para eliminar
  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Tarea'),
          content: Text(
            '¿Estás seguro de que quieres eliminar "${task.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}

/// Widget separado para el fondo de eliminación (optimización)
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: const Icon(Icons.delete, color: Colors.white, size: 30),
    );
  }
}

/// Widget separado para la tarjeta de tarea (optimización)
class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleCompletion;

  const _TaskCard({required this.task, this.onTap, this.onToggleCompletion});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Checkbox para marcar como completada
              _CompletionCheckbox(
                isCompleted: task.isCompleted,
                onChanged: onToggleCompletion,
              ),
              const SizedBox(width: 12),
              // Contenido de la tarea
              Expanded(child: _TaskContent(task: task)),
              // Indicador visual de completado
              if (task.isCompleted) const _CompletionIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget separado para el checkbox de completado (optimización)
class _CompletionCheckbox extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback? onChanged;

  const _CompletionCheckbox({required this.isCompleted, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: isCompleted,
      onChanged: (_) => onChanged?.call(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      activeColor: Theme.of(context).primaryColor,
    );
  }
}

/// Widget separado para el contenido de la tarea (optimización)
class _TaskContent extends StatelessWidget {
  final Task task;

  const _TaskContent({required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la tarea
        Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey[600] : null,
          ),
        ),
        const SizedBox(height: 4),
        // Información adicional
        Row(
          children: [
            Icon(
              task.isCompleted ? Icons.check_circle : Icons.pending,
              size: 14,
              color: task.isCompleted ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 4),
            Text(
              task.statusText,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const Spacer(),
            Text(
              _formatDate(task.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }

  /// Formatear fecha para mostrar
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Widget separado para el indicador de completado (optimización)
class _CompletionIndicator extends StatelessWidget {
  const _CompletionIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check, size: 16, color: Colors.green[700]),
    );
  }
}
