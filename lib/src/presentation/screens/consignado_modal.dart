import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/bank_account_notifier.dart';
import '../../domain/entities/bank_account.dart';

/// Modal para seleccionar consignado
class ConsignadoModal extends ConsumerStatefulWidget {
  const ConsignadoModal({super.key});

  @override
  ConsumerState<ConsignadoModal> createState() => _ConsignadoModalState();
}

class _ConsignadoModalState extends ConsumerState<ConsignadoModal> {
  final _searchController = TextEditingController();
  String _selectedConsignado = '';
  List<BankAccount> _filteredAccounts = [];

  @override
  void initState() {
    super.initState();
    // Las cuentas se cargan automáticamente en build()
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAccounts(String query, List<BankAccount> accounts) {
    setState(() {
      if (query.isEmpty) {
        _filteredAccounts = accounts;
      } else {
        _filteredAccounts = accounts
            .where((account) =>
                account.descripcion
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bankAccountState = ref.watch(bankAccountListNotifierProvider);
    
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
                      'Seleccionar Consignado',
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
                onChanged: (query) {
                  bankAccountState.whenData((accounts) {
                    _filterAccounts(query, accounts);
                  });
                },
              ),
            ),

            // Tabla de consignados
            Expanded(
              child: bankAccountState.when(
                data: (accounts) {
                  // Inicializar la lista filtrada si está vacía o si el texto de búsqueda está vacío
                  if (_filteredAccounts.isEmpty || _searchController.text.isEmpty) {
                    _filteredAccounts = accounts;
                  }
                  
                  return SingleChildScrollView(
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
                                  flex: 3,
                                  child: Text(
                                    'Descripción',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'ID',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Nro. Cuenta',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Filas de la tabla
                          if (_filteredAccounts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'No se encontraron cuentas bancarias',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          else
                            ...List.generate(_filteredAccounts.length, (index) {
                              final account = _filteredAccounts[index];
                              final isSelected = _selectedConsignado ==
                                  account.descripcion;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedConsignado = account.descripcion;
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
                                        flex: 3,
                                        child: Text(
                                          account.descripcion,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          account.id,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          account.nroCuenta ?? '-',
                                          textAlign: TextAlign.center,
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
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) => Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar cuentas bancarias',
                        style: TextStyle(color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(bankAccountListNotifierProvider.notifier).refresh();
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
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
                    onPressed: _selectedConsignado.isEmpty
                        ? null
                        : () {
                            // Buscar la cuenta seleccionada para obtener el número de cuenta
                            final selectedAccount = _filteredAccounts.firstWhere(
                              (account) => account.descripcion == _selectedConsignado,
                            );
                            Navigator.pop(context, {
                              'descripcion': _selectedConsignado,
                              'nroCuenta': selectedAccount.nroCuenta ?? '',
                            });
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

