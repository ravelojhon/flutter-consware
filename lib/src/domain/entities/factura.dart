/// Entidad de dominio que representa una factura
class Factura {
  // Campos originales (mapeados desde los nuevos campos)
  final String sucursal;
  final String tipo;
  final String factura;
  final String fecha;
  final String vence;
  final double valor;
  final double abonos;
  final double saldo;
  double valRecibo;
  bool ok;

  // Nuevos campos de la API
  final int? idCia;
  final int? rowid;
  final String? idCo;
  final String? idTipoDocto;
  final String? consecDocto;
  final String? prefijo;
  final String? idPeriodo;
  final int? rowidTercero;
  final String? idSucursal;
  final double? totalDb;
  final double? totalCr;
  final String? idClaseDocto;
  final int? indEstado;
  final int? indTransmit;
  final String? fechaTsCreacion;
  final String? fechaTsActualizacion;
  final String? fechaTsAprobacion;
  final String? fechaTsAnulacion;
  final String? usuarioCreacion;
  final String? usuarioActualizacion;
  final String? usuarioAprobacion;
  final String? usuarioAnulacion;
  final double? totalBaseGravable;
  final int? indImpresion;
  final int? nroImpresiones;
  final String? fechaTsHabilitaImp;
  final String? usuarioHabilitaImp;
  final String? notas;
  final int? rowidDoctoBase;
  final String? referencia;
  final String? idMandato;
  final int? rowidMovtoEntidad;
  final String? idMotivoOtros;
  final String? idMonedaDocto;
  final String? idMonedaConv;
  final int? indFormaConv;
  final double? tasaConv;
  final String? idMonedaLocal;
  final int? indFormaLocal;
  final double? tasaLocal;
  final String? idTipoCambio;
  final int? indCfd;
  final String? usuarioImpresion;
  final String? fechaTsImpresion;
  final int? rowidTePlantilla;
  final double? totalDb2;
  final double? totalCr2;
  final double? totalDb3;
  final double? totalCr3;
  final int? indImptoAsumido;
  final int? rowidSesion;
  final int? indTipoOrigen;
  final int? rowidDoctoRp;
  final String? idProyecto;
  final int? indDifCambioForma;
  final int? indClaseOrigen;
  final int? indEnvioCorreo;
  final String? usuarioEnvioCorreo;
  final String? fechaTsEnvioCorreo;

  Factura({
    required this.sucursal,
    required this.tipo,
    required this.factura,
    required this.fecha,
    required this.vence,
    required this.valor,
    required this.abonos,
    required this.saldo,
    this.valRecibo = 0.0,
    this.ok = false,
    this.idCia,
    this.rowid,
    this.idCo,
    this.idTipoDocto,
    this.consecDocto,
    this.prefijo,
    this.idPeriodo,
    this.rowidTercero,
    this.idSucursal,
    this.totalDb,
    this.totalCr,
    this.idClaseDocto,
    this.indEstado,
    this.indTransmit,
    this.fechaTsCreacion,
    this.fechaTsActualizacion,
    this.fechaTsAprobacion,
    this.fechaTsAnulacion,
    this.usuarioCreacion,
    this.usuarioActualizacion,
    this.usuarioAprobacion,
    this.usuarioAnulacion,
    this.totalBaseGravable,
    this.indImpresion,
    this.nroImpresiones,
    this.fechaTsHabilitaImp,
    this.usuarioHabilitaImp,
    this.notas,
    this.rowidDoctoBase,
    this.referencia,
    this.idMandato,
    this.rowidMovtoEntidad,
    this.idMotivoOtros,
    this.idMonedaDocto,
    this.idMonedaConv,
    this.indFormaConv,
    this.tasaConv,
    this.idMonedaLocal,
    this.indFormaLocal,
    this.tasaLocal,
    this.idTipoCambio,
    this.indCfd,
    this.usuarioImpresion,
    this.fechaTsImpresion,
    this.rowidTePlantilla,
    this.totalDb2,
    this.totalCr2,
    this.totalDb3,
    this.totalCr3,
    this.indImptoAsumido,
    this.rowidSesion,
    this.indTipoOrigen,
    this.rowidDoctoRp,
    this.idProyecto,
    this.indDifCambioForma,
    this.indClaseOrigen,
    this.indEnvioCorreo,
    this.usuarioEnvioCorreo,
    this.fechaTsEnvioCorreo,
  });

  /// Convierte la factura a un Map para usar en el formulario
  Map<String, dynamic> toMap() {
    return {
      'sucursal': sucursal,
      'tipo': tipo,
      'factura': factura,
      'fecha': fecha,
      'vence': vence,
      'valor': valor,
      'abonos': abonos,
      'saldo': saldo,
      'valRecibo': valRecibo,
      'ok': ok,
      // Nuevos campos
      'idCia': idCia,
      'rowid': rowid,
      'idCo': idCo,
      'idTipoDocto': idTipoDocto,
      'consecDocto': consecDocto,
      'prefijo': prefijo,
      'idPeriodo': idPeriodo,
      'rowidTercero': rowidTercero,
      'idSucursal': idSucursal,
      'totalDb': totalDb,
      'totalCr': totalCr,
      'idClaseDocto': idClaseDocto,
      'indEstado': indEstado,
      'indTransmit': indTransmit,
      'fechaTsCreacion': fechaTsCreacion,
      'fechaTsActualizacion': fechaTsActualizacion,
      'fechaTsAprobacion': fechaTsAprobacion,
      'fechaTsAnulacion': fechaTsAnulacion,
      'usuarioCreacion': usuarioCreacion,
      'usuarioActualizacion': usuarioActualizacion,
      'usuarioAprobacion': usuarioAprobacion,
      'usuarioAnulacion': usuarioAnulacion,
      'totalBaseGravable': totalBaseGravable,
      'indImpresion': indImpresion,
      'nroImpresiones': nroImpresiones,
      'fechaTsHabilitaImp': fechaTsHabilitaImp,
      'usuarioHabilitaImp': usuarioHabilitaImp,
      'notas': notas,
      'rowidDoctoBase': rowidDoctoBase,
      'referencia': referencia,
      'idMandato': idMandato,
      'rowidMovtoEntidad': rowidMovtoEntidad,
      'idMotivoOtros': idMotivoOtros,
      'idMonedaDocto': idMonedaDocto,
      'idMonedaConv': idMonedaConv,
      'indFormaConv': indFormaConv,
      'tasaConv': tasaConv,
      'idMonedaLocal': idMonedaLocal,
      'indFormaLocal': indFormaLocal,
      'tasaLocal': tasaLocal,
      'idTipoCambio': idTipoCambio,
      'indCfd': indCfd,
      'usuarioImpresion': usuarioImpresion,
      'fechaTsImpresion': fechaTsImpresion,
      'rowidTePlantilla': rowidTePlantilla,
      'totalDb2': totalDb2,
      'totalCr2': totalCr2,
      'totalDb3': totalDb3,
      'totalCr3': totalCr3,
      'indImptoAsumido': indImptoAsumido,
      'rowidSesion': rowidSesion,
      'indTipoOrigen': indTipoOrigen,
      'rowidDoctoRp': rowidDoctoRp,
      'idProyecto': idProyecto,
      'indDifCambioForma': indDifCambioForma,
      'indClaseOrigen': indClaseOrigen,
      'indEnvioCorreo': indEnvioCorreo,
      'usuarioEnvioCorreo': usuarioEnvioCorreo,
      'fechaTsEnvioCorreo': fechaTsEnvioCorreo,
    };
  }
}

