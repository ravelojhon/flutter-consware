import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estados posibles de un viático
enum EstadoViatico {
  pendiente,
  aprobado,
  rechazado,
}

/// Tipos de viático
enum TipoViatico {
  automatico,
  manual,
}

/// Modelo de viático
class Viatico {
  final String id;
  final String? ordenId;
  final String usuarioId;
  final String usuarioNombre;
  final double monto;
  final String concepto;
  final TipoViatico tipo;
  final String? evidenciaUrl;
  final EstadoViatico estado;
  final DateTime fechaCreado;
  final DateTime? fechaAprobado;
  final String? aprobadoPor;
  final String? observaciones;
  final double? distanciaKm; // Para viáticos automáticos por distancia

  Viatico({
    required this.id,
    this.ordenId,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.monto,
    required this.concepto,
    required this.tipo,
    this.evidenciaUrl,
    required this.estado,
    required this.fechaCreado,
    this.fechaAprobado,
    this.aprobadoPor,
    this.observaciones,
    this.distanciaKm,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ordenId': ordenId,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'monto': monto,
      'concepto': concepto,
      'tipo': tipo.name,
      'evidenciaUrl': evidenciaUrl,
      'estado': estado.name,
      'fechaCreado': fechaCreado.toIso8601String(),
      'fechaAprobado': fechaAprobado?.toIso8601String(),
      'aprobadoPor': aprobadoPor,
      'observaciones': observaciones,
      'distanciaKm': distanciaKm,
    };
  }

  factory Viatico.fromMap(Map<String, dynamic> map) {
    return Viatico(
      id: map['id'] as String,
      ordenId: map['ordenId'] as String?,
      usuarioId: map['usuarioId'] as String,
      usuarioNombre: map['usuarioNombre'] as String,
      monto: (map['monto'] as num).toDouble(),
      concepto: map['concepto'] as String,
      tipo: TipoViatico.values.firstWhere(
        (e) => e.name == map['tipo'],
        orElse: () => TipoViatico.manual,
      ),
      evidenciaUrl: map['evidenciaUrl'] as String?,
      estado: EstadoViatico.values.firstWhere(
        (e) => e.name == map['estado'],
        orElse: () => EstadoViatico.pendiente,
      ),
      fechaCreado: DateTime.parse(map['fechaCreado'] as String),
      fechaAprobado: map['fechaAprobado'] != null
          ? DateTime.parse(map['fechaAprobado'] as String)
          : null,
      aprobadoPor: map['aprobadoPor'] as String?,
      observaciones: map['observaciones'] as String?,
      distanciaKm: map['distanciaKm'] != null
          ? (map['distanciaKm'] as num).toDouble()
          : null,
    );
  }

  Viatico copyWith({
    String? id,
    String? ordenId,
    String? usuarioId,
    String? usuarioNombre,
    double? monto,
    String? concepto,
    TipoViatico? tipo,
    String? evidenciaUrl,
    EstadoViatico? estado,
    DateTime? fechaCreado,
    DateTime? fechaAprobado,
    String? aprobadoPor,
    String? observaciones,
    double? distanciaKm,
  }) {
    return Viatico(
      id: id ?? this.id,
      ordenId: ordenId ?? this.ordenId,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      monto: monto ?? this.monto,
      concepto: concepto ?? this.concepto,
      tipo: tipo ?? this.tipo,
      evidenciaUrl: evidenciaUrl ?? this.evidenciaUrl,
      estado: estado ?? this.estado,
      fechaCreado: fechaCreado ?? this.fechaCreado,
      fechaAprobado: fechaAprobado ?? this.fechaAprobado,
      aprobadoPor: aprobadoPor ?? this.aprobadoPor,
      observaciones: observaciones ?? this.observaciones,
      distanciaKm: distanciaKm ?? this.distanciaKm,
    );
  }
}

/// Modelo de zona para cálculo de viáticos por distancia
class Zona {
  final String id;
  final String nombre;
  final int kmMin;
  final int kmMax;
  final double viatico;

  Zona({
    required this.id,
    required this.nombre,
    required this.kmMin,
    required this.kmMax,
    required this.viatico,
  });
}

/// Notifier para gestionar viáticos
class ViaticoListNotifier extends Notifier<List<Viatico>> {
  @override
  List<Viatico> build() {
    // Datos mock iniciales
    return _getMockViaticos();
  }

  /// Obtener viáticos mock
  List<Viatico> _getMockViaticos() {
    final now = DateTime.now();
    return [
      Viatico(
        id: '1',
        ordenId: 'ORD-001',
        usuarioId: '12345678',
        usuarioNombre: 'Juan Pérez',
        monto: 15000.0,
        concepto: 'Gasto gasolina para entrega fuera de ciudad',
        tipo: TipoViatico.manual,
        estado: EstadoViatico.pendiente,
        fechaCreado: now.subtract(const Duration(days: 2)),
        distanciaKm: null,
      ),
      Viatico(
        id: '2',
        ordenId: 'ORD-002',
        usuarioId: '87654321',
        usuarioNombre: 'María García',
        monto: 25000.0,
        concepto: 'Viático automático por distancia',
        tipo: TipoViatico.automatico,
        estado: EstadoViatico.aprobado,
        fechaCreado: now.subtract(const Duration(days: 5)),
        fechaAprobado: now.subtract(const Duration(days: 4)),
        aprobadoPor: 'Admin Sistema',
        distanciaKm: 50.0,
      ),
      Viatico(
        id: '3',
        ordenId: null,
        usuarioId: '11223344',
        usuarioNombre: 'Carlos Rodríguez',
        monto: 10000.0,
        concepto: 'Alimentación durante entrega',
        tipo: TipoViatico.manual,
        estado: EstadoViatico.aprobado,
        fechaCreado: now.subtract(const Duration(days: 1)),
        fechaAprobado: now.subtract(const Duration(hours: 12)),
        aprobadoPor: 'Admin Sistema',
        evidenciaUrl: 'https://example.com/recibo.jpg',
      ),
      Viatico(
        id: '4',
        ordenId: 'ORD-003',
        usuarioId: '44332211',
        usuarioNombre: 'Ana Martínez',
        monto: 30000.0,
        concepto: 'Gasto por ida a banco',
        tipo: TipoViatico.manual,
        estado: EstadoViatico.rechazado,
        fechaCreado: now.subtract(const Duration(days: 3)),
        fechaAprobado: now.subtract(const Duration(days: 2)),
        aprobadoPor: 'Admin Sistema',
        observaciones: 'No se justifica el monto',
      ),
      Viatico(
        id: '5',
        ordenId: 'ORD-004',
        usuarioId: '55667788',
        usuarioNombre: 'Luis Hernández',
        monto: 18000.0,
        concepto: 'Viático automático por distancia',
        tipo: TipoViatico.automatico,
        estado: EstadoViatico.aprobado,
        fechaCreado: now.subtract(const Duration(hours: 6)),
        fechaAprobado: now.subtract(const Duration(hours: 5)),
        aprobadoPor: 'Sistema',
        distanciaKm: 36.0,
      ),
    ];
  }

  /// Agregar un nuevo viático
  Future<void> agregarViatico(Viatico viatico) async {
    // Simular guardado
    await Future<void>.delayed(const Duration(milliseconds: 500));
    state = [viatico, ...state];
  }

  /// Aprobar un viático
  Future<void> aprobarViatico(String id, String aprobadoPor, {String? observaciones}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = state.map((viatico) {
      if (viatico.id == id) {
        return viatico.copyWith(
          estado: EstadoViatico.aprobado,
          fechaAprobado: DateTime.now(),
          aprobadoPor: aprobadoPor,
          observaciones: observaciones,
        );
      }
      return viatico;
    }).toList();
  }

  /// Rechazar un viático
  Future<void> rechazarViatico(String id, String aprobadoPor, String observaciones) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = state.map((viatico) {
      if (viatico.id == id) {
        return viatico.copyWith(
          estado: EstadoViatico.rechazado,
          fechaAprobado: DateTime.now(),
          aprobadoPor: aprobadoPor,
          observaciones: observaciones,
        );
      }
      return viatico;
    }).toList();
  }

  /// Eliminar un viático
  Future<void> eliminarViatico(String id) async {
    state = state.where((v) => v.id != id).toList();
  }

  /// Obtener viáticos por estado
  List<Viatico> obtenerPorEstado(EstadoViatico estado) {
    return state.where((v) => v.estado == estado).toList();
  }

  /// Obtener viáticos por usuario
  List<Viatico> obtenerPorUsuario(String usuarioId) {
    return state.where((v) => v.usuarioId == usuarioId).toList();
  }

  /// Calcular total de viáticos aprobados
  double calcularTotalAprobados() {
    return state
        .where((v) => v.estado == EstadoViatico.aprobado)
        .fold<double>(0.0, (sum, v) => sum + v.monto);
  }
}

/// Provider para la lista de viáticos
final viaticoListNotifierProvider =
    NotifierProvider<ViaticoListNotifier, List<Viatico>>(() {
  return ViaticoListNotifier();
});

/// Provider para zonas (mock)
final zonasProvider = Provider<List<Zona>>((ref) {
  return [
    Zona(id: '1', nombre: 'Zona Local', kmMin: 0, kmMax: 10, viatico: 5000.0),
    Zona(id: '2', nombre: 'Zona Media', kmMin: 11, kmMax: 30, viatico: 15000.0),
    Zona(id: '3', nombre: 'Zona Lejana', kmMin: 31, kmMax: 50, viatico: 25000.0),
    Zona(id: '4', nombre: 'Zona Muy Lejana', kmMin: 51, kmMax: 100, viatico: 40000.0),
    Zona(id: '5', nombre: 'Fuera de Ciudad', kmMin: 101, kmMax: 999, viatico: 60000.0),
  ];
});

