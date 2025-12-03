import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/client.dart';
import '../providers/bank_account_notifier.dart';
import '../providers/company_notifier.dart';
import '../providers/factura_notifier.dart';
import '../providers/recibo_notifier.dart';
import 'busqueda_clientes_modal.dart';
import 'busqueda_conceptos_modal.dart';
import 'formas_pago_modal.dart';

/// Pantalla de formulario de Recaudos de Cartera
class RecaudosCarteraFormScreen extends ConsumerStatefulWidget {
  const RecaudosCarteraFormScreen({super.key});

  @override
  ConsumerState<RecaudosCarteraFormScreen> createState() =>
      _RecaudosCarteraFormScreenState();
}

class _RecaudosCarteraFormScreenState
    extends ConsumerState<RecaudosCarteraFormScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _observacionController =
      TextEditingController(); // Para Recaudos de Cartera
  final _observacionAnticipoController =
      TextEditingController(); // Para Anticipos y Recaudos

  // Controllers para los campos compartidos
  final _fechaController = TextEditingController();
  final _reciboController = TextEditingController();
  final _vrReciboController = TextEditingController();

  // Controllers para el tab de Recaudos de Cartera
  final _carteraClienteController = TextEditingController();
  final _carteraNitController = TextEditingController();
  final _carteraSaldoController = TextEditingController();
  int? _carteraCcSeleccionado;
  int? _carteraClienteSeleccionadoId;
  List<Map<String, dynamic>> _carteraFacturas = [];
  final List<Map<String, dynamic>> _carteraConceptos = [];
  String? _carteraConceptoSeleccionado;

  // Valores calculados (inicializados en 0)
  final double _descuentos = 0;
  double _retenciones = 0;
  final double _otrosIngresos = 0;
  double _netoRecibo = 0;

  // Número de cuenta del consignado seleccionado
  String? _nroCuentaConsignado;

  // Controladores para los campos Val. Recibo de cada factura
  final Map<int, TextEditingController> _valReciboControllers = {};

  // Estado del footer expandible
  bool _isFooterExpanded = true;
  final GlobalKey _footerKey = GlobalKey();

  // Contador para número de recibo autoincrementable
  static int _reciboCounter = 3641;

  // Variables para el tab de Anticipos
  String? _tipoAnticipoSeleccionado; // 'cliente' o null
  final _anticipoClienteController = TextEditingController();
  final _anticipoNitController = TextEditingController();
  final List<Map<String, dynamic>> _anticipoConceptos = [];
  final Map<int, TextEditingController> _anticipoValorControllers = {};
  int? _anticipoCcSeleccionado;

  // Controlador para el campo de búsqueda de facturas
  final _searchFacturaController = TextEditingController();
  String _searchFacturaText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Agregar listener al TabController para actualizar el footer cuando cambie de tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // El tab ya cambió, actualizar los totales
        _calcularTotales();
      }
    });

    _fechaController.text = _formatDate(DateTime.now());
    _reciboController.text = _generateReciboNumber();
    _carteraSaldoController.text = '0';
    _vrReciboController.text = '0';
    _calcularTotales();

    // Cargar compañías al inicializar (se cargan automáticamente en build())

    // Cargar cuentas bancarias (consignado) al inicializar para que estén listas cuando se abra el modal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar cuentas bancarias para el modal de consignado
      ref.read(bankAccountListNotifierProvider.notifier).refresh();

      // Agregar listener para cambios en el estado de facturas
      final notifier = ref.read<FacturaListNotifier>(
        facturaListNotifierProvider,
      );
      notifier.addListener(() {
        _onFacturaStateChanged(notifier.state);
      });
    });
  }

  /// Calcular totales dinámicamente
  void _calcularTotales({bool actualizarVrRecibo = true}) {
    // Calcular total de Val. Recibo de todas las facturas (suma de todos los valores)
    double totalVrRecibo = 0;
    for (final factura in _carteraFacturas) {
      totalVrRecibo += factura['valRecibo'] as double? ?? 0.0;
    }

    // Calcular total de retenciones
    double totalRetenciones = 0;
    for (final concepto in _carteraConceptos) {
      totalRetenciones += concepto['valor'] as double? ?? 0.0;
    }

    // Calcular total cartera (suma de todas las facturas del cliente)
    // Usar totalDb si está disponible, sino usar saldo
    double totalCartera = 0;
    for (final factura in _carteraFacturas) {
      // Intentar usar totalDb primero, luego saldo
      final totalDb = factura['totalDb'] as double?;
      final saldo = factura['saldo'] as double? ?? 0.0;
      totalCartera += totalDb ?? saldo;
    }

    setState(() {
      _retenciones = totalRetenciones;
      _carteraSaldoController.text = totalCartera > 0
          ? _formatCurrencyInput(totalCartera)
          : '0';

      // Actualizar Vr Recibo con la suma de todos los Val. Recibo de las facturas
      // Solo si no se está actualizando desde el campo Vr Recibo
      if (actualizarVrRecibo) {
        final formatted = _formatCurrencyInput(totalVrRecibo);
        if (_vrReciboController.text != formatted) {
          _vrReciboController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }

      _netoRecibo = totalVrRecibo - _descuentos - _retenciones + _otrosIngresos;
    });
  }

  /// Distribuir el valor de Vr Recibo entre las facturas automáticamente
  void _distribuirVrReciboEnFacturas(double valorTotal) {
    if (_carteraFacturas.isEmpty || valorTotal <= 0) {
      // Si no hay facturas o el valor es 0, limpiar todas las selecciones
      setState(() {
        for (final factura in _carteraFacturas) {
          factura['ok'] = false;
          factura['valRecibo'] = 0.0;
        }
        // Actualizar controladores
        for (final entry in _valReciboControllers.entries) {
          entry.value.text = '0';
        }
      });
      _calcularTotales(actualizarVrRecibo: false);
      return;
    }

    // Crear una copia de las facturas ordenadas por fecha (más antiguas primero)
    final facturasOrdenadas = List<Map<String, dynamic>>.from(_carteraFacturas);
    facturasOrdenadas.sort((a, b) {
      final fechaA = a['fecha'] as String? ?? '';
      final fechaB = b['fecha'] as String? ?? '';
      return fechaA.compareTo(fechaB);
    });

    double valorRestante = valorTotal;

    setState(() {
      // Primero, limpiar todas las facturas
      for (final factura in _carteraFacturas) {
        factura['ok'] = false;
        factura['valRecibo'] = 0.0;
      }

      // Distribuir el valor entre las facturas
      for (int i = 0; i < facturasOrdenadas.length && valorRestante > 0; i++) {
        final factura = facturasOrdenadas[i];
        final saldo = (factura['saldo'] as num?)?.toDouble() ?? 0.0;
        final totalDb = (factura['totalDb'] as num?)?.toDouble();
        final saldoDisponible = saldo > 0 ? saldo : (totalDb ?? 0.0);

        if (saldoDisponible > 0) {
          // Buscar el índice original de esta factura en _carteraFacturas
          final indexOriginal = _carteraFacturas.indexWhere(
            (f) =>
                f['factura'] == factura['factura'] &&
                f['sucursal'] == factura['sucursal'] &&
                f['tipo'] == factura['tipo'],
          );

          if (indexOriginal != -1) {
            if (valorRestante >= saldoDisponible) {
              // El valor cubre todo el saldo de esta factura
              _carteraFacturas[indexOriginal]['ok'] = true;
              _carteraFacturas[indexOriginal]['valRecibo'] = saldoDisponible;
              valorRestante -= saldoDisponible;
            } else {
              // El valor restante es menor que el saldo, asignar el restante a esta factura
              _carteraFacturas[indexOriginal]['ok'] = true;
              _carteraFacturas[indexOriginal]['valRecibo'] = valorRestante;
              valorRestante = 0;
              break;
            }
          }
        }
      }

      // Actualizar los controladores de Val. Recibo
      for (int i = 0; i < _carteraFacturas.length; i++) {
        final valRecibo =
            (_carteraFacturas[i]['valRecibo'] as num?)?.toDouble() ?? 0.0;
        if (_valReciboControllers.containsKey(i)) {
          _valReciboControllers[i]!.text = _formatCurrencyInput(valRecibo);
        }
      }
    });

    _calcularTotales(actualizarVrRecibo: false);
  }

  /// Cargar facturas del cliente seleccionado usando el notifier con paginación
  Future<void> _cargarFacturasCliente(int idTercero) async {
    // Debug: confirmar que se está usando el ID correcto (f9740_id)
    debugPrint(
      '📋 Cargando facturas para cliente con ID (f9740_id): $idTercero',
    );

    // Limpiar controladores de facturas anteriores
    for (final controller in _valReciboControllers.values) {
      controller.dispose();
    }
    _valReciboControllers.clear();

    setState(() {
      _carteraFacturas = [];
    });

    // Usar el notifier para cargar facturas con paginación
    // El idTercero aquí es el f9740_id del cliente seleccionado
    final notifier = ref.read<FacturaListNotifier>(facturaListNotifierProvider);

    // Asegurar que el listener esté agregado
    notifier.addListener(() {
      _onFacturaStateChanged(notifier.state);
    });

    await notifier.loadFacturas(idTercero: idTercero);

    // Forzar actualización inmediata después de cargar para asegurar que se muestren las facturas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentState = notifier.state;
        debugPrint(
          '🔄 Forzando actualización después de cargar: ${currentState.facturas.length} facturas',
        );
        _onFacturaStateChanged(currentState);
      }
    });
  }

  /// Actualizar la lista de facturas cuando el estado del notifier cambie
  void _onFacturaStateChanged(FacturaListState state) {
    if (!mounted) return;

    debugPrint(
      '🔄 _onFacturaStateChanged: ${state.facturas.length} facturas, isLoading: ${state.isLoading}, error: ${state.error?.message}',
    );

    // Convertir facturas a Map para mantener compatibilidad con el código existente
    final nuevasFacturas = state.facturas.map((f) {
      final map = f.toMap();
      // Inicializar valores por defecto si no existen
      map['ok'] = map['ok'] ?? false;
      map['valRecibo'] = map['valRecibo'] ?? 0.0;
      debugPrint(
        '📄 Factura mapeada: Factura=${map['factura']}, Sucursal="${map['sucursal']}", Tipo="${map['tipo']}", Fecha="${map['fecha']}", Valor=${map['valor']}, Saldo=${map['saldo']}, Ok=${map['ok']}, ValRecibo=${map['valRecibo']}',
      );
      return map;
    }).toList();

    debugPrint('✅ Total facturas procesadas: ${nuevasFacturas.length}');

    // Debug: verificar que las facturas tengan datos
    if (nuevasFacturas.isNotEmpty) {
      final primera = nuevasFacturas.first;
      debugPrint('🔍 Primera factura: $primera');
    }

    // Actualizar siempre que haya facturas nuevas o la cantidad cambie
    // Esto asegura que la UI se actualice correctamente
    final debeActualizar =
        !_listasFacturasSonIguales(_carteraFacturas, nuevasFacturas) ||
        _carteraFacturas.length != nuevasFacturas.length ||
        (nuevasFacturas.isNotEmpty && _carteraFacturas.isEmpty);

    if (debeActualizar || nuevasFacturas.isNotEmpty) {
      debugPrint(
        '🔄 Actualizando _carteraFacturas: ${_carteraFacturas.length} -> ${nuevasFacturas.length}',
      );

      // Usar SchedulerBinding para asegurar que el setState se ejecute en el frame correcto
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _carteraFacturas = nuevasFacturas;
            debugPrint(
              '✅ _carteraFacturas actualizado en setState: ${_carteraFacturas.length} facturas',
            );

            // Si hay error y no hay facturas, mostrar mensaje
            if (state.error != null && state.facturas.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error al cargar facturas: ${state.error!.message}',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }

            // Recalcular totales cuando se cargan las facturas
            if (!state.isLoading && state.facturas.isNotEmpty) {
              _calcularTotales();
            }
          });
        }
      });
    } else {
      // Aunque las listas sean iguales, recalcular totales por si acaso
      if (!state.isLoading && state.facturas.isNotEmpty) {
        _calcularTotales();
      }
    }
  }

  /// Comparar si dos listas de facturas son iguales
  bool _listasFacturasSonIguales(
    List<Map<String, dynamic>> lista1,
    List<Map<String, dynamic>> lista2,
  ) {
    if (lista1.length != lista2.length) return false;

    for (int i = 0; i < lista1.length; i++) {
      final f1 = lista1[i];
      final f2 = lista2[i];

      // Comparar campos clave para determinar si son la misma factura
      if (f1['factura'] != f2['factura'] ||
          f1['sucursal'] != f2['sucursal'] ||
          f1['tipo'] != f2['tipo']) {
        return false;
      }
    }

    return true;
  }

  /// Formatear moneda para input (sin símbolo $)
  String _formatCurrencyInput(double value) {
    // Formatear sin decimales, solo números enteros con separadores de miles
    final intValue = value.toInt();
    return intValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  /// Agregar concepto seleccionado a la lista
  void _agregarConcepto() {
    if (_carteraConceptoSeleccionado == null) return;

    // Calcular base (suma de facturas seleccionadas)
    double base = 0;
    for (final factura in _carteraFacturas) {
      if (factura['ok'] == true) {
        base += factura['valRecibo'] as double;
      }
    }

    String descripcion = '';
    double porcentaje = 0;
    double valor = 0;

    switch (_carteraConceptoSeleccionado) {
      case 'retencion_ica':
        descripcion = '003 RETENCION DE ICA 7 X 1000';
        porcentaje = 0.54;
        valor = base * 0.0054;
        break;
      case 'retencion_iva':
        descripcion = '004 RETENCION DE IVA';
        porcentaje = 0.19;
        valor = base * 0.0019;
        break;
      case 'descuento_comercial':
        descripcion = '005 DESCUENTO COMERCIAL';
        porcentaje = 5.0;
        valor = base * 0.05;
        break;
    }

    // Agregar el concepto
    setState(() {
      _carteraConceptos.add({
        'descripcion': descripcion,
        'base': base,
        'porcentaje': porcentaje,
        'valor': valor,
      });
      _carteraConceptoSeleccionado = null; // Vaciar el dropdown
      _calcularTotales();
    });
  }

  String _generateReciboNumber() {
    _reciboCounter++;
    return _reciboCounter.toString().padLeft(8, '0');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _observacionController.dispose();
    _observacionAnticipoController.dispose();
    _carteraClienteController.dispose();
    _carteraNitController.dispose();
    _carteraSaldoController.dispose();
    _fechaController.dispose();
    _reciboController.dispose();
    _vrReciboController.dispose();
    _anticipoClienteController.dispose();
    _anticipoNitController.dispose();
    for (final controller in _anticipoValorControllers.values) {
      controller.dispose();
    }
    // Dispose de todos los controladores de Val. Recibo
    for (final controller in _valReciboControllers.values) {
      controller.dispose();
    }
    _valReciboControllers.clear();
    _searchFacturaController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      title: const Text(
        'Recaudos de Cartera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Recaudos de Cartera'),
          Tab(text: 'Anticipos y Recaudos'),
        ],
      ),
    ),
    body: Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildRecaudosCarteraTab(), _buildAnticiposTab()],
            ),
          ),
          _buildFooter(),
        ],
      ),
    ),
  );

  /// Tab de Recaudos de Cartera
  Widget _buildRecaudosCarteraTab() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Información del recibo (compacta, no inputs)
        _buildReciboInfo(),
        const SizedBox(height: 16),

        // Información del cliente (sin título)
        _buildSectionCard(title: '', children: [_buildCCTField()]),
        const SizedBox(height: 16),

        // Información del cliente (mejorada visualmente)
        _buildClienteSection(),
        const SizedBox(height: 16),

        // Total cartera y valores (sin título)
        _buildSectionCard(
          title: '',
          children: [
            TextFormField(
              controller: _carteraSaldoController,
              readOnly: true,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'Total Cartera',
                labelStyle: const TextStyle(color: Colors.red),
                prefixIcon: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.red,
                ),
                prefixText: r'$ ',
                prefixStyle: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                filled: true,
                fillColor: Colors.red[50],
              ),
            ),
            const SizedBox(height: 12),
            _buildVrReciboField(),
          ],
        ),
        const SizedBox(height: 16),

        // Tabla de facturas
        _buildFacturasTable(),

        const SizedBox(height: 16),

        // Conceptos de descuentos y retenciones
        _buildDescuentosRetencionesSection(),

        const SizedBox(height: 16),

        // Campo de observación (sección separada)
        _buildObservacionSection(),
      ],
    ),
  );

  /// Tab de Anticipos
  Widget _buildAnticiposTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sección de cliente mejorada visualmente
        _buildAnticipoClienteSection(),
        const SizedBox(height: 16),

        // Tabla de conceptos
        if (_tipoAnticipoSeleccionado == 'cliente')
          _buildAnticipoConceptosTable(),

        const SizedBox(height: 16),

        // Conceptos de descuentos y retenciones (reutilizar la misma sección)
        _buildDescuentosRetencionesSection(),

        const SizedBox(height: 16),

        // Campo de observación
        _buildObservacionSection(),

        const SizedBox(height: 100), // Espacio para el footer
      ],
    ),
  );

  /// Construir tabla de conceptos de anticipos
  Widget _buildAnticipoConceptosTable() => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header de la tabla
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'Conceptos',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Detalle',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Cuenta',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Filas de la tabla (mínimo 5 filas vacías)
        ...List.generate(
          _anticipoConceptos.length > 5 ? _anticipoConceptos.length : 5,
          (index) {
            if (index < _anticipoConceptos.length) {
              final concepto = _anticipoConceptos[index];
              return _buildAnticipoConceptoRow(index, concepto);
            } else {
              return _buildAnticipoConceptoRowEmpty(index);
            }
          },
        ),
      ],
    ),
  );

  /// Construir fila de concepto con datos
  Widget _buildAnticipoConceptoRow(int index, Map<String, dynamic> concepto) {
    final valorController = _getAnticipoValorController(index);
    final tieneConcepto =
        (concepto['referencia'] as String?)?.isNotEmpty ?? false;

    return InkWell(
      onTap: () {
        _mostrarModalConceptos(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: index % 2 == 0 ? Colors.white : Colors.grey[50],
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (tieneConcepto) ...[
                  Expanded(
                    child: Text(
                      (concepto['referencia'] as String?) ?? '',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      (concepto['descripcion'] as String?) ?? '',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      (concepto['cuenta'] as String?) ?? '',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  // Botón minimalista para quitar el concepto
                  SizedBox(
                    width: 24,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      color: Colors.grey[600],
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Quitar concepto',
                      onPressed: () {
                        _quitarAnticipoConcepto(index);
                      },
                    ),
                  ),
                ] else ...[
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Click para seleccionar concepto',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            // Input de valor debajo del concepto cuando está seleccionado
            if (tieneConcepto) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: 200,
                child: TextFormField(
                  controller: valorController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    prefixText: r'$ ',
                    prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    // Limpiar el valor de caracteres no numéricos
                    final String cleanValue = value.replaceAll(
                      RegExp(r'[^\d]'),
                      '',
                    );

                    // Convertir a número
                    final numValue = double.tryParse(cleanValue) ?? 0.0;

                    // Formatear con separadores de miles
                    final formatted = _formatCurrencyInput(numValue);

                    // Actualizar el controlador solo si el valor formateado es diferente
                    if (valorController.text != formatted) {
                      valorController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }

                    setState(() {
                      _anticipoConceptos[index]['valor'] = numValue;
                      _calcularTotalesAnticipos();
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Construir fila vacía de concepto
  Widget _buildAnticipoConceptoRowEmpty(int index) => InkWell(
    onTap: () {
      _mostrarModalConceptos(index);
    },
    child: Container(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Icon(Icons.touch_app, size: 16, color: Colors.blue[600]),
                const SizedBox(width: 4),
                Text(
                  'Click para seleccionar concepto',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  /// Mostrar modal de conceptos
  void _mostrarModalConceptos(int index) {
    showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const BusquedaConceptosModal(),
    ).then((concepto) {
      if (concepto != null && mounted) {
        setState(() {
          // Si el índice es mayor que la lista, agregar nuevas filas vacías
          while (_anticipoConceptos.length <= index) {
            _anticipoConceptos.add({
              'referencia': '',
              'descripcion': '',
              'cuenta': '',
              'valor': 0.0,
            });
          }

          _anticipoConceptos[index] = {
            'referencia': concepto['referencia'] ?? '',
            'descripcion': concepto['descripcion'] ?? '',
            'cuenta': '28050501', // Cuenta por defecto
            'valor': _anticipoConceptos[index]['valor'] ?? 0.0,
          };

          _calcularTotalesAnticipos();
        });
      }
    });
  }

  /// Obtener o crear controlador de valor para concepto
  TextEditingController _getAnticipoValorController(int index) {
    if (!_anticipoValorControllers.containsKey(index)) {
      final valor = (_anticipoConceptos[index]['valor'] as double?) ?? 0.0;
      _anticipoValorControllers[index] = TextEditingController(
        text: valor > 0 ? _formatCurrencyInput(valor) : '',
      );
    }
    return _anticipoValorControllers[index]!;
  }

  /// Quitar un concepto de anticipo y restablecer valores
  void _quitarAnticipoConcepto(int index) {
    if (index >= _anticipoConceptos.length) return;

    setState(() {
      // Limpiar el controlador de valor si existe
      if (_anticipoValorControllers.containsKey(index)) {
        _anticipoValorControllers[index]!.dispose();
        _anticipoValorControllers.remove(index);
      }

      // Eliminar el concepto de la lista
      _anticipoConceptos.removeAt(index);

      // Reorganizar los controladores restantes
      final keysToUpdate = <int, TextEditingController>{};
      _anticipoValorControllers.forEach((key, controller) {
        if (key > index) {
          keysToUpdate[key - 1] = controller;
        } else if (key < index) {
          keysToUpdate[key] = controller;
        }
      });
      _anticipoValorControllers.clear();
      _anticipoValorControllers.addAll(keysToUpdate);

      // Recalcular totales
      _calcularTotalesAnticipos();
    });
  }

  /// Calcular totales para anticipos
  void _calcularTotalesAnticipos() {
    double totalConceptos = 0;
    for (final concepto in _anticipoConceptos) {
      totalConceptos += concepto['valor'] as double? ?? 0.0;
    }

    setState(() {
      _netoRecibo =
          totalConceptos - _descuentos - _retenciones + _otrosIngresos;
    });
  }

  /// Obtener el total de ingresos según el tab activo
  double _getTotalIngresos() {
    final currentTab = _tabController.index;
    if (currentTab == 0) {
      // Tab de Recaudos de Cartera: suma de Val. Recibo de facturas
      double totalVrRecibo = 0;
      for (final factura in _carteraFacturas) {
        totalVrRecibo += factura['valRecibo'] as double? ?? 0.0;
      }
      return totalVrRecibo;
    } else {
      // Tab de Anticipos: suma de valores de conceptos de anticipos
      double totalConceptos = 0;
      for (final concepto in _anticipoConceptos) {
        totalConceptos += concepto['valor'] as double? ?? 0.0;
      }
      return totalConceptos;
    }
  }

  /// Obtener el neto recibo según el tab activo
  double _getNetoRecibo() {
    final totalIngresos = _getTotalIngresos();
    return totalIngresos - _descuentos - _retenciones + _otrosIngresos;
  }

  /// Construir tarjeta de sección
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    ),
  );

  /// Construir campo de Valor Recibo con formato y color verde
  Widget _buildVrReciboField() => TextFormField(
    controller: _vrReciboController,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
    decoration: InputDecoration(
      labelText: 'Vr Recibo',
      labelStyle: const TextStyle(color: Colors.green),
      prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
      prefixText: r'$ ',
      prefixStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.green),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.green),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      filled: true,
      fillColor: Colors.green[50],
      hintText: 'Ingrese el valor total a distribuir',
      helperText: 'Valor distribuido automáticamente entre las facturas',
    ),
    onChanged: (value) {
      // Limpiar el valor de caracteres no numéricos
      final String cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');

      // Convertir a número
      final numValue = double.tryParse(cleanValue) ?? 0.0;

      // Calcular el total de la cartera (suma de todos los saldos de facturas)
      double totalCartera = 0;
      for (final factura in _carteraFacturas) {
        final saldo = (factura['saldo'] as num?)?.toDouble() ?? 0.0;
        final totalDb = (factura['totalDb'] as num?)?.toDouble() ?? 0.0;
        totalCartera += saldo > 0 ? saldo : totalDb;
      }

      // Si el valor ingresado es mayor al total de la cartera, ajustarlo al total de la cartera
      double valorAjustado = numValue;
      if (numValue > totalCartera && totalCartera > 0) {
        valorAjustado = totalCartera;
        final formattedAjustado = _formatCurrencyInput(valorAjustado);
        _vrReciboController.value = TextEditingValue(
          text: formattedAjustado,
          selection: TextSelection.collapsed(offset: formattedAjustado.length),
        );
      } else {
        // Formatear con separadores de miles
        final formatted = _formatCurrencyInput(numValue);

        // Actualizar el controlador solo si el valor formateado es diferente
        if (_vrReciboController.text != formatted) {
          _vrReciboController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }

      // Distribuir el valor ajustado entre las facturas
      _distribuirVrReciboEnFacturas(valorAjustado);
    },
  );

  /// Construir campo de NIT con modal de búsqueda
  Widget _buildNitField() => TextFormField(
    controller: _carteraNitController,
    readOnly: true,
    decoration: InputDecoration(
      labelText: 'Nº Recaudo Vdor Nit',
      prefixIcon: const Icon(Icons.badge_outlined),
      suffixIcon: const Icon(Icons.search),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[600]!, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    onTap: () async {
      final cliente = await showGeneralDialog<Client>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Búsqueda de Clientes',
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BusquedaClientesModal(),
        transitionBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            ),
      );
      if (cliente != null && mounted) {
        setState(() {
          _carteraClienteController.text = cliente.fullName;
          _carteraNitController.text = cliente.nit;
          // Guardar el ID del cliente (f9740_id) para validaciones
          _carteraClienteSeleccionadoId = cliente.id;
          // Cargar facturas del cliente seleccionado usando el f9740_id como id_tercero
          // El cliente.id contiene el valor de f9740_id del cliente seleccionado
          _cargarFacturasCliente(cliente.id);
        });
      }
    },
  );

  /// Construir sección de cliente (mejorada visualmente)
  Widget _buildClienteSection() => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Información del Cliente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNitField(),
            const SizedBox(height: 12),
            _buildClienteField(),
          ],
        ),
      ),
    ),
  );

  /// Construir campo de cliente (solo lectura)
  Widget _buildClienteField() => TextFormField(
    controller: _carteraClienteController,
    readOnly: true,
    decoration: InputDecoration(
      labelText: 'Cliente',
      prefixIcon: const Icon(Icons.person_outline),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[600]!, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  /// Construir sección de cliente para anticipos (mejorada visualmente)
  Widget _buildAnticipoClienteSection() => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Información del Cliente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Radio<String>(
                  value: 'cliente',
                  groupValue: _tipoAnticipoSeleccionado,
                  onChanged: (value) {
                    setState(() {
                      _tipoAnticipoSeleccionado = value;
                      if (value != 'cliente') {
                        _anticipoClienteController.clear();
                        _anticipoNitController.clear();
                        _anticipoConceptos.clear();
                      }
                    });
                  },
                ),
                const Text('Cliente'),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _anticipoClienteController,
              readOnly: true,
              enabled: _tipoAnticipoSeleccionado == 'cliente',
              decoration: InputDecoration(
                labelText: 'Cliente',
                prefixIcon: const Icon(Icons.person_outline),
                suffixIcon: _tipoAnticipoSeleccionado == 'cliente'
                    ? const Icon(Icons.search)
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[600]!, width: 2),
                ),
                filled: true,
                fillColor: _tipoAnticipoSeleccionado == 'cliente'
                    ? Colors.white
                    : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onTap: _tipoAnticipoSeleccionado == 'cliente'
                  ? () async {
                      final cliente = await showGeneralDialog<Client>(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: 'Búsqueda de Clientes',
                        barrierColor: Colors.black54,
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const BusquedaClientesModal(),
                        transitionBuilder:
                            (context, animation, secondaryAnimation, child) =>
                                SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 0.3),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                ),
                      );
                      if (cliente != null && mounted) {
                        setState(() {
                          _anticipoClienteController.text = cliente.fullName;
                          _anticipoNitController.text = cliente.nit;
                        });
                      }
                    }
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _anticipoNitController,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'C.C o Nit',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[600]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  /// Construir información del recibo (compacta, no inputs)
  Widget _buildReciboInfo() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.blue[50],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.blue[200]!),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'Fecha: ${_fechaController.text}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.receipt, size: 18, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Recibo No: ${_reciboController.text}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  /// Construir campo C.C seleccionable
  Widget _buildCCTField() {
    final companyState = ref.watch(companyListNotifierProvider);

    return companyState.when(
      data: (companies) {
        // Si hay compañías y no hay ninguna seleccionada, seleccionar la primera automáticamente
        if (companies.isNotEmpty && _carteraCcSeleccionado == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _carteraCcSeleccionado = companies.first.id;
              });
            }
          });
        }

        return DropdownButtonFormField<int>(
          initialValue: _carteraCcSeleccionado,
          decoration: InputDecoration(
            labelText: 'C.C',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.business),
            errorStyle: const TextStyle(height: 0, fontSize: 0),
          ),
          hint: const Text('Seleccione C.C'),
          isExpanded: true,
          items: companies
              .map(
                (company) => DropdownMenuItem<int>(
                  value: company.id,
                  child: Text(
                    company.displayName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _carteraCcSeleccionado = value;
            });
          },
        );
      },
      loading: () => DropdownButtonFormField<int>(
        initialValue: _carteraCcSeleccionado,
        decoration: InputDecoration(
          labelText: 'C.C',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const SizedBox(
            width: 20,
            height: 20,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorStyle: const TextStyle(height: 0, fontSize: 0),
        ),
        hint: const Text('Cargando compañías...'),
        isExpanded: true,
        items: const [],
        onChanged: null,
      ),
      error: (error, stackTrace) {
        final errorMessage = error.toString();
        final isConnectionError =
            errorMessage.contains('conexión') ||
            errorMessage.contains('conectar') ||
            errorMessage.contains('timeout') ||
            errorMessage.contains('Tiempo de espera');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _carteraCcSeleccionado,
              decoration: InputDecoration(
                labelText: 'C.C',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.red[50],
                prefixIcon: const Icon(Icons.error_outline, color: Colors.red),
                errorStyle: const TextStyle(height: 0, fontSize: 0),
                errorText: 'Error al cargar',
              ),
              hint: Text(
                isConnectionError
                    ? 'Error de conexión'
                    : 'Error al cargar compañías',
                style: const TextStyle(color: Colors.red),
              ),
              isExpanded: true,
              items: const [],
              onChanged: null,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                isConnectionError
                    ? 'No se pudo conectar al servidor. Verifica la configuración de red.'
                    : errorMessage.length > 100
                    ? '${errorMessage.substring(0, 100)}...'
                    : errorMessage,
                style: TextStyle(fontSize: 12, color: Colors.red[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(companyListNotifierProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Construir tabla de facturas
  Widget _buildFacturasTable() {
    final facturaState = ref.watch<FacturaListState>(facturaListStateProvider);

    // Preparar facturas del estado del provider con valores por defecto
    final facturasFromState = facturaState.facturas.map((f) {
      final map = f.toMap();
      map['ok'] = map['ok'] ?? false;
      map['valRecibo'] = map['valRecibo'] ?? 0.0;
      return map;
    }).toList();

    // Sincronizar _carteraFacturas con el estado del provider cuando sea necesario
    // Si _carteraFacturas está vacío pero el estado tiene facturas, programar actualización
    if (_carteraFacturas.isEmpty && facturaState.facturas.isNotEmpty) {
      debugPrint(
        '🔄 Programando sincronización de _carteraFacturas: ${facturasFromState.length} facturas',
      );
      // Programar actualización para el siguiente frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _carteraFacturas = facturasFromState;
            debugPrint(
              '✅ _carteraFacturas sincronizado: ${_carteraFacturas.length} facturas',
            );
            _calcularTotales();
          });
        }
      });
    } else if (_carteraFacturas.length != facturaState.facturas.length &&
        facturaState.facturas.isNotEmpty) {
      // Si la cantidad de facturas cambió, actualizar (nuevo cliente seleccionado)
      debugPrint(
        '🔄 Programando actualización de _carteraFacturas por cambio de cantidad: ${facturasFromState.length} facturas',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _carteraFacturas = facturasFromState;
            debugPrint(
              '✅ _carteraFacturas actualizado: ${_carteraFacturas.length} facturas',
            );
            _calcularTotales();
          });
        }
      });
    }

    // Priorizar _carteraFacturas sobre el estado del provider porque _carteraFacturas se actualiza
    // inmediatamente cuando cambia el estado y puede tener cambios locales del usuario
    // Solo usar el estado del provider si _carteraFacturas está vacío
    final facturasBase = _carteraFacturas.isNotEmpty
        ? _carteraFacturas
        : (facturaState.facturas.isNotEmpty
              ? facturasFromState
              : <Map<String, dynamic>>[]);

    // Filtrar facturas por número de factura si hay texto de búsqueda
    final facturasParaMostrar = _searchFacturaText.isEmpty
        ? facturasBase
        : facturasBase.where((factura) {
            final facturaNum =
                (factura['factura'] as String?)?.toLowerCase() ?? '';
            return facturaNum.contains(_searchFacturaText.toLowerCase());
          }).toList();

    debugPrint(
      '📊 _buildFacturasTable: _carteraFacturas.length=${_carteraFacturas.length}, facturaState.facturas.length=${facturaState.facturas.length}, facturasParaMostrar.length=${facturasParaMostrar.length}, isLoading=${facturaState.isLoading}, error=${facturaState.error?.message}',
    );

    // Debug adicional: mostrar contenido de las primeras facturas
    if (facturasParaMostrar.isNotEmpty) {
      debugPrint(
        '📋 Primera factura en facturasParaMostrar: ${facturasParaMostrar.first}',
      );
    }
    if (_carteraFacturas.isNotEmpty) {
      debugPrint(
        '📋 Primera factura en _carteraFacturas: ${_carteraFacturas.first}',
      );
    }
    if (facturaState.facturas.isNotEmpty) {
      debugPrint(
        '📋 Primera factura en facturaState: ${facturaState.facturas.first.toMap()}',
      );
    }

    // Si no hay cliente seleccionado, mostrar mensaje
    if (_carteraClienteSeleccionadoId == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Seleccionar Cliente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Por favor seleccione un cliente para ver sus facturas',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Mostrar indicador de carga si se están cargando facturas Y no hay facturas para mostrar
    if (facturaState.isLoading && facturasParaMostrar.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Cargando facturas...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Por favor espere',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Si no hay facturas para mostrar y no está cargando, mostrar mensaje
    // IMPORTANTE: Verificar facturasParaMostrar, no solo facturaState.facturas
    if (!facturaState.isLoading &&
        facturasParaMostrar.isEmpty &&
        facturaState.error == null) {
      debugPrint(
        '⚠️ Mostrando mensaje "No hay facturas": facturasParaMostrar.isEmpty=${facturasParaMostrar.isEmpty}, _carteraFacturas.length=${_carteraFacturas.length}, facturaState.facturas.length=${facturaState.facturas.length}',
      );
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay facturas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'El cliente seleccionado no tiene facturas pendientes',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Si hay facturas para mostrar, mostrar la tabla
    if (facturasParaMostrar.isEmpty) {
      debugPrint(
        '⚠️ facturasParaMostrar está vacío pero llegamos aquí. Esto no debería pasar.',
      );
    }

    // Calcular total del saldo de todas las facturas
    double totalSaldo = 0;
    for (final factura in facturasParaMostrar) {
      totalSaldo += (factura['saldo'] as num?)?.toDouble() ?? 0.0;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Facturas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    if (facturasParaMostrar.length != facturasBase.length)
                      Text(
                        '${facturasParaMostrar.length} de ${facturasBase.length}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Campo de búsqueda
                TextField(
                  controller: _searchFacturaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por número de factura...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchFacturaText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchFacturaController.clear();
                                _searchFacturaText = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchFacturaText = value;
                    });
                  },
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              // Para pantallas pequeñas, mostrar lista vertical
              if (constraints.maxWidth < 600) {
                return _buildFacturasList();
              }
              // Para pantallas grandes, mostrar tabla horizontal
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.blue[50]),
                  columns: const [
                    DataColumn(label: Text('Sucursal')),
                    DataColumn(label: Text('Tipo')),
                    DataColumn(label: Text('Factura')),
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('Vence')),
                    DataColumn(label: Text('Valor'), numeric: true),
                    DataColumn(label: Text('Abonos'), numeric: true),
                    DataColumn(label: Text('Saldo'), numeric: true),
                    DataColumn(label: Text('Val. Recibo'), numeric: true),
                    DataColumn(label: Text('Ok')),
                  ],
                  rows: facturasParaMostrar.isEmpty
                      ? []
                      : facturasParaMostrar.map((factura) {
                          debugPrint(
                            '🔍 Construyendo fila para factura: ${factura['factura']}',
                          );
                          return _buildDataRow(
                            (factura['sucursal'] as String?)?.trim() ?? '',
                            (factura['tipo'] as String?)?.trim() ?? '',
                            (factura['factura'] as String?)?.trim() ?? '',
                            (factura['fecha'] as String?)?.trim() ?? '',
                            (factura['vence'] as String?)?.trim() ?? '',
                            (factura['valor'] as num?)?.toDouble() ?? 0.0,
                            (factura['abonos'] as num?)?.toDouble() ?? 0.0,
                            (factura['saldo'] as num?)?.toDouble() ?? 0.0,
                            (factura['valRecibo'] as num?)?.toDouble() ?? 0.0,
                            factura['ok'] as bool? ?? false,
                          );
                        }).toList(),
                ),
              );
            },
          ),
          // Footer con total del saldo y controles de paginación
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                // Total del saldo
                if (facturasParaMostrar.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Saldo:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          _formatCurrency(totalSaldo),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Controles de paginación
                if (facturaState.total > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed:
                              (facturaState.currentPage > 1) &&
                                  (!facturaState.isLoadingMore)
                              ? () {
                                  final notifier = ref
                                      .read<FacturaListNotifier>(
                                        facturaListNotifierProvider,
                                      );
                                  notifier.loadPreviousPage();
                                }
                              : null,
                          tooltip: 'Página anterior',
                        ),
                        Text(
                          _getPageRange(facturaState),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed:
                              facturaState.hasMore &&
                                  (!facturaState.isLoadingMore)
                              ? () {
                                  final notifier = ref
                                      .read<FacturaListNotifier>(
                                        facturaListNotifierProvider,
                                      );
                                  notifier.loadNextPage();
                                }
                              : null,
                          tooltip: 'Página siguiente',
                        ),
                        if (facturaState.isLoadingMore == true)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Obtener el rango de registros de la página actual
  String _getPageRange(FacturaListState state) {
    if (state.total == 0) return 'Sin registros';

    final start = ((state.currentPage - 1) * state.pageSize) + 1;
    final end = (state.currentPage * state.pageSize) > state.total
        ? state.total
        : (state.currentPage * state.pageSize);

    return '$start - $end de ${state.total}';
  }

  /// Obtener o crear el controlador para Val. Recibo de una factura
  TextEditingController _getValReciboController(int index) {
    if (!_valReciboControllers.containsKey(index)) {
      final factura = _carteraFacturas[index];
      _valReciboControllers[index] = TextEditingController(
        text: _formatCurrencyInput(factura['valRecibo'] as double),
      );
    } else {
      // Actualizar el texto del controlador si el valor cambió externamente
      final factura = _carteraFacturas[index];
      final currentValue = _formatCurrencyInput(factura['valRecibo'] as double);
      if (_valReciboControllers[index]!.text != currentValue) {
        _valReciboControllers[index]!.text = currentValue;
      }
    }
    return _valReciboControllers[index]!;
  }

  /// Construir lista de facturas para móviles
  Widget _buildFacturasList() {
    final facturaState = ref.watch<FacturaListState>(facturaListStateProvider);

    // Preparar facturas del estado del provider con valores por defecto
    final facturasFromState = facturaState.facturas.map((f) {
      final map = f.toMap();
      map['ok'] = map['ok'] ?? false;
      map['valRecibo'] = map['valRecibo'] ?? 0.0;
      return map;
    }).toList();

    // Priorizar _carteraFacturas sobre el estado del provider
    final facturasBase = _carteraFacturas.isNotEmpty
        ? _carteraFacturas
        : (facturaState.facturas.isNotEmpty
              ? facturasFromState
              : <Map<String, dynamic>>[]);

    // Filtrar facturas por número de factura si hay texto de búsqueda
    final facturasParaMostrar = _searchFacturaText.isEmpty
        ? facturasBase
        : facturasBase.where((factura) {
            final facturaNum =
                (factura['factura'] as String?)?.toLowerCase() ?? '';
            return facturaNum.contains(_searchFacturaText.toLowerCase());
          }).toList();

    // Limpiar controladores de facturas que ya no existen
    final existingIndices = List.generate(facturasParaMostrar.length, (i) => i);
    _valReciboControllers.removeWhere(
      (key, value) => !existingIndices.contains(key),
    );

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: facturasParaMostrar.length,
      itemBuilder: (context, index) {
        final factura = facturasParaMostrar[index];

        final isChecked = factura['ok'] as bool;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: isChecked ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isChecked ? Colors.green : Colors.transparent,
              width: isChecked ? 2 : 0,
            ),
          ),
          color: isChecked ? Colors.green[50] : null,
          child: ListTile(
            leading: Checkbox(
              value: isChecked,
              onChanged: (value) {
                setState(() {
                  final isChecked = value ?? false;
                  // Actualizar en facturasParaMostrar y sincronizar con _carteraFacturas
                  facturasParaMostrar[index]['ok'] = isChecked;
                  if (facturasParaMostrar != _carteraFacturas &&
                      index < _carteraFacturas.length) {
                    _carteraFacturas[index]['ok'] = isChecked;
                  } else if (facturasParaMostrar == _carteraFacturas) {
                    _carteraFacturas[index]['ok'] = isChecked;
                  }

                  if (isChecked) {
                    // Si se marca la factura y no tiene valor en Val. Recibo, asignar el saldo
                    final valReciboActual =
                        (facturasParaMostrar[index]['valRecibo'] as num?)
                            ?.toDouble() ??
                        0.0;
                    if (valReciboActual == 0.0) {
                      // Usar saldo si está disponible, sino usar totalDb
                      final saldo =
                          (facturasParaMostrar[index]['saldo'] as num?)
                              ?.toDouble();
                      final totalDb =
                          (facturasParaMostrar[index]['totalDb'] as num?)
                              ?.toDouble();
                      final valorAsignar = saldo ?? totalDb ?? 0.0;
                      facturasParaMostrar[index]['valRecibo'] = valorAsignar;

                      // Sincronizar con _carteraFacturas
                      if (facturasParaMostrar != _carteraFacturas &&
                          index < _carteraFacturas.length) {
                        _carteraFacturas[index]['valRecibo'] = valorAsignar;
                      } else if (facturasParaMostrar == _carteraFacturas) {
                        _carteraFacturas[index]['valRecibo'] = valorAsignar;
                      }

                      // Actualizar el controlador si existe
                      if (_valReciboControllers.containsKey(index)) {
                        final formatted = _formatCurrencyInput(valorAsignar);
                        _valReciboControllers[index]!.text = formatted;
                      }
                    }
                  } else {
                    // Si se desmarca, poner Val. Recibo en 0
                    facturasParaMostrar[index]['valRecibo'] = 0.0;

                    // Sincronizar con _carteraFacturas
                    if (facturasParaMostrar != _carteraFacturas &&
                        index < _carteraFacturas.length) {
                      _carteraFacturas[index]['valRecibo'] = 0.0;
                    } else if (facturasParaMostrar == _carteraFacturas) {
                      _carteraFacturas[index]['valRecibo'] = 0.0;
                    }

                    // Actualizar el controlador si existe
                    if (_valReciboControllers.containsKey(index)) {
                      _valReciboControllers[index]!.text = '0';
                    }
                  }

                  _calcularTotales();
                });
              },
            ),
            title: Text(
              'Factura ${factura['factura']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isChecked ? Colors.green[800] : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${factura['tipo']} - ${factura['fecha']}'),
                const SizedBox(height: 4),
                Text(
                  'Saldo: ${_formatCurrency((factura['saldo'] as num?)?.toDouble() ?? 0.0)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _mostrarDetalleFacturaModal(context, index);
            },
          ),
        );
      },
    );
  }

  /// Mostrar modal con detalle de factura
  void _mostrarDetalleFacturaModal(BuildContext context, int index) {
    final factura = _carteraFacturas[index];
    final valReciboController = _getValReciboController(index);

    // Helper para formatear valores opcionales
    String formatOptionalValue(
      dynamic value, {
      String Function(dynamic)? formatter,
    }) {
      if (value == null) return 'N/A';
      if (formatter != null) return formatter(value);
      return value.toString();
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Factura ${factura['factura'] ?? 'N/A'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Contenido scrolleable
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Información básica
                    const Text(
                      'Información Básica',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFacturaModalRow(
                      'Sucursal',
                      formatOptionalValue(factura['sucursal']),
                    ),
                    _buildFacturaModalRow(
                      'Tipo',
                      formatOptionalValue(factura['tipo']),
                    ),
                    _buildFacturaModalRow(
                      'Factura',
                      formatOptionalValue(factura['factura']),
                    ),
                    _buildFacturaModalRow(
                      'Prefijo',
                      formatOptionalValue(factura['prefijo']),
                    ),
                    _buildFacturaModalRow(
                      'Fecha',
                      formatOptionalValue(factura['fecha']),
                    ),
                    _buildFacturaModalRow(
                      'Vence',
                      formatOptionalValue(factura['vence']),
                    ),
                    _buildFacturaModalRow(
                      'Período',
                      formatOptionalValue(factura['idPeriodo']),
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Valores financieros
                    const Text(
                      'Valores Financieros',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFacturaModalRow(
                      'Valor',
                      formatOptionalValue(
                        factura['valor'] ?? factura['totalDb'],
                        formatter: (v) => _formatCurrency(v as double),
                      ),
                    ),
                    _buildFacturaModalRow(
                      'Total Débito',
                      formatOptionalValue(
                        factura['totalDb'],
                        formatter: (v) => _formatCurrency(v as double),
                      ),
                    ),
                    _buildFacturaModalRow(
                      'Total Crédito',
                      formatOptionalValue(
                        factura['totalCr'],
                        formatter: (v) => _formatCurrency(v as double),
                      ),
                    ),
                    _buildFacturaModalRow(
                      'Abonos',
                      formatOptionalValue(
                        factura['abonos'],
                        formatter: (v) => _formatCurrency(v as double),
                      ),
                    ),
                    _buildFacturaModalRow(
                      'Saldo',
                      formatOptionalValue(
                        factura['saldo'],
                        formatter: (v) => _formatCurrency(v as double),
                      ),
                    ),
                    _buildFacturaModalRow(
                      'Base Gravable',
                      formatOptionalValue(
                        factura['totalBaseGravable'],
                        formatter: (v) => _formatCurrency(v as double),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Información adicional
                    const Text(
                      'Información Adicional',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFacturaModalRow(
                      'ID Compañía',
                      formatOptionalValue(factura['idCia']),
                    ),
                    _buildFacturaModalRow(
                      'RowID',
                      formatOptionalValue(factura['rowid']),
                    ),
                    _buildFacturaModalRow(
                      'ID Tercero',
                      formatOptionalValue(factura['rowidTercero']),
                    ),
                    _buildFacturaModalRow(
                      'Clase Documento',
                      formatOptionalValue(factura['idClaseDocto']),
                    ),
                    _buildFacturaModalRow(
                      'Estado',
                      formatOptionalValue(factura['indEstado']),
                    ),
                    _buildFacturaModalRow(
                      'Moneda',
                      formatOptionalValue(factura['idMonedaDocto']),
                    ),
                    _buildFacturaModalRow(
                      'Referencia',
                      formatOptionalValue(factura['referencia']),
                    ),
                    if (factura['notas'] != null &&
                        factura['notas'].toString().isNotEmpty)
                      _buildFacturaModalRow(
                        'Notas',
                        formatOptionalValue(factura['notas']),
                      ),
                  ],
                ),
              ),
            ),

            // Campo fijo para Val. Recibo (fuera del scroll)
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Valor a Recibir',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: valReciboController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'Val. Recibo',
                labelStyle: const TextStyle(color: Colors.green),
                prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
                prefixText: r'$ ',
                prefixStyle: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                filled: true,
                fillColor: Colors.green[50],
              ),
              onChanged: (value) {
                // Solo permitir números enteros
                final String cleanValue = value.replaceAll(
                  RegExp(r'[^\d]'),
                  '',
                );

                // Convertir a número entero
                final numValue = int.tryParse(cleanValue) ?? 0;

                // Si se ingresa un valor y la factura está desmarcada, marcarla automáticamente
                if (numValue > 0 && !(factura['ok'] as bool)) {
                  setState(() {
                    _carteraFacturas[index]['ok'] = true;
                  });
                }

                // Formatear con separadores de miles
                final formatted = numValue.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (m) => '${m[1]},',
                );

                // Actualizar el controlador solo si el valor formateado es diferente
                if (valReciboController.text != formatted) {
                  // Calcular nueva posición del cursor al final del texto
                  final newCursorPosition = formatted.length;

                  valReciboController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: newCursorPosition,
                    ),
                  );
                }

                // Actualizar el valor y calcular totales
                _carteraFacturas[index]['valRecibo'] = numValue.toDouble();
                _calcularTotales();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Al cerrar, actualizar Vr Recibo con la suma de todos los Val. Recibo
              _calcularTotales();
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Construir fila para el modal de factura
  Widget _buildFacturaModalRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );

  DataRow _buildDataRow(
    String sucursal,
    String tipo,
    String factura,
    String fecha,
    String vence,
    double valor,
    double abonos,
    double saldo,
    double valRecibo,
    bool ok,
  ) => DataRow(
    cells: [
      DataCell(Text(sucursal)),
      DataCell(Text(tipo)),
      DataCell(Text(factura)),
      DataCell(Text(fecha)),
      DataCell(Text(vence)),
      DataCell(Text(_formatCurrency(valor))),
      DataCell(Text(_formatCurrency(abonos))),
      DataCell(
        Text(
          _formatCurrency(saldo),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataCell(Text(_formatCurrency(valRecibo))),
      DataCell(
        Checkbox(
          value: ok,
          onChanged: (value) {
            final index = _carteraFacturas.indexWhere(
              (f) =>
                  f['factura'] == factura &&
                  f['sucursal'] == sucursal &&
                  f['tipo'] == tipo,
            );
            if (index != -1) {
              setState(() {
                _carteraFacturas[index]['ok'] = value ?? false;
                _calcularTotales();
              });
            }
          },
        ),
      ),
    ],
  );

  String _formatCurrency(double value) =>
      '\$${value.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  /// Construir sección de descuentos y retenciones (dinámica según el tab)
  Widget _buildDescuentosRetencionesSection() {
    final currentTab = _tabController.index;
    final conceptos = currentTab == 0 ? _carteraConceptos : _anticipoConceptos;
    final conceptoSeleccionado = currentTab == 0
        ? _carteraConceptoSeleccionado
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.calculate, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Conceptos de descuentos, retenciones u otros ingresos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: conceptoSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Concepto',
                        hintText: 'Seleccione concepto',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey[600]!,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(
                          Icons.arrow_drop_down_circle,
                          color: Colors.grey[600],
                        ),
                        errorStyle: const TextStyle(height: 0, fontSize: 0),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'retencion_ica',
                          child: Text('003 RETENCION DE ICA 7 X 1000'),
                        ),
                        DropdownMenuItem(
                          value: 'retencion_iva',
                          child: Text('004 RETENCION DE IVA'),
                        ),
                        DropdownMenuItem(
                          value: 'descuento_comercial',
                          child: Text('005 DESCUENTO COMERCIAL'),
                        ),
                      ],
                      onChanged: currentTab == 0
                          ? (value) {
                              setState(() {
                                _carteraConceptoSeleccionado = value;
                              });
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: (currentTab == 0 && conceptoSeleccionado != null)
                        ? _agregarConcepto
                        : null,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Agregar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Lista de conceptos - Compacta
              if (conceptos.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Text(
                      'No hay conceptos agregados',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(conceptos.length, (index) {
                    final concepto = conceptos[index];
                    return Container(
                      constraints: const BoxConstraints(minWidth: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      concepto['descripcion'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        'Base: ${_formatCurrency(concepto['base'] as double)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '%: ${concepto['porcentaje']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        'Valor: ${_formatCurrency(concepto['valor'] as double)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: Colors.grey[600],
                              onPressed: () {
                                setState(() {
                                  if (currentTab == 0) {
                                    _carteraConceptos.removeAt(index);
                                    _calcularTotales();
                                  } else {
                                    _anticipoConceptos.removeAt(index);
                                    _calcularTotalesAnticipos();
                                  }
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construir sección de observación
  Widget _buildObservacionSection() {
    // Determinar qué controlador usar según el tab activo
    final currentTab = _tabController.index;
    final controller = currentTab == 0
        ? _observacionController
        : _observacionAnticipoController;
    final hintText = currentTab == 0
        ? 'Ingrese una observación para Recaudos de Cartera (opcional)'
        : 'Ingrese una observación para Anticipos y Recaudos (opcional)';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.note_alt, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Observación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[600]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construir footer con resumen y botones (expandible con animación mejorada)
  Widget _buildFooter() => SafeArea(
    top: false,
    child: GestureDetector(
      onVerticalDragUpdate: (details) {
        // Detectar dirección del arrastre
        if (details.delta.dy > 10) {
          // Arrastre hacia abajo - contraer
          if (_isFooterExpanded) {
            setState(() {
              _isFooterExpanded = false;
            });
          }
        } else if (details.delta.dy < -10) {
          // Arrastre hacia arriba - expandir
          if (!_isFooterExpanded) {
            setState(() {
              _isFooterExpanded = true;
            });
          }
        }
      },
      onVerticalDragEnd: (details) {
        // Al finalizar el arrastre, ajustar según velocidad
        if (details.velocity.pixelsPerSecond.dy > 500) {
          // Arrastre rápido hacia abajo - contraer
          setState(() {
            _isFooterExpanded = false;
          });
        } else if (details.velocity.pixelsPerSecond.dy < -500) {
          // Arrastre rápido hacia arriba - expandir
          setState(() {
            _isFooterExpanded = true;
          });
        }
      },
      child: AnimatedContainer(
        key: _footerKey,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 4.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -4),
              spreadRadius: 2,
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_isFooterExpanded ? 0 : 24),
            topRight: Radius.circular(_isFooterExpanded ? 0 : 24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle para arrastrar
            GestureDetector(
              onTap: () {
                setState(() {
                  _isFooterExpanded = !_isFooterExpanded;
                });
              },
              child: Container(
                width: 60,
                height: 6,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isFooterExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ),
            ),
            // Contenido expandible con animación mejorada
            AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              child: _isFooterExpanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Resumen financiero (más compacto)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSummaryRow('Descuentos', _descuentos),
                              _buildSummaryRow('Retenciones', _retenciones),
                              _buildSummaryRow(
                                'Otros Ingresos',
                                _otrosIngresos,
                              ),
                              const Divider(height: 16),
                              _buildSummaryRow(
                                'Neto Recibo',
                                _getNetoRecibo(),
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Botones de acción - Organizados verticalmente en móvil
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              // Layout horizontal para tablets
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: _buildActionButtons(),
                              );
                            } else {
                              // Layout vertical para móviles
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ..._buildActionButtons().asMap().entries.map((
                                    entry,
                                  ) {
                                    final index = entry.key;
                                    final button = entry.value;
                                    final isLast =
                                        index ==
                                        _buildActionButtons().length - 1;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: isLast ? 0.0 : 8.0,
                                      ),
                                      child: button,
                                    );
                                  }),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Vista contraída - mostrar todos los valores organizados
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Fila principal con Neto Recibo
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Neto Recibo:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(_getNetoRecibo()),
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Valores secundarios en letras pequeñas
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Descuentos:',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              _formatCurrency(_descuentos),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Retenciones:',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              _formatCurrency(_retenciones),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Otros Ingresos:',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              _formatCurrency(_otrosIngresos),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
          ],
        ),
      ),
    ),
  );

  /// Validar que todos los campos requeridos estén llenos según el tab activo
  String? _validarFormulario() {
    final currentTab = _tabController.index;

    if (currentTab == 0) {
      // Validaciones para Tab de Recaudos de Cartera
      // Validar cliente
      if (_carteraClienteController.text.trim().isEmpty ||
          _carteraClienteSeleccionadoId == null) {
        return 'Debe seleccionar un cliente';
      }

      // Validar C.C
      if (_carteraCcSeleccionado == null) {
        return 'Debe seleccionar un C.C';
      }

      // Validar que al menos una factura esté seleccionada
      final facturasSeleccionadas = _carteraFacturas
          .where((f) => f['ok'] == true)
          .toList();
      if (facturasSeleccionadas.isEmpty) {
        return 'Debe seleccionar al menos una factura';
      }

      // Validar Vr Recibo
      final vrReciboText = _vrReciboController.text
          .replaceAll(',', '')
          .replaceAll('.', '');
      final vrRecibo = int.tryParse(vrReciboText) ?? 0;
      if (vrRecibo <= 0) {
        return 'El valor del recibo debe ser mayor a cero';
      }
    } else {
      // Validaciones para Tab de Anticipos y Recaudos
      // Validar que se haya seleccionado el tipo de anticipo
      if (_tipoAnticipoSeleccionado == null) {
        return 'Debe seleccionar el tipo de anticipo';
      }

      // Si es anticipo de cliente, validar que se haya seleccionado un cliente
      if (_tipoAnticipoSeleccionado == 'cliente') {
        if (_anticipoClienteController.text.trim().isEmpty) {
          return 'Debe seleccionar un cliente';
        }
      }

      // Validar que haya al menos un concepto con valor
      final conceptosConValor = _anticipoConceptos.where((c) {
        final referencia = c['referencia'] as String?;
        final valor = c['valor'] as double? ?? 0.0;
        return (referencia?.isNotEmpty ?? false) && valor > 0;
      }).toList();

      if (conceptosConValor.isEmpty) {
        return 'Debe agregar al menos un concepto con valor mayor a cero';
      }

      // Validar que el total de conceptos sea mayor a cero
      double totalConceptos = 0;
      for (final concepto in conceptosConValor) {
        totalConceptos += concepto['valor'] as double? ?? 0.0;
      }

      if (totalConceptos <= 0) {
        return 'El total de conceptos debe ser mayor a cero';
      }
    }

    return null; // Todo está válido
  }

  /// Verificar si el formulario está completo para habilitar el botón
  bool _isFormularioCompleto() => _validarFormulario() == null;

  List<Widget> _buildActionButtons() => [
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isFormularioCompleto()
                ? () async {
                    // Validar formulario
                    final errorValidacion = _validarFormulario();
                    if (errorValidacion != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorValidacion),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    if (_formKey.currentState!.validate()) {
                      // Mostrar modal de formas de pago con animación
                      final result = await showGeneralDialog<dynamic>(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: 'Formas de Pago',
                        barrierColor: Colors.black54,
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FormasPagoModal(
                              netoAPagar: _netoRecibo,
                              numeroCuenta: _nroCuentaConsignado ?? '',
                            ),
                        transitionBuilder:
                            (context, animation, secondaryAnimation, child) =>
                                SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 0.3),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                ),
                      );

                      // Verificar si se guardó correctamente
                      bool guardado = false;
                      List<Map<String, dynamic>> formasPago = [];
                      String numeroCuentaModal = '';

                      if (result != null) {
                        if (result is Map<String, dynamic>) {
                          guardado = result['guardado'] == true;
                          final formasPagoData = result['formasPago'];
                          if (formasPagoData is List) {
                            formasPago = formasPagoData
                                .map((e) => Map<String, dynamic>.from(e as Map))
                                .toList();
                          }
                          // Obtener el número de cuenta del modal
                          numeroCuentaModal =
                              result['numeroCuenta'] as String? ?? '';
                        } else if (result is bool) {
                          guardado = result;
                        }
                      }

                      if (guardado && mounted) {
                        // Obtener información de la compañía seleccionada
                        String nombreCompania = '';
                        String nitCompania = '';
                        if (_carteraCcSeleccionado != null) {
                          final companyState = ref.read(
                            companyListNotifierProvider,
                          );
                          final companies = companyState.whenOrNull(
                            data: (companies) => companies,
                          );
                          if (companies != null && companies.isNotEmpty) {
                            try {
                              final company = companies.firstWhere(
                                (c) => c.id == _carteraCcSeleccionado,
                              );
                              nombreCompania = company.razonSocial;
                              nitCompania = company.nitCompleto;
                            } catch (e) {
                              final company = companies.first;
                              nombreCompania = company.razonSocial;
                              nitCompania = company.nitCompleto;
                            }
                          }
                        }

                        // Guardar el recibo en memoria
                        final reciboGuardado = ReciboGuardado(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          numeroRecibo: _reciboController.text,
                          fecha: _fechaController.text,
                          cliente: _carteraClienteController.text,
                          nit: _carteraNitController.text,
                          totalRecibo:
                              double.tryParse(
                                _vrReciboController.text
                                    .replaceAll(',', '')
                                    .replaceAll('.', ''),
                              ) ??
                              0.0,
                          netoRecibo: _netoRecibo,
                          formasPago: formasPago,
                          cuenta: numeroCuentaModal.isNotEmpty
                              ? numeroCuentaModal
                              : (_nroCuentaConsignado ?? ''),
                          fechaCreacion: DateTime.now(),
                          nombreCompania: nombreCompania,
                          nitCompania: nitCompania,
                        );

                        // Simular guardado
                        await ref
                            .read<ReciboListNotifier>(
                              reciboListNotifierProvider.notifier,
                            )
                            .agregarRecibo(reciboGuardado);

                        // Cerrar formulario y redirigir al listado ANTES de mostrar el mensaje
                        // Esto asegura que el loading del modal se cierre primero
                        if (mounted) {
                          Navigator.pop(
                            context,
                          ); // Cierra el formulario y vuelve al listado

                          // Mostrar notificación push de éxito después de redirigir
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Recibo guardado exitosamente',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            }
                          });
                        }
                      }
                    }
                  }
                : null,
            icon: const Icon(Icons.payment, size: 20),
            label: const Text('Forma Pago'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFormularioCompleto()
                  ? Colors.green
                  : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.exit_to_app, size: 20),
            label: const Text('Salir'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    ),
  ];

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 15 : 13,
              ),
            ),
            Text(
              _formatCurrency(value),
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 15 : 13,
                color: isTotal ? Colors.blue : Colors.black87,
              ),
            ),
          ],
        ),
      );
}
