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

      final salesByType = _groupFinance(
        items,
        _saleTypeLabel,
        preferredOrder: const ['Entrada Individual', 'Abono'],
      );
      final tariffsByType = _groupFinance(
        items.where((item) => _tariffLabel(item).isNotEmpty),
        _tariffLabel,
        preferredOrder: const [
          'General',
          'Estudiante',
          'Jubilado',
          'Acreditado',
          'VIP',
        ],
      );
      final detailsBySubtype = _groupFinance(
        items,
        (item) {
          final subtype = item.subtipoVenta.trim().isEmpty
              ? 'Sin subtipo'
              : item.subtipoVenta.trim();
          return '${_saleTypeLabel(item)} / $subtype';
        },
      );

      final salesCard = CardBox(

        title: 'Por tipo de venta',

        subtitle: 'Entradas individuales vs. abonos',

        accent: slate,

        child: Column(

          children: salesByType.map((item) {

            final percent = _financePercent(item.totalRecaudado, total);

            return ProgressRow(

              '${item.label} - ${item.cantidadVentas} ventas - Bs ${item.totalRecaudado.toStringAsFixed(2)}',

              percent,

              item.totalRecaudado == 0

                  ? slate

                  : normalizeText(item.label).contains('abono')

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

          children: tariffsByType.map((f) {

            final percent = _financePercent(f.totalRecaudado, total);

            return Tooltip(

              message:

                  '${f.label}\nRecaudacion: Bs ${f.totalRecaudado.toStringAsFixed(2)}\nCantidad: ${f.cantidadVentas}',

              waitDuration: const Duration(milliseconds: 250),

              child: ProgressRow(

                '${f.label} - ${f.cantidadVentas} ventas - Bs ${f.totalRecaudado.toStringAsFixed(2)}',

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

            title: 'Detalle por subtipo de venta',

            subtitle:

                'Consulta: total recaudado separado por subtipo de venta',

            accent: slate,

            child: Column(

              children: detailsBySubtype

                  .take(10)

                  .map((s) => ProgressRow(

                        '${s.label} - ${s.cantidadVentas} ventas - Bs ${s.totalRecaudado.toStringAsFixed(2)}',

                        _financePercent(s.totalRecaudado, total),

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

  List<_FinanceGroup> _groupFinance(
    Iterable<FinanceItem> items,
    String Function(FinanceItem item) labelFor, {
    List<String> preferredOrder = const [],
  }) {
    final groups = <String, _FinanceGroup>{};
    for (final item in items) {
      final label = labelFor(item).trim();
      if (label.isEmpty) continue;
      final current = groups[label];
      groups[label] = _FinanceGroup(
        label,
        (current?.cantidadVentas ?? 0) + item.cantidadVentas,
        (current?.totalRecaudado ?? 0) + item.totalRecaudado,
      );
    }
    final ordered = groups.values.toList();
    ordered.sort((a, b) {
      final aIndex = preferredOrder.indexOf(a.label);
      final bIndex = preferredOrder.indexOf(b.label);
      if (aIndex != -1 || bIndex != -1) {
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;
        return aIndex.compareTo(bIndex);
      }
      return a.label.compareTo(b.label);
    });
    return ordered;
  }

  String _saleTypeLabel(FinanceItem item) {
    final normalized = normalizeText(item.tipoVenta);
    return normalized.contains('abono') ? 'Abono' : 'Entrada Individual';
  }

  String _tariffLabel(FinanceItem item) {
    final normalized = normalizeText(item.tipoTarifa);
    return switch (normalized) {
      'general' => 'General',
      'estudiante' => 'Estudiante',
      'jubilado' => 'Jubilado',
      'acreditado' => 'Acreditado',
      'vip' => 'VIP',
      _ => '',
    };
  }

  int _financePercent(double amount, double total) =>
      total == 0 ? 0 : ((amount / total) * 100).round();

}

class _FinanceGroup {
  const _FinanceGroup(this.label, this.cantidadVentas, this.totalRecaudado);

  final String label;
  final int cantidadVentas;
  final double totalRecaudado;
}

