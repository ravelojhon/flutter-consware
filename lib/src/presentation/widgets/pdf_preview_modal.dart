import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

/// Modal para mostrar preview del PDF dentro de la aplicación
class PdfPreviewModal extends StatelessWidget {
  final Future<Uint8List> Function(PdfPageFormat format) buildPdf;

  const PdfPreviewModal({
    super.key,
    required this.buildPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header del modal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Cerrar',
                  ),
                  const Expanded(
                    child: Text(
                      'Vista Previa del Recibo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Botón de descargar (sutil, como el de imprimir)
                  IconButton(
                    icon: const Icon(Icons.download_outlined, size: 22),
                    onPressed: () async {
                      // Descargar el PDF
                      final pdfBytes = await buildPdf(PdfPageFormat.a4);
                      await Printing.sharePdf(
                        bytes: pdfBytes,
                        filename: 'recibo_${DateTime.now().millisecondsSinceEpoch}.pdf',
                      );
                    },
                    tooltip: 'Descargar',
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),
            // Preview del PDF
            Expanded(
              child: PdfPreview(
                build: buildPdf,
                allowPrinting: true,
                allowSharing: true,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar el modal de preview del PDF
  static Future<void> show(
    BuildContext context, {
    required Future<Uint8List> Function(PdfPageFormat format) buildPdf,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => PdfPreviewModal(buildPdf: buildPdf),
    );
  }
}
