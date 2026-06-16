part of '../../main.dart';

class DashboardPage extends StatelessWidget {

  const DashboardPage({

    super.key,

    required this.edition,

    required this.editions,

    required this.onEditionChanged,

  });



  final FestivalEdition edition;

  final List<FestivalEdition> editions;

  final ValueChanged<FestivalEdition> onEditionChanged;



  @override

  Widget build(BuildContext context) {

    final currentFuture = DatabaseGateway.fetchDashboardBundle(edition.id);

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Header(

          edition.name,

          '${edition.dateRange} - ${edition.status}',

          trailing: SizedBox(

            width: 260,

            child: DropdownButtonFormField<String>(

              initialValue: edition.id,

              decoration: const InputDecoration(

                labelText: 'Edicion',

                isDense: true,

              ),

              items: editions

                  .map(

                    (item) => DropdownMenuItem(

                      value: item.id,

                      child: Text(item.name),

                    ),

                  )

                  .toList(),

              onChanged: (id) {

                final selected = editions.firstWhere(

                  (item) => item.id == id,

                  orElse: () => edition,

                );

                onEditionChanged(selected);

              },

            ),

          ),

        ),

        const SizedBox(height: 20),

        FutureBuilder<DashboardBundle>(

          future: currentFuture,

          builder: (context, snapshot) {

            if (snapshot.connectionState != ConnectionState.done) {

              return const CardBox(

                title: 'Cargando dashboard',

                child: LinearProgressIndicator(),

              );

            }

            if (snapshot.hasError) {

              return AlertBanner(

                friendlyError(snapshot.error),

                red,

                onClose: () {},

              );

            }

            final data = snapshot.data!;

            return Column(

              children: [

                ResponsiveGrid(

                  minWidth: 210,

                  aspectRatio: 1.35,

                  children: [

                    StatCard(

                      'Peliculas',

                      data.dashboard.peliculas.toString(),

                      '${data.dashboard.proyecciones} proyecciones',

                      Icons.movie_outlined,

                      burgundy,

                    ),

                    StatCard(

                      'Asistentes',

                      data.dashboard.asistentes.toString(),

                      'registrados en la edicion',

                      Icons.groups_outlined,

                      slate,

                    ),

                    StatCard(

                      'Entradas vendidas',

                      data.dashboard.entradasVendidas.toString(),

                      '${data.dashboard.abonosVendidos} abonos vendidos',

                      Icons.confirmation_number_outlined,

                      green,

                    ),

                    StatCard(

                      'Recaudacion',

                      'Bs ${data.dashboard.totalRecaudado.toStringAsFixed(2)}',

                      'entradas individuales + abonos',

                      Icons.payments_outlined,

                      slate,

                    ),

                  ],

                ),

                const SizedBox(height: 18),

                LayoutBuilder(

                  builder: (context, c) {

                    final narrow = c.maxWidth < 760;

                    final mostViewed = CardBox(

                      title: 'Peliculas mas vistas',

                      subtitle: 'Calculado por asistencia/capacidad',

                      child: Column(

                        children: data.ranking.take(5).map((item) {

                          return ProgressRow(

                            '${item.titulo} - ${item.asistentesReales}/${item.capacidadTotal}',

                            item.porcentajeOcupacion.round(),

                            item.porcentajeOcupacion >= 85

                                ? burgundy

                                : item.porcentajeOcupacion >= 70

                                ? slate

                                : green,

                          );

                        }).toList(),

                      ),

                    );

                    final topSold = CardBox(

                      title: 'Mas vendidas',

                      subtitle: 'Entradas individuales vendidas',

                      child: Column(

                        children: data.topSold.take(5).map((item) {

                          final percent = data.maxSold == 0

                              ? 0

                              : ((item.sales / data.maxSold) * 100).round();

                          return ProgressRow(

                            '${item.title} - ${item.sales}',

                            percent,

                            percent >= 80 ? burgundy : green,

                          );

                        }).toList(),

                      ),

                    );

                    if (narrow) {

                      return Column(

                        children: [

                          mostViewed,

                          const SizedBox(height: 16),

                          topSold,

                        ],

                      );

                    }

                    return Flex(

                      direction: Axis.horizontal,

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Expanded(flex: 2, child: mostViewed),

                        const SizedBox(width: 16),

                        Expanded(flex: 1, child: topSold),

                      ],

                    );

                  },

                ),

                const SizedBox(height: 18),

                ResponsiveGrid(

                  minWidth: 330,

                  aspectRatio: 1.45,

                  children: [

                    CardBox(

                      title: 'Proximas proyecciones',

                      child: Column(

                        children: data.projections.take(4).map((item) {

                          return ProgressRow(

                            '${item.title} - ${item.room} - ${item.when}',

                            65,

                            roomColor(item.room),

                            compact: true,

                          );

                        }).toList(),

                      ),

                    ),

                    CardBox(

                      title: 'Resumen financiero',

                      child: Column(

                        children: data.finance.take(4).map((item) {

                          return ProgressRow(

                            '${item.tipoVenta} / ${item.tipoTarifa}: Bs ${item.totalRecaudado.toStringAsFixed(2)}',

                            data.financeTotal == 0

                                ? 0

                                : ((item.totalRecaudado / data.financeTotal) * 100)

                                      .round(),

                            item.totalRecaudado == 0 ? slate : green,

                            compact: true,

                          );

                        }).toList(),

                      ),

                    ),

                  ],

                ),

              ],

            );

          },

        ),

      ],

    );

  }

}

