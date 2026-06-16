part of '../main.dart';

class Shell extends StatefulWidget {
  const Shell({super.key, required this.role, required this.onLogout});

  final UserRole role;
  final VoidCallback onLogout;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  Module active = Module.dashboard;
  final List<Movie> moviesCatalog = [...initialMovies];
  List<Attendee> attendees = fallbackAttendees;
  List<PersonOption> people = fallbackPeople;
  List<ScreeningPlan> scheduleCatalog = [...baseSchedule];
  List<String> agendaRooms = [...rooms];
  List<String> agendaMovieTitles = [...movieTitles];
  List<String> agendaDays = [...festivalDays];
  List<VenueOption> venues = fallbackVenues;
  List<MovieOption> movieOptions = fallbackMovieOptions;
  List<CategoryOption> categoryOptions = fallbackCategoryOptions;
  List<GenreOption> genreOptions = fallbackGenreOptions;
  List<DirectorOption> directorOptions = fallbackDirectorOptions;
  List<JuryMember> juryMembers = fallbackJuryMembers;
  List<SponsorOption> sponsors = fallbackSponsors;
  List<SubscriptionType> subscriptionTypes = fallbackSubscriptionTypes;
  List<AccreditationType> accreditationTypes = fallbackAccreditationTypes;
  List<FestivalEvent> eventsCatalog = [];
  List<RoomOption> roomOptions = fallbackRoomOptions;
  List<FestivalEdition> editions = fallbackEditions;
  FestivalEdition selectedEdition = fallbackEditions.first;
  String? apiMessage;
  bool apiMessageIsError = false;

  @override
  void initState() {
    super.initState();
    _loadApiCatalog();
  }

  @override
  Widget build(BuildContext context) {
    final nav = _navForRole(widget.role);
    if (!nav.any((item) => item.module == active)) {
      active = nav.first.module;
    }
    final wide = MediaQuery.sizeOf(context).width >= 880;
    final current = nav.firstWhere((item) => item.module == active);
    final page = switch (active) {
      Module.dashboard => DashboardPage(
        edition: selectedEdition,
        editions: editions,
        onEditionChanged: _selectEdition,
      ),
      Module.taquilla => TaquillaPage(
        movies: moviesCatalog,
        attendees: attendees,
        people: people,
        editionId: selectedEdition.id,
        subscriptionTypes: subscriptionTypes,
        accreditationTypes: accreditationTypes,
      ),
      Module.eventos => widget.role == UserRole.cashier
          ? EventTicketPage(
              attendees: attendees,
              people: people,
              events: eventsCatalog,
              edition: selectedEdition,
              onDataChanged: _loadApiCatalog,
            )
          : AdminEventsPage(
              events: eventsCatalog,
              rooms: roomOptions,
              editions: editions,
              selectedEdition: selectedEdition,
              onEditionChanged: _selectEdition,
              onAdd: _addEvent,
            ),
      Module.agenda => AgendaPage(
        initialSchedule: scheduleCatalog,
        movieOptions: agendaMovieTitles,
        roomOptions: agendaRooms,
        movies: moviesCatalog,
        roomCatalog: roomOptions,
        dayOptions: agendaDays,
      ),
      Module.reportes => ReportesPage(edition: selectedEdition),
      Module.peliculas => AdminMoviesPage(
        movies: moviesCatalog,
        editionId: selectedEdition.id,
        movieOptions: movieOptions,
        genres: genreOptions,
        directors: directorOptions,
        people: people,
        onAdd: _addMovie,
        onDelete: _deleteMovie,
        onRefresh: () => _selectEdition(selectedEdition),
      ),
      Module.ediciones => AdminEditionsPage(
        venues: venues,
        movies: movieOptions,
        categories: categoryOptions,
        jurors: juryMembers,
        sponsors: sponsors,
        onJurorAdd: _addJuror,
      ),
    };

    return Scaffold(
      drawer: wide
          ? null
          : Drawer(
              backgroundColor: sidebarBg,
              child: _Sidebar(nav, active, _go, widget.role, selectedEdition),
            ),
      body: Row(
        children: [
          if (wide)
            SizedBox(
              width: 268,
              child: _Sidebar(nav, active, _go, widget.role, selectedEdition),
            ),
          Expanded(
            child: Column(
              children: [
                Builder(
                  builder: (context) => _Topbar(
                    title: current.label,
                    subtitle: current.subtitle,
                    showMenu: !wide,
                    onMenu: () => Scaffold.of(context).openDrawer(),
                    role: widget.role,
                    onLogout: widget.onLogout,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (apiMessage != null) ...[
                              AlertBanner(
                                apiMessage!,
                                apiMessageIsError ? red : green,
                                onClose: () => setState(() => apiMessage = null),
                              ),
                              const SizedBox(height: 12),
                            ],
                            page,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _go(Module module) => setState(() => active = module);

  Future<void> _loadApiCatalog() async {
    try {
      final catalog = await DatabaseGateway.fetchCatalog();
      if (!mounted) return;
      setState(() {
        editions = catalog.editions.isEmpty ? fallbackEditions : catalog.editions;
        selectedEdition = editions.firstWhere(
          (edition) => edition.status == 'Actual',
          orElse: () => editions.first,
        );
        moviesCatalog
          ..clear()
          ..addAll(catalog.movies.isEmpty ? initialMovies : catalog.movies);
        attendees = catalog.attendees.isEmpty ? fallbackAttendees : catalog.attendees;
        people = catalog.people.isEmpty ? fallbackPeople : catalog.people;
        scheduleCatalog =
            catalog.schedule.isEmpty ? [...baseSchedule] : catalog.schedule;
        agendaRooms = catalog.rooms.isEmpty ? [...rooms] : catalog.rooms;
        agendaMovieTitles =
            catalog.movieTitles.isEmpty ? [...movieTitles] : catalog.movieTitles;
        agendaDays = catalog.days.isEmpty ? [...festivalDays] : catalog.days;
        venues = catalog.venues.isEmpty ? fallbackVenues : catalog.venues;
        movieOptions = catalog.movieOptions.isEmpty
            ? fallbackMovieOptions
            : catalog.movieOptions;
        categoryOptions = catalog.categoryOptions.isEmpty
            ? fallbackCategoryOptions
            : catalog.categoryOptions;
        genreOptions = catalog.genreOptions.isEmpty
            ? fallbackGenreOptions
            : catalog.genreOptions;
        directorOptions = catalog.directorOptions.isEmpty
            ? fallbackDirectorOptions
            : catalog.directorOptions;
        juryMembers = catalog.juryMembers.isEmpty
            ? fallbackJuryMembers
            : catalog.juryMembers;
        sponsors = catalog.sponsors.isEmpty ? fallbackSponsors : catalog.sponsors;
        subscriptionTypes = catalog.subscriptionTypes.isEmpty
            ? fallbackSubscriptionTypes
            : catalog.subscriptionTypes;
        accreditationTypes = catalog.accreditationTypes.isEmpty
            ? fallbackAccreditationTypes
            : catalog.accreditationTypes;
        eventsCatalog = catalog.events;
        roomOptions = catalog.roomOptions.isEmpty
            ? fallbackRoomOptions
            : catalog.roomOptions;
        apiMessage = null;
        apiMessageIsError = false;
      });
    } on DatabaseException catch (error) {
      if (!mounted) return;
      setState(() {
        apiMessage =
            'No se pudo cargar el backend. Modo local activo: ${error.friendlyMessage}';
        apiMessageIsError = true;
      });
    }
  }

  Future<void> _selectEdition(FestivalEdition edition) async {
    setState(() {
      selectedEdition = edition;
      apiMessage = null;
      apiMessageIsError = false;
    });
    try {
      final catalog = await DatabaseGateway.fetchCatalog(editionId: edition.id);
      if (!mounted) return;
      setState(() {
        moviesCatalog
          ..clear()
          ..addAll(catalog.movies.isEmpty ? initialMovies : catalog.movies);
        attendees = catalog.attendees.isEmpty ? fallbackAttendees : catalog.attendees;
        people = catalog.people.isEmpty ? fallbackPeople : catalog.people;
        scheduleCatalog =
            catalog.schedule.isEmpty ? [...baseSchedule] : catalog.schedule;
        agendaRooms = catalog.rooms.isEmpty ? [...rooms] : catalog.rooms;
        agendaMovieTitles =
            catalog.movieTitles.isEmpty ? [...movieTitles] : catalog.movieTitles;
        agendaDays = catalog.days.isEmpty ? [...festivalDays] : catalog.days;
        movieOptions = catalog.movieOptions.isEmpty
            ? fallbackMovieOptions
            : catalog.movieOptions;
        categoryOptions = catalog.categoryOptions.isEmpty
            ? fallbackCategoryOptions
            : catalog.categoryOptions;
        genreOptions = catalog.genreOptions.isEmpty
            ? fallbackGenreOptions
            : catalog.genreOptions;
        directorOptions = catalog.directorOptions.isEmpty
            ? fallbackDirectorOptions
            : catalog.directorOptions;
        juryMembers = catalog.juryMembers.isEmpty
            ? fallbackJuryMembers
            : catalog.juryMembers;
        sponsors = catalog.sponsors.isEmpty ? fallbackSponsors : catalog.sponsors;
        subscriptionTypes = catalog.subscriptionTypes.isEmpty
            ? fallbackSubscriptionTypes
            : catalog.subscriptionTypes;
        accreditationTypes = catalog.accreditationTypes.isEmpty
            ? fallbackAccreditationTypes
            : catalog.accreditationTypes;
        eventsCatalog = catalog.events;
        roomOptions = catalog.roomOptions.isEmpty
            ? fallbackRoomOptions
            : catalog.roomOptions;
        apiMessage = null;
      });
    } on DatabaseException catch (error) {
      if (!mounted) return;
      setState(() {
        apiMessage = error.friendlyMessage;
        apiMessageIsError = true;
      });
    }
  }

  List<_NavItem> _navForRole(UserRole role) {
    return [
      const _NavItem(
        Module.dashboard,
        'Dashboard',
        'Vista general',
        Icons.movie_filter_outlined,
      ),
      if (role == UserRole.cashier)
        const _NavItem(
          Module.taquilla,
          'Taquilla',
          'Venta de entradas',
          Icons.confirmation_number_outlined,
        ),
      if (role == UserRole.cashier)
        const _NavItem(
          Module.eventos,
          'Eventos',
          'Venta de eventos',
          Icons.event_available_outlined,
        ),
      if (role == UserRole.admin) ...const [
        _NavItem(
          Module.eventos,
          'Eventos',
          'Charlas y talleres',
          Icons.event_available_outlined,
        ),
        _NavItem(
          Module.agenda,
          'Control de Agenda',
          'Administrador',
          Icons.calendar_month_outlined,
        ),
        _NavItem(
          Module.reportes,
          'Reportes',
          'Estadisticas DQL',
          Icons.bar_chart_outlined,
        ),
        _NavItem(
          Module.peliculas,
          'Peliculas',
          'Cartelera y estrenos',
          Icons.video_library_outlined,
        ),
        _NavItem(
          Module.ediciones,
          'Ediciones',
          'Festival completo',
          Icons.festival_outlined,
        ),
      ],
    ];
  }

  void _addMovie(Movie movie) {
    setState(() {
      moviesCatalog.insert(0, movie);
      if (movie.idPelicula.isNotEmpty &&
          !movieOptions.any((item) => item.id == movie.idPelicula)) {
        movieOptions.insert(
          0,
          MovieOption(movie.idPelicula, movie.title, DateTime.now().year),
        );
      }
      if (!agendaMovieTitles.contains(movie.title)) {
        agendaMovieTitles.insert(0, movie.title);
      }
      active = Module.peliculas;
    });
  }

  void _deleteMovie(Movie movie) {
    setState(() {
      moviesCatalog.remove(movie);
    });
  }

  void _addJuror(JuryMember juror) {
    setState(() {
      if (!juryMembers.any((item) => item.id == juror.id)) {
        juryMembers.insert(0, juror);
      }
    });
  }

  void _addEvent(FestivalEvent event) {
    setState(() {
      eventsCatalog.insert(0, event);
      active = Module.eventos;
    });
  }
}

class _NavItem {
  const _NavItem(this.module, this.label, this.subtitle, this.icon);
  final Module module;
  final String label;
  final String subtitle;
  final IconData icon;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar(this.nav, this.active, this.onTap, this.role, this.edition);

  final List<_NavItem> nav;
  final Module active;
  final ValueChanged<Module> onTap;
  final UserRole role;
  final FestivalEdition edition;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: sidebarBg,
        border: Border(right: BorderSide(color: sidebarPanel)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const BadgeIcon(Icons.movie_filter, gold),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FestCine',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'FESTIVAL INTERNACIONAL',
                          style: TextStyle(
                            color: peach,
                            fontSize: 10,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Pill(
                    role == UserRole.cashier ? 'CAJA' : 'ADMIN',
                    color: gold,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Text(
                'MODULOS',
                style: TextStyle(
                  color: peach,
                  fontSize: 11,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            ...nav.map((item) {
              final selected = active == item.module;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 3,
                ),
                child: Material(
                  color: selected
                      ? gold
                      : sidebarPanel,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.maybePop(context);
                      onTap(item.module);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected ? gold : sidebarPanel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: selected ? peach : sidebarPanel,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          BadgeIcon(
                            item.icon,
                            selected ? Colors.white : onDark,
                            compact: true,
                            background: selected
                                ? Colors.white24
                                : sidebarBg.withValues(alpha: .72),
                            borderColor: selected ? Colors.white : line,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    color: selected ? Colors.white : onDark,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                    color: Color(0xffffc5ac),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            Padding(
              padding: EdgeInsets.all(20),
              child: InfoBox(
                title: 'Edicion seleccionada',
                body: edition.name,
                footer: '${edition.dateRange} - ${edition.status}',
                icon: Icons.circle,
                color: peach,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    child: Text(
                      'AD',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role == UserRole.cashier
                              ? 'Cajero FestCine'
                              : 'Admin FestCine',
                          style: const TextStyle(
                            color: onDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          role == UserRole.cashier
                              ? 'Taquilla'
                              : 'Agenda',
                          style: const TextStyle(color: peach, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.emoji_events_outlined,
                    color: gold,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Topbar extends StatefulWidget {
  const _Topbar({
    required this.title,
    required this.subtitle,
    required this.showMenu,
    required this.onMenu,
    required this.role,
    required this.onLogout,
  });

  final String title;
  final String subtitle;
  final bool showMenu;
  final VoidCallback onMenu;
  final UserRole role;
  final VoidCallback onLogout;

  @override
  State<_Topbar> createState() => _TopbarState();
}

class _TopbarState extends State<_Topbar> {
  late DateTime currentDateTime;
  Timer? clockTimer;

  @override
  void initState() {
    super.initState();
    currentDateTime = DateTime.now();
    clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() => currentDateTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: Color(0xffffefe6),
          border: Border(bottom: BorderSide(color: line)),
        ),
        child: Row(
          children: [
            if (widget.showMenu)
              IconButton(
                onPressed: widget.onMenu,
                icon: const Icon(Icons.menu, color: sidebarBg),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            StatusChip(
              widget.role == UserRole.cashier ? 'Perfil Cajero' : 'Perfil Admin',
              widget.role == UserRole.cashier ? sidebarBg : gold,
            ),
            const SizedBox(width: 10),
            StatusChip(formatCurrentDateTime(currentDateTime), slate),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Cerrar sesion',
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout, color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
