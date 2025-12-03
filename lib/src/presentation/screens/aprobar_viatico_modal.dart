import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/viatico_notifier.dart';

/// Modal para aprobar o rechazar viáticos
class AprobarViaticoModal extends ConsumerStatefulWidget {
  final Viatico viatico;
  final bool esAprobacion;

  const AprobarViaticoModal({
    super.key,
    required this.viatico,
    required this.esAprobacion,
  });

  @override
  ConsumerState<AprobarViaticoModal> createState() => _AprobarViaticoModalState();
}

class _AprobarViaticoModalState extends ConsumerState<AprobarViaticoModal> {
  final _observacionesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.esAprobacion
                    ? Colors.green[50]
                    : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.esAprobacion ? Icons.check_circle : Icons.cancel,
                color: widget.esAprobacion ? Colors.green : Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            
            // Título
            Text(
              widget.esAprobacion
                  ? 'Aprobar Viático'
                  : 'Rechazar Viático',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Información del viático
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Usuario', widget.viatico.usuarioNombre),
                  const SizedBox(height: 8),
                  _buildInfoRow('Concepto', widget.viatico.concepto),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Monto',
                    _formatCurrency(widget.viatico.monto),
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Observaciones
            TextField(
              controller: _observacionesController,
              decoration: InputDecoration(
                labelText: widget.esAprobacion
                    ? 'Observaciones (Opcional)'
                    : 'Motivo del Rechazo *',
                hintText: widget.esAprobacion
                    ? 'Agregar comentarios...'
                    : 'Explique el motivo del rechazo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmarAccion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.esAprobacion
                          ? Colors.green
                          : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.esAprobacion ? 'Aprobar' : 'Rechazar',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? Colors.blue[700] : Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmarAccion() async {
    if (!widget.esAprobacion &&
        _observacionesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe ingresar el motivo del rechazo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final aprobadoPor = 'Admin Sistema'; // En producción sería el usuario actual
      final observaciones = _observacionesController.text.trim().isNotEmpty
          ? _observacionesController.text.trim()
          : null;

      if (widget.esAprobacion) {
        await ref.read(viaticoListNotifierProvider.notifier).aprobarViatico(
              widget.viatico.id,
              aprobadoPor,
              observaciones: observaciones,
            );
      } else {
        await ref.read(viaticoListNotifierProvider.notifier).rechazarViatico(
              widget.viatico.id,
              aprobadoPor,
              observaciones!,
            );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.esAprobacion
                  ? 'Viático aprobado exitosamente'
                  : 'Viático rechazado',
            ),
            backgroundColor: widget.esAprobacion ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }
}

