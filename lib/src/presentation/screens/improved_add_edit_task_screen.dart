import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../providers/task_list_notifier.dart';

/// Pantalla mejorada para agregar o editar una tarea
/// Con mejor UX y diseño más atractivo
class ImprovedAddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task;

  const ImprovedAddEditTaskScreen({super.key, this.task});

  @override
  ConsumerState<ImprovedAddEditTaskScreen> createState() =>
      _ImprovedAddEditTaskScreenState();
}

class _ImprovedAddEditTaskScreenState
    extends ConsumerState<ImprovedAddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late bool _isCompleted;
  bool _isLoading = false;

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
      _descriptionController.text = widget.task!.description ?? '';
      _isCompleted = widget.task!.isCompleted;
    } else {
      _isCompleted = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [_buildSliverAppBar(context), _buildFormContent()],
      ),
    );
  }

  /// Construir App Bar personalizado
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _isEditing ? 'Editar Tarea' : 'Nueva Tarea',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              _isEditing ? Icons.edit : Icons.add_task,
              color: Colors.white,
              size: 60,
            ),
          ),
        ),
      ),
      actions: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        if (_isEditing && !_isLoading)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Eliminar tarea',
          ),
      ],
    );
  }

  /// Construir contenido del formulario
  Widget _buildFormContent() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información de la tarea (solo si está editando)
            if (_isEditing) _buildTaskInfo(),

            // Formulario principal
            _buildMainForm(),

            // Botones de acción
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Construir información de la tarea
  Widget _buildTaskInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Información de la tarea',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.tag, 'ID', widget.task!.id.toString()),
          _buildInfoRow(
            Icons.access_time,
            'Creada',
            _formatDate(widget.task!.createdAt),
          ),
          _buildInfoRow(
            Icons.update,
            'Actualizada',
            _formatDate(widget.task!.updatedAt),
          ),
          _buildInfoRow(
            Icons.check_circle,
            'Estado',
            widget.task!.isCompleted ? 'Completada' : 'Pendiente',
            color: widget.task!.isCompleted ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  /// Construir fila de información
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  /// Construir formulario principal
  Widget _buildMainForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del formulario
            Row(
              children: [
                Icon(
                  _isEditing ? Icons.edit : Icons.add_circle,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _isEditing ? 'Editar Tarea' : 'Crear Nueva Tarea',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Campo de título
            _buildTitleField(),
            const SizedBox(height: 20),

            // Campo de descripción
            _buildDescriptionField(),
            const SizedBox(height: 20),

            // Checkbox de completado
            _buildCompletionCheckbox(),
          ],
        ),
      ),
    );
  }

  /// Construir campo de título
  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Título de la tarea',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Ingresa el título de la tarea...',
            prefixIcon: const Icon(Icons.title),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: _validateTitle,
          textInputAction: TextInputAction.done,
          maxLength: 255,
          maxLines: 3,
          minLines: 1,
        ),
        const SizedBox(height: 4),
        Text(
          '${_titleController.text.length}/255 caracteres',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  /// Construir campo de descripción
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción (opcional)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Agrega una descripción detallada de la tarea...',
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 4,
          minLines: 2,
          maxLength: 500,
        ),
        const SizedBox(height: 4),
        Text(
          '${_descriptionController.text.length}/500 caracteres',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  /// Construir checkbox de completado
  Widget _buildCompletionCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCompleted ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCompleted ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isCompleted ? Icons.check_circle : Icons.pending,
            color: _isCompleted ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de la tarea',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isCompleted
                      ? 'Esta tarea está completada'
                      : 'Esta tarea está pendiente',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: _isCompleted,
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() {
                      _isCompleted = value;
                    });
                  },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  /// Construir botones de acción
  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botón principal (Crear/Actualizar)
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleSubmit,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(_isEditing ? Icons.update : Icons.add),
            label: Text(_isEditing ? 'Actualizar Tarea' : 'Crear Tarea'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),

          // Botón de eliminar (solo en modo edición)
          if (_isEditing) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _showDeleteConfirmation,
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar Tarea'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
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

  /// Formatear fecha
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Manejar envío del formulario
  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isEditing) {
          // Actualizar tarea existente
          final updatedTask = widget.task!.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            isCompleted: _isCompleted,
            updatedAt: DateTime.now(),
          );
          await ref.read(taskListProvider.notifier).updateTask(updatedTask);
        } else {
          // Crear nueva tarea
          await ref
              .read(taskListProvider.notifier)
              .addTask(
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                isCompleted: _isCompleted,
              );
        }

        if (mounted) {
          Navigator.of(context).pop();
          _showSuccessMessage();
        }
      } catch (e) {
        if (mounted) {
          _showErrorMessage(
            'Error al ${_isEditing ? 'actualizar' : 'crear'} la tarea: $e',
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  /// Mostrar confirmación de eliminación
  void _showDeleteConfirmation() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Tarea'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Estás seguro de que quieres eliminar esta tarea?'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  '"${widget.task!.title}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
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
        _showSuccessMessage('Tarea eliminada exitosamente');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error al eliminar la tarea: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Mostrar mensaje de éxito
  void _showSuccessMessage([String? message]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              message ??
                  'Tarea ${_isEditing ? 'actualizada' : 'creada'} exitosamente',
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Mostrar mensaje de error
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
