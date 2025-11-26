import 'package:flutter/material.dart';

/// Modal para búsqueda y selección de conceptos
class BusquedaConceptosModal extends StatefulWidget {
  const BusquedaConceptosModal({super.key});

  @override
  State<BusquedaConceptosModal> createState() => _BusquedaConceptosModalState();
}

class _BusquedaConceptosModalState extends State<BusquedaConceptosModal> {
  final _searchController = TextEditingController();
  String _selectedReferencia = '';

  final List<Map<String, String>> _conceptos = [
    {'referencia': '001', 'descripcion': 'ANTICIPO DE CLIENTE'},
    {'referencia': '002', 'descripcion': 'CLIENTE RECOGIO CHEQUE EN EFECTIVO'},
    {'referencia': '003', 'descripcion': 'CHEQUE DEVUELTO RECIBIDO DE BANCOS'},
    {'referencia': '004', 'descripcion': 'DISMINUCION DE CAJA MENOR'},
    {'referencia': '005', 'descripcion': 'PRESTAMOS RECIBIDO DE SOCIOS'},
    {'referencia': '006', 'descripcion': 'INGRESOS RECIBIDOS DIAN'},
    {'referencia': '007', 'descripcion': 'PRESTAMOS RECIBIDOS DE TERCEROS'},
    {'referencia': '008', 'descripcion': 'INGRESOS POR INCAPACIDADES'},
    {'referencia': '009', 'descripcion': 'CAMBIO CHEQUE PARA PAGO PROVEEDORES'},
    {'referencia': '010', 'descripcion': 'RETENCION CREE NO PRACTICADA'},
    {'referencia': '011', 'descripcion': 'ANTICIPO RETENCION COMPRAS AL 1,5%-2013'},
    {'referencia': '012', 'descripcion': 'CAMBIO DE CHEQUE A PARTICULARES'},
    {'referencia': '013', 'descripcion': 'RETENC.FUENTE SALARIO NO PRACTICADA'},
    {'referencia': '014', 'descripcion': 'REINT.ANTIC. RETEICA TARIFA 5.4 X 1000'},
    {'referencia': '015', 'descripcion': 'REINTEGRO ANTIC.RETEFUENTE RENTA'},
    {'referencia': '016', 'descripcion': 'REINTEGRO ANTIC. RETEIVA'},
    {'referencia': '017', 'descripcion': 'APROVECHAMIENTO'},
    {'referencia': '018', 'descripcion': 'CONSIGNACION DE DESEMBARGO'},
    {'referencia': '019', 'descripcion': 'REINTEGRO DE RETEFUENTE NO CERTIFICADA'},
  ];

  List<Map<String, String>> _filteredConceptos = [];

  @override
  void initState() {
    super.initState();
    _filteredConceptos = _conceptos;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterConceptos(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredConceptos = _conceptos;
      } else {
        _filteredConceptos = _conceptos
            .where((concepto) =>
                concepto['referencia']!
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                concepto['descripcion']!
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      'Busqueda de Conceptos',
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

            // Búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: _filterConceptos,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.folder),
                    label: const Text('Retornar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Tabla de conceptos
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Header de la tabla
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Referencia',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Descripción',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Filas de la tabla
                      if (_filteredConceptos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No se encontraron conceptos',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...List.generate(_filteredConceptos.length, (index) {
                          final concepto = _filteredConceptos[index];
                          final isSelected = _selectedReferencia ==
                              concepto['referencia'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedReferencia =
                                    concepto['referencia']!;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue[100]
                                    : (index % 2 == 0
                                        ? Colors.white
                                        : Colors.grey[50]),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      concepto['referencia']!,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      concepto['descripcion']!,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),

            // Footer con botones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _selectedReferencia.isEmpty
                        ? null
                        : () {
                            final conceptoSeleccionado = _conceptos.firstWhere(
                              (c) => c['referencia'] == _selectedReferencia,
                            );
                            Navigator.pop(context, conceptoSeleccionado);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

