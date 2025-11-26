import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  int? _selectedBarIndex;
  String? _selectedPeriod;
  int? _selectedClienteIndex;
  String? _selectedFormaPago;
  int? _selectedConceptoIndex;
  
  // Controladores de animación
  late AnimationController _chartAnimationController;

  @override
  void initState() {
    super.initState();
    _chartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    super.dispose();
  }

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
          'Formularios',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 20),
              onPressed: () {
                // TODO: Implementar búsqueda
              },
              tooltip: 'Buscar',
            ),
          ),
        ],
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
            
            // Tarjetas de métricas principales
            _buildMetricsCards(dashboardData),
            const SizedBox(height: 24),
            
            // Gráfico de tendencias
            _buildTrendChart(dashboardData),
            const SizedBox(height: 24),
            
            // Análisis por período
            _buildPeriodAnalysis(dashboardData),
            const SizedBox(height: 24),
            
            // Top clientes
            _buildTopClientes(dashboardData),
            const SizedBox(height: 24),
            
            // Análisis de formas de pago
            _buildFormasPagoAnalysis(dashboardData),
            const SizedBox(height: 24),
            
            // Resumen de conceptos
            _buildConceptosSummary(dashboardData),
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
    return Column(
      children: [
        Row(
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
            const SizedBox(width: 12),
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
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                key: 'promedioRecibo',
                title: 'Promedio por Recibo',
                value: _formatCurrency(data['promedioRecibo'] as double),
                icon: Icons.trending_up,
                color: Colors.orange,
                subtitle: 'Promedio mensual',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                key: 'recibosHoy',
                title: 'Recibos Hoy',
                value: '${data['recibosHoy']}',
                icon: Icons.today,
                color: Colors.purple,
                subtitle: _formatCurrency(data['ingresosHoy'] as double),
              ),
            ),
          ],
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
                  _selectedBarIndex = null;
                  _selectedPeriod = null;
                  _selectedClienteIndex = null;
                  _selectedFormaPago = null;
                  _selectedConceptoIndex = null;
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(isSelected ? 0.3 : 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: color, size: 24),
                              ),
                              Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
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

  /// Construir gráfico de tendencias
  Widget _buildTrendChart(Map<String, dynamic> data) {
    final tendencia = data['tendenciaSemanal'] as List;
    final maxValue = tendencia.map((e) => e['valor'] as double).reduce((a, b) => a > b ? a : b);
    
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tendencia Semanal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        '+12.5%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _chartAnimationController,
              builder: (context, child) {
                return SizedBox(
                  height: 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: tendencia.asMap().entries.map<Widget>((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final valor = item['valor'] as double;
                      final dia = item['dia'] as String;
                      final isSelected = _selectedBarIndex == index;
                      final isAnySelected = _selectedBarIndex != null;
                      final opacity = isSelected ? 1.0 : (isAnySelected ? 0.3 : 1.0);
                      final scale = isSelected ? 1.1 : 1.0;
                      
                      // Animación de altura
                      final animatedHeight = ((valor / maxValue) * 180) * _chartAnimationController.value;
                      
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedBarIndex == index) {
                                _selectedBarIndex = null;
                              } else {
                                _selectedBarIndex = index;
                                // Deseleccionar otros elementos
                                _selectedMetricCard = null;
                                _selectedPeriod = null;
                                _selectedClienteIndex = null;
                                _selectedFormaPago = null;
                                _selectedConceptoIndex = null;
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Tooltip(
                                        message: '$dia: ${_formatCurrency(valor)}',
                                        child: Container(
                                          width: double.infinity,
                                          height: animatedHeight,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: isSelected
                                                  ? [
                                                      Colors.blue[600]!,
                                                      Colors.blue[400]!,
                                                    ]
                                                  : [
                                                      Colors.blue[400]!,
                                                      Colors.blue[200]!,
                                                    ],
                                            ),
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.blue.withOpacity(0.5),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, -2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        dia,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isSelected ? Colors.blue[700] : Colors.grey[600],
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Construir análisis por período
  Widget _buildPeriodAnalysis(Map<String, dynamic> data) {
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
              'Análisis por Período',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildPeriodRow('Hoy', 8500000.0, 12, Colors.blue),
            const SizedBox(height: 12),
            _buildPeriodRow('Esta Semana', 89000000.0, 98, Colors.green),
            const SizedBox(height: 12),
            _buildPeriodRow('Este Mes', 125000000.0, 156, Colors.orange),
            const SizedBox(height: 12),
            _buildPeriodRow('Este Año', 1450000000.0, 1845, Colors.purple),
          ],
        ),
      ),
    );
  }

  /// Construir fila de período
  Widget _buildPeriodRow(String periodo, double total, int recibos, Color color) {
    final isSelected = _selectedPeriod == periodo;
    final isAnySelected = _selectedPeriod != null;
    final opacity = isSelected ? 1.0 : (isAnySelected ? 0.4 : 1.0);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedPeriod == periodo) {
            _selectedPeriod = null;
          } else {
            _selectedPeriod = periodo;
            // Deseleccionar otros elementos
            _selectedMetricCard = null;
            _selectedBarIndex = null;
            _selectedClienteIndex = null;
            _selectedFormaPago = null;
            _selectedConceptoIndex = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(isSelected ? 0.15 : 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: opacity,
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      periodo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$recibos recibos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(total),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${((total / 125000000.0) * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construir top clientes
  Widget _buildTopClientes(Map<String, dynamic> data) {
    final topClientes = data['topClientes'] as List;
    
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top 5 Clientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(topClientes.length, (index) {
              final cliente = topClientes[index];
              final total = cliente['total'] as double;
              final recibos = cliente['recibos'] as int;
              final nombre = cliente['nombre'] as String;
              final maxTotal = (topClientes[0]['total'] as double);
              final porcentaje = (total / maxTotal) * 100;
              final isSelected = _selectedClienteIndex == index;
              final isAnySelected = _selectedClienteIndex != null;
              final opacity = isSelected ? 1.0 : (isAnySelected ? 0.4 : 1.0);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedClienteIndex == index) {
                      _selectedClienteIndex = null;
                    } else {
                      _selectedClienteIndex = index;
                      // Deseleccionar otros elementos
                      _selectedMetricCard = null;
                      _selectedBarIndex = null;
                      _selectedPeriod = null;
                      _selectedFormaPago = null;
                      _selectedConceptoIndex = null;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? _getRankColor(index).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: _getRankColor(index), width: 2)
                        : null,
                  ),
                  child: Opacity(
                    opacity: opacity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getRankColor(index).withOpacity(isSelected ? 0.3 : 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getRankColor(index),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nombre,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$recibos recibos',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatCurrency(total),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? _getRankColor(index) : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: porcentaje / 100,
                            minHeight: isSelected ? 8 : 6,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(_getRankColor(index)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
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
                      _selectedBarIndex = null;
                      _selectedPeriod = null;
                      _selectedClienteIndex = null;
                      _selectedConceptoIndex = null;
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

  /// Construir resumen de conceptos
  Widget _buildConceptosSummary(Map<String, dynamic> data) {
    final conceptos = data['conceptos'] as List;
    
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
              'Distribución por Conceptos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _chartAnimationController,
              builder: (context, child) {
                return SizedBox(
                  height: 200,
                  child: Row(
                    children: conceptos.asMap().entries.map<Widget>((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final nombre = item['nombre'] as String;
                      final itemTotal = item['total'] as double;
                      final porcentaje = item['porcentaje'] as double;
                      final isSelected = _selectedConceptoIndex == index;
                      final isAnySelected = _selectedConceptoIndex != null;
                      final opacity = isSelected ? 1.0 : (isAnySelected ? 0.3 : 1.0);
                      final scale = isSelected ? 1.1 : 1.0;
                      
                      // Animación de altura
                      final animatedHeight = ((porcentaje / 100) * 180) * _chartAnimationController.value;
                      
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedConceptoIndex == index) {
                                _selectedConceptoIndex = null;
                              } else {
                                _selectedConceptoIndex = index;
                                // Deseleccionar otros elementos
                                _selectedMetricCard = null;
                                _selectedBarIndex = null;
                                _selectedPeriod = null;
                                _selectedClienteIndex = null;
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Tooltip(
                                        message: '$nombre\n${_formatCurrency(itemTotal)}\n${porcentaje.toStringAsFixed(1)}%',
                                        child: Container(
                                          width: double.infinity,
                                          height: animatedHeight,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: isSelected
                                                  ? [
                                                      _getConceptoColor(nombre),
                                                      _getConceptoColor(nombre).withOpacity(0.8),
                                                    ]
                                                  : [
                                                      _getConceptoColor(nombre),
                                                      _getConceptoColor(nombre).withOpacity(0.6),
                                                    ],
                                            ),
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: _getConceptoColor(nombre).withOpacity(0.5),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, -2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        nombre.split(' ').first,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isSelected ? _getConceptoColor(nombre) : Colors.grey[600],
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${porcentaje.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _getConceptoColor(nombre),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Obtener color según el ranking
  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey[400]!;
      case 2:
        return Colors.brown[400]!;
      default:
        return Colors.blue;
    }
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

  /// Obtener color según concepto
  Color _getConceptoColor(String nombre) {
    if (nombre.contains('Cartera')) {
      return Colors.blue;
    } else if (nombre.contains('Anticipo')) {
      return Colors.green;
    } else {
      return Colors.orange;
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
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Implementar búsqueda
                        },
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
                      // TODO: Navegar a Panel
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
                  icon: Icons.receipt_outlined,
                  title: 'Facturas',
                  color: Colors.blue[300]!,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      // TODO: Navegar a Facturas
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 3,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Presupuesto',
                  color: Colors.blue[300]!,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      // TODO: Navegar a Presupuesto
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 4,
                  icon: Icons.credit_card_outlined,
                  title: 'Notas de Crédito',
                  color: Colors.blue[300]!,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      // TODO: Navegar a Notas de Crédito
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 5,
                  icon: Icons.inventory_2_outlined,
                  title: 'Artículo/Servicios',
                  color: Colors.green,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      // TODO: Navegar a Artículo/Servicios
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 6,
                  icon: Icons.people_outline,
                  title: 'Clientes/Proveedores',
                  color: Colors.red,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      // TODO: Navegar a Clientes/Proveedores
                    });
                  },
                ),
                _buildDrawerItem(
                  context,
                  index: 7,
                  icon: Icons.bar_chart_outlined,
                  title: 'Informes, Exportación',
                  color: Colors.green,
                  onTap: () {
                    _navigateWithAnimation(context, () {
                      // TODO: Navegar a Informes
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

