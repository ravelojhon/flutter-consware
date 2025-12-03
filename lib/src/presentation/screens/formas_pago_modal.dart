import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'seleccion_forma_pago_modal.dart';
import 'consignado_modal.dart';

/// Modal para seleccionar formas de pago
class FormasPagoModal extends ConsumerStatefulWidget {
  final double netoAPagar;
  final String numeroCuenta;

  const FormasPagoModal({
    super.key,
    required this.netoAPagar,
    this.numeroCuenta = '',
  });

  @override
  ConsumerState<FormasPagoModal> createState() => _FormasPagoModalState();
}

class _FormasPagoModalState extends ConsumerState<FormasPagoModal> {
  final _documentoController = TextEditingController();
  final _valorController = TextEditingController();
  final _cuentaController = TextEditingController();
  final _consignadoController = TextEditingController();

  final List<Map<String, dynamic>> _formasPago = [];
  double _totalPago = 0.0;
  String _formaPagoSeleccionada = '';
  String _franquiciaSeleccionada = '';
  String _codigoFormaPago = ''; // ID de la forma de pago - vacío inicialmente para ocultar consignar en
  String? _nroCuentaConsignado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializar el campo cuenta con el número de cuenta del consignado
    if (widget.numeroCuenta.isNotEmpty) {
      _cuentaController.text = widget.numeroCuenta;
    }
  }

  @override
  void dispose() {
    _documentoController.dispose();
    _valorController.dispose();
    _cuentaController.dispose();
    _consignadoController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String _formatCurrencyInput(double value) {
    // Formatear sin decimales, solo números enteros con separadores de miles
    final intValue = value.toInt();
    return intValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  bool _puedeAgregarMasFormasPago() {
    // Verificar si el total actual es menor que el neto a pagar
    return _totalPago < widget.netoAPagar;
  }

  /// Obtener el color del total según qué tan cerca esté del neto a pagar
  Color _getColorTotal() {
    if (widget.netoAPagar <= 0) return Colors.grey;
    
    final porcentaje = (_totalPago / widget.netoAPagar) * 100;
    final diferencia = (widget.netoAPagar - _totalPago).abs();
    final tolerancia = widget.netoAPagar * 0.01; // 1% de tolerancia
    
    // Si está exacto (dentro de 1% de tolerancia)
    if (diferencia <= tolerancia) {
      return Colors.green;
    }
    // Si está muy cerca (entre 80% y 99.9%)
    else if (porcentaje >= 80 && porcentaje < 99.9) {
      return Colors.orange;
    }
    // Si está muy inferior (menos del 80%)
    else {
      return Colors.red;
    }
  }

  /// Verificar si se puede grabar (total igual al neto a pagar y hay formas de pago)
  bool _puedeGrabar() {
    if (_formasPago.isEmpty) return false;
    final diferencia = (widget.netoAPagar - _totalPago).abs();
    return diferencia < 0.01; // Tolerancia de 0.01
  }

  /// Confirmar grabar recibo
  Future<void> _confirmarGrabado(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con icono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              
              // Título
              const Text(
                'Confirmar Guardado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              // Descripción
              Text(
                '¿Desea guardar el recibo?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              
              // Detalles compactos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Neto a Pagar',
                      _formatCurrency(widget.netoAPagar),
                      Colors.blue,
                      isBold: true,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Total Formas de Pago',
                      _formatCurrency(_totalPago),
                      _getColorTotal(),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Cantidad de Pagos',
                      '${_formasPago.length}',
                      Colors.grey[700]!,
                    ),
                    if (_cuentaController.text.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Cuenta',
                        _cuentaController.text,
                        Colors.grey[700]!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Botones alineados y bonitos
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

    if (confirmar == true && mounted) {
      setState(() {
        _isLoading = true;
      });
      
      // Simular guardado con delay de 2 segundos
      await Future<void>.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        // Devolver las formas de pago junto con la confirmación y el número de cuenta
        // Antes de cerrar el loading y redirigir
        Navigator.pop(context, {
          'guardado': true,
          'formasPago': _formasPago,
          'numeroCuenta': _nroCuentaConsignado ?? '',
        });
        
        // El loading se mantendrá hasta que se cierre el modal desde el formulario principal
      }
    }
  }

  /// Construir fila de detalle compacta
  Widget _buildDetailRow(String label, String value, Color valueColor, {bool isBold = false}) {
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
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// Cerrar modal con confirmación si hay formas de pago
  Future<void> _cerrarModal(BuildContext context) async {
    if (_formasPago.isNotEmpty) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Cerrar modal?'),
          content: const Text(
            'Se borrarán las formas de pago agregadas. ¿Desea continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );

      if (confirmar == true && mounted) {
        Navigator.pop(context, false);
      }
    } else {
      Navigator.pop(context, false);
    }
  }

  void _agregarFormaPago() {
    // Validar que no se exceda el neto a pagar
    if (!_puedeAgregarMasFormasPago()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El total de formas de pago ya es igual al neto a pagar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final valorText = _valorController.text.replaceAll(',', '').replaceAll('.', '');
    final valor = double.tryParse(valorText) ?? 0.0;
    
    if (valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El valor debe ser mayor a cero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verificar que el nuevo total no exceda el neto a pagar
    final nuevoTotal = _totalPago + valor;
    if (nuevoTotal > widget.netoAPagar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El total no puede exceder el neto a pagar. Restante: ${_formatCurrency(widget.netoAPagar - _totalPago)}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _formasPago.add({
        'formaPago': _formaPagoSeleccionada,
        'codigo': _codigoFormaPago, // ID de la forma de pago
        'banco': '41',
        'documento': _documentoController.text.isNotEmpty
            ? _documentoController.text
            : '100188227',
        'franquicia': _franquiciaSeleccionada,
        'valor': valor,
        'cuenta': _nroCuentaConsignado ?? '',
      });
      _totalPago += valor;
      _valorController.clear();
      _documentoController.clear();
      _formaPagoSeleccionada = '';
      _franquiciaSeleccionada = '';
      _codigoFormaPago = ''; // Vacío para ocultar consignar en inicialmente
      // Limpiar consignado al agregar forma de pago
      _consignadoController.clear();
      _nroCuentaConsignado = null;
      _cuentaController.clear();
      
      // Quitar el foco del input valor
      FocusScope.of(context).unfocus();
    });
  }

  void _eliminarFormaPago(int index) {
    setState(() {
      final valorEliminado = _formasPago[index]['valor'] as double;
      _totalPago -= valorEliminado;
      _formasPago.removeAt(index);
      
      // Validar que el total no sea menor que 0
      if (_totalPago < 0) {
        _totalPago = 0;
      }
      
      // Siempre restablecer el formulario cuando se elimina una forma de pago
      // para que al volver a seleccionar EF se calcule el saldo pendiente correctamente
      _formaPagoSeleccionada = '';
      _franquiciaSeleccionada = '';
      _codigoFormaPago = ''; // Vacío para ocultar consignar en
      _documentoController.clear();
      _valorController.clear();
      _cuentaController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Formas de Pago',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Neto a Pagar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          _formatCurrency(widget.netoAPagar),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contenido
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card para el formulario de entrada
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Agregar Forma de Pago',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Campos de entrada - Responsivos
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isMobile = constraints.maxWidth < 600;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Campo de forma de pago
                                    TextFormField(
                                      controller: _documentoController,
                                      readOnly: true,
                                      enabled: _puedeAgregarMasFormasPago(),
                                      decoration: InputDecoration(
                                        labelText: 'Elija Forma Pago',
                                        hintText: 'Elija la forma de pago',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor: _puedeAgregarMasFormasPago() ? Colors.white : Colors.grey[200],
                                        suffixIcon: Icon(
                                          Icons.arrow_drop_down,
                                          color: _puedeAgregarMasFormasPago() ? null : Colors.grey,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                      onTap: _puedeAgregarMasFormasPago() ? () async {
                                        final formaPago = await showDialog<Map<String, String>>(
                                          context: context,
                                          builder: (context) => const SeleccionFormaPagoModal(),
                                        );
                                        if (formaPago != null && mounted) {
                                          setState(() {
                                            _formaPagoSeleccionada = formaPago['nombre']!;
                                            _franquiciaSeleccionada = formaPago['codigo']!;
                                            _codigoFormaPago = formaPago['codigo']!;
                                            // Mostrar ID y nombre en el campo
                                            _documentoController.text = '${formaPago['codigo']} - ${formaPago['nombre']}';
                                            
                                            // Si el código es "EF", autocompletar el valor con el neto a pagar
                                            if (formaPago['codigo'] == 'EF') {
                                              final valorRestante = widget.netoAPagar - _totalPago;
                                              if (valorRestante > 0) {
                                                _valorController.text = _formatCurrencyInput(valorRestante);
                                              }
                                              // Limpiar consignado si es efectivo
                                              _consignadoController.clear();
                                              _nroCuentaConsignado = null;
                                              _cuentaController.clear();
                                            } else {
                                              // Si no es efectivo, limpiar consignado para que el usuario lo seleccione
                                              _consignadoController.clear();
                                              _nroCuentaConsignado = null;
                                              _cuentaController.clear();
                                            }
                                          });
                                        }
                                      } : null,
                                    ),
                                    // Mostrar select de consignar en solo si la forma de pago no es efectivo
                                    if (_codigoFormaPago != 'EF' && _codigoFormaPago.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _consignadoController,
                                        readOnly: true,
                                        enabled: _puedeAgregarMasFormasPago(),
                                        decoration: InputDecoration(
                                          labelText: 'Consignar en',
                                          hintText: 'Seleccione la cuenta',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          filled: true,
                                          fillColor: _puedeAgregarMasFormasPago() ? Colors.white : Colors.grey[200],
                                          suffixIcon: Icon(
                                            Icons.arrow_drop_down,
                                            color: _puedeAgregarMasFormasPago() ? null : Colors.grey,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                        onTap: _puedeAgregarMasFormasPago() ? () async {
                                          final selected = await showGeneralDialog<dynamic>(
                                            context: context,
                                            barrierDismissible: true,
                                            barrierLabel: 'Consignado',
                                            barrierColor: Colors.black54,
                                            transitionDuration: const Duration(milliseconds: 300),
                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                const ConsignadoModal(),
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
                                          if (selected != null && mounted) {
                                            setState(() {
                                              if (selected is Map<String, dynamic>) {
                                                _consignadoController.text = selected['descripcion'] as String? ?? '';
                                                _nroCuentaConsignado = selected['nroCuenta'] as String? ?? '';
                                                // Mostrar el número de cuenta en el input de cuenta
                                                _cuentaController.text = _nroCuentaConsignado ?? '';
                                              }
                                            });
                                          }
                                        } : null,
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: isMobile ? 3 : 2,
                                          child: TextFormField(
                                            controller: _valorController,
                                            enabled: _puedeAgregarMasFormasPago(),
                                            decoration: InputDecoration(
                                              labelText: 'Valor',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: const BorderSide(color: Colors.grey),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: const BorderSide(color: Colors.blue, width: 2),
                                              ),
                                              filled: true,
                                              fillColor: _puedeAgregarMasFormasPago() ? Colors.white : Colors.grey[200],
                                              prefixText: r'$ ',
                                              prefixStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                            ],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            onChanged: _puedeAgregarMasFormasPago() ? (value) {
                                              // Formatear con separadores de miles
                                              final String cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
                                              final numValue = int.tryParse(cleanValue) ?? 0;
                                              
                                              // Calcular el valor restante del neto a pagar
                                              final valorRestante = widget.netoAPagar - _totalPago;
                                              
                                              // Si el valor ingresado supera el restante, ajustarlo al restante
                                              double valorAjustado = numValue.toDouble();
                                              if (numValue > valorRestante && valorRestante > 0) {
                                                valorAjustado = valorRestante;
                                              }
                                              
                                              final formatted = _formatCurrencyInput(valorAjustado);
                                              
                                              if (_valorController.text != formatted) {
                                                _valorController.value = TextEditingValue(
                                                  text: formatted,
                                                  selection: TextSelection.collapsed(
                                                    offset: formatted.length,
                                                  ),
                                                );
                                              }
                                            } : null,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: isMobile ? 56 : 64,
                                          child: ElevatedButton(
                                            onPressed: _puedeAgregarMasFormasPago() ? _agregarFormaPago : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Icon(Icons.add, size: 24),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (!_puedeAgregarMasFormasPago())
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Total alcanzado. No se pueden agregar más formas de pago.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange[700],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                    ),
                    // Tabla de formas de pago
                    if (_formasPago.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Text(
                          'No hay formas de pago agregadas',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            // Header de la tabla
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Forma de Pago',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Cuenta',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.blue,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 48),
                                ],
                              ),
                            ),
                            // Body de la tabla
                            ...List.generate(_formasPago.length, (index) {
                              final formaPago = _formasPago[index];
                              final esEfectivo = formaPago['codigo'] == 'EF';
                              final cuentaTexto = esEfectivo ? '- - -' : (formaPago['cuenta'] as String? ?? '-');
                              return Container(
                                decoration: BoxDecoration(
                                  color: index % 2 == 0
                                      ? Colors.white
                                      : Colors.grey[50],
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              formaPago['formaPago'] as String? ?? formaPago['codigo'] as String? ?? formaPago['franquicia'] as String,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatCurrency(formaPago['valor'] as double),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          cuentaTexto,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: esEfectivo ? Colors.grey[400] : Colors.grey[700],
                                            fontStyle: esEfectivo ? FontStyle.italic : FontStyle.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 48,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () => _eliminarFormaPago(index),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          tooltip: 'Quitar',
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
                  ],
                ),
              ),
            ),

            // Footer con botones y totales
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Totales y cuenta
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      final valorRestante = widget.netoAPagar - _totalPago;
                      final mostrarRestante = valorRestante.abs() > 0.01;
                      
                      if (isMobile) {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getColorTotal().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getColorTotal().withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Totales',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(_totalPago),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _getColorTotal(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (mostrarRestante) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      valorRestante > 0
                                          ? 'Restante: ${_formatCurrency(valorRestante)}'
                                          : 'Excedente: ${_formatCurrency(valorRestante.abs())}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getColorTotal().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getColorTotal().withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Totales',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _formatCurrency(_totalPago),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: _getColorTotal(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (mostrarRestante) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        valorRestante > 0
                                            ? 'Restante: ${_formatCurrency(valorRestante)}'
                                            : 'Excedente: ${_formatCurrency(valorRestante.abs())}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: OutlinedButton.icon(
                          onPressed: () => _cerrarModal(context),
                          icon: const Icon(Icons.close, size: 20),
                          label: const Text('Cerrar'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: (_puedeGrabar() && !_isLoading) ? () => _confirmarGrabado(context) : null,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.save, size: 20),
                          label: Text(_isLoading ? 'Guardando...' : 'Grabar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_puedeGrabar() && !_isLoading) ? Colors.green : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
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
          // Loading overlay global
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 4,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Guardando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

