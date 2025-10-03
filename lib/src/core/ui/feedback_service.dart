import 'package:flutter/material.dart';

/// Servicio centralizado para mostrar feedback al usuario
/// Maneja SnackBars, Toasts y otros tipos de notificaciones
class FeedbackService {
  static const Duration _defaultDuration = Duration(seconds: 3);
  static const Duration _longDuration = Duration(seconds: 5);

  /// Mostrar mensaje de éxito
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = _defaultDuration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Mostrar mensaje de error
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = _longDuration,
    VoidCallback? onRetry,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
      duration: duration,
      onAction: onRetry,
      actionLabel: onRetry != null ? 'Reintentar' : null,
    );
  }

  /// Mostrar mensaje de advertencia
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = _defaultDuration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
      duration: duration,
    );
  }

  /// Mostrar mensaje informativo
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = _defaultDuration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Mostrar mensaje de carga (indefinido hasta que se oculte)
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLoading(
    BuildContext context, {
    required String message,
  }) {
    return _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.grey[700]!,
      icon: Icons.hourglass_empty,
      duration: Duration.zero, // Indefinido
      showProgressIndicator: true,
    );
  }

  /// Ocultar el SnackBar actual
  static void hideCurrent(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Mostrar SnackBar personalizado
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
  _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = _defaultDuration,
    VoidCallback? onAction,
    String? actionLabel,
    bool showProgressIndicator = false,
  }) {
    // Ocultar SnackBar anterior si existe
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showProgressIndicator) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ],
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Mostrar Toast personalizado (usando SnackBar pero más pequeño)
  static void showToast(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case ToastType.error:
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case ToastType.warning:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      case ToastType.info:
        backgroundColor = Colors.blue;
        icon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 100, // Posicionar más arriba
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

/// Tipos de Toast disponibles
enum ToastType { success, error, warning, info }
