import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../providers/task_list_notifier.dart';
import '../widgets/error_modal.dart';

/// Pantalla simple para agregar o editar una tarea
/// Con el diseño anterior y manejo de errores mejorado
class SimpleAddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task;

  const SimpleAddEditTaskScreen({super.key, this.task});

  @override
  ConsumerState<SimpleAddEditTaskScreen> createState() =>
      _SimpleAddEditTaskScreenState();
}

class _SimpleAddEditTaskScreenState
    extends ConsumerState<SimpleAddEditTaskScreen> {
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
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Tarea' : 'Nueva Tarea'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card principal del formulario
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título del formulario
                        Row(
                          children: [
                            Icon(
                              _isEditing ? Icons.edit : Icons.add_circle,
                              color: Theme.of(context).primaryColor,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isEditing ? 'Editar Tarea' : 'Crear Nueva Tarea',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
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
                ),

                const SizedBox(height: 24),

                // Botones de acción
                _buildActionButtons(),
              ],
            ),
          ),
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
          'Título *',
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
          validator: _validateTitle,
          textInputAction: TextInputAction.next,
          maxLength: 255,
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
          'Descripción',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Agrega una descripción detallada (opcional)...',
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
          maxLines: 4,
          minLines: 2,
          maxLength: 500,
          textInputAction: TextInputAction.done,
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
        borderRadius: BorderRadius.circular(10),
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
                  _isCompleted ? 'Completada' : 'Pendiente',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón principal (Crear/Actualizar)
        ElevatedButton.icon(
          onPressed: _isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  _handleSubmit();
                },
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
          label: Text(
            _isLoading
                ? 'Procesando...'
                : (_isEditing ? 'Actualizar Tarea' : 'Crear Tarea'),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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
                borderRadius: BorderRadius.circular(10),
              ),
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      ],
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
          _showErrorModal(
            'Error al ${_isEditing ? 'actualizar' : 'crear'} la tarea',
            e.toString(),
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
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task!.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    if (widget.task!.description != null &&
                        widget.task!.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.task!.description!,
                        style: TextStyle(fontSize: 12, color: Colors.red[600]),
                      ),
                    ],
                  ],
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
        _showErrorModal('Error al eliminar la tarea', e.toString());
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

  /// Mostrar modal de error
  void _showErrorModal(String title, String message) {
    ErrorModal.show(context, title: title, message: message);
  }
}
