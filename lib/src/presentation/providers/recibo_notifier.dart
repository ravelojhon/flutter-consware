import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modelo de recibo guardado
class ReciboGuardado {
  final String id;
  final String numeroRecibo;
  final String fecha;
  final String cliente;
  final String nit;
  final double totalRecibo;
  final double netoRecibo;
  final List<Map<String, dynamic>> formasPago;
  final String cuenta;
  final DateTime fechaCreacion;
  final String nombreCompania;
  final String nitCompania;

  ReciboGuardado({
    required this.id,
    required this.numeroRecibo,
    required this.fecha,
    required this.cliente,
    required this.nit,
    required this.totalRecibo,
    required this.netoRecibo,
    required this.formasPago,
    required this.cuenta,
    required this.fechaCreacion,
    required this.nombreCompania,
    required this.nitCompania,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroRecibo': numeroRecibo,
      'fecha': fecha,
      'cliente': cliente,
      'nit': nit,
      'totalRecibo': totalRecibo,
      'netoRecibo': netoRecibo,
      'formasPago': formasPago,
      'cuenta': cuenta,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'nombreCompania': nombreCompania,
      'nitCompania': nitCompania,
    };
  }

  factory ReciboGuardado.fromMap(Map<String, dynamic> map) {
    return ReciboGuardado(
      id: map['id'] as String,
      numeroRecibo: map['numeroRecibo'] as String,
      fecha: map['fecha'] as String,
      cliente: map['cliente'] as String,
      nit: map['nit'] as String,
      totalRecibo: (map['totalRecibo'] as num).toDouble(),
      netoRecibo: (map['netoRecibo'] as num).toDouble(),
      formasPago: List<Map<String, dynamic>>.from(map['formasPago'] as List),
      cuenta: map['cuenta'] as String,
      fechaCreacion: DateTime.parse(map['fechaCreacion'] as String),
      nombreCompania: map['nombreCompania'] as String? ?? '',
      nitCompania: map['nitCompania'] as String? ?? '',
    );
  }
}

/// Notifier para gestionar recibos guardados
class ReciboListNotifier extends Notifier<List<ReciboGuardado>> {
  @override
  List<ReciboGuardado> build() {
    return [];
  }

  /// Agregar un nuevo recibo
  Future<void> agregarRecibo(ReciboGuardado recibo) async {
    // Simular guardado (delay pequeño)
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    state = [recibo, ...state];
  }

  /// Obtener todos los recibos
  List<ReciboGuardado> obtenerRecibos() {
    return state;
  }

  /// Obtener un recibo por ID
  ReciboGuardado? obtenerReciboPorId(String id) {
    try {
      return state.firstWhere((ReciboGuardado r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Eliminar un recibo
  Future<void> eliminarRecibo(String id) async {
    state = state.where((ReciboGuardado r) => r.id != id).toList();
  }

  /// Limpiar todos los recibos
  void limpiarRecibos() {
    state = [];
  }
}

/// Provider para la lista de recibos
final reciboListNotifierProvider =
    NotifierProvider<ReciboListNotifier, List<ReciboGuardado>>(() {
  return ReciboListNotifier();
});

