import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/viatico_notifier.dart';

/// Pantalla para crear un nuevo viático
class CrearViaticoScreen extends ConsumerStatefulWidget {
  const CrearViaticoScreen({super.key});

  @override
  ConsumerState<CrearViaticoScreen> createState() => _CrearViaticoScreenState();
}

class _CrearViaticoScreenState extends ConsumerState<CrearViaticoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _conceptoController = TextEditingController();
  final _ordenIdController = TextEditingController();
  final _distanciaController = TextEditingController();
  
  TipoViatico _tipoSeleccionado = TipoViatico.manual;
  String? _usuarioSeleccionado;
  String? _usuarioIdSeleccionado;
  bool _isLoading = false;

  // Lista mock de usuarios
  final Map<String, String> _usuarios = {
    'Juan Pérez': '12345678',
    'María García': '87654321',
    'Carlos Rodríguez': '11223344',
    'Ana Martínez': '44332211',
    'Luis Hernández': '55667788',
    'Laura López': '88776655',
    'Pedro Sánchez': '99887766',
    'Carmen González': '66778899',
  };

  @override
  void dispose() {
    _montoController.dispose();
    _conceptoController.dispose();
    _ordenIdController.dispose();
    _distanciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text(
          'Nuevo Viático',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tipo de viático
              _buildSectionTitle('Tipo de Viático'),
              const SizedBox(height: 8),
              _buildTipoSelector(),
              const SizedBox(height: 24),
              
              // Usuario
              _buildSectionTitle('Usuario'),
              const SizedBox(height: 8),
              _buildUsuarioSelector(),
              const SizedBox(height: 24),
              
              // Orden (opcional)
              _buildSectionTitle('Orden (Opcional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ordenIdController,
                decoration: InputDecoration(
                  labelText: 'Número de Orden',
                  hintText: 'Ej: ORD-001',
                  prefixIcon: const Icon(Icons.receipt_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // Concepto
              _buildSectionTitle('Concepto'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _conceptoController,
                decoration: InputDecoration(
                  labelText: 'Concepto *',
                  hintText: 'Ej: Gasto gasolina, Alimentación, etc.',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El concepto es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Monto o Distancia según el tipo
              if (_tipoSeleccionado == TipoViatico.automatico) ...[
                _buildSectionTitle('Distancia'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _distanciaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Distancia (km) *',
                    hintText: 'Ej: 25.5',
                    prefixIcon: const Icon(Icons.straighten),
                    suffixText: 'km',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La distancia es obligatoria';
                    }
                    final distancia = double.tryParse(value);
                    if (distancia == null || distancia <= 0) {
                      return 'La distancia debe ser mayor a 0';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final distancia = double.tryParse(value);
                      if (distancia != null) {
                        final monto = _calcularViaticoPorDistancia(distancia);
                        _montoController.text = monto.toStringAsFixed(0);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Monto calculado
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calculate, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monto Calculado',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _montoController.text.isNotEmpty
                                  ? _formatCurrency(double.parse(_montoController.text))
                                  : '\$0',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _buildSectionTitle('Monto'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _montoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: 'Monto *',
                    hintText: 'Ej: 15000',
                    prefixIcon: const Icon(Icons.attach_money),
                    prefixText: r'$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El monto es obligatorio';
                    }
                    final monto = double.tryParse(value);
                    if (monto == null || monto <= 0) {
                      return 'El monto debe ser mayor a 0';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Formatear con separadores de miles
                    if (value.isNotEmpty) {
                      final cleanValue = value.replaceAll(',', '');
                      final numValue = double.tryParse(cleanValue);
                      if (numValue != null) {
                        final formatted = _formatCurrencyInput(numValue);
                        if (_montoController.text != formatted) {
                          _montoController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
              const SizedBox(height: 32),
              
              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _guardarViatico,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Guardar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Información sobre aprobación
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _tipoSeleccionado == TipoViatico.automatico
                            ? 'Los viáticos automáticos se aprueban automáticamente.'
                            : 'Los viáticos manuales requieren aprobación de un administrador.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
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
  }

  /// Construir título de sección
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// Construir selector de tipo
  Widget _buildTipoSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTipoOption(
            TipoViatico.manual,
            'Manual',
            Icons.edit,
            'Ingresado manualmente',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTipoOption(
            TipoViatico.automatico,
            'Automático',
            Icons.auto_awesome,
            'Calculado por distancia',
          ),
        ),
      ],
    );
  }

  /// Construir opción de tipo
  Widget _buildTipoOption(
    TipoViatico tipo,
    String label,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _tipoSeleccionado == tipo;
    return InkWell(
      onTap: () {
        setState(() {
          _tipoSeleccionado = tipo;
          if (tipo == TipoViatico.automatico) {
            _montoController.clear();
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.orange : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.orange[700] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Construir selector de usuario
  Widget _buildUsuarioSelector() {
    return InkWell(
      onTap: () => _mostrarSelectorUsuario(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.person_outline, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _usuarioSeleccionado ?? 'Seleccionar Usuario *',
                    style: TextStyle(
                      fontSize: 14,
                      color: _usuarioSeleccionado != null
                          ? Colors.black87
                          : Colors.grey[500],
                      fontWeight: _usuarioSeleccionado != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (_usuarioIdSeleccionado != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ID: $_usuarioIdSeleccionado',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  /// Mostrar selector de usuario
  void _mostrarSelectorUsuario() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const Text(
              'Seleccionar Usuario',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._usuarios.entries.map((entry) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(entry.key),
                subtitle: Text('ID: ${entry.value}'),
                onTap: () {
                  setState(() {
                    _usuarioSeleccionado = entry.key;
                    _usuarioIdSeleccionado = entry.value;
                  });
                  Navigator.pop(context);
                },
                selected: _usuarioSeleccionado == entry.key,
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Calcular viático por distancia
  double _calcularViaticoPorDistancia(double distancia) {
    final zonas = ref.read(zonasProvider);
    
    for (final zona in zonas) {
      if (distancia >= zona.kmMin && distancia <= zona.kmMax) {
        return zona.viatico;
      }
    }
    
    // Si excede todas las zonas, usar la última
    if (zonas.isNotEmpty) {
      return zonas.last.viatico;
    }
    
    // Valor por defecto: $500 por km
    return distancia * 500;
  }

  /// Guardar viático
  Future<void> _guardarViatico() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_usuarioSeleccionado == null || _usuarioIdSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un usuario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final monto = double.parse(
        _montoController.text.replaceAll(',', ''),
      );
      final distancia = _tipoSeleccionado == TipoViatico.automatico
          ? double.tryParse(_distanciaController.text)
          : null;

      final viatico = Viatico(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ordenId: _ordenIdController.text.isNotEmpty
            ? _ordenIdController.text
            : null,
        usuarioId: _usuarioIdSeleccionado!,
        usuarioNombre: _usuarioSeleccionado!,
        monto: monto,
        concepto: _conceptoController.text,
        tipo: _tipoSeleccionado,
        estado: _tipoSeleccionado == TipoViatico.automatico
            ? EstadoViatico.aprobado
            : EstadoViatico.pendiente,
        fechaCreado: DateTime.now(),
        fechaAprobado: _tipoSeleccionado == TipoViatico.automatico
            ? DateTime.now()
            : null,
        aprobadoPor: _tipoSeleccionado == TipoViatico.automatico
            ? 'Sistema'
            : null,
        distanciaKm: distancia,
      );

      await ref.read(viaticoListNotifierProvider.notifier)
          .agregarViatico(viatico);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tipoSeleccionado == TipoViatico.automatico
                  ? 'Viático creado y aprobado automáticamente'
                  : 'Viático creado. Pendiente de aprobación',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
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

  /// Formatear moneda para input
  String _formatCurrencyInput(double value) {
    final intValue = value.toInt();
    return intValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  /// Formatear moneda
  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }
}

