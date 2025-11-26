import 'package:flutter/material.dart';

/// Modal bonito para mostrar errores
class ErrorModal extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorModal({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red[50]!, Colors.red[100]!],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de error
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red[300]!, width: 2),
              ),
              child: Icon(
                Icons.error_outline,
                size: 32,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 16),

            // Título
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Mensaje
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                // Botón de cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.red[300]!),
                      foregroundColor: Colors.red[700],
                    ),
                    child: const Text('Cerrar'),
                  ),
                ),

                // Botón de reintentar (si existe)
                if (onRetry != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRetry?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                      ),
                      child: Text(retryText ?? 'Reintentar'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar modal de error
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    String? retryText,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => ErrorModal(
        title: title,
        message: message,
        onRetry: onRetry,
        retryText: retryText,
      ),
    );
  }
}
