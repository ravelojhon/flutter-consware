import 'package:flutter/foundation.dart';

import '../../domain/entities/factura.dart';

/// Modelo de datos que representa una factura desde la API
class FacturaModel extends Factura {
  FacturaModel({
    required super.sucursal,
    required super.tipo,
    required super.factura,
    required super.fecha,
    required super.vence,
    required super.valor,
    required super.abonos,
    required super.saldo,
    super.valRecibo,
    super.ok,
    super.idCia,
    super.rowid,
    super.idCo,
    super.idTipoDocto,
    super.consecDocto,
    super.prefijo,
    super.idPeriodo,
    super.rowidTercero,
    super.idSucursal,
    super.totalDb,
    super.totalCr,
    super.idClaseDocto,
    super.indEstado,
    super.indTransmit,
    super.fechaTsCreacion,
    super.fechaTsActualizacion,
    super.fechaTsAprobacion,
    super.fechaTsAnulacion,
    super.usuarioCreacion,
    super.usuarioActualizacion,
    super.usuarioAprobacion,
    super.usuarioAnulacion,
    super.totalBaseGravable,
    super.indImpresion,
    super.nroImpresiones,
    super.fechaTsHabilitaImp,
    super.usuarioHabilitaImp,
    super.notas,
    super.rowidDoctoBase,
    super.referencia,
    super.idMandato,
    super.rowidMovtoEntidad,
    super.idMotivoOtros,
    super.idMonedaDocto,
    super.idMonedaConv,
    super.indFormaConv,
    super.tasaConv,
    super.idMonedaLocal,
    super.indFormaLocal,
    super.tasaLocal,
    super.idTipoCambio,
    super.indCfd,
    super.usuarioImpresion,
    super.fechaTsImpresion,
    super.rowidTePlantilla,
    super.totalDb2,
    super.totalCr2,
    super.totalDb3,
    super.totalCr3,
    super.indImptoAsumido,
    super.rowidSesion,
    super.indTipoOrigen,
    super.rowidDoctoRp,
    super.idProyecto,
    super.indDifCambioForma,
    super.indClaseOrigen,
    super.indEnvioCorreo,
    super.usuarioEnvioCorreo,
    super.fechaTsEnvioCorreo,
  });

  /// Helper para parsear números con comas como separador decimal
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Reemplazar comas por puntos para parsear números
      final cleaned = value.replaceAll(',', '.').trim();
      if (cleaned.isEmpty || cleaned == 'NULL') return null;
      return double.tryParse(cleaned);
    }
    return null;
  }

  /// Helper para parsear enteros
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) {
      final cleaned = value.trim();
      if (cleaned.isEmpty || cleaned == 'NULL') return null;
      return int.tryParse(cleaned);
    }
    return null;
  }

  /// Helper para parsear strings
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed == 'NULL') return null;
      return trimmed;
    }
    // Si es un número, convertirlo a string
    if (value is num) {
      return value.toString();
    }
    return value.toString().trim();
  }

  /// Crea un FacturaModel desde un JSON
  factory FacturaModel.fromJson(Map<String, dynamic> json) {
    // Mapear campos originales desde los nuevos campos de la API
    // f350_id_sucursal puede venir como string con espacios: "0  "
    final idSucursalRaw = json['f350_id_sucursal'];
    final idSucursal = idSucursalRaw != null 
        ? (idSucursalRaw is String ? idSucursalRaw.trim() : idSucursalRaw.toString().trim())
        : '';
    
    // f350_id_tipo_docto viene como string: "FCE"
    final idTipoDoctoRaw = json['f350_id_tipo_docto'];
    final idTipoDocto = idTipoDoctoRaw != null 
        ? (idTipoDoctoRaw is String ? idTipoDoctoRaw.trim() : idTipoDoctoRaw.toString().trim())
        : '';
    
    // f350_consec_docto puede venir como número (2820) o string
    final consecDoctoValue = json['f350_consec_docto'];
    final consecDocto = consecDoctoValue != null 
        ? (consecDoctoValue is num 
            ? consecDoctoValue.toString() 
            : (consecDoctoValue as String?)?.trim() ?? '')
        : '';
    
    // f350_fecha viene como ISO string: "2021-02-23T00:00:00.000Z"
    final fechaValue = json['f350_fecha'];
    final fecha = fechaValue != null
        ? (fechaValue is String 
            ? fechaValue.split('T')[0] // Extraer solo la fecha: "2021-02-23"
            : fechaValue.toString())
        : '';
    
    // f350_total_db y f350_total_cr vienen como números
    final totalDb = _parseDouble(json['f350_total_db']);
    final totalCr = _parseDouble(json['f350_total_cr']);
    
    // Calcular saldo (totalDb - totalCr, aunque normalmente son iguales)
    // Para facturas, el saldo sería el totalDb menos los abonos
    // Por ahora usamos totalDb como valor base
    final saldo = totalDb ?? 0.0;
    
    debugPrint('🔍 Factura parseada - Sucursal: "$idSucursal", Tipo: "$idTipoDocto", Factura: "$consecDocto", Fecha: "$fecha", TotalDb: $totalDb');

    return FacturaModel(
      // Campos originales mapeados desde los nuevos campos
      sucursal: idSucursal.isNotEmpty 
          ? idSucursal
          : (_parseString(json['sucursal']) ?? ''),
      tipo: idTipoDocto.isNotEmpty
          ? idTipoDocto
          : (_parseString(json['tipo']) ?? ''),
      factura: consecDocto.isNotEmpty 
          ? consecDocto
          : (_parseString(json['factura']) ?? 
             _parseString(json['numero']) ?? 
             _parseString(json['numero_factura']) ?? ''),
      fecha: fecha.isNotEmpty
          ? fecha
          : (_parseString(json['fecha']) ?? ''),
      vence: _parseString(json['vence']) ?? 
             _parseString(json['fecha_vencimiento']) ?? 
             fecha, // Si no hay fecha de vencimiento, usar la fecha del documento
      valor: totalDb ?? 
             _parseDouble(json['valor']) ?? 
             _parseDouble(json['valor_total']) ?? 0.0,
      abonos: _parseDouble(json['abonos']) ?? 
              _parseDouble(json['valor_abonado']) ?? 0.0,
      saldo: saldo, // Usar el saldo calculado (totalDb por ahora)
      valRecibo: 0.0,
      ok: false,
      // Nuevos campos de la API
      idCia: _parseInt(json['f350_id_cia']),
      rowid: _parseInt(json['f350_rowid']),
      idCo: _parseString(json['f350_id_co']),
      idTipoDocto: idTipoDocto,
      consecDocto: consecDocto,
      prefijo: _parseString(json['f350_prefijo']),
      idPeriodo: _parseString(json['f350_id_periodo']),
      rowidTercero: _parseInt(json['f350_rowid_tercero']),
      idSucursal: idSucursal,
      totalDb: totalDb,
      totalCr: totalCr,
      idClaseDocto: _parseString(json['f350_id_clase_docto']),
      indEstado: _parseInt(json['f350_ind_estado']),
      indTransmit: _parseInt(json['f350_ind_transmit']),
      fechaTsCreacion: _parseString(json['f350_fecha_ts_creacion']),
      fechaTsActualizacion: _parseString(json['f350_fecha_ts_actualizacion']),
      fechaTsAprobacion: _parseString(json['f350_fecha_ts_aprobacion']),
      fechaTsAnulacion: _parseString(json['f350_fecha_ts_anulacion']),
      usuarioCreacion: _parseString(json['f350_usuario_creacion']),
      usuarioActualizacion: _parseString(json['f350_usuario_actualizacion']),
      usuarioAprobacion: _parseString(json['f350_usuario_aprobacion']),
      usuarioAnulacion: _parseString(json['f350_usuario_anulacion']),
      totalBaseGravable: _parseDouble(json['f350_total_base_gravable']),
      indImpresion: _parseInt(json['f350_ind_impresion']),
      nroImpresiones: _parseInt(json['f350_nro_impresiones']),
      fechaTsHabilitaImp: _parseString(json['f350_fecha_ts_habilita_imp']),
      usuarioHabilitaImp: _parseString(json['f350_usuario_habilita_imp']),
      notas: _parseString(json['f350_notas']),
      rowidDoctoBase: _parseInt(json['f350_rowid_docto_base']),
      referencia: _parseString(json['f350_referencia']),
      idMandato: _parseString(json['f350_id_mandato']),
      rowidMovtoEntidad: _parseInt(json['f350_rowid_movto_entidad']),
      idMotivoOtros: _parseString(json['f350_id_motivo_otros']),
      idMonedaDocto: _parseString(json['f350_id_moneda_docto']),
      idMonedaConv: _parseString(json['f350_id_moneda_conv']),
      indFormaConv: _parseInt(json['f350_ind_forma_conv']),
      tasaConv: _parseDouble(json['f350_tasa_conv']),
      idMonedaLocal: _parseString(json['f350_id_moneda_local']),
      indFormaLocal: _parseInt(json['f350_ind_forma_local']),
      tasaLocal: _parseDouble(json['f350_tasa_local']),
      idTipoCambio: _parseString(json['f350_id_tipo_cambio']),
      indCfd: _parseInt(json['f350_ind_cfd']),
      usuarioImpresion: _parseString(json['f350_usuario_impresion']),
      fechaTsImpresion: _parseString(json['f350_fecha_ts_impresion']),
      rowidTePlantilla: _parseInt(json['f350_rowid_te_plantilla']),
      totalDb2: _parseDouble(json['f350_total_db2']),
      totalCr2: _parseDouble(json['f350_total_cr2']),
      totalDb3: _parseDouble(json['f350_total_db3']),
      totalCr3: _parseDouble(json['f350_total_cr3']),
      indImptoAsumido: _parseInt(json['f350_ind_impto_asumido']),
      rowidSesion: _parseInt(json['f350_rowid_sesion']),
      indTipoOrigen: _parseInt(json['f350_ind_tipo_origen']),
      rowidDoctoRp: _parseInt(json['f350_rowid_docto_rp']),
      idProyecto: _parseString(json['f350_id_proyecto']),
      indDifCambioForma: _parseInt(json['f350_ind_dif_cambio_forma']),
      indClaseOrigen: _parseInt(json['f350_ind_clase_origen']),
      indEnvioCorreo: _parseInt(json['f350_ind_envio_correo']),
      usuarioEnvioCorreo: _parseString(json['f350_usuario_envio_correo']),
      fechaTsEnvioCorreo: _parseString(json['f350_fecha_ts_envio_correo']),
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'sucursal': sucursal,
      'tipo': tipo,
      'factura': factura,
      'fecha': fecha,
      'vence': vence,
      'valor': valor,
      'abonos': abonos,
      'saldo': saldo,
    };
  }

  /// Convierte el modelo a entidad de dominio
  Factura toEntity() {
    return Factura(
      sucursal: sucursal,
      tipo: tipo,
      factura: factura,
      fecha: fecha,
      vence: vence,
      valor: valor,
      abonos: abonos,
      saldo: saldo,
      valRecibo: valRecibo,
      ok: ok,
      idCia: idCia,
      rowid: rowid,
      idCo: idCo,
      idTipoDocto: idTipoDocto,
      consecDocto: consecDocto,
      prefijo: prefijo,
      idPeriodo: idPeriodo,
      rowidTercero: rowidTercero,
      idSucursal: idSucursal,
      totalDb: totalDb,
      totalCr: totalCr,
      idClaseDocto: idClaseDocto,
      indEstado: indEstado,
      indTransmit: indTransmit,
      fechaTsCreacion: fechaTsCreacion,
      fechaTsActualizacion: fechaTsActualizacion,
      fechaTsAprobacion: fechaTsAprobacion,
      fechaTsAnulacion: fechaTsAnulacion,
      usuarioCreacion: usuarioCreacion,
      usuarioActualizacion: usuarioActualizacion,
      usuarioAprobacion: usuarioAprobacion,
      usuarioAnulacion: usuarioAnulacion,
      totalBaseGravable: totalBaseGravable,
      indImpresion: indImpresion,
      nroImpresiones: nroImpresiones,
      fechaTsHabilitaImp: fechaTsHabilitaImp,
      usuarioHabilitaImp: usuarioHabilitaImp,
      notas: notas,
      rowidDoctoBase: rowidDoctoBase,
      referencia: referencia,
      idMandato: idMandato,
      rowidMovtoEntidad: rowidMovtoEntidad,
      idMotivoOtros: idMotivoOtros,
      idMonedaDocto: idMonedaDocto,
      idMonedaConv: idMonedaConv,
      indFormaConv: indFormaConv,
      tasaConv: tasaConv,
      idMonedaLocal: idMonedaLocal,
      indFormaLocal: indFormaLocal,
      tasaLocal: tasaLocal,
      idTipoCambio: idTipoCambio,
      indCfd: indCfd,
      usuarioImpresion: usuarioImpresion,
      fechaTsImpresion: fechaTsImpresion,
      rowidTePlantilla: rowidTePlantilla,
      totalDb2: totalDb2,
      totalCr2: totalCr2,
      totalDb3: totalDb3,
      totalCr3: totalCr3,
      indImptoAsumido: indImptoAsumido,
      rowidSesion: rowidSesion,
      indTipoOrigen: indTipoOrigen,
      rowidDoctoRp: rowidDoctoRp,
      idProyecto: idProyecto,
      indDifCambioForma: indDifCambioForma,
      indClaseOrigen: indClaseOrigen,
      indEnvioCorreo: indEnvioCorreo,
      usuarioEnvioCorreo: usuarioEnvioCorreo,
      fechaTsEnvioCorreo: fechaTsEnvioCorreo,
    );
  }
}

/// Modelo para la respuesta paginada de facturas
class PaginatedFacturasResponse {
  final List<FacturaModel> facturas;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedFacturasResponse({
    required this.facturas,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  /// Crea un PaginatedFacturasResponse desde un JSON
  factory PaginatedFacturasResponse.fromJson(
    Map<String, dynamic> json,
    int currentPage,
    int currentPageSize,
  ) {
    List<dynamic> facturasList = [];
    
    // Intentar obtener la lista de facturas de diferentes formas
    if (json['data'] is List) {
      facturasList = json['data'] as List<dynamic>;
    } else if (json['facturas'] is List) {
      facturasList = json['facturas'] as List<dynamic>;
    }
    
    final facturas = facturasList
        .map((json) => FacturaModel.fromJson(json as Map<String, dynamic>))
        .toList();

    // Obtener información de paginación del objeto pagination si existe
    final pagination = json['pagination'] as Map<String, dynamic>?;
    final total = pagination?['total'] as int? ?? 
                  json['total'] as int? ?? 
                  json['count'] as int? ?? 
                  facturas.length;
    
    // Obtener totalPages del objeto pagination
    final totalPages = pagination?['totalPages'] as int?;
    final hasMore = totalPages != null 
        ? (currentPage < totalPages)
        : (json['hasMore'] as bool? ??
           json['has_more'] as bool? ??
           (facturas.length >= currentPageSize));

    return PaginatedFacturasResponse(
      facturas: facturas,
      total: total,
      page: currentPage,
      pageSize: currentPageSize,
      hasMore: hasMore,
    );
  }
}

