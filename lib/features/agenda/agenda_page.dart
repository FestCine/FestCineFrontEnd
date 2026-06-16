part of '../../main.dart';

class AgendaPage extends StatefulWidget {

  const AgendaPage({

    super.key,

    required this.initialSchedule,

    required this.movieOptions,

    required this.roomOptions,

    required this.movies,

    required this.roomCatalog,

    required this.dayOptions,

  });



  final List<ScreeningPlan> initialSchedule;

  final List<String> movieOptions;

  final List<String> roomOptions;

  final List<Movie> movies;

  final List<RoomOption> roomCatalog;

  final List<String> dayOptions;



  @override

  State<AgendaPage> createState() => _AgendaPageState();

}



class _AgendaPageState extends State<AgendaPage> {

  late List<ScreeningPlan> schedule;

  late List<String> movieOptions;

  late List<String> roomOptions;

  late List<String> dayOptions;

  late String movie;

  late String room;

  late String day;

  TimeOfDay time = const TimeOfDay(hour: 19, minute: 30);

  bool qa = false;

  String? message;

  bool conflict = false;

  bool scheduling = false;



  @override

  void initState() {

    super.initState();

    _syncOptionsFromWidget();

  }



  @override

  void didUpdateWidget(covariant AgendaPage oldWidget) {

    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialSchedule != widget.initialSchedule ||

        oldWidget.movieOptions != widget.movieOptions ||

        oldWidget.roomOptions != widget.roomOptions ||

        oldWidget.movies != widget.movies ||

        oldWidget.roomCatalog != widget.roomCatalog ||

        oldWidget.dayOptions != widget.dayOptions) {

      _syncOptionsFromWidget();

    }

  }



  @override

  Widget build(BuildContext context) {

    final dayItems = schedule.where((s) => s.day == day).toList()

      ..sort((a, b) => a.time.compareTo(b.time));

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Header(

          'Control de Agenda',

          'Programacion de salas con validacion de conflictos',

        ),

        const SizedBox(height: 16),

        if (message != null)

          AlertBanner(

            message!,

            conflict ? red : green,

            onClose: () => setState(() => message = null),

          ),

        const SizedBox(height: 12),

        LayoutBuilder(

          builder: (context, c) {

            final narrow = c.maxWidth < 860;

            if (narrow) {

              return Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  _form(),

                  const SizedBox(height: 16),

                  _timeline(dayItems),

                ],

              );

            }

            return Flex(

              direction: Axis.horizontal,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Expanded(flex: 1, child: _form()),

                const SizedBox(width: 16),

                Expanded(flex: 2, child: _timeline(dayItems)),

              ],

            );

          },

        ),

      ],

    );

  }



  Widget _form() => CardBox(

    title: 'Nueva funcion',

    subtitle: 'Incluye 30 minutos de limpieza entre funciones',

    child: Column(

      children: [

        SelectLine(

          'Pelicula',

          movie,

          movieOptions,

          (v) => setState(() => movie = v),

        ),

        SelectLine('Sala', room, roomOptions, (v) => setState(() => room = v)),

        SelectLine('Dia', day, dayOptions, (v) => setState(() => day = v)),

        const SizedBox(height: 4),

        ListTile(

          contentPadding: EdgeInsets.zero,

          title: const Text('Hora', style: TextStyle(color: muted)),

          subtitle: Text(

            time.format(context),

            style: const TextStyle(color: text, fontSize: 18),

          ),

          trailing: IconButton(

            icon: const Icon(Icons.schedule, color: gold),

            onPressed: () async {

              final picked = await showTimePicker(

                context: context,

                initialTime: time,

              );

              if (picked != null) setState(() => time = picked);

            },

          ),

        ),

        SwitchListTile(

          contentPadding: EdgeInsets.zero,

          value: qa,

          onChanged: (v) => setState(() => qa = v),

          title: const Text('Q&A con equipo invitado'),

        ),

        const SizedBox(height: 10),

        FilledButton.icon(

          onPressed: scheduling ? null : _addScreening,

          icon: scheduling

              ? const SizedBox(

                  width: 18,

                  height: 18,

                  child: CircularProgressIndicator(strokeWidth: 2),

                )

              : const Icon(Icons.add),

          label: Text(

            scheduling ? 'Programando funcion...' : 'Programar funcion',

          ),

        ),

        const SizedBox(height: 10),

        const Text(

          'Al programar se valida la disponibilidad de la sala y se guarda la funcion.',

          style: TextStyle(color: muted, fontSize: 12),

        ),

      ],

    ),

  );



  Widget _timeline(List<ScreeningPlan> items) => CardBox(

    title: 'Agenda del dia',

    subtitle: '$day - ${items.length} funciones programadas',

    child: Column(

      children: [

        Wrap(

          spacing: 8,

          runSpacing: 8,

          children: dayOptions

              .map(

                (d) => ChoiceChip(

                  label: Text(d.substring(5)),

                  selected: d == day,

                  onSelected: (_) => setState(() => day = d),

                ),

              )

              .toList(),

        ),

        const SizedBox(height: 16),

        if (items.isEmpty)

          const EmptyState(

            icon: Icons.event_busy_outlined,

            text: 'No hay funciones programadas para este dia.',

          )

        else

          ...items.map(_timelineItem),

      ],

    ),

  );



  Widget _timelineItem(ScreeningPlan s) {

    final color = roomColor(s.room);

    return Container(

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color: surface,

        borderRadius: BorderRadius.circular(radiusMd),

        border: Border.all(color: color, width: 1.1),

      ),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(

            width: 64,

            padding: const EdgeInsets.symmetric(vertical: 7),

            alignment: Alignment.center,

            decoration: BoxDecoration(

              color: cardFillFor(color),

              borderRadius: BorderRadius.circular(radiusSm),

              border: Border.all(color: color),

            ),

            child: Text(

              s.time,

              style: TextStyle(color: color, fontWeight: FontWeight.w900),

            ),

          ),

          const SizedBox(width: 12),

          Expanded(

            child: ProgressRow(

              '${s.movie} - ${s.room}${s.qa ? " - Q&A" : ""}',

              (s.duration / 150 * 100).round(),

              color,

            ),

          ),

        ],

      ),

    );

  }



  Future<void> _addScreening() async {

    final duration = movieDuration[movie] ?? 100;

    final hh = time.hour.toString().padLeft(2, '0');

    final mm = time.minute.toString().padLeft(2, '0');

    final projection = ScreeningPlan(

      movie,

      room,

      day,

      '$hh:$mm',

      duration,

      qa,

      idProyeccion: nextProjectionId(schedule),

      idSala: idSalaForRoom(room, schedule, widget.roomCatalog),

      idPeliculaEdicion: idPeliculaEdicionForMovie(

        movie,

        schedule,

        widget.movies,

      ),

    );



    setState(() {

      scheduling = true;

      message = null;

    });



    try {

      await DatabaseGateway.insertProjection(

        projection: projection,

        existing: schedule,

      );

      if (!mounted) return;

      setState(() {

        scheduling = false;

        conflict = false;

        schedule.add(projection);

        message = null;

      });

    } on DatabaseException catch (error) {

      if (!mounted) return;

      setState(() {

        scheduling = false;

        conflict = true;

        message = error.friendlyMessage;

      });

    }

  }



  void _syncOptionsFromWidget() {

    schedule = [...widget.initialSchedule];

    final catalogMovieTitles = widget.movies

        .map((item) => item.title)

        .where((title) => title.trim().isNotEmpty)

        .toSet()

        .toList()

      ..sort();

    final catalogRoomNames = widget.roomCatalog

        .map((item) => item.name)

        .where((name) => name.trim().isNotEmpty)

        .toSet()

        .toList()

      ..sort();

    movieOptions = catalogMovieTitles.isNotEmpty

        ? catalogMovieTitles

        : (widget.movieOptions.isEmpty ? [...movieTitles] : widget.movieOptions);

    roomOptions = catalogRoomNames.isNotEmpty

        ? catalogRoomNames

        : (widget.roomOptions.isEmpty ? [...rooms] : widget.roomOptions);

    dayOptions = widget.dayOptions.isEmpty ? [...festivalDays] : widget.dayOptions;

    movie = movieOptions.contains('La Ultima Luz')

        ? 'La Ultima Luz'

        : movieOptions.first;

    room = roomOptions.first;

    day = dayOptions.first;

  }

}

