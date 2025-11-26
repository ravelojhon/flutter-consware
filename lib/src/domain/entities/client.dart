import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa un cliente
class Client extends Equatable {
  final int id;
  final String nit;
  final String razonSocial;
  final String nombre;
  final String? email;
  final String? celular;
  final String? direccion1;

  const Client({
    required this.id,
    required this.nit,
    required this.razonSocial,
    required this.nombre,
    this.email,
    this.celular,
    this.direccion1,
  });

  /// Obtiene el nombre para mostrar en el dropdown
  String get displayName => '$nombre ($nit)';

  /// Obtiene el nombre completo para búsqueda
  String get fullName => razonSocial.isNotEmpty ? razonSocial : nombre;

  @override
  List<Object?> get props => [
        id,
        nit,
        razonSocial,
        nombre,
        email,
        celular,
        direccion1,
      ];
}

