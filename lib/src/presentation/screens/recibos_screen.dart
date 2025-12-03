import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/pdf_service.dart';
import '../widgets/pdf_preview_modal.dart';
import '../providers/recibo_notifier.dart';
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
    final recibos = ref.watch(reciboListNotifierProvider);

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
      body: recibos.isEmpty
          ? _buildEmptyState(context)
          : _buildRecibosList(context, recibos),
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

  /// Construir lista de recibos
  Widget _buildRecibosList(BuildContext context, List<ReciboGuardado> recibos) {
    return RefreshIndicator(
      onRefresh: () async {
        // El provider se actualizará automáticamente con ref.watch
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recibos.length,
        itemBuilder: (context, index) {
          final recibo = recibos[index];
          return _buildReciboCard(context, recibo);
        },
      ),
    );
  }

  /// Construir tarjeta de recibo
  Widget _buildReciboCard(BuildContext context, ReciboGuardado recibo) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Ver detalle del recibo
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con número de recibo y acciones sutiles
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 18,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recibo #${recibo.numeroRecibo}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recibo.fecha,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botones sutiles de acciones
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSubtleActionButton(
                        icon: Icons.print_outlined,
                        tooltip: 'Imprimir',
                        onPressed: () => _imprimirRecibo(recibo),
                      ),
                      const SizedBox(width: 4),
                      _buildSubtleActionButton(
                        icon: Icons.delete_outline,
                        tooltip: 'Eliminar',
                        onPressed: () => _eliminarRecibo(context, recibo),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              
              // Información del cliente
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recibo.cliente,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // NIT
              Row(
                children: [
                  Icon(Icons.badge_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'NIT: ${recibo.nit}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Totales
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Recibo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(recibo.totalRecibo),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Neto Recibo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(recibo.netoRecibo),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construir botón de acción sutil
  Widget _buildSubtleActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          hoverColor: Colors.grey[100],
          splashColor: Colors.grey[200],
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  /// Formatear moneda
  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  /// Imprimir recibo
  Future<void> _imprimirRecibo(ReciboGuardado recibo) async {
    try {
      // Generar PDF y mostrar en modal
      final pdfBytes = await PdfService.generarPdfReciboBytes(recibo);
      
      if (mounted) {
        // Mostrar el PDF en un modal dentro de la app
        await PdfPreviewModal.show(
          context,
          buildPdf: (format) async => pdfBytes,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Error al generar PDF: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Eliminar recibo
  void _eliminarRecibo(BuildContext context, ReciboGuardado recibo) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar recibo?'),
        content: Text(
          '¿Está seguro de eliminar el recibo #${recibo.numeroRecibo}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(reciboListNotifierProvider.notifier).eliminarRecibo(recibo.id);
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recibo eliminado'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
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

