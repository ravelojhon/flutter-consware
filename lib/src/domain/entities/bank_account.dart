import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa una cuenta bancaria
class BankAccount extends Equatable {
  final int idCia;
  final String id;
  final String descripcion;
  final int? rowidAuxBancos;
  final String? idBanco;
  final String? nroCuenta;
  final int indControlaChequera;
  final int? inicial1;
  final int? final1;
  final int? siguiente1;

  const BankAccount({
    required this.idCia,
    required this.id,
    required this.descripcion,
    this.rowidAuxBancos,
    this.idBanco,
    this.nroCuenta,
    required this.indControlaChequera,
    this.inicial1,
    this.final1,
    this.siguiente1,
  });

  /// Obtiene el nombre para mostrar en el dropdown
  String get displayName => descripcion;

  /// Obtiene el ID completo para identificar la cuenta
  String get fullId => '$idCia-$id';

  @override
  List<Object?> get props => [
        idCia,
        id,
        descripcion,
        rowidAuxBancos,
        idBanco,
        nroCuenta,
        indControlaChequera,
        inicial1,
        final1,
        siguiente1,
      ];
}

