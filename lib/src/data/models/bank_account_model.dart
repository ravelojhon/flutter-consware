import '../../domain/entities/bank_account.dart';

/// Modelo de datos que representa una cuenta bancaria desde la API
class BankAccountModel extends BankAccount {
  const BankAccountModel({
    required super.idCia,
    required super.id,
    required super.descripcion,
    super.rowidAuxBancos,
    super.idBanco,
    super.nroCuenta,
    required super.indControlaChequera,
    super.inicial1,
    super.final1,
    super.siguiente1,
  });

  /// Crea un BankAccountModel desde un JSON
  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      idCia: json['f026_id_cia'] as int? ?? 0,
      id: (json['f026_id'] as String?)?.trim() ?? '',
      descripcion: (json['f026_descripcion'] as String?)?.trim() ?? '',
      rowidAuxBancos: json['f026_rowid_aux_bancos'] as int?,
      idBanco: (json['f026_id_banco'] as String?)?.trim(),
      nroCuenta: (json['f026_nro_cuenta'] as String?)?.trim(),
      indControlaChequera: json['f026_ind_controla_chequera'] as int? ?? 0,
      inicial1: json['f026_inicial1'] as int?,
      final1: json['f026_final1'] as int?,
      siguiente1: json['f026_siguiente1'] as int?,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'f026_id_cia': idCia,
      'f026_id': id,
      'f026_descripcion': descripcion,
      'f026_rowid_aux_bancos': rowidAuxBancos,
      'f026_id_banco': idBanco,
      'f026_nro_cuenta': nroCuenta,
      'f026_ind_controla_chequera': indControlaChequera,
      'f026_inicial1': inicial1,
      'f026_final1': final1,
      'f026_siguiente1': siguiente1,
    };
  }

  /// Convierte el modelo a entidad de dominio
  BankAccount toEntity() {
    return BankAccount(
      idCia: idCia,
      id: id,
      descripcion: descripcion,
      rowidAuxBancos: rowidAuxBancos,
      idBanco: idBanco,
      nroCuenta: nroCuenta,
      indControlaChequera: indControlaChequera,
      inicial1: inicial1,
      final1: final1,
      siguiente1: siguiente1,
    );
  }
}

