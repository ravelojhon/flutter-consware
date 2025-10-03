import 'package:flutter/material.dart';

import '../errors/error_mapper.dart';

/// Widget genérico para mostrar errores de manera consistente
class AppErrorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final String? title;
  final String? subtitle;
  final bool showIcon;
  final bool showRetryButton;

  const AppErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.title,
    this.subtitle,
    this.showIcon = true,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = ErrorMapper.mapToUserMessage(error);
    final errorIcon = ErrorMapper.getErrorIcon(error);
    final errorColor = ErrorMapper.getErrorColor(error);
    final isRecoverable = ErrorMapper.isRecoverable(error);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(errorIcon, size: 48, color: errorColor),
            ),
            const SizedBox(height: 16),
          ],

          Text(
            title ?? 'Algo salió mal',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: errorColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            subtitle ?? errorMessage,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          if (isRecoverable && showRetryButton && onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget compacto para mostrar errores en listas
class CompactErrorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry? padding;

  const CompactErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = ErrorMapper.mapToUserMessage(error);
    final errorIcon = ErrorMapper.getErrorIcon(error);
    final errorColor = ErrorMapper.getErrorColor(error);
    final isRecoverable = ErrorMapper.isRecoverable(error);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: errorColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(errorIcon, color: errorColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(color: errorColor, fontWeight: FontWeight.w500),
            ),
          ),
          if (isRecoverable && onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

/// Widget para mostrar errores en tarjetas
class CardErrorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final String? title;

  const CardErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = ErrorMapper.mapToUserMessage(error);
    final errorIcon = ErrorMapper.getErrorIcon(error);
    final errorColor = ErrorMapper.getErrorColor(error);
    final isRecoverable = ErrorMapper.isRecoverable(error);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: errorColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(errorIcon, color: errorColor, size: 32),
            const SizedBox(height: 12),
            Text(
              title ?? 'Error',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: errorColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (isRecoverable && onRetry != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: errorColor,
                    side: BorderSide(color: errorColor),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
