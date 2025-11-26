import 'package:flutter/material.dart';

/// Modal para seleccionar forma de pago
class SeleccionFormaPagoModal extends StatelessWidget {
  const SeleccionFormaPagoModal({super.key});

  @override
  Widget build(BuildContext context) {
    final formasPago = [
      {'codigo': 'TR', 'nombre': 'TRANSFERENCIA BAI'},
      {'codigo': 'EF', 'nombre': 'EFECTIVO'},
      {'codigo': 'CH', 'nombre': 'CHEQUE'},
      {'codigo': 'TC', 'nombre': 'TARJETA DE CREDITO'},
      {'codigo': 'TD', 'nombre': 'TARJETA DE DEBITO'},
      {'codigo': 'NE', 'nombre': 'NEGOCIABLE'},
      {'codigo': 'OT', 'nombre': 'OTRO'},
    ];

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Seleccionar Forma de Pago',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Lista de formas de pago
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: formasPago.length,
                itemBuilder: (context, index) {
                  final formaPago = formasPago[index];
                  return ListTile(
                    title: Text(formaPago['nombre']!),
                    subtitle: Text('Código: ${formaPago['codigo']}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context, formaPago);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

