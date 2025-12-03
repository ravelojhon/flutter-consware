import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/company_notifier.dart';
import 'en_desarrollo_screen.dart';
import 'recibos_screen.dart';
import 'viaticos_screen.dart';

/// Pantalla de formularios con estado vacío y drawer de navegación
class FormulariosScreen extends ConsumerStatefulWidget {
  const FormulariosScreen({super.key});

  @override
  ConsumerState<FormulariosScreen> createState() => _FormulariosScreenState();
}

class _FormulariosScreenState extends ConsumerState<FormulariosScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;
  
  // Estado para rastrear selección
  String? _selectedMetricCard;
  String? _selectedFormaPago;
  
  // Estado para filtros
  DateTimeRange? _selectedDateRange;
  String? _selectedConductor;
  final TextEditingController _conductorSearchController = TextEditingController();
  
  // Lista simulada de conductores con identificación
  final Map<String, String> _conductores = {
    'Juan Pérez': '12345678',
    'María García': '87654321',
    'Carlos Rodríguez': '11223344',
    'Ana Martínez': '44332211',
    'Luis Hernández': '55667788',
    'Laura López': '88776655',
    'Pedro Sánchez': '99887766',
    'Carmen González': '66778899',
    'José Ramírez': '22334455',
    'Isabel Torres': '55443322',
  };
  
  List<String> _filteredConductores = [];
  
  @override
  void initState() {
    super.initState();
    _filteredConductores = List<String>.from(_conductores.keys);
    _conductorSearchController.addListener(_filterConductores);
    
    // Cargar compañías al ingresar al dashboard para que estén listas cuando se abra el formulario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companyListNotifierProvider.notifier).refresh();
    });
  }
  
  @override
  void dispose() {
    _conductorSearchController.removeListener(_filterConductores);
    _conductorSearchController.dispose();
    super.dispose();
  }
  
  void _filterConductores() {
    final query = _conductorSearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredConductores = List<String>.from(_conductores.keys);
      } else {
        _filteredConductores = _conductores.keys
            .where((conductor) => 
                conductor.toLowerCase().contains(query) ||
                (_conductores[conductor] ?? '').toLowerCase().contains(query))
            .toList();
      }
    });
  }
  
  String? get _selectedConductorId => _selectedConductor != null 
      ? _conductores[_selectedConductor] 
      : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      drawer: _buildNavigationDrawer(context),
      onDrawerChanged: (isOpened) {
        setState(() {
          _isDrawerOpen = isOpened;
        });
      },
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          tooltip: 'Menú',
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildDashboard(context),
    );
  }

  /// Construir dashboard principal
  Widget _buildDashboard(BuildContext context) {
    // Datos simulados para el dashboard (en producción vendrían de una API)
    final dashboardData = _getDashboardData();
    
    return RefreshIndicator(
      onRefresh: () async {
        // Simular actualización de datos
        await Future<void>.delayed(const Duration(seconds: 1));
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título del dashboard
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.dashboard, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard de Recibos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Análisis de recibos de caja',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Sección de filtros
            _buildFilterSection(),
            const SizedBox(height: 24),
            
            // Accesos directos
            _buildQuickAccess(),
            const SizedBox(height: 24),
            
            // Tarjetas de métricas principales
            _buildMetricsCards(dashboardData),
            const SizedBox(height: 24),
            
            // Análisis de formas de pago
            _buildFormasPagoAnalysis(dashboardData),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// Obtener datos del dashboard (simulados)
  Map<String, dynamic> _getDashboardData() {
    return {
      'totalRecibos': 156,
      'totalIngresos': 125000000.0,
      'promedioRecibo': 801282.05,
      'recibosHoy': 12,
      'ingresosHoy': 8500000.0,
      'tendenciaSemanal': [
        {'dia': 'Lun', 'valor': 12000000.0},
        {'dia': 'Mar', 'valor': 15000000.0},
        {'dia': 'Mié', 'valor': 18000000.0},
        {'dia': 'Jue', 'valor': 14000000.0},
        {'dia': 'Vie', 'valor': 20000000.0},
        {'dia': 'Sáb', 'valor': 10000000.0},
        {'dia': 'Dom', 'valor': 8000000.0},
      ],
      'topClientes': [
        {'nombre': 'A CONSTRUIR SA', 'total': 35000000.0, 'recibos': 45},
        {'nombre': 'CONSTRUCTORA ANAYA', 'total': 28000000.0, 'recibos': 32},
        {'nombre': 'ACABADOS E & H SAS', 'total': 22000000.0, 'recibos': 28},
        {'nombre': 'BRACHO TECNICOS', 'total': 18000000.0, 'recibos': 22},
        {'nombre': 'CONSTRUCCIONES JYE', 'total': 15000000.0, 'recibos': 18},
      ],
      'formasPago': [
        {'tipo': 'Efectivo', 'cantidad': 45, 'total': 35000000.0},
        {'tipo': 'Transferencia', 'cantidad': 38, 'total': 42000000.0},
        {'tipo': 'Cheque', 'cantidad': 28, 'total': 28000000.0},
        {'tipo': 'Tarjeta', 'cantidad': 45, 'total': 20000000.0},
      ],
      'conceptos': [
        {'nombre': 'Recaudos de Cartera', 'total': 85000000.0, 'porcentaje': 68.0},
        {'nombre': 'Anticipos', 'total': 30000000.0, 'porcentaje': 24.0},
        {'nombre': 'Otros Ingresos', 'total': 10000000.0, 'porcentaje': 8.0},
      ],
    };
  }

  /// Construir tarjetas de métricas principales
  Widget _buildMetricsCards(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            key: 'totalRecibos',
            title: 'Total Recibos',
            value: '${data['totalRecibos']}',
            icon: Icons.receipt_long,
            color: Colors.blue,
            subtitle: 'Este mes',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            key: 'totalIngresos',
            title: 'Total Ingresos',
            value: _formatCurrency(data['totalIngresos'] as double),
            icon: Icons.attach_money,
            color: Colors.green,
            subtitle: 'Este mes',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            key: 'recibosHoy',
            title: 'Hoy',
            value: '${data['recibosHoy']}',
            icon: Icons.today,
            color: Colors.purple,
            subtitle: _formatCurrency(data['ingresosHoy'] as double),
          ),
        ),
      ],
    );
  }

  /// Construir tarjeta de métrica
  Widget _buildMetricCard({
    required String key,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    final isSelected = _selectedMetricCard == key;
    final isAnySelected = _selectedMetricCard != null;
    final opacity = isSelected ? 1.0 : (isAnySelected ? 0.4 : 1.0);
    final scale = isSelected ? 1.05 : 1.0;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.8 + (animValue * 0.2),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_selectedMetricCard == key) {
                  _selectedMetricCard = null;
                } else {
                  _selectedMetricCard = key;
                  // Deseleccionar otros elementos
                  _selectedFormaPago = null;
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Card(
                    elevation: isSelected ? 8 : 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isSelected
                          ? BorderSide(color: color, width: 2)
                          : BorderSide.none,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(isSelected ? 0.2 : 0.1),
                            color.withOpacity(isSelected ? 0.1 : 0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(isSelected ? 0.3 : 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(icon, color: color, size: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construir sección de filtros
  /// Formatear fecha en formato corto (ej: "4 nov")
  String _formatShortDate(DateTime date) {
    final months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 
                    'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${date.day} ${months[date.month - 1]}';
  }

  /// Formatear rango de fechas (ej: "4 nov - 20 nov")
  String _formatDateRange(DateTimeRange range) {
    final startFormatted = _formatShortDate(range.start);
    final endFormatted = _formatShortDate(range.end);
    return '$startFormatted - $endFormatted';
  }

  Widget _buildFilterSection() {
    int? daysCount;
    int? selectedYear;
    if (_selectedDateRange != null) {
      daysCount = _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays + 1;
      selectedYear = _selectedDateRange!.start.year;
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Icon(Icons.filter_list, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Espacio para el año (siempre presente para mantener alineación)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(
                    selectedYear != null ? '$selectedYear' : ' ',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _selectDateRange,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedDateRange == null
                                ? 'Rango de fechas'
                                : _formatDateRange(_selectedDateRange!),
                            style: TextStyle(
                              fontSize: 13,
                              color: _selectedDateRange == null ? Colors.grey[500] : Colors.grey[800],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_selectedDateRange != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedDateRange = null;
                                });
                              },
                              child: Icon(Icons.clear, size: 16, color: Colors.grey[400]),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (daysCount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      daysCount == 1 
                          ? '1 día seleccionado'
                          : '$daysCount días seleccionados',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                // Espacio adicional si no hay días para mantener alineación
                if (daysCount == null)
                  const SizedBox(height: 18),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Espacio vacío para alineación con el año
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(
                    ' ',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.0,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _showConductorSelector(context),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedConductor ?? 'Todos los conductores',
                            style: TextStyle(
                              fontSize: 13,
                              color: _selectedConductor == null ? Colors.grey[500] : Colors.grey[800],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
                if (_selectedConductorId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      'ID: ${_selectedConductorId}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                // Espacio adicional si no hay ID para mantener alineación
                if (_selectedConductorId == null)
                  const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Seleccionar rango de fechas
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showModalBottomSheet<DateTimeRange?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DateRangePickerBottomSheet(
        initialDateRange: _selectedDateRange,
      ),
    );
    
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }
  
  /// Mostrar selector de conductor con búsqueda
  void _showConductorSelector(BuildContext context) {
    _conductorSearchController.clear();
    _filteredConductores = _conductores.keys.toList();
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Seleccionar Conductor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _conductorSearchController,
              decoration: InputDecoration(
                hintText: 'Buscar conductor...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                _filterConductores();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.people, color: Colors.blue),
                    title: Text('Todos los conductores'),
                    onTap: () {
                      setState(() {
                        _selectedConductor = null;
                      });
                      Navigator.pop(context);
                    },
                    selected: _selectedConductor == null,
                  ),
                  Divider(),
                  ..._filteredConductores.map((conductor) {
                    final id = _conductores[conductor];
                    return ListTile(
                      leading: Icon(Icons.person, color: Colors.grey[600]),
                      title: Text(conductor),
                      subtitle: id != null 
                          ? Text('ID: $id', style: TextStyle(fontSize: 12, color: Colors.grey[600]))
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedConductor = conductor;
                        });
                        Navigator.pop(context);
                      },
                      selected: _selectedConductor == conductor,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Construir accesos directos
  Widget _buildQuickAccess() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAccessCard(
            title: 'Recibos',
            subtitle: 'Gestionar recibos de caja',
            icon: Icons.receipt_long,
            color: Colors.blue,
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(builder: (context) => const RecibosScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickAccessCard(
            title: 'Viaticos',
            subtitle: 'Gestionar viáticos',
            icon: Icons.card_travel,
            color: Colors.orange,
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const ViaticosScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  /// Construir tarjeta de acceso directo
  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool showDevelopmentBadge = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.08),
                color.withOpacity(0.03),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  /// Construir análisis de formas de pago
  Widget _buildFormasPagoAnalysis(Map<String, dynamic> data) {
    final formasPago = data['formasPago'] as List;
    final total = formasPago.fold<double>(0.0, (sum, item) => sum + (item['total'] as double));
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Formas de Pago',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...formasPago.map<Widget>((item) {
              final tipo = item['tipo'] as String;
              final cantidad = item['cantidad'] as int;
              final itemTotal = item['total'] as double;
              final porcentaje = (itemTotal / total) * 100;
              final isSelected = _selectedFormaPago == tipo;
              final isAnySelected = _selectedFormaPago != null;
              final opacity = isSelected ? 1.0 : (isAnySelected ? 0.4 : 1.0);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedFormaPago == tipo) {
                      _selectedFormaPago = null;
                  } else {
                    _selectedFormaPago = tipo;
                    // Deseleccionar otros elementos
                    _selectedMetricCard = null;
                  }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? _getFormaPagoColor(tipo).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: _getFormaPagoColor(tipo), width: 2)
                        : null,
                  ),
                  child: Opacity(
                    opacity: opacity,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tipo,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$cantidad transacciones',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatCurrency(itemTotal),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? _getFormaPagoColor(tipo) : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: porcentaje / 100,
                                  minHeight: isSelected ? 10 : 8,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(_getFormaPagoColor(tipo)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${porcentaje.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// Obtener color según forma de pago
  Color _getFormaPagoColor(String tipo) {
    switch (tipo) {
      case 'Efectivo':
        return Colors.green;
      case 'Transferencia':
        return Colors.blue;
      case 'Cheque':
        return Colors.orange;
      case 'Tarjeta':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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

  /// Construir drawer de navegación con opciones de formularios
  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header del drawer mejorado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[700]!,
                  Colors.blue[500]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.settings, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ajustes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Menú de opciones',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lista de opciones con animación secuencial
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  title: 'Panel',
                  color: Colors.blue[300]!,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const EnDesarrolloScreen(titulo: 'Panel'),
                        ),
                      );
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 1,
                  icon: Icons.receipt_long_outlined,
                  title: 'Recibos',
                  color: Colors.blue[300]!,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      Navigator.pushNamed(context, '/recibos');
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 2,
                  icon: Icons.card_travel_outlined,
                  title: 'Viaticos',
                  color: Colors.orange[300]!,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const ViaticosScreen(),
                        ),
                      );
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 3,
                  icon: Icons.receipt_outlined,
                  title: 'Facturas',
                  color: Colors.blue[300]!,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const EnDesarrolloScreen(titulo: 'Facturas'),
                        ),
                      );
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 4,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Presupuesto',
                  color: Colors.blue[300]!,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const EnDesarrolloScreen(titulo: 'Presupuesto'),
                        ),
                      );
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 5,
                  icon: Icons.credit_card_outlined,
                  title: 'Notas de Crédito',
                  color: Colors.blue[300]!,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const EnDesarrolloScreen(titulo: 'Notas de Crédito'),
                        ),
                      );
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 6,
                  icon: Icons.inventory_2_outlined,
                  title: 'Artículo/Servicios',
                  color: Colors.green,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const EnDesarrolloScreen(titulo: 'Artículo/Servicios'),
                        ),
                      );
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 7,
                  icon: Icons.people_outline,
                  title: 'Clientes/Proveedores',
                  color: Colors.red,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const EnDesarrolloScreen(titulo: 'Clientes/Proveedores'),
                        ),
                      );
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 8,
                  icon: Icons.bar_chart_outlined,
                  title: 'Informes, Exportación',
                  color: Colors.green,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const EnDesarrolloScreen(titulo: 'Informes, Exportación'),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Navegar con animación al hacer click en opción del menú
  void _navigateWithAnimation(BuildContext context, VoidCallback navigationAction) {
    // Cerrar el drawer con animación
    Navigator.pop(context);
    
    // Esperar un poco para que se cierre el drawer antes de navegar
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        navigationAction();
      }
    });
  }

  /// Construir item del drawer con animación secuencial
  Widget _buildDrawerItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _AnimatedDrawerItem(
      index: index,
      icon: icon,
      title: title,
      color: color,
      isDrawerOpen: _isDrawerOpen,
      onTap: onTap,
    );
  }
}

/// Widget animado para items del drawer con animación secuencial
class _AnimatedDrawerItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final String title;
  final Color color;
  final bool isDrawerOpen;
  final VoidCallback onTap;

  const _AnimatedDrawerItem({
    required this.index,
    required this.icon,
    required this.title,
    required this.color,
    required this.isDrawerOpen,
    required this.onTap,
  });

  @override
  State<_AnimatedDrawerItem> createState() => _AnimatedDrawerItemState();
}

class _AnimatedDrawerItemState extends State<_AnimatedDrawerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _slideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.index * 0.05,
          0.2 + widget.index * 0.05,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.index * 0.05,
          0.2 + widget.index * 0.05,
          curve: Curves.easeOut,
        ),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.index * 0.05,
          0.2 + widget.index * 0.05,
          curve: Curves.easeOutBack,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedDrawerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDrawerOpen && !oldWidget.isDrawerOpen) {
      // Delay reducido para animación más rápida
      Future<void>.delayed(Duration(milliseconds: widget.index * 20), () {
        if (mounted && widget.isDrawerOpen) {
          _controller.forward();
        }
      });
    } else if (!widget.isDrawerOpen && oldWidget.isDrawerOpen) {
      _controller.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Iniciar animación si el drawer ya está abierto
    if (widget.isDrawerOpen && _controller.value == 0.0) {
      Future<void>.delayed(Duration(milliseconds: widget.index * 20), () {
        if (mounted && widget.isDrawerOpen) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Icon(widget.icon, color: widget.color, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(10 * (1 - _fadeAnimation.value), 0),
                          child: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget personalizado para el modal de selección de rango de fechas
class _DateRangePickerBottomSheet extends StatefulWidget {
  final DateTimeRange? initialDateRange;

  const _DateRangePickerBottomSheet({
    this.initialDateRange,
  });

  @override
  State<_DateRangePickerBottomSheet> createState() => _DateRangePickerBottomSheetState();
}

class _DateRangePickerBottomSheetState extends State<_DateRangePickerBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _focusedMonth = DateTime.now();
  
  final List<String> _weekDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  final List<String> _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialDateRange != null) {
      _startDate = widget.initialDateRange!.start;
      _endDate = widget.initialDateRange!.end;
      _focusedMonth = widget.initialDateRange!.start;
    } else {
      _focusedMonth = DateTime.now();
    }
  }

  void _selectDate(DateTime date) {
    if (_startDate == null || (_startDate != null && _endDate != null)) {
      // Iniciar nueva selección
      setState(() {
        _startDate = date;
        _endDate = null;
      });
    } else if (_startDate != null && _endDate == null) {
      // Completar rango
      if (date.isBefore(_startDate!)) {
        // Si la fecha seleccionada es anterior, intercambiar
        setState(() {
          _endDate = _startDate;
          _startDate = date;
        });
      } else {
        setState(() {
          _endDate = date;
        });
      }
      
      // Crear rango y cerrar automáticamente
      final range = DateTimeRange(
        start: _startDate!,
        end: _endDate!,
      );
      
      // Cerrar automáticamente después de un breve delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.pop(context, range);
        }
      });
    }
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null) return false;
    if (_endDate == null) return date.isAtSameMomentAs(_startDate!);
    
    final start = _startDate!.isBefore(_endDate!) ? _startDate! : _endDate!;
    final end = _startDate!.isBefore(_endDate!) ? _endDate! : _startDate!;
    
    return (date.isAfter(start.subtract(const Duration(days: 1))) && 
            date.isBefore(end.add(const Duration(days: 1)))) ||
           date.isAtSameMomentAs(start) ||
           date.isAtSameMomentAs(end);
  }

  bool _isStartDate(DateTime date) {
    return _startDate != null && date.isAtSameMomentAs(_startDate!);
  }

  bool _isEndDate(DateTime date) {
    return _endDate != null && date.isAtSameMomentAs(_endDate!);
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    
    // Obtener el primer lunes de la semana que contiene el primer día
    int firstWeekday = firstDay.weekday;
    int daysToSubtract = (firstWeekday - 1) % 7;
    final firstMonday = firstDay.subtract(Duration(days: daysToSubtract));
    
    // Obtener el último domingo de la semana que contiene el último día
    int lastWeekday = lastDay.weekday;
    int daysToAdd = 7 - lastWeekday;
    final lastSunday = lastDay.add(Duration(days: daysToAdd));
    
    final days = <DateTime>[];
    DateTime current = firstMonday;
    
    while (!current.isAfter(lastSunday)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return days;
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_focusedMonth);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Handle y X de cerrar
          Row(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey[600], size: 24),
                onPressed: () => Navigator.pop(context, null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Título con navegación de mes
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_today, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: Colors.grey[700]),
                      onPressed: _previousMonth,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: Colors.grey[700]),
                      onPressed: _nextMonth,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Días de la semana
          Row(
            children: _weekDays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Calendario
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.1,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final date = days[index];
                final isCurrentMonth = date.month == _focusedMonth.month;
                final isToday = date.isAtSameMomentAs(today);
                final isInRange = _isDateInRange(date);
                final isStart = _isStartDate(date);
                final isEnd = _isEndDate(date);
                
                return GestureDetector(
                  onTap: () => _selectDate(date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isStart || isEnd
                          ? Colors.blue
                          : isInRange
                              ? Colors.blue[100]
                              : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isStart || isEnd
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: !isCurrentMonth
                              ? Colors.grey[400]
                              : isStart || isEnd
                                  ? Colors.white
                                  : Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
