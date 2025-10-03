import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';

/// Pantalla para agregar o editar una tarea
/// Incluye validación completa y manejo de errores
class AddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isCompleted = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Inicializar campos con datos de la tarea existente
  void _initializeFields() {
    if (_isEditing && widget.task != null) {
      _titleController.text = widget.task!.title;
      _isCompleted = widget.task!.isCompleted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
  }

  /// Construir AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(_isEditing ? 'Editar Tarea' : 'Nueva Tarea'),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      actions: [
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
            child: Text(
              _isEditing ? 'Actualizar' : 'Guardar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  /// Construir cuerpo de la pantalla
  Widget _buildBody(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información de la tarea (si está editando)
            if (_isEditing) ...[
              _buildTaskInfo(context),
              const SizedBox(height: 24),
            ],

            // Campo de título
            _buildTitleField(context),
            const SizedBox(height: 16),

            // Campo de descripción (opcional)
            _buildDescriptionField(context),
            const SizedBox(height: 24),

            // Checkbox para estado completado
            _buildCompletionCheckbox(context),
            const SizedBox(height: 24),

            // Información adicional (si está editando)
            if (_isEditing) ...[
              _buildAdditionalInfo(context),
              const SizedBox(height: 24),
            ],

            // Botón de guardar
            _buildSaveButton(context),
            const SizedBox(height: 16),

            // Botón de eliminar (solo en edición)
            if (_isEditing) _buildDeleteButton(context),

            // Mostrar error si existe
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(context),
            ],
          ],
        ),
      ),
    );
  }

  /// Construir información de la tarea
  Widget _buildTaskInfo(BuildContext context) {
    if (!_isEditing || widget.task == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Editando tarea',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'ID: ${widget.task!.id}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construir campo de título
  Widget _buildTitleField(BuildContext context) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Título de la tarea',
        hintText: 'Ingresa el título de la tarea',
        prefixIcon: const Icon(Icons.title),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      textCapitalization: TextCapitalization.sentences,
      maxLines: 2,
      maxLength: 255,
      validator: _validateTitle,
      onChanged: (_) => setState(() => _errorMessage = null),
    );
  }

  /// Construir campo de descripción
  Widget _buildDescriptionField(BuildContext context) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Descripción (opcional)',
        hintText: 'Agrega una descripción detallada',
        prefixIcon: const Icon(Icons.description),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
      maxLength: 500,
    );
  }

  /// Construir checkbox de completado
  Widget _buildCompletionCheckbox(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        title: const Text('Tarea completada'),
        subtitle: const Text('Marca esta opción si la tarea ya está terminada'),
        value: _isCompleted,
        onChanged: (value) {
          setState(() {
            _isCompleted = value ?? false;
          });
        },
        secondary: Icon(
          _isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: _isCompleted ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  /// Construir información adicional
  Widget _buildAdditionalInfo(BuildContext context) {
    if (!_isEditing || widget.task == null) return const SizedBox.shrink();

    final task = widget.task!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información adicional',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Creada',
              _formatDateTime(task.createdAt),
              Icons.access_time,
            ),
            _buildInfoRow(
              'Última actualización',
              _formatDateTime(task.updatedAt),
              Icons.update,
            ),
            _buildInfoRow(
              'Estado actual',
              task.statusText,
              task.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              task.isCompleted ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// Construir fila de información
  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  /// Construir botón de guardar
  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _saveTask,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(_isEditing ? Icons.update : Icons.save),
      label: Text(_isEditing ? 'Actualizar Tarea' : 'Crear Tarea'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Construir botón de eliminar
  Widget _buildDeleteButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _deleteTask,
      icon: const Icon(Icons.delete_outline),
      label: const Text('Eliminar Tarea'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Construir mensaje de error
  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Validar título
  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El título es requerido';
    }
    if (value.trim().length < 3) {
      return 'El título debe tener al menos 3 caracteres';
    }
    if (value.length > 255) {
      return 'El título no puede exceder 255 caracteres';
    }
    return null;
  }

  /// Guardar tarea
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isEditing && widget.task != null) {
        // Actualizar tarea existente
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          isCompleted: _isCompleted,
          updatedAt: DateTime.now(),
        );

        await ref.read(taskListProvider.notifier).updateTask(updatedTask);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarea actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Crear nueva tarea
        await ref
            .read(taskListProvider.notifier)
            .addTask(
              title: _titleController.text.trim(),
              isCompleted: _isCompleted,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarea creada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Eliminar tarea
  Future<void> _deleteTask() async {
    if (!_isEditing || widget.task == null) return;

    final confirmed = await _showDeleteConfirmation(context);
    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(taskListProvider.notifier).deleteTask(widget.task!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarea eliminada correctamente'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            const Text('¿Estás seguro de que quieres eliminar esta tarea?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${widget.task?.title}"',
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

  /// Formatear fecha y hora
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
