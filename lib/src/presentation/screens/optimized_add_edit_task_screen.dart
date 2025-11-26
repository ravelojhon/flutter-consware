import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../providers/task_list_notifier.dart';
import '../widgets/optimized_task_form.dart';

/// Pantalla optimizada para agregar/editar tareas
/// Implementa buenas prácticas de performance
class OptimizedAddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task;

  const OptimizedAddEditTaskScreen({super.key, this.task});

  @override
  ConsumerState<OptimizedAddEditTaskScreen> createState() =>
      _OptimizedAddEditTaskScreenState();
}

class _OptimizedAddEditTaskScreenState
    extends ConsumerState<OptimizedAddEditTaskScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarea' : 'Nueva Tarea'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (isEditing && !_isLoading)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context),
              tooltip: 'Eliminar tarea',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información de la tarea (solo si está editando)
            if (isEditing) _TaskInfo(task: widget.task!),

            const SizedBox(height: 16),

            // Formulario optimizado
            Expanded(
              child: OptimizedTaskForm(
                task: widget.task,
                onSubmit: _handleSubmit,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Manejar el envío del formulario
  void _handleSubmit(String title, bool isCompleted) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.task != null) {
        // Actualizar tarea existente
        final updatedTask = widget.task!.copyWith(
          title: title,
          isCompleted: isCompleted,
        );
        await ref.read(taskListProvider.notifier).updateTask(updatedTask);
      } else {
        // Crear nueva tarea
        await ref
            .read(taskListProvider.notifier)
            .addTask(title: title, isCompleted: isCompleted);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error al guardar la tarea: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Mostrar confirmación de eliminación
  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Tarea'),
          content: Text(
            '¿Estás seguro de que quieres eliminar "${widget.task!.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteTask();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  /// Eliminar la tarea
  Future<void> _deleteTask() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(taskListProvider.notifier).deleteTask(widget.task!.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error al eliminar la tarea: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Mostrar mensaje de error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

/// Widget para mostrar información de la tarea
class _TaskInfo extends StatelessWidget {
  final Task task;

  const _TaskInfo({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de la tarea',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.tag, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('ID: ${task.id}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Creada: ${_formatDate(task.createdAt)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.update, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Actualizada: ${_formatDate(task.updatedAt)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  task.isCompleted ? Icons.check_circle : Icons.pending,
                  size: 16,
                  color: task.isCompleted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text('Estado: ${task.statusText}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Formatear fecha para mostrar
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
