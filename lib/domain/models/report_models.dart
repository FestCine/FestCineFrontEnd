part of '../../main.dart';

class PurchaseReceipt {

  const PurchaseReceipt({

    required this.idCompra,

    required this.idEntrada,

    required this.idFactura,

    required this.codigoEntrada,

    required this.montoPagado,

    required this.metodoPago,

  });



  final String idCompra;

  final String idEntrada;

  final String idFactura;

  final String codigoEntrada;

  final double montoPagado;

  final String metodoPago;

}



class DashboardMetrics {

  const DashboardMetrics({

    required this.peliculas,

    required this.proyecciones,

    required this.asistentes,

    required this.entradasVendidas,

    required this.abonosVendidos,

    required this.totalRecaudado,

  });



  final int peliculas;

  final int proyecciones;

  final int asistentes;

  final int entradasVendidas;

  final int abonosVendidos;

  final double totalRecaudado;

}



class RankingItem {

  const RankingItem({

    required this.idPelicula,

    required this.titulo,

    required this.cantidadProyecciones,

    required this.capacidadTotal,

    required this.asistentesReales,

    required this.porcentajeOcupacion,

  });



  final String idPelicula;

  final String titulo;

  final int cantidadProyecciones;

  final int capacidadTotal;

  final int asistentesReales;

  final double porcentajeOcupacion;

}



class AwardItem {

  const AwardItem({

    required this.nombreCategoria,

    required this.nombrePremio,

    required this.titulo,

    required this.cantidadEvaluaciones,

    required this.promedioVotacion,

  });



  final String nombreCategoria;

  final String nombrePremio;

  final String titulo;

  final int cantidadEvaluaciones;

  final double promedioVotacion;

}



class FinanceItem {

  const FinanceItem({

    required this.tipoVenta,

    required this.subtipoVenta,

    required this.tipoTarifa,

    required this.cantidadVentas,

    required this.totalRecaudado,

  });



  final String tipoVenta;

  final String subtipoVenta;

  final String tipoTarifa;

  final int cantidadVentas;

  final double totalRecaudado;

}



class SoldMovie {

  const SoldMovie(this.title, this.sales);



  final String title;

  final int sales;

}



class ProjectionSummary {

  const ProjectionSummary(this.title, this.room, this.when);



  final String title;

  final String room;

  final String when;

}



class ReportBundle {

  const ReportBundle({

    required this.dashboard,

    required this.ranking,

    required this.awards,

    required this.finance,

  });



  final DashboardMetrics dashboard;

  final List<RankingItem> ranking;

  final List<AwardItem> awards;

  final List<FinanceItem> finance;

}



class DashboardBundle extends ReportBundle {

  const DashboardBundle({

    required super.dashboard,

    required super.ranking,

    required super.awards,

    required super.finance,

    required this.topSold,

    required this.projections,

  });



  final List<SoldMovie> topSold;

  final List<ProjectionSummary> projections;



  int get maxSold => topSold.fold<int>(

        0,

        (max, item) => item.sales > max ? item.sales : max,

      );



  double get financeTotal => finance.fold<double>(

        0,

        (sum, item) => sum + item.totalRecaudado,

      );

}

