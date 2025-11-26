import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa una compañía
class Company extends Equatable {
  final int id;
  final String razonSocial;
  final String nit;
  final int indEstado;
  final int indConsolidadora;
  final int maxPerAbiertos;
  final int ultPerAbierto;
  final int ultPerCerrado;
  final int ultAnoCerrado;
  final int numeroPeriodos;
  final String? dvNit;

  const Company({
    required this.id,
    required this.razonSocial,
    required this.nit,
    required this.indEstado,
    required this.indConsolidadora,
    required this.maxPerAbiertos,
    required this.ultPerAbierto,
    required this.ultPerCerrado,
    required this.ultAnoCerrado,
    required this.numeroPeriodos,
    this.dvNit,
  });

  /// Obtiene el NIT completo con dígito de verificación
  String get nitCompleto {
    final nitLimpio = nit.trim();
    final dv = dvNit?.trim() ?? '';
    return dv.isNotEmpty ? '$nitLimpio-$dv' : nitLimpio;
  }

  /// Obtiene el nombre para mostrar en el dropdown
  String get displayName => '$razonSocial (${nitCompleto})';

  @override
  List<Object?> get props => [
        id,
        razonSocial,
        nit,
        indEstado,
        indConsolidadora,
        maxPerAbiertos,
        ultPerAbierto,
        ultPerCerrado,
        ultAnoCerrado,
        numeroPeriodos,
        dvNit,
      ];
}

