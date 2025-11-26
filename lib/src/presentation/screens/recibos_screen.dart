import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'recaudos_cartera_form_screen.dart';

/// Pantalla de lista de recibos
class RecibosScreen extends ConsumerStatefulWidget {
  const RecibosScreen({super.key});

  @override
  ConsumerState<RecibosScreen> createState() => _RecibosScreenState();
}

class _RecibosScreenState extends ConsumerState<RecibosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text(
          'Recibos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildEmptyState(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder<void>(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const RecaudosCarteraFormScreen(),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
            ),
          );
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo Recaudo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Construir estado vacío
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono grande de recibo
          Stack(
            alignment: Alignment.center,
            children: [
              // Ícono principal
              CustomPaint(
                size: const Size(120, 140),
                painter: _ReceiptIconPainter(
                  color: Colors.blue[300]!,
                ),
              ),
              // Ícono secundario (documento pequeño con rotación)
              Positioned(
                bottom: 10,
                left: 30,
                child: Transform.rotate(
                  angle: -0.3,
                  child: CustomPaint(
                    size: const Size(50, 60),
                    painter: _ReceiptIconPainter(
                      color: Colors.blue[200]!,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Texto descriptivo
          Text(
            'No hay recibos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              'Toca el botón + para crear tu primer recibo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter para dibujar un ícono de recibo con borde ondulado
class _ReceiptIconPainter extends CustomPainter {
  final Color color;

  _ReceiptIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Borde superior ondulado (simulando recibo)
    path.moveTo(0, height * 0.15);
    for (double x = 0; x < width; x += 8) {
      final y = height * 0.15 + (x % 16 < 8 ? 3 : -3);
      path.lineTo(x, y);
    }
    path.lineTo(width, height * 0.15);

    // Líneas horizontales dentro del documento
    path.moveTo(width * 0.2, height * 0.35);
    path.lineTo(width * 0.8, height * 0.35);
    path.moveTo(width * 0.2, height * 0.5);
    path.lineTo(width * 0.8, height * 0.5);
    path.moveTo(width * 0.2, height * 0.65);
    path.lineTo(width * 0.6, height * 0.65);

    // Bordes laterales y inferior
    path.moveTo(0, height * 0.15);
    path.lineTo(0, height);
    path.lineTo(width, height);
    path.lineTo(width, height * 0.15);

    // Relleno
    final fillPath = Path()
      ..moveTo(0, height * 0.15)
      ..lineTo(width, height * 0.15)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

