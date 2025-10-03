import 'package:flutter/material.dart';

/// Widgets para mostrar estados de carga de manera consistente
class LoadingWidgets {
  /// Indicador de carga simple
  static Widget simple({String? message, Color? color, double size = 24.0}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: color, strokeWidth: 2.5),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: color ?? Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Indicador de carga con tarjeta
  static Widget card({
    String? title,
    String? message,
    Color? color,
    EdgeInsetsGeometry? padding,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: color, strokeWidth: 2.5),
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Indicador de carga compacto para listas
  static Widget compact({String? message, Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: color, strokeWidth: 2),
          ),
          if (message != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: color ?? Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Indicador de carga con skeleton
  static Widget skeleton({int itemCount = 3, double itemHeight = 80}) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: itemHeight,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  /// Botón con estado de carga
  static Widget button({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    String? loadingText,
    Color? loadingColor,
    ButtonStyle? style,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: loadingColor ?? Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                if (loadingText != null) ...[
                  const SizedBox(width: 8),
                  Text(loadingText),
                ],
              ],
            )
          : child,
    );
  }

  /// Overlay de carga para pantalla completa
  static Widget overlay({
    required String message,
    Color? backgroundColor,
    Color? indicatorColor,
  }) {
    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: indicatorColor,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar estado de carga en listas
class ListLoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const ListLoadingWidget({super.key, this.message, this.color, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: LoadingWidgets.compact(
        message: message ?? 'Cargando...',
        color: color,
      ),
    );
  }
}

/// Widget para mostrar estado de carga en tarjetas
class CardLoadingWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const CardLoadingWidget({
    super.key,
    this.title,
    this.message,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingWidgets.card(
      title: title,
      message: message,
      color: color,
      padding: padding,
    );
  }
}

/// Widget para mostrar skeleton loading
class SkeletonLoadingWidget extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const SkeletonLoadingWidget({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: LoadingWidgets.skeleton(
        itemCount: itemCount,
        itemHeight: itemHeight,
      ),
    );
  }
}
