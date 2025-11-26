import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';

/// Widget optimizado para el formulario de tareas
/// Implementa buenas prácticas de performance
class OptimizedTaskForm extends ConsumerStatefulWidget {
  final Task? task;
  final void Function(String title, bool isCompleted) onSubmit;
  final bool isLoading;

  const OptimizedTaskForm({
    super.key,
    this.task,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  ConsumerState<OptimizedTaskForm> createState() => _OptimizedTaskFormState();
}

class _OptimizedTaskFormState extends ConsumerState<OptimizedTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _isCompleted = widget.task!.isCompleted;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo de título
          _TitleField(
            controller: _titleController,
            isEnabled: !widget.isLoading,
          ),
          const SizedBox(height: 16),

          // Checkbox de completado
          _CompletionCheckbox(
            value: _isCompleted,
            onChanged: widget.isLoading
                ? null
                : (value) {
                    setState(() {
                      _isCompleted = value ?? false;
                    });
                  },
          ),
          const SizedBox(height: 24),

          // Botón de guardar
          _SaveButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            isLoading: widget.isLoading,
            isEditing: widget.task != null,
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(_titleController.text.trim(), _isCompleted);
    }
  }
}

/// Widget separado para el campo de título (optimización)
class _TitleField extends StatelessWidget {
  final TextEditingController controller;
  final bool isEnabled;

  const _TitleField({required this.controller, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: isEnabled,
      decoration: InputDecoration(
        labelText: 'Título de la tarea',
        hintText: 'Ingresa el título de la tarea',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.title),
      ),
      validator: _validateTitle,
      textInputAction: TextInputAction.done,
      maxLength: 255,
    );
  }

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
}

/// Widget separado para el checkbox de completado (optimización)
class _CompletionCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const _CompletionCheckbox({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: const Text('Tarea completada'),
      subtitle: const Text('Marca si la tarea ya está terminada'),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

/// Widget separado para el botón de guardar (optimización)
class _SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEditing;

  const _SaveButton({
    this.onPressed,
    required this.isLoading,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              isEditing ? 'Actualizar Tarea' : 'Crear Tarea',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }
}
