import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../presentation/providers/recibo_notifier.dart';

/// Servicio para generar PDFs de recibos
class PdfService {
  /// Generar PDF del recibo y devolver los bytes
  static Future<Uint8List> generarPdfReciboBytes(ReciboGuardado recibo) async {
    final pdf = await _crearPdfRecibo(recibo);
    return await pdf.save();
  }

  /// Crear PDF del recibo
  static Future<pw.Document> _crearPdfRecibo(ReciboGuardado recibo) async {
    final pdf = pw.Document();
    final fechaFormateada = DateFormat('dd/MM/yyyy').format(recibo.fechaCreacion);
    final horaFormateada = DateFormat('HH:mm:ss').format(recibo.fechaCreacion);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Encabezado con nombre de compañía, título, número y fecha
          _buildHeader(recibo),
          pw.SizedBox(height: 12),
          
          // Información del beneficiario/cliente
          _buildClienteInfo(recibo),
          pw.SizedBox(height: 10),
          
          // Formas de pago
          _buildFormasPago(recibo),
          pw.SizedBox(height: 10),
          
          // Totales
          _buildTotales(recibo),
          pw.SizedBox(height: 10),
          
          // Pie de página
          _buildFooter(fechaFormateada, horaFormateada),
        ],
      ),
    );

    return pdf;
  }

  /// Construir encabezado del PDF
  static pw.Widget _buildHeader(ReciboGuardado recibo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Primera fila: Compañía a la izquierda, título centrado, número y fecha a la derecha
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Nombre de la compañía y NIT a la izquierda
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (recibo.nombreCompania.isNotEmpty) ...[
                    pw.Text(
                      recibo.nombreCompania,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                  ],
                  if (recibo.nitCompania.isNotEmpty) ...[
                    pw.Text(
                      'NIT ${recibo.nitCompania}',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Título RECIBOS DE CAJA centrado
            pw.Expanded(
              child: pw.Center(
                child: pw.Text(
                  'RECIBOS DE CAJA',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            // Número y fecha a la derecha
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Número: ${recibo.numeroRecibo}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Text(
                    'Fecha: ${recibo.fecha}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construir información del beneficiario/cliente
  static pw.Widget _buildClienteInfo(ReciboGuardado recibo) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8, bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Beneficiario:', recibo.cliente),
          pw.SizedBox(height: 4),
          _buildInfoRow('NIT / C.C:', recibo.nit),
        ],
      ),
    );
  }

  /// Construir fila de información
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  /// Construir formas de pago
  static pw.Widget _buildFormasPago(ReciboGuardado recibo) {
    if (recibo.formasPago.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: PdfColors.amber50,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: PdfColors.amber300, width: 1),
        ),
        child: pw.Center(
          child: pw.Text(
            'No se registraron formas de pago',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.amber900,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
            ),
          ),
          child: pw.Text(
            'FORMAS DE PAGO',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
              letterSpacing: 0.8,
            ),
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(
            color: PdfColors.black,
            width: 1,
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(2.5),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(2),
          },
          children: [
            // Encabezado de la tabla
            pw.TableRow(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              children: [
                _buildTableCell('Forma de Pago', isHeader: true),
                _buildTableCell('Valor', isHeader: true, align: pw.TextAlign.right),
                _buildTableCell('Cuenta / Documento', isHeader: true),
              ],
            ),
            // Filas de formas de pago
            ...recibo.formasPago.map((formaPago) {
              final forma = formaPago['formaPago'] as String? ?? 'N/A';
              final valor = formaPago['valor'] as num? ?? 0.0;
              final cuenta = formaPago['cuenta'] as String? ?? '';
              final documento = formaPago['documento'] as String? ?? '-';
              final cuentaDoc = cuenta.isNotEmpty ? cuenta : documento;
              
              return pw.TableRow(
                children: [
                  _buildTableCell(forma),
                  _buildTableCell(
                    _formatCurrency(valor.toDouble()),
                    align: pw.TextAlign.right,
                  ),
                  _buildTableCell(cuentaDoc),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  /// Construir celda de tabla
  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9.5,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.grey900 : PdfColors.grey800,
          letterSpacing: isHeader ? 0.3 : 0,
        ),
      ),
    );
  }

  /// Construir totales
  static pw.Widget _buildTotales(ReciboGuardado recibo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'TOTAL DEL RECIBO:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.Text(
                _formatCurrency(recibo.totalRecibo),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.black, height: 1),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'NETO RECIBIDO:',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.Text(
                _formatCurrency(recibo.netoRecibo),
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construir pie de página
  static pw.Widget _buildFooter(String fechaFormateada, String horaFormateada) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Documento generado electrónicamente',
            style: pw.TextStyle(
              fontSize: 7.5,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.Text(
            '$fechaFormateada $horaFormateada',
            style: pw.TextStyle(
              fontSize: 7.5,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Formatear moneda
  static String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
      locale: 'es_CO',
    );
    return formatter.format(value);
  }
}

