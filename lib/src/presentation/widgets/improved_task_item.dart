import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../../core/ui/confirmation_service.dart';

/// Widget mejorado para mostrar un elemento individual de tarea
/// Incluye descripción, mejor diseño y confirmación para completar
class ImprovedTaskItem extends ConsumerWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggleCompleted;

  const ImprovedTaskItem({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: task.isCompleted
                ? Colors.green.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primera fila: Checkbox y título con botón de editar
                Row(
                  children: [
                    // Checkbox con confirmación
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showCompletionConfirmation(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            HapticFeedback.lightImpact();
                            _showCompletionConfirmation(context);
                          },
                          activeColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Título y descripción
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? Colors.grey[600]
                                  : Colors.black87,
                            ),
                          ),

                          // Descripción (si existe)
                          if (task.description != null &&
                              task.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Botones de acción
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de editar
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            onEdit?.call();
                          },
                          icon: const Icon(Icons.edit),
                          iconSize: 18,
                          color: Theme.of(context).primaryColor,
                          tooltip: 'Editar tarea',
                        ),
                        // Botón de eliminar
                        IconButton(
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            final confirmed = await _showDeleteConfirmation(
                              context,
                            );
                            if (confirmed) {
                              onDelete?.call();
                            }
                          },
                          icon: const Icon(Icons.delete),
                          iconSize: 18,
                          color: Colors.red[600],
                          tooltip: 'Eliminar tarea',
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Segunda fila: Estado y fechas
                Row(
                  children: [
                    // Estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? Colors.green[100]
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.pending,
                            size: 14,
                            color: task.isCompleted
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.isCompleted ? 'Completada' : 'Pendiente',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: task.isCompleted
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botón deshacer para tareas completadas
                    if (task.isCompleted) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showCompletionConfirmation(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.undo,
                                size: 12,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Deshacer',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Fecha de actualización
                    Text(
                      _formatDate(task.updatedAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mostrar confirmación para completar/descompletar tarea
  Future<void> _showCompletionConfirmation(BuildContext context) async {
    final bool newValue = !task.isCompleted;

    final confirmed = await ConfirmationService.showCompleteConfirmation(
      context,
      title: newValue ? 'Completar Tarea' : 'Marcar como Pendiente',
      message: newValue
          ? '¿Estás seguro de que quieres marcar esta tarea como completada?'
          : '¿Estás seguro de que quieres marcar esta tarea como pendiente?',
      itemName: task.title,
      isCompleting: newValue,
    );

    if (confirmed) {
      onToggleCompleted?.call(newValue);
    }
  }

  /// Mostrar confirmación de eliminación
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await ConfirmationService.showDeleteConfirmation(
      context,
      title: 'Eliminar Tarea',
      message: '¿Estás seguro de que quieres eliminar esta tarea?',
      itemName: task.title,
      itemType: 'tarea',
    );
  }

  /// Formatear fecha para mostrar
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Ahora';
    }
  }
}
