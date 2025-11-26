import '../../domain/entities/company.dart';

/// Modelo de datos que representa una compañía desde la API
class CompanyModel extends Company {
  const CompanyModel({
    required super.id,
    required super.razonSocial,
    required super.nit,
    required super.indEstado,
    required super.indConsolidadora,
    required super.maxPerAbiertos,
    required super.ultPerAbierto,
    required super.ultPerCerrado,
    required super.ultAnoCerrado,
    required super.numeroPeriodos,
    super.dvNit,
  });

  /// Crea un CompanyModel desde un JSON
  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['f010_id'] as int,
      razonSocial: (json['f010_razon_social'] as String?)?.trim() ?? '',
      nit: (json['f010_nit'] as String?)?.trim() ?? '',
      indEstado: json['f010_ind_estado'] as int? ?? 0,
      indConsolidadora: json['f010_ind_consolidadora'] as int? ?? 0,
      maxPerAbiertos: json['f010_max_per_abiertos'] as int? ?? 0,
      ultPerAbierto: json['f010_ult_per_abierto'] as int? ?? 0,
      ultPerCerrado: json['f010_ult_per_cerrado'] as int? ?? 0,
      ultAnoCerrado: json['f010_ult_ano_cerrado'] as int? ?? 0,
      numeroPeriodos: json['f010_numero_periodos'] as int? ?? 12,
      dvNit: (json['f010_dv_nit'] as String?)?.trim(),
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'f010_id': id,
      'f010_razon_social': razonSocial,
      'f010_nit': nit,
      'f010_ind_estado': indEstado,
      'f010_ind_consolidadora': indConsolidadora,
      'f010_max_per_abiertos': maxPerAbiertos,
      'f010_ult_per_abierto': ultPerAbierto,
      'f010_ult_per_cerrado': ultPerCerrado,
      'f010_ult_ano_cerrado': ultAnoCerrado,
      'f010_numero_periodos': numeroPeriodos,
      'f010_dv_nit': dvNit,
    };
  }

  /// Convierte el modelo a entidad de dominio
  Company toEntity() {
    return Company(
      id: id,
      razonSocial: razonSocial,
      nit: nit,
      indEstado: indEstado,
      indConsolidadora: indConsolidadora,
      maxPerAbiertos: maxPerAbiertos,
      ultPerAbierto: ultPerAbierto,
      ultPerCerrado: ultPerCerrado,
      ultAnoCerrado: ultAnoCerrado,
      numeroPeriodos: numeroPeriodos,
      dvNit: dvNit,
    );
  }
}

