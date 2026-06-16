part of '../../main.dart';

class ReportesPage extends StatefulWidget {

  const ReportesPage({super.key, required this.edition});



  final FestivalEdition edition;



  @override

  State<ReportesPage> createState() => _ReportesPageState();

}



class _ReportesPageState extends State<ReportesPage> {

  int tab = 0;



  @override

  Widget build(BuildContext context) {

    final reportFuture = DatabaseGateway.fetchReportBundle(widget.edition.id);

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Header(

          'Reportes Estadisticos',

          '${widget.edition.name} - ${widget.edition.dateRange}',

        ),

        const SizedBox(height: 16),

        FutureBuilder<ReportBundle>(

          future: reportFuture,

          builder: (context, snapshot) {

            if (snapshot.connectionState != ConnectionState.done) {

              return const CardBox(

                title: 'Cargando reportes',

                child: LinearProgressIndicator(),

              );

            }

            if (snapshot.hasError) {

              return AlertBanner(friendlyError(snapshot.error), red, onClose: () {});

            }

            final data = snapshot.data!;

            final best = data.ranking.isEmpty ? null : data.ranking.first;

            final avgOccupation = data.ranking.isEmpty

                ? 0

                : data.ranking

                        .map((item) => item.porcentajeOcupacion)

                        .reduce((a, b) => a + b) /

                    data.ranking.length;

            return Column(

              children: [

                ResponsiveGrid(

                  minWidth: 220,

                  aspectRatio: 1.35,

                  children: [

                    StatCard(

                      'Total Asistentes',

                      data.dashboard.asistentes.toString(),

                      'registrados',

                      Icons.trending_up,

                      burgundy,

                    ),

                    StatCard(

                      'Recaudacion Total',

                      'Bs ${data.dashboard.totalRecaudado.toStringAsFixed(2)}',

                      'taquilla y abonos',

                      Icons.payments_outlined,

                      green,

                    ),

                    StatCard(

                      'Pelicula mas vista',

                      best?.titulo ?? 'Sin datos',

                      best == null

                          ? 'sin asistencias registradas'

                          : '${best.asistentesReales} asistentes',

                      Icons.star_outline,

                      slate,

                    ),

                    StatCard(

                      'Promedio Ocupacion',

                      '${avgOccupation.toStringAsFixed(1)}%',

                      'segun ranking',

                      Icons.chair_outlined,

                      slate,

                    ),

                  ],

                ),

                const SizedBox(height: 16),

                SegmentedButton<int>(

                  segments: const [

                    ButtonSegment(

                      value: 0,

                      label: Text('Ranking'),

                      icon: Icon(Icons.movie_outlined),

                    ),

                    ButtonSegment(

                      value: 1,

                      label: Text('Premiacion'),

                      icon: Icon(Icons.emoji_events_outlined),

                    ),

                    ButtonSegment(

                      value: 2,

                      label: Text('Financiero'),

                      icon: Icon(Icons.bar_chart_outlined),

                    ),

                  ],

                  selected: {tab},

                  onSelectionChanged: (v) => setState(() => tab = v.first),

                ),

                const SizedBox(height: 16),

                if (tab == 0) _ranking(data.ranking),

                if (tab == 1) _awards(data.awards),

                if (tab == 2) _finance(data.finance),

              ],

            );

          },

        ),

      ],

    );

  }



  Widget _ranking(List<RankingItem> items) => CardBox(

    title: 'Ranking de peliculas por ocupacion',

    subtitle:

        'Consulta: peliculas mas vistas calculando asistentes reales contra capacidad de sala',

    child: Column(

      children: items

          .map(

            (r) => ProgressRow(

              '${r.titulo} - ${r.asistentesReales}/${r.capacidadTotal} asistentes',

              r.porcentajeOcupacion.round(),

              r.porcentajeOcupacion >= 85

                  ? gold

                  : r.porcentajeOcupacion >= 70

                  ? purple

                  : green,

            ),

          )

          .toList(),

    ),

  );



  Widget _awards(List<AwardItem> items) => ResponsiveGrid(

    minWidth: 280,

    aspectRatio: 1.25,

    children: items

        .map(

          (a) => CardBox(

            title: a.nombreCategoria,

            subtitle: '${a.nombrePremio} - ${a.cantidadEvaluaciones} evaluaciones',

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  a.titulo,

                  style: const TextStyle(

                    color: gold,

                    fontSize: 21,

                    fontWeight: FontWeight.w800,

                  ),

                ),

                const SizedBox(height: 8),

                Pill(

                  'Promedio jurado: ${a.promedioVotacion.toStringAsFixed(1)}',

                  color: green,

                ),

              ],

            ),

          ),

        )

        .toList(),

  );



  Widget _finance(List<FinanceItem> items) => LayoutBuilder(

    builder: (context, c) {

      final narrow = c.maxWidth < 760;

      final total = items.fold<double>(0, (sum, item) => sum + item.totalRecaudado);

      final salesCard = CardBox(

        title: 'Recaudacion por venta',

        subtitle: 'Entradas individuales y abonos desde la base',

        accent: slate,

        child: Column(

          children: items.take(8).map((item) {

            final percent = total == 0

                ? 0

                : ((item.totalRecaudado / total) * 100).round();

            return ProgressRow(

              '${item.tipoVenta} / ${item.subtipoVenta}',

              percent,

              item.totalRecaudado == 0

                  ? slate

                  : item.tipoVenta.toLowerCase().contains('abono')

                  ? purple

                  : gold,

              compact: true,

            );

          }).toList(),

        ),

      );

      final tariffCard = CardBox(

        title: 'Por tipo de tarifa',

        subtitle: 'Monto real agrupado por tarifa',

        accent: slate,

        child: Column(

          children: items.take(8).map((f) {

            final percent = total == 0

                ? 0

                : ((f.totalRecaudado / total) * 100).round();

            return Tooltip(

              message:

                  '${f.tipoTarifa}\nRecaudacion: Bs ${f.totalRecaudado.toStringAsFixed(2)}\nCantidad: ${f.cantidadVentas}',

              waitDuration: const Duration(milliseconds: 250),

              child: ProgressRow(

                '${f.tipoTarifa} - Bs ${f.totalRecaudado.toStringAsFixed(2)}',

                percent,

                f.totalRecaudado == 0 ? slate : green,

                compact: true,

              ),

            );

          }).toList(),

        ),

      );

      return Column(

        children: [

          if (narrow) ...[

            salesCard,

            const SizedBox(height: 16),

            tariffCard,

          ] else

          Flex(

            direction: Axis.horizontal,

            children: [

              Expanded(flex: 2, child: salesCard),

              const SizedBox(width: 16),

              Expanded(flex: 1, child: tariffCard),

            ],

          ),

          const SizedBox(height: 16),

          CardBox(

            title: 'Por tipo de venta',

            subtitle:

                'Consulta: total recaudado separado en entradas individuales y abonos',

            accent: slate,

            child: Column(

              children: items

                  .take(10)

                  .map((s) => ProgressRow(

                        '${s.tipoVenta} - ${s.cantidadVentas} ventas',

                        total == 0

                            ? 0

                            : ((s.totalRecaudado / total) * 100).round(),

                        s.totalRecaudado == 0 ? slate : gold,

                        compact: true,

                      ))

                  .toList(),

            ),

          ),

        ],

      );

    },

  );

}

