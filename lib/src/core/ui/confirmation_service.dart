import 'package:flutter/material.dart';

/// Servicio centralizado para mostrar confirmaciones de acciones críticas
class ConfirmationService {
  /// Mostrar confirmación para eliminar un elemento
  static Future<bool> showDeleteConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String? itemName,
    String? itemType = 'elemento',
    bool isDestructive = true,
  }) async {
    return await _showConfirmationDialog(
      context,
      title: title,
      message: message,
      itemName: itemName,
      itemType: itemType,
      isDestructive: isDestructive,
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
    );
  }

  /// Mostrar confirmación para completar una tarea
  static Future<bool> showCompleteConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String? itemName,
    bool isCompleting = true,
  }) async {
    return await _showConfirmationDialog(
      context,
      title: title,
      message: message,
      itemName: itemName,
      itemType: 'tarea',
      isDestructive: false,
      confirmText: isCompleting ? 'Completar' : 'Marcar Pendiente',
      cancelText: 'Cancelar',
      confirmIcon: isCompleting ? Icons.check_circle : Icons.pending,
      confirmColor: isCompleting ? Colors.green : Colors.orange,
    );
  }

  /// Mostrar confirmación para limpiar elementos completados
  static Future<bool> showClearCompletedConfirmation(
    BuildContext context, {
    required int count,
  }) async {
    return await _showConfirmationDialog(
      context,
      title: 'Limpiar Tareas Completadas',
      message: count > 1
          ? '¿Estás seguro de que quieres eliminar las $count tareas completadas?'
          : '¿Estás seguro de que quieres eliminar la tarea completada?',
      itemType: 'tareas completadas',
      isDestructive: true,
      confirmText: 'Limpiar',
      cancelText: 'Cancelar',
      warningMessage: 'Esta acción no se puede deshacer.',
    );
  }

  /// Mostrar confirmación para eliminar todas las tareas
  static Future<bool> showDeleteAllConfirmation(
    BuildContext context, {
    required int count,
  }) async {
    return await _showConfirmationDialog(
      context,
      title: 'Eliminar Todas las Tareas',
      message: count > 1
          ? '¿Estás seguro de que quieres eliminar las $count tareas?'
          : '¿Estás seguro de que quieres eliminar la tarea?',
      itemType: 'todas las tareas',
      isDestructive: true,
      confirmText: 'Eliminar Todo',
      cancelText: 'Cancelar',
      warningMessage: 'Esta acción no se puede deshacer.',
    );
  }

  /// Mostrar confirmación para resetear filtros
  static Future<bool> showResetFiltersConfirmation(BuildContext context) async {
    return await _showConfirmationDialog(
      context,
      title: 'Limpiar Filtros',
      message: '¿Quieres restablecer todos los filtros y búsquedas?',
      itemType: 'filtros',
      isDestructive: false,
      confirmText: 'Limpiar',
      cancelText: 'Cancelar',
      confirmIcon: Icons.clear_all,
      confirmColor: Colors.blue,
    );
  }

  /// Mostrar confirmación genérica personalizada
  static Future<bool> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? itemName,
    String? itemType,
    required bool isDestructive,
    required String confirmText,
    required String cancelText,
    IconData? confirmIcon,
    Color? confirmColor,
    String? warningMessage,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                confirmIcon ??
                    (isDestructive ? Icons.warning : Icons.help_outline),
                color:
                    confirmColor ?? (isDestructive ? Colors.red : Colors.blue),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontSize: 16)),

              if (itemName != null && itemName.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          (confirmColor ??
                                  (isDestructive ? Colors.red : Colors.blue))
                              .withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              confirmColor ??
                              (isDestructive ? Colors.red : Colors.blue),
                        ),
                      ),
                      if (itemType != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          itemType,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              if (warningMessage != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warningMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelText,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    confirmColor ?? (isDestructive ? Colors.red : Colors.blue),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                confirmText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// Mostrar confirmación rápida con Toast
  static Future<bool> showQuickConfirmation(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String confirmText = 'Sí',
    String cancelText = 'No',
  }) async {
    bool? result;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.grey[800],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: confirmText,
          textColor: Colors.white,
          onPressed: () {
            result = true;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );

    // Esperar a que se oculte el SnackBar
    await Future<void>.delayed(duration);
    return result ?? false;
  }
}
