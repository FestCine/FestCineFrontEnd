import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const FestCineApp());

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:5075',
);
const bg = Color(0xfff2efe7);
const surface = Color(0xfffbfaf4);
const surface2 = Color(0xffe9e5dc);
const freshSurface = Color(0xfff5f3ed);
const sidebarBg = Color(0xff050505);
const sidebarPanel = Color(0xff2f2d2b);
const peach = Color(0xffeee9dd);
const burgundy = Color(0xff7c1010);
const slate = Color(0xff6a6661);
const line = Color(0xffa29d95);
const gold = Color(0xff7c1010);
const green = Color(0xff2f2d2b);
const purple = Color(0xff7c1010);
const blue = Color(0xff6a6661);
const red = Color(0xff7c1010);
const text = Color(0xff22201f);
const muted = Color(0xff68645f);
const onDark = Color(0xfff2efe7);
const radiusSm = 8.0;
const radiusMd = 10.0;
const radiusLg = 14.0;

OutlineInputBorder appInputBorder(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(radiusMd),
    borderSide: BorderSide(color: color, width: width),
  );
}

class FestCineApp extends StatelessWidget {
  const FestCineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FestCine',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          brightness: Brightness.light,
          primary: gold,
          secondary: peach,
          tertiary: burgundy,
          surface: surface,
        ),
        fontFamily: 'Arial',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          labelStyle: const TextStyle(color: burgundy),
          floatingLabelStyle: const TextStyle(
            color: gold,
            fontWeight: FontWeight.w800,
          ),
          helperStyle: const TextStyle(color: muted),
          errorStyle: const TextStyle(color: red, fontWeight: FontWeight.w700),
          border: appInputBorder(line),
          enabledBorder: appInputBorder(line),
          focusedBorder: appInputBorder(gold, width: 1.7),
          errorBorder: appInputBorder(red, width: 1.4),
          focusedErrorBorder: appInputBorder(red, width: 1.8),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: gold,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            side: const BorderSide(color: gold, width: 1.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: freshSurface,
          selectedColor: surface2,
          disabledColor: freshSurface,
          checkmarkColor: gold,
          labelStyle: const TextStyle(color: text, fontWeight: FontWeight.w700),
          secondaryLabelStyle:
              const TextStyle(color: text, fontWeight: FontWeight.w700),
          side: const BorderSide(color: line, width: 1.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        checkboxTheme: CheckboxThemeData(
          side: const BorderSide(color: slate, width: 1.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        switchTheme: SwitchThemeData(
          trackOutlineColor: WidgetStateProperty.all(line),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            side: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return BorderSide(
                color: selected ? gold : line,
                width: selected ? 1.5 : 1,
              );
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? surface2
                  : surface;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected) ? gold : text;
            }),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusMd),
              ),
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.hovered)
                  ? surface2
                  : Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.all(sidebarBg),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusMd),
              ),
            ),
            side: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.hovered)
                  ? const BorderSide(color: line)
                  : BorderSide.none;
            }),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

enum Module { dashboard, taquilla, eventos, agenda, reportes, peliculas, ediciones }

enum UserRole { cashier, admin }

enum SaleMode { ticket, subscription }

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  UserRole? role;

  @override
  Widget build(BuildContext context) {
    final currentRole = role;
    if (currentRole == null) {
      return LoginPage(
        onLogin: (selectedRole) => setState(() => role = selectedRole),
      );
    }
    return Shell(
      role: currentRole,
      onLogout: () => setState(() => role = null),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLogin});

  final ValueChanged<UserRole> onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserRole selectedRole = UserRole.cashier;
  final email = TextEditingController(text: 'cajero@festcine.bo');
  final password = TextEditingController(text: 'demo123');

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sidebarBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: CardBox(
              title: 'INGRESO FESTCINE',
              subtitle: 'Login de FestCine',
              accent: gold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: BadgeIcon(Icons.movie_filter, gold)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(labelText: 'Correo'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contrasena'),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<UserRole>(
                    segments: const [
                      ButtonSegment(
                        value: UserRole.cashier,
                        label: Text('Cajero'),
                        icon: Icon(Icons.point_of_sale_outlined),
                      ),
                      ButtonSegment(
                        value: UserRole.admin,
                        label: Text('Admin'),
                        icon: Icon(Icons.admin_panel_settings_outlined),
                      ),
                    ],
                    selected: {selectedRole},
                    onSelectionChanged: (value) {
                      final role = value.first;
                      setState(() {
                        selectedRole = role;
                        email.text = role == UserRole.cashier
                            ? 'cajero@festcine.bo'
                            : 'admin@festcine.bo';
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => widget.onLogin(selectedRole),
                    icon: const Icon(Icons.login),
                    label: Text(
                      selectedRole == UserRole.cashier
                          ? 'Ingresar como Cajero'
                          : 'Ingresar como Administrador',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cajero: venta de entradas. Admin: agenda, ediciones y reportes del festival.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
        genres: genreOptions,
        directors: directorOptions,
        people: people,
        onAdd: _addMovie,
        onDelete: _deleteMovie,
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

class _Topbar extends StatelessWidget {
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
            if (showMenu)
              IconButton(
                onPressed: onMenu,
                icon: const Icon(Icons.menu, color: sidebarBg),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            StatusChip(
              role == UserRole.cashier ? 'Perfil Cajero' : 'Perfil Admin',
              role == UserRole.cashier ? sidebarBg : gold,
            ),
            const SizedBox(width: 10),
            const StatusChip('Vie 13 Jun - 20:14', slate),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Cerrar sesion',
              onPressed: onLogout,
              icon: const Icon(Icons.logout, color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

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

class TaquillaPage extends StatefulWidget {
  const TaquillaPage({
    super.key,
    required this.movies,
    required this.attendees,
    required this.people,
    required this.editionId,
    required this.subscriptionTypes,
    required this.accreditationTypes,
  });

  final List<Movie> movies;
  final List<Attendee> attendees;
  final List<PersonOption> people;
  final String editionId;
  final List<SubscriptionType> subscriptionTypes;
  final List<AccreditationType> accreditationTypes;

  @override
  State<TaquillaPage> createState() => _TaquillaPageState();
}

class _TaquillaPageState extends State<TaquillaPage> {
  int step = 1;
  Movie? movie;
  Session? session;
  Attendee? attendee;
  PersonOption? selectedPerson;
  final attendeeName = TextEditingController();
  final attendeeLastName = TextEditingController();
  final attendeeEmail = TextEditingController();
  final attendeePhone = TextEditingController();
  final nit = TextEditingController();
  final selectedSeats = <String>{};
  SaleMode saleMode = SaleMode.ticket;
  String rate = 'General';
  String paymentMethod = 'Efectivo';
  SubscriptionType? subscriptionType;
  List<OwnedPass> accreditedPasses = const [];
  String? selectedAccreditedPassId;
  bool loadingAccreditedPasses = false;
  ActiveAccreditation? activeAccreditation;
  String? selectedAccreditationTypeId;
  bool loadingAccreditation = false;
  String? message;
  bool purchaseError = false;
  bool purchasing = false;
  PurchaseReceipt? receipt;

  @override
  void initState() {
    super.initState();
    attendee = _preferredAttendee(widget.attendees);
    if (attendee != null) _fillAttendee(attendee!, notify: false);
    subscriptionType = _preferredSubscriptionType(widget.subscriptionTypes);
  }

  @override
  void dispose() {
    attendeeName.dispose();
    attendeeLastName.dispose();
    attendeeEmail.dispose();
    attendeePhone.dispose();
    nit.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TaquillaPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = attendee;
    if (selected == null ||
        !widget.attendees.any((item) => item.id == selected.id)) {
      attendee = _preferredAttendee(widget.attendees);
      if (attendee != null) _fillAttendee(attendee!, notify: false);
    }
    if (subscriptionType == null ||
        !widget.subscriptionTypes.any((item) => item.id == subscriptionType!.id)) {
      subscriptionType = _preferredSubscriptionType(widget.subscriptionTypes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Header(
          'Taquilla',
          saleMode == SaleMode.ticket
              ? 'Venta guiada de entradas para FestCine XII'
              : 'Venta de abonos por tipo de acceso',
          trailing: saleMode == SaleMode.ticket
              ? StepperPills(step)
              : const Pill('ABONOS', color: purple),
        ),
        const SizedBox(height: 18),
        if (message != null) ...[
          AlertBanner(
            message!,
            purchaseError ? red : green,
            onClose: () => setState(() => message = null),
          ),
          const SizedBox(height: 12),
        ],
        Center(child: _saleModeControl()),
        const SizedBox(height: 16),
        if (saleMode == SaleMode.ticket && step == 1) _movies(),
        if (saleMode == SaleMode.ticket && step == 2) _sessions(),
        if (saleMode == SaleMode.ticket && step == 3) _seats(),
        if (saleMode == SaleMode.ticket && step == 4) _confirmation(),
        if (saleMode == SaleMode.subscription && step != 4) _subscriptionSale(),
        if (saleMode == SaleMode.subscription && step == 4) _confirmation(),
      ],
    );
  }

  Widget _saleModeControl() => SegmentedButton<SaleMode>(
    segments: const [
      ButtonSegment(
        value: SaleMode.ticket,
        label: Text('Entrada'),
        icon: Icon(Icons.confirmation_number_outlined),
      ),
      ButtonSegment(
        value: SaleMode.subscription,
        label: Text('Abono'),
        icon: Icon(Icons.workspace_premium_outlined),
      ),
    ],
    selected: {saleMode},
    onSelectionChanged: purchasing
        ? null
        : (value) => setState(() {
              saleMode = value.first;
              step = 1;
              receipt = null;
              message = null;
              selectedSeats.clear();
            }),
  );

  Widget _centeredPanel(Widget child, {double maxWidth = 980}) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }

  Widget _subscriptionSale() {
    final availableTypes = widget.subscriptionTypes.isEmpty
        ? fallbackSubscriptionTypes
        : widget.subscriptionTypes;
    final current = availableTypes.any((item) => item.id == subscriptionType?.id)
        ? subscriptionType!
        : (_preferredSubscriptionType(availableTypes) ??
            fallbackSubscriptionTypes.first);
    return _centeredPanel(
      CardBox(
        title: 'Venta de abono',
        subtitle: 'Selecciona el tipo de abono y registra la persona',
        accent: purple,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: current.id,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Tipo de abono',
              border: OutlineInputBorder(),
            ),
            items: availableTypes
                .map(
                  (item) => DropdownMenuItem(
                    value: item.id,
                    child: Text(
                      '${item.name} - Bs ${item.price.toStringAsFixed(2)}',
                    ),
                  ),
                )
                .toList(),
            onChanged: purchasing
                ? null
                : (id) => setState(() {
                      subscriptionType = availableTypes.firstWhere(
                        (item) => item.id == id,
                        orElse: () => current,
                      );
                      if (subscriptionType?.price == 0 && rate == 'General') {
                        rate = 'VIP';
                      }
                    }),
          ),
          const SizedBox(height: 8),
          Text(
            current.description.isEmpty
                ? 'Abono disponible para la edicion seleccionada.'
                : current.description,
            style: const TextStyle(color: muted, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['General', 'Estudiante', 'Jubilado', 'Acreditado', 'VIP']
                .map(
              (r) {
                return ChoiceChip(
                  label: Text(r),
                  selected: rate == r,
                  selectedColor: purple.withValues(alpha: .2),
                  onSelected: purchasing ? null : (_) => setState(() => rate = r),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 14),
          _attendeeForm(),
          const SizedBox(height: 14),
          _paymentFields(),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: !_attendeeFormValid || purchasing
                ? null
                : _confirmSubscriptionPurchase,
            icon: purchasing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.workspace_premium_outlined),
            label: Text(purchasing ? 'Registrando abono...' : 'Confirmar abono'),
          ),
        ],
        ),
      ),
    );
  }

  Widget _movies() => ResponsiveGrid(
    minWidth: 300,
    aspectRatio: .66,
    children: widget.movies.map((m) {
      return MovieCard(
        movie: m,
        onTap: () => setState(() {
          movie = m;
          step = 2;
        }),
      );
    }).toList(),
  );

  Widget _sessions() => Column(
    children: [
      BackLine('Elegiste: ${movie!.title}', () => setState(() => step = 1)),
      const SizedBox(height: 12),
      ResponsiveGrid(
        minWidth: 260,
        aspectRatio: 1.2,
        children: movie!.sessions.map((s) {
          final capacity = s.capacity == 0 ? roomCapacity(s.room) : s.capacity;
          final pct = ((s.occupied.length / capacity) * 100).round();
          return ActionCard(
            icon: Icons.schedule,
            title: '${s.date} - ${s.time}',
            subtitle:
                '${s.room} - ${s.qa ? "Q&A incluido" : "Funcion regular"}',
            footer: '$pct% vendido',
            color: pct > 70 ? red : green,
            onTap: () {
              setState(() {
                session = s;
                selectedSeats.clear();
                selectedAccreditedPassId = null;
                accreditedPasses = const [];
                step = 3;
              });
              if (attendee != null) {
                _loadAttendeeAccreditation(attendee!);
                _loadAccreditedPasses(attendee!);
              }
            },
          );
        }).toList(),
      ),
    ],
  );

  Widget _seats() => _centeredPanel(
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BackLine(
          '${movie!.title} - ${session!.date} - ${session!.time}',
          () => setState(() => step = 2),
        ),
        const SizedBox(height: 12),
        CardBox(
          title: 'Seleccion de asientos',
          subtitle: 'Un boleto individual por operacion',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SeatMap(
                occupied: session!.occupied,
                selected: selectedSeats,
                onTap: (id) => setState(() {
                  if (selectedSeats.contains(id)) {
                    selectedSeats.remove(id);
                  } else if (!session!.occupied.contains(id)) {
                    selectedSeats.clear();
                    selectedSeats.add(id);
                  }
                }),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: ['General', 'Estudiante', 'Jubilado', 'Acreditado', 'VIP']
                    .map(
                  (r) {
                    return ChoiceChip(
                      label: Text(r),
                      selected: rate == r,
                      selectedColor: gold,
                      onSelected: (_) => _selectTicketRate(r),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 14),
              _attendeeForm(),
              const SizedBox(height: 14),
              _accreditationSelector(),
              const SizedBox(height: 14),
              _ownedPassSelector(),
              const SizedBox(height: 14),
              _paymentFields(),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed:
                    selectedSeats.isEmpty || !_attendeeFormValid || purchasing
                        ? null
                        : _confirmPurchase,
                icon: purchasing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  purchasing ? 'Reservando asiento...' : 'Confirmar entrada',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Al confirmar se reserva el asiento y se emite la factura.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );


  Widget _attendeeForm() {
    final suggestions = _attendeeSuggestions().take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 220,
              child: TextField(
                controller: attendeeName,
                onChanged: (_) => _markAttendeeDirty(),
                decoration: const InputDecoration(
                  labelText: 'Nombre persona',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                controller: attendeeLastName,
                onChanged: (_) => _markAttendeeDirty(),
                decoration: const InputDecoration(
                  labelText: 'Apellido persona',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: 260,
              child: TextField(
                controller: attendeeEmail,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _markAttendeeDirty(),
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: TextField(
                controller: attendeePhone,
                keyboardType: TextInputType.phone,
                onChanged: (_) => _markAttendeeDirty(),
                decoration: const InputDecoration(
                  labelText: 'Telefono',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            'Coincidencias encontradas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: text,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((item) {
              final detail = item.person.email.isEmpty
                  ? item.person.id
                  : '${item.person.id} - ${item.person.email}';
              return ActionChip(
                avatar: const Icon(Icons.person_search, size: 18),
                label: Text('Usar ${item.person.displayName} ($detail)'),
                onPressed: purchasing ? null : () => _fillPersonMatch(item),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          attendee == null
              ? selectedPerson == null
                  ? 'Si no existe, se registrara automaticamente antes de la compra.'
                  : 'Persona encontrada: ${selectedPerson!.displayName}. Se creara como asistente de esta edicion al confirmar.'
              : 'Coincidencia detectada: ${attendee!.displayName}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _paymentFields() => Wrap(
    alignment: WrapAlignment.center,
    spacing: 10,
    runSpacing: 10,
    children: [
      SizedBox(
        width: 220,
        child: DropdownButtonFormField<String>(
          initialValue: paymentMethod,
          decoration: const InputDecoration(
            labelText: 'Metodo de pago',
            border: OutlineInputBorder(),
          ),
          items: const ['Efectivo', 'Tarjeta', 'QR', 'Transferencia']
              .map(
                (method) => DropdownMenuItem(
                  value: method,
                  child: Text(method),
                ),
              )
              .toList(),
          onChanged: purchasing
              ? null
              : (value) => setState(() {
                    paymentMethod = value ?? 'Efectivo';
                  }),
        ),
      ),
      SizedBox(
        width: 220,
        child: TextField(
          controller: nit,
          decoration: const InputDecoration(
            labelText: 'NIT / CI factura',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    ],
  );

  Widget _accreditationSelector() {
    if (!_usesAccreditationRate) return const SizedBox.shrink();
    final types = widget.accreditationTypes.isEmpty
        ? fallbackAccreditationTypes
        : widget.accreditationTypes;
    AccreditationType? vipType;
    for (final item in types) {
      if (item.name == 'VIP') {
        vipType = item;
        break;
      }
    }
    final selectedId = selectedAccreditationTypeId ??
        activeAccreditation?.typeId ??
        (rate == 'VIP' ? vipType?.id : null) ??
        (types.isEmpty ? null : types.first.id);
    final orderedTypes = [...types]..sort((a, b) {
        if (a.id == activeAccreditation?.typeId) return -1;
        if (b.id == activeAccreditation?.typeId) return 1;
        if (rate == 'VIP' && a.name == 'VIP') return -1;
        if (rate == 'VIP' && b.name == 'VIP') return 1;
        return a.name.compareTo(b.name);
      });

    if (loadingAccreditation) {
      return const SizedBox(width: 320, child: LinearProgressIndicator());
    }

    return SizedBox(
      width: 460,
      child: DropdownButtonFormField<String>(
        initialValue: orderedTypes.any((item) => item.id == selectedId) ? selectedId : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Tipo de acreditacion',
          helperText: activeAccreditation == null
              ? 'Si no tiene acreditacion, se creara al confirmar la compra.'
              : 'Acreditacion actual: ${activeAccreditation!.typeName}',
          border: const OutlineInputBorder(),
        ),
        items: orderedTypes.map((item) {
          final current = item.id == activeAccreditation?.typeId;
          return DropdownMenuItem(
            value: item.id,
            child: Text(current ? '${item.name} - actual' : item.name),
          );
        }).toList(),
        onChanged: purchasing
            ? null
            : (value) => setState(() {
                  selectedAccreditationTypeId = value;
                  if (rate == 'VIP' &&
                      types.firstWhere(
                            (item) => item.id == value,
                            orElse: () => const AccreditationType('', ''),
                          ).name !=
                          'VIP') {
                    purchaseError = true;
                    message = 'La tarifa VIP requiere acreditacion VIP activa.';
                  } else {
                    message = null;
                  }
                }),
      ),
    );
  }

  Widget _ownedPassSelector() {
    if (attendee == null) {
      return const Text(
        'Si la persona tiene abonos, se mostraran cuando exista como asistente.',
        textAlign: TextAlign.center,
        style: TextStyle(color: muted, fontSize: 12),
      );
    }
    if (loadingAccreditedPasses) {
      return const SizedBox(width: 320, child: LinearProgressIndicator());
    }
    if (accreditedPasses.isEmpty) {
      return const Text(
        'No hay abonos activos disponibles para esta persona.',
        textAlign: TextAlign.center,
        style: TextStyle(color: muted, fontSize: 12),
      );
    }
    final selectedExists =
        accreditedPasses.any((item) => item.id == selectedAccreditedPassId);
    final selectedPass = selectedExists
        ? accreditedPasses.firstWhere((item) => item.id == selectedAccreditedPassId)
        : null;
    return SizedBox(
      width: 520,
      child: DropdownButtonFormField<String>(
        initialValue: selectedExists ? selectedAccreditedPassId : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Abono disponible',
          helperText: selectedPass != null && !selectedPass.allowed
              ? 'Este abono no es valido para esta proyeccion.'
              : 'Se valida contra AbonoProyeccion de la proyeccion seleccionada',
          helperStyle: TextStyle(
            color: selectedPass != null && !selectedPass.allowed ? red : muted,
          ),
          border: const OutlineInputBorder(),
        ),
        items: accreditedPasses.map((pass) {
          return DropdownMenuItem(
            value: pass.id,
            child: Text(
              '${pass.label} - ${pass.allowed ? "permitido" : "no permitido"}',
            ),
          );
        }).toList(),
        onChanged: purchasing
            ? null
            : (value) {
                final pass = accreditedPasses.firstWhere(
                  (item) => item.id == value,
                  orElse: () => const OwnedPass.empty(),
                );
                setState(() {
                  selectedAccreditedPassId = value;
                  if (pass.id.isNotEmpty && !pass.allowed) {
                    purchaseError = true;
                    message =
                        'El abono seleccionado no es valido para esta proyeccion.';
                  } else {
                    message = null;
                  }
                });
              },
      ),
    );
  }

  Widget _confirmation() {
    final price = switch (rate) {
      'Estudiante' => 8,
      'Jubilado' => 7,
      'Acreditado' => 0,
      'VIP' => 0,
      _ => 12,
    };
    final total = price * selectedSeats.length;
    final isSubscription = saleMode == SaleMode.subscription;
    final title = isSubscription
        ? subscriptionType?.name ?? 'Abono'
        : movie?.title ?? 'Entrada';
    final detail = isSubscription
        ? 'Abono para ${attendee?.displayName ?? "persona"}'
        : '${session!.date} - ${session!.time} - ${session!.room}';
    return _centeredPanel(
      CardBox(
        title: 'Venta confirmada',
        subtitle: 'Operacion registrada correctamente',
        accent: isSubscription ? purple : green,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: green, size: 54),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            detail,
            style: const TextStyle(color: muted),
          ),
          const SizedBox(height: 14),
          if (!isSubscription)
            Text(
              'Asientos: ${selectedSeats.join(", ")}',
              style: const TextStyle(color: text),
            ),
          Text(
            'Persona: ${attendee?.displayName ?? "No seleccionada"}',
            style: const TextStyle(color: text),
          ),
          Text(
            'Pago: ${receipt?.metodoPago ?? paymentMethod} - NIT/CI: ${nit.text.trim().isEmpty ? "S/N" : nit.text.trim()}',
            style: const TextStyle(color: text),
          ),
          if (!isSubscription && selectedAccreditedPassId != null)
            Text(
              'Abono validado: ${_selectedAccreditedPassLabel()}',
              style: const TextStyle(color: text),
            ),
          Text(
            isSubscription
                ? 'Tarifa: $rate - Total: Bs ${(receipt?.montoPagado ?? subscriptionType?.price ?? 0).toStringAsFixed(2)}'
                : 'Tarifa: $rate - Total: Bs ${(receipt?.montoPagado ?? total).toStringAsFixed(2)}',
            style: const TextStyle(
              color: gold,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (receipt != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenericQr(label: receipt!.codigoEntrada),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Codigo: ${receipt!.codigoEntrada}\nFactura: ${receipt!.idFactura}\nMetodo de pago: ${receipt!.metodoPago}',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          const Text(
            'Compra procesada correctamente y validada contra aforo disponible.',
            style: TextStyle(color: green, fontSize: 12),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              step = 1;
              movie = null;
              session = null;
              selectedSeats.clear();
              receipt = null;
              message = null;
            }),
            icon: const Icon(Icons.add),
            label: Text(isSubscription ? 'Nuevo abono' : 'Nueva venta'),
          ),
        ],
        ),
      ),
      maxWidth: 760,
    );
  }

  Future<void> _confirmPurchase() async {
    setState(() {
      purchasing = true;
      message = null;
    });

    try {
      final resolved = await DatabaseGateway.resolveAttendee(
        widget.editionId,
        AttendeeFormData(
          idPersona: selectedPerson?.id ?? attendee?.idPersona ?? '',
          firstName: attendeeName.text.trim(),
          lastName: attendeeLastName.text.trim(),
          email: attendeeEmail.text.trim(),
          phone: attendeePhone.text.trim(),
        ),
      );
      ActiveAccreditation? ensuredAccreditation;
      if (_usesAccreditationRate) {
        final types = widget.accreditationTypes.isEmpty
            ? fallbackAccreditationTypes
            : widget.accreditationTypes;
        final selectedType = types.firstWhere(
          (item) =>
              item.id ==
              (selectedAccreditationTypeId ?? activeAccreditation?.typeId),
          orElse: () => rate == 'VIP'
              ? types.firstWhere(
                  (item) => item.name == 'VIP',
                  orElse: () => types.isEmpty
                      ? const AccreditationType('', '')
                      : types.first,
                )
              : (types.isEmpty ? const AccreditationType('', '') : types.first),
        );
        if (selectedType.id.isEmpty) {
          throw const DatabaseException(
            'ACREDITACION_TIPO_REQUERIDO',
            'Selecciona un tipo de acreditacion para usar esta tarifa.',
          );
        }
        if (rate == 'VIP' && selectedType.name != 'VIP') {
          throw const DatabaseException(
            'ACREDITACION_VIP_REQUERIDA',
            'La tarifa VIP requiere acreditacion VIP activa.',
          );
        }
        ensuredAccreditation = await DatabaseGateway.ensureAccreditation(
          attendee: resolved.attendee,
          selectedType: selectedType,
        );
      }
      if (selectedAccreditedPassId != null) {
        final passes = await DatabaseGateway.fetchAttendeePasses(
          attendeeId: resolved.attendee.id,
          projectionId: session!.idProyeccion,
          subscriptionTypes: widget.subscriptionTypes,
        );
        final selectedPass = passes.firstWhere(
          (pass) => pass.id == selectedAccreditedPassId,
          orElse: () => const OwnedPass.empty(),
        );
        if (selectedPass.id.isNotEmpty && !selectedPass.allowed) {
          throw DatabaseException(
            'ABONO_NO_PERMITIDO',
            'El abono seleccionado no esta permitido para esta proyeccion segun AbonoProyeccion.',
          );
        }
      }
      final response = await DatabaseGateway.p1ComprarEntrada(
        movie: movie!,
        session: session!,
        attendee: resolved.attendee,
        tarifa: rate,
        metodoPago: paymentMethod,
        nit: nit.text.trim().isEmpty ? null : nit.text.trim(),
        seats: selectedSeats.toList(),
      );
      if (!mounted) return;
      setState(() {
        purchasing = false;
        purchaseError = false;
        attendee = resolved.attendee;
        activeAccreditation = ensuredAccreditation ?? activeAccreditation;
        if (!widget.attendees.any((item) => item.id == resolved.attendee.id)) {
          widget.attendees.add(resolved.attendee);
        }
        _fillAttendee(resolved.attendee, notify: false);
        try {
          session!.occupied.add(selectedSeats.single);
        } catch (_) {
          // Some fallback demo sessions are const; API-loaded sessions are mutable.
        }
        receipt = response;
        message = null;
        step = 4;
      });
    } on DatabaseException catch (error) {
      if (!mounted) return;
      setState(() {
        purchasing = false;
        purchaseError = true;
        message = error.friendlyMessage;
      });
    }
  }

  Future<void> _confirmSubscriptionPurchase() async {
    setState(() {
      purchasing = true;
      message = null;
    });

    try {
      final selectedSubscription =
          subscriptionType ?? _preferredSubscriptionType(widget.subscriptionTypes);
      if (selectedSubscription == null) {
        throw const DatabaseException(
          'API_TIPO_ABONO_NO_ENCONTRADO',
          'No hay tipos de abono disponibles para vender.',
        );
      }
      final resolved = await DatabaseGateway.resolveAttendee(
        widget.editionId,
        AttendeeFormData(
          idPersona: selectedPerson?.id ?? attendee?.idPersona ?? '',
          firstName: attendeeName.text.trim(),
          lastName: attendeeLastName.text.trim(),
          email: attendeeEmail.text.trim(),
          phone: attendeePhone.text.trim(),
        ),
      );
      final response = await DatabaseGateway.venderAbono(
        attendee: resolved.attendee,
        subscriptionType: selectedSubscription,
        tarifa: rate,
        metodoPago: paymentMethod,
        nit: nit.text.trim().isEmpty ? null : nit.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        purchasing = false;
        purchaseError = false;
        attendee = resolved.attendee;
        subscriptionType = selectedSubscription;
        if (!widget.attendees.any((item) => item.id == resolved.attendee.id)) {
          widget.attendees.add(resolved.attendee);
        }
        _fillAttendee(resolved.attendee, notify: false);
        receipt = response;
        message = null;
        step = 4;
      });
    } on DatabaseException catch (error) {
      if (!mounted) return;
      setState(() {
        purchasing = false;
        purchaseError = true;
        message = error.friendlyMessage;
      });
    }
  }

  bool get _attendeeFormValid =>
      attendeeName.text.trim().isNotEmpty &&
      attendeeLastName.text.trim().isNotEmpty;

  bool get _usesAccreditationRate => _isAccreditationRate(rate);

  bool _isAccreditationRate(String value) =>
      value == 'Acreditado' || value == 'VIP';

  void _selectTicketRate(String value) {
    setState(() {
      rate = value;
      selectedAccreditedPassId = null;
      accreditedPasses = const [];
    });
    if (attendee != null) {
      _loadAttendeeAccreditation(attendee!);
      _loadAccreditedPasses(attendee!);
    }
  }

  Future<void> _loadAccreditedPasses(Attendee item) async {
    if (session == null || item.id.isEmpty) return;
    setState(() => loadingAccreditedPasses = true);
    try {
      final passes = await DatabaseGateway.fetchAttendeePasses(
        attendeeId: item.id,
        projectionId: session!.idProyeccion,
        subscriptionTypes: widget.subscriptionTypes,
      );
      if (!mounted) return;
      setState(() {
        accreditedPasses = passes;
        selectedAccreditedPassId = passes.length == 1
            ? passes.first.id
            : (passes.any((pass) => pass.id == selectedAccreditedPassId)
                ? selectedAccreditedPassId
                : null);
        loadingAccreditedPasses = false;
      });
    } on DatabaseException catch (error) {
      if (!mounted) return;
      setState(() {
        loadingAccreditedPasses = false;
        purchaseError = true;
        message = error.friendlyMessage;
      });
    }
  }

  Future<void> _loadAttendeeAccreditation(Attendee item) async {
    if (item.id.isEmpty) return;
    setState(() => loadingAccreditation = true);
    try {
      final accreditation = await DatabaseGateway.fetchAttendeeAccreditation(
        attendeeId: item.id,
        types: widget.accreditationTypes.isEmpty
            ? fallbackAccreditationTypes
            : widget.accreditationTypes,
      );
      if (!mounted) return;
      setState(() {
        activeAccreditation = accreditation;
        selectedAccreditationTypeId ??= accreditation?.typeId;
        loadingAccreditation = false;
      });
    } on DatabaseException catch (error) {
      if (!mounted) return;
      setState(() {
        loadingAccreditation = false;
        purchaseError = true;
        message = error.friendlyMessage;
      });
    }
  }

  String _selectedAccreditedPassLabel() {
    final id = selectedAccreditedPassId;
    if (id == null) return 'No seleccionado';
    return accreditedPasses
        .firstWhere(
          (pass) => pass.id == id,
          orElse: () => OwnedPass(id, id, 'Abono', 'Activo', allowed: true),
        )
        .label;
  }

  void _markAttendeeDirty() {
    final suggestions = _attendeeSuggestions();
    final match = suggestions.isEmpty ? null : suggestions.first;
    setState(() {
      selectedPerson = match?.person;
      attendee = match?.attendee;
      selectedAccreditedPassId = null;
      accreditedPasses = const [];
      activeAccreditation = null;
      selectedAccreditationTypeId = null;
    });
    if (match?.attendee != null) {
      _loadAttendeeAccreditation(match!.attendee!);
      _loadAccreditedPasses(match.attendee!);
    }
  }

  List<PersonMatch> _attendeeSuggestions() {
    final fullName = normalizeText(
      '${attendeeName.text} ${attendeeLastName.text}',
    );
    final email = attendeeEmail.text.trim().toLowerCase();
    final phone = onlyDigits(attendeePhone.text);

    if (fullName.length < 3 && email.length < 3 && phone.length < 3) {
      return const [];
    }

    final sourcePeople = widget.people.isEmpty
        ? widget.attendees.map((item) => PersonOption.fromAttendee(item)).toList()
        : widget.people;
    final matches = sourcePeople
        .where((item) => _personMatchScore(item, fullName, email, phone) > 0)
        .map((person) => PersonMatch(person, _attendeeForPerson(person)))
        .toList()
      ..sort((a, b) {
        final score = _personMatchScore(b.person, fullName, email, phone)
            .compareTo(_personMatchScore(a.person, fullName, email, phone));
        if (score != 0) return score;
        return a.person.displayName.compareTo(b.person.displayName);
      });
    return matches;
  }

  int _personMatchScore(
    PersonOption item,
    String fullName,
    String email,
    String phone,
  ) {
    var score = 0;
    final candidateName = normalizeText(
      '${item.firstName} ${item.lastName} ${item.displayName}',
    );
    final candidateEmail = item.email.toLowerCase();
    final candidatePhone = onlyDigits(item.phone);

    if (fullName.length >= 3) {
      if (candidateName == fullName) score += 120;
      if (candidateName.contains(fullName) || fullName.contains(candidateName)) {
        score += 100;
      }
      if (fuzzyScore(candidateName, fullName) >= 0.72) score += 80;
    }
    if (email.isNotEmpty && candidateEmail == email) score += 60;
    if (phone.isNotEmpty && candidatePhone == phone) score += 50;
    return score;
  }

  Attendee? _attendeeForPerson(PersonOption person) {
    final personId = person.id;
    final email = person.email.toLowerCase();
    final phone = onlyDigits(person.phone);
    final fullName = normalizeText(person.displayName);
    for (final item in widget.attendees) {
      final samePersonId = personId.isNotEmpty && item.idPersona == personId;
      final sameEmail = email.isNotEmpty && item.email.toLowerCase() == email;
      final samePhone = phone.isNotEmpty && onlyDigits(item.phone) == phone;
      final sameName = fullName.isNotEmpty &&
          normalizeText('${item.firstName} ${item.lastName} ${item.name}') ==
              fullName;
      if (samePersonId || sameEmail || samePhone || sameName) return item;
    }
    return null;
  }

  void _fillPersonMatch(PersonMatch match) {
    attendeeName.text = match.person.firstName.isEmpty
        ? match.person.displayName
        : match.person.firstName;
    attendeeLastName.text = match.person.lastName;
    attendeeEmail.text = match.person.email;
    attendeePhone.text = match.person.phone;
    setState(() {
      selectedPerson = match.person;
      attendee = match.attendee;
      selectedAccreditedPassId = null;
      accreditedPasses = const [];
      activeAccreditation = null;
      selectedAccreditationTypeId = null;
    });
    if (match.attendee != null) {
      _loadAttendeeAccreditation(match.attendee!);
      _loadAccreditedPasses(match.attendee!);
    }
  }


  void _fillAttendee(Attendee item, {bool notify = true}) {
    attendeeName.text = item.firstName.isEmpty ? item.name : item.firstName;
    attendeeLastName.text = item.lastName;
    attendeeEmail.text = item.email;
    attendeePhone.text = item.phone;
    if (notify) {
      setState(() {
        selectedPerson = PersonOption.fromAttendee(item);
        attendee = item;
        selectedAccreditedPassId = null;
        accreditedPasses = const [];
        activeAccreditation = null;
        selectedAccreditationTypeId = null;
      });
      _loadAttendeeAccreditation(item);
      _loadAccreditedPasses(item);
    }
  }

  Attendee? _preferredAttendee(List<Attendee> items) {
    if (items.isEmpty) return null;
    return items.firstWhere(
      (item) => item.id == 'AS005',
      orElse: () => items.first,
    );
  }

  SubscriptionType? _preferredSubscriptionType(List<SubscriptionType> items) {
    if (items.isEmpty) return null;
    return items.firstWhere(
      (item) => item.name == 'Abono Fin de Semana',
      orElse: () => items.first,
    );
  }
}

class AdminMoviesPage extends StatefulWidget {
  const AdminMoviesPage({
    super.key,
    required this.movies,
    required this.editionId,
    required this.genres,
    required this.directors,
    required this.people,
    required this.onAdd,
    required this.onDelete,
  });

  final List<Movie> movies;
  final String editionId;
  final List<GenreOption> genres;
  final List<DirectorOption> directors;
  final List<PersonOption> people;
  final ValueChanged<Movie> onAdd;
  final ValueChanged<Movie> onDelete;

  @override
  State<AdminMoviesPage> createState() => _AdminMoviesPageState();
}

class _AdminMoviesPageState extends State<AdminMoviesPage> {
  final title = TextEditingController();
  final productionYear = TextEditingController(text: DateTime.now().year.toString());
  final duration = TextEditingController(text: '100');
  final rating = TextEditingController(text: '+13');
  final country = TextEditingController(text: 'Bolivia');
  final synopsis = TextEditingController();
  final poster = TextEditingController(text: randomPosterUrls.first);
  late List<GenreOption> availableGenres;
  late List<DirectorOption> availableDirectors;
  final selectedGenres = <GenreOption>[];
  String selectedDirectorId = '';
  String selectedFormat = projectionFormatOptions.first;
  int posterIndex = 0;
  String? message;
  bool messageIsError = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    availableGenres = [...widget.genres];
    availableDirectors = [...widget.directors];
    if (availableGenres.isNotEmpty) selectedGenres.add(availableGenres.first);
    selectedDirectorId =
        availableDirectors.isEmpty ? '' : availableDirectors.first.id;
  }

  @override
  void didUpdateWidget(covariant AdminMoviesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.genres != widget.genres) {
      availableGenres = mergeGenreOptions(availableGenres, widget.genres);
    }
    if (oldWidget.directors != widget.directors) {
      availableDirectors = mergeDirectorOptions(
        availableDirectors,
        widget.directors,
      );
      if (selectedDirectorId.isEmpty && availableDirectors.isNotEmpty) {
        selectedDirectorId = availableDirectors.first.id;
      }
    }
  }

  @override
  void dispose() {
    title.dispose();
    productionYear.dispose();
    duration.dispose();
    rating.dispose();
    country.dispose();
    synopsis.dispose();
    poster.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Header(
          'Gestion de peliculas',
          'Administrador: agrega estrenos, sube portada por URL y borra peliculas de cartelera',
        ),
        const SizedBox(height: 16),
        if (message != null) ...[
          AlertBanner(
            message!,
            messageIsError ? red : green,
            onClose: () => setState(() => message = null),
          ),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (context, c) {
            final narrow = c.maxWidth < 860;
            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _form(),
                  const SizedBox(height: 16),
                  _list(),
                ],
              );
            }
            return Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _form()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _list()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _form() {
    return CardBox(
      title: 'Nueva pelicula / estreno',
      subtitle: 'Completa los datos que se veran en cartelera',
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                poster.text,
                key: ValueKey(poster.text),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: surface2,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: red,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: title,
            decoration: const InputDecoration(
              labelText: 'Nombre de la pelicula',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: poster,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Portada',
              helperText: 'Pega una URL de imagen o usa portada random',
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(width: 360, child: _genrePicker()),
              SizedBox(
                width: 150,
                child: TextField(
                  controller: productionYear,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Anio produccion',
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: duration,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Duracion'),
                ),
              ),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: rating,
                  decoration: const InputDecoration(labelText: 'Clasif.'),
                ),
              ),
              SizedBox(
                width: 145,
                child: TextField(
                  controller: country,
                  decoration: const InputDecoration(labelText: 'Pais'),
                ),
              ),
              SizedBox(width: 260, child: _directorPicker()),
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedFormat,
                  isExpanded: true,
                  decoration:
                      const InputDecoration(labelText: 'Formato proyeccion'),
                  items: projectionFormatOptions
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => selectedFormat = value ?? selectedFormat,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: synopsis,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Sinopsis'),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _randomPoster,
                icon: const Icon(Icons.shuffle),
                label: const Text('Portada random'),
              ),
              FilledButton.icon(
                onPressed: saving ? null : _createMovie,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(saving ? 'Guardando...' : 'Crear pelicula'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _genrePicker() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Generos',
                style: TextStyle(color: burgundy, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Agregar genero',
              onPressed: _openGenreDialog,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (selectedGenres.isEmpty)
              const Text(
                'Agrega al menos un genero.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ...selectedGenres.map(
              (genre) => RemovableChip(
                label: genre.name,
                onDeleted: () => setState(() => selectedGenres.remove(genre)),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _directorPicker() {
    final selectedExists =
        availableDirectors.any((item) => item.id == selectedDirectorId);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: selectedExists ? selectedDirectorId : null,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Director'),
            items: availableDirectors
                .map(
                  (item) => DropdownMenuItem(
                    value: item.id,
                    child: Text(item.name),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(
              () => selectedDirectorId = value ?? selectedDirectorId,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: 'Registrar director',
          onPressed: _openDirectorDialog,
          icon: const Icon(Icons.person_add_alt_1_outlined),
        ),
      ],
    );
  }

  Future<void> _openGenreDialog() async {
    final option = await showDialog<GenreOption>(
      context: context,
      builder: (context) => GenrePickerDialog(options: availableGenres),
    );
    if (option == null) return;
    final alreadySelected = selectedGenres.any(
      (item) => normalizeText(item.name) == normalizeText(option.name),
    );
    if (alreadySelected) {
      setState(() {
        message = 'Ese genero ya esta seleccionado.';
        messageIsError = true;
      });
      return;
    }
    setState(() {
      availableGenres = mergeGenreOptions(availableGenres, [option]);
      selectedGenres.add(option);
      message = null;
      messageIsError = false;
    });
  }

  Future<void> _openDirectorDialog() async {
    final option = await showDialog<DirectorOption>(
      context: context,
      builder: (context) => DirectorFormDialog(people: widget.people),
    );
    if (option == null) return;
    setState(() {
      availableDirectors = mergeDirectorOptions(availableDirectors, [option]);
      selectedDirectorId = availableDirectors
          .firstWhere(
            (item) => normalizeText(item.name) == normalizeText(option.name),
            orElse: () => option,
          )
          .id;
      message = null;
      messageIsError = false;
    });
  }

  Widget _list() {
    return CardBox(
      title: 'Cartelera actual',
      subtitle: 'Estas peliculas aparecen en Taquilla para el Cajero',
      child: Column(
        children: widget.movies.map((movie) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: line),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      movie.posterUrl,
                      width: 92,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 92,
                        height: 58,
                        color: bg,
                        child: const Icon(Icons.movie_outlined, color: red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            color: text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${movie.genre} - ${movie.duration} min - ${movie.country}',
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                        if (movie.director.isNotEmpty)
                          Text(
                            'Director: ${movie.director}',
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Borrar de cartelera',
                    onPressed: widget.movies.length == 1
                        ? null
                        : () => _confirmDelete(movie),
                    icon: const Icon(Icons.delete_outline, color: red),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _randomPoster() {
    setState(() {
      posterIndex = (posterIndex + 1) % randomPosterUrls.length;
      poster.text = randomPosterUrls[posterIndex];
    });
  }

  Future<void> _createMovie() async {
    final cleanTitle = title.text.trim();
    if (cleanTitle.isEmpty) {
      setState(() {
        message = 'Escribe el nombre de la pelicula antes de crearla.';
        messageIsError = true;
      });
      return;
    }
    if (selectedGenres.isEmpty) {
      setState(() {
        message = 'Agrega al menos un genero para la pelicula.';
        messageIsError = true;
      });
      return;
    }

    final minutes = int.tryParse(duration.text.trim()) ?? 100;
    setState(() {
      saving = true;
      message = 'Guardando pelicula en el backend...';
      messageIsError = false;
    });

    try {
      final selectedDirector = availableDirectors.firstWhere(
        (item) => item.id == selectedDirectorId,
        orElse: () => const DirectorOption('', 'Sin director registrado'),
      );
      final newMovie = await DatabaseGateway.createMovieForEdition(
        MovieDraft(
          title: cleanTitle,
          productionYear:
              int.tryParse(productionYear.text.trim()) ?? DateTime.now().year,
          duration: minutes,
          rating: rating.text.trim().isEmpty ? '+13' : rating.text.trim(),
          country: country.text.trim().isEmpty ? 'Bolivia' : country.text.trim(),
          synopsis: synopsis.text.trim().isEmpty
              ? 'Estreno agregado por administracion para la cartelera del festival.'
              : synopsis.text.trim(),
          posterUrl:
              poster.text.trim().isEmpty ? randomPosterUrls.first : poster.text.trim(),
          format: selectedFormat,
          editionId: widget.editionId,
          genres: selectedGenres,
          director: selectedDirector,
        ),
      );

      widget.onAdd(newMovie);
      setState(() {
        saving = false;
        message =
            '"$cleanTitle" fue agregada a cartelera y guardada en la base de datos.';
        messageIsError = false;
        title.clear();
        synopsis.clear();
        selectedGenres
          ..clear()
          ..addAll(availableGenres.isEmpty ? const [] : [availableGenres.first]);
        selectedDirectorId =
            availableDirectors.isEmpty ? '' : availableDirectors.first.id;
        selectedFormat = projectionFormatOptions.first;
        _randomPoster();
      });
    } on DatabaseException catch (error) {
      setState(() {
        saving = false;
        message = error.friendlyMessage;
        messageIsError = true;
      });
    }
  }

  Future<void> _confirmDelete(Movie movie) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar pelicula'),
        content: Text(
          'Estas seguro de borrar "${movie.title}" de la cartelera?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    widget.onDelete(movie);
    setState(() {
      message = '"${movie.title}" fue retirada de cartelera.';
    });
  }
}

class EventTicketPage extends StatefulWidget {
  const EventTicketPage({
    super.key,
    required this.attendees,
    required this.people,
    required this.events,
    required this.edition,
    this.onDataChanged,
  });

  final List<Attendee> attendees;
  final List<PersonOption> people;
  final List<FestivalEvent> events;
  final FestivalEdition edition;
  final Future<void> Function()? onDataChanged;

  @override
  State<EventTicketPage> createState() => _EventTicketPageState();
}

class _EventTicketPageState extends State<EventTicketPage> {
  FestivalEvent? event;
  Attendee? attendee;
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final nit = TextEditingController();
  String paymentMethod = 'Efectivo';
  String? message;
  bool messageIsError = false;
  bool saving = false;
  PurchaseReceipt? receipt;

  @override
  void initState() {
    super.initState();
    event = _preferredEvent(_eventsForEdition());
    attendee = widget.attendees.isEmpty ? null : widget.attendees.first;
    if (attendee != null) _fillAttendee(attendee!);
  }

  @override
  void didUpdateWidget(covariant EventTicketPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final editionEvents = _eventsForEdition();
    if (event == null || !editionEvents.any((item) => item.id == event!.id)) {
      event = _preferredEvent(editionEvents);
    }
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
    nit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = _eventsForEdition();
    final current = events.any((item) => item.id == event?.id)
        ? event!
        : (events.isEmpty ? null : events.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Header(
          'Eventos',
          'Venta de entradas para eventos de ${widget.edition.name}',
          trailing: const Pill('EVENTOS', color: gold),
        ),
        const SizedBox(height: 16),
        if (message != null) ...[
          AlertBanner(
            message!,
            messageIsError ? red : green,
            onClose: () => setState(() => message = null),
          ),
          const SizedBox(height: 12),
        ],
        _centeredPanel(
          CardBox(
            title: 'Entrada para evento',
            subtitle: 'Selecciona un evento y registra a la persona',
            accent: gold,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: current?.id,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Evento disponible'),
                  items: events
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(
                            '${item.name} - ${item.type} - Bs ${item.cost.toStringAsFixed(2)}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: saving
                      ? null
                      : (id) => setState(() {
                            event = events.firstWhere(
                              (item) => item.id == id,
                              orElse: () => current ?? events.first,
                            );
                          }),
                ),
                if (current != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${current.room} - ${current.dateLabel} ${current.timeLabel} - Aforo ${current.sold}/${current.capacity}',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: firstName,
                        decoration: const InputDecoration(labelText: 'Nombre persona'),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: lastName,
                        decoration: const InputDecoration(labelText: 'Apellido persona'),
                      ),
                    ),
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: email,
                        decoration: const InputDecoration(labelText: 'Correo'),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: phone,
                        decoration: const InputDecoration(labelText: 'Telefono'),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<String>(
                        initialValue: paymentMethod,
                        decoration: const InputDecoration(labelText: 'Metodo de pago'),
                        items: const ['Efectivo', 'Tarjeta', 'QR', 'Transferencia']
                            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                            .toList(),
                        onChanged: saving
                            ? null
                            : (value) => setState(() {
                                  paymentMethod = value ?? 'Efectivo';
                                }),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: nit,
                        decoration: const InputDecoration(labelText: 'NIT / CI factura'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: saving || current == null ? null : _confirm,
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.event_available_outlined),
                  label: Text(saving ? 'Vendiendo evento...' : 'Confirmar entrada de evento'),
                ),
                if (receipt != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Factura ${receipt!.idFactura} - Codigo ${receipt!.codigoEntrada} - ${receipt!.metodoPago}',
                    style: const TextStyle(color: green, fontWeight: FontWeight.w800),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _centeredPanel(Widget child, {double maxWidth = 760}) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }

  void _fillAttendee(Attendee item) {
    firstName.text = item.firstName.isEmpty ? item.name : item.firstName;
    lastName.text = item.lastName;
    email.text = item.email;
    phone.text = item.phone;
  }

  FestivalEvent? _preferredEvent(List<FestivalEvent> items) {
    if (items.isEmpty) return null;
    return items.first;
  }

  List<FestivalEvent> _eventsForEdition() {
    return widget.events
        .where((item) => item.editionId == widget.edition.id)
        .toList();
  }

  Future<void> _confirm() async {
    final events = _eventsForEdition();
    final selectedEvent = events.any((item) => item.id == event?.id)
        ? event
        : (events.isEmpty ? null : events.first);
    if (selectedEvent == null) return;
    setState(() {
      saving = true;
      message = null;
    });
    try {
      final resolved = await DatabaseGateway.resolveAttendee(
        widget.edition.id,
        AttendeeFormData(
          idPersona: attendee?.idPersona ?? '',
          firstName: firstName.text.trim(),
          lastName: lastName.text.trim(),
          email: email.text.trim(),
          phone: phone.text.trim(),
        ),
      );
      final response = await DatabaseGateway.venderEntradaEvento(
        attendee: resolved.attendee,
        event: selectedEvent,
        metodoPago: paymentMethod,
        nit: nit.text.trim().isEmpty ? null : nit.text.trim(),
      );
      if (widget.onDataChanged != null) await widget.onDataChanged!();
      if (!mounted) return;
      setState(() {
        saving = false;
        messageIsError = false;
        message = 'Entrada de evento vendida correctamente.';
        receipt = response;
      });
    } on DatabaseException catch (error) {
      if (!mounted) return;
      setState(() {
        saving = false;
        messageIsError = true;
        message = error.friendlyMessage;
      });
    }
  }
}

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({
    super.key,
    required this.events,
    required this.rooms,
    required this.editions,
    required this.selectedEdition,
    required this.onEditionChanged,
    required this.onAdd,
  });

  final List<FestivalEvent> events;
  final List<RoomOption> rooms;
  final List<FestivalEdition> editions;
  final FestivalEdition selectedEdition;
  final ValueChanged<FestivalEdition> onEditionChanged;
  final ValueChanged<FestivalEvent> onAdd;

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  final name = TextEditingController();
  final description = TextEditingController();
  final capacity = TextEditingController(text: '40');
  final cost = TextEditingController(text: '0');
  final date = TextEditingController(text: '2026-08-13');
  final time = TextEditingController(text: '18:00');
  final duration = TextEditingController(text: '120');
  String type = 'Masterclass';
  String? roomId;
  String? message;
  bool messageIsError = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    roomId = widget.rooms.isEmpty ? null : widget.rooms.first.id;
  }

  @override
  void didUpdateWidget(covariant AdminEventsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (roomId == null || !widget.rooms.any((item) => item.id == roomId)) {
      roomId = widget.rooms.isEmpty ? null : widget.rooms.first.id;
    }
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    capacity.dispose();
    cost.dispose();
    date.dispose();
    time.dispose();
    duration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Header(
          'Eventos',
          'Administrador: crea eventos paralelos, talleres, cocteles y masterclass',
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 320,
          child: DropdownButtonFormField<String>(
            initialValue: widget.selectedEdition.id,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Edicion de eventos'),
            items: widget.editions
                .map(
                  (edition) => DropdownMenuItem(
                    value: edition.id,
                    child: Text(edition.name),
                  ),
                )
                .toList(),
            onChanged: saving
                ? null
                : (id) {
                    final edition = widget.editions.firstWhere(
                      (item) => item.id == id,
                      orElse: () => widget.selectedEdition,
                    );
                    widget.onEditionChanged(edition);
                  },
          ),
        ),
        const SizedBox(height: 16),
        if (message != null) ...[
          AlertBanner(
            message!,
            messageIsError ? red : green,
            onClose: () => setState(() => message = null),
          ),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (context, c) {
            final narrow = c.maxWidth < 860;
            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _form(),
                  const SizedBox(height: 16),
                  _list(),
                ],
              );
            }
            return Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _form()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _list()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _form() {
    final rooms = widget.rooms.isEmpty ? fallbackRoomOptions : widget.rooms;
    final selectedRoomId = rooms.any((item) => item.id == roomId)
        ? roomId
        : rooms.first.id;
    final editionBlockReason = _editionBlockReason(widget.selectedEdition);
    final canCreateEvent = _editionAllowsEventCreation(widget.selectedEdition);
    return CardBox(
      title: 'Nuevo evento',
      subtitle: 'El evento se registrara en ${widget.selectedEdition.name}',
      accent: gold,
      child: Column(
        children: [
          if (editionBlockReason != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: red.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(radiusSm),
                border: Border.all(color: red.withValues(alpha: .35)),
              ),
              child: Text(
                editionBlockReason,
                style: const TextStyle(color: red, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
          ],
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Nombre del evento'),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<String>(
                  initialValue: type,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tipo de evento'),
                  items: const ['Masterclass', 'Taller', 'Coctel']
                      .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) => setState(() => type = value ?? type),
                ),
              ),
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedRoomId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Sala'),
                  items: rooms
                      .map((item) => DropdownMenuItem(value: item.id, child: Text(item.label)))
                      .toList(),
                  onChanged: (value) => setState(() => roomId = value),
                ),
              ),
              SizedBox(
                width: 130,
                child: TextField(
                  controller: capacity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Aforo'),
                ),
              ),
              SizedBox(
                width: 130,
                child: TextField(
                  controller: cost,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Costo'),
                ),
              ),
              SizedBox(
                width: 150,
                child: TextField(
                  controller: date,
                  decoration: const InputDecoration(labelText: 'Fecha'),
                ),
              ),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: time,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Hora',
                    suffixIcon: Icon(Icons.schedule),
                  ),
                  onTap: saving ? null : _pickEventTime,
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: duration,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Duracion min'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: description,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Descripcion'),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: saving || !canCreateEvent ? null : _createEvent,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.event_available_outlined),
              label: Text(saving ? 'Creando evento...' : 'Crear evento'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list() {
    final items = widget.events
        .where((item) => item.editionId == widget.selectedEdition.id)
        .toList();
    return CardBox(
      title: 'Eventos registrados',
      subtitle: 'Eventos de ${widget.selectedEdition.name}',
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: line),
              ),
              child: Row(
                children: [
                  BadgeIcon(Icons.event_available_outlined, gold, compact: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${item.type} - ${item.room} - ${item.dateLabel} ${item.timeLabel}',
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                        Text(
                          'Aforo ${item.sold}/${item.capacity} - Bs ${item.cost.toStringAsFixed(2)}',
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _pickEventTime() async {
    final parts = time.text.split(':');
    final initialHour = parts.isNotEmpty ? int.tryParse(parts.first) ?? 18 : 18;
    final initialMinute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: initialHour.clamp(0, 23),
        minute: initialMinute.clamp(0, 59),
      ),
    );
    if (picked == null) return;
    setState(() {
      time.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _createEvent() async {
    final cleanName = name.text.trim();
    final selectedRoom = (widget.rooms.isEmpty ? fallbackRoomOptions : widget.rooms)
        .firstWhere(
          (item) => item.id == roomId,
          orElse: () => (widget.rooms.isEmpty ? fallbackRoomOptions : widget.rooms).first,
        );
    if (cleanName.isEmpty) {
      setState(() {
        message = 'Escribe el nombre del evento antes de crearlo.';
        messageIsError = true;
      });
      return;
    }
    final editionBlockReason = _editionBlockReason(widget.selectedEdition);
    if (editionBlockReason != null) {
      setState(() {
        message = editionBlockReason;
        messageIsError = true;
      });
      return;
    }
    final eventDateTime = DateTime.tryParse('${date.text.trim()}T${time.text.trim()}:00');
    if (eventDateTime == null) {
      setState(() {
        message = 'La fecha u hora del evento no tiene un formato valido.';
        messageIsError = true;
      });
      return;
    }
    final eventDateBlockReason = _eventDateBlockReason(widget.selectedEdition, eventDateTime);
    if (eventDateBlockReason != null) {
      setState(() {
        message = eventDateBlockReason;
        messageIsError = true;
      });
      return;
    }
    setState(() {
      saving = true;
      message = 'Guardando evento en el backend...';
      messageIsError = false;
    });
    try {
      final created = await DatabaseGateway.createFestivalEvent(
        EventDraft(
          name: cleanName,
          type: type,
          description: description.text.trim().isEmpty
              ? 'Evento agregado desde el panel administrativo.'
              : description.text.trim(),
          capacity: int.tryParse(capacity.text.trim()) ?? 40,
          cost: double.tryParse(cost.text.trim().replaceAll(',', '.')) ?? 0,
          date: date.text.trim(),
          time: time.text.trim(),
          durationMinutes: int.tryParse(duration.text.trim()) ?? 120,
          editionId: widget.selectedEdition.id,
          room: selectedRoom,
        ),
      );
      widget.onAdd(created);
      setState(() {
        saving = false;
        message = '"$cleanName" fue creado correctamente.';
        messageIsError = false;
        name.clear();
        description.clear();
      });
    } on DatabaseException catch (error) {
      setState(() {
        saving = false;
        message = error.friendlyMessage;
        messageIsError = true;
      });
    }
  }
}

class AdminEditionsPage extends StatefulWidget {
  const AdminEditionsPage({
    super.key,
    required this.venues,
    required this.movies,
    required this.categories,
    required this.jurors,
    required this.sponsors,
    required this.onJurorAdd,
  });

  final List<VenueOption> venues;
  final List<MovieOption> movies;
  final List<CategoryOption> categories;
  final List<JuryMember> jurors;
  final List<SponsorOption> sponsors;
  final ValueChanged<JuryMember> onJurorAdd;

  @override
  State<AdminEditionsPage> createState() => _AdminEditionsPageState();
}

class _AdminEditionsPageState extends State<AdminEditionsPage> {
  final name = TextEditingController(text: 'FestCine 2027');
  final start = TextEditingController(text: '2027-08-07');
  final end = TextEditingController(text: '2027-08-15');
  final sponsorName = TextEditingController();
  final sponsorPhone = TextEditingController();
  final sponsorEmail = TextEditingController();
  final sponsorAmount = TextEditingController(text: '10000');
  final sponsorDescription = TextEditingController(
    text: 'Aporte para la nueva edicion del festival.',
  );
  String status = 'Planificada';
  String? venueId;
  bool includeSponsor = true;
  bool createSponsor = false;
  String? sponsorId;
  String sponsorContributionType = 'Economica';
  late List<CategoryOption> availableCategories;
  late List<JuryMember> availableJurors;
  final selectedMovies = <String>{};
  final selectedCategories = <CategoryOption>[];
  final selectedJurors = <String>{};
  String? message;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    venueId = widget.venues.isEmpty ? null : widget.venues.first.id;
    sponsorId = widget.sponsors.isEmpty ? null : widget.sponsors.first.id;
    availableCategories = [...widget.categories];
    availableJurors = [...widget.jurors];
    selectedMovies.addAll(widget.movies.take(3).map((movie) => movie.id));
    selectedCategories.addAll(availableCategories.take(3));
    selectedJurors.addAll(availableJurors.take(2).map((juror) => juror.id));
  }

  @override
  void didUpdateWidget(covariant AdminEditionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      availableCategories = mergeCategoryOptions(
        availableCategories,
        widget.categories,
      );
    }
    if (oldWidget.jurors != widget.jurors) {
      availableJurors = mergeJuryMembers(availableJurors, widget.jurors);
    }
  }

  @override
  void dispose() {
    name.dispose();
    start.dispose();
    end.dispose();
    sponsorName.dispose();
    sponsorPhone.dispose();
    sponsorEmail.dispose();
    sponsorAmount.dispose();
    sponsorDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Header(
          'Ediciones del festival',
          'Registro integral: sede, peliculas, categorias y jurados',
        ),
        const SizedBox(height: 16),
        if (message != null) ...[
          AlertBanner(
            message!,
            message!.startsWith('Error') ? red : green,
            onClose: () => setState(() => message = null),
          ),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (context, c) {
            final narrow = c.maxWidth < 900;
            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _editionForm(),
                  const SizedBox(height: 16),
                  _selectionPanel(),
                ],
              );
            }
            return Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _editionForm()),
                const SizedBox(width: 16),
                Expanded(flex: 1, child: _selectionPanel()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _editionForm() => CardBox(
    title: 'Nueva edicion',
    subtitle: 'Datos principales y sede habilitada',
    child: Column(
      children: [
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Nombre de la edicion'),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 170,
              child: TextField(
                controller: start,
                decoration: const InputDecoration(labelText: 'Fecha inicio'),
              ),
            ),
            SizedBox(
              width: 170,
              child: TextField(
                controller: end,
                decoration: const InputDecoration(labelText: 'Fecha fin'),
              ),
            ),
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const ['Planificada', 'Actual', 'Finalizada', 'Cancelada']
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => status = value ?? status),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: venueId,
          decoration: const InputDecoration(labelText: 'Sede principal'),
          items: widget.venues
              .map(
                (venue) => DropdownMenuItem(
                  value: venue.id,
                  child: Text(venue.name),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => venueId = value),
        ),
        const SizedBox(height: 10),
        _categoryPicker(),
        const SizedBox(height: 12),
        _sponsorForm(),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: saving ? null : _saveEdition,
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(saving ? 'Registrando...' : 'Registrar edicion'),
        ),
      ],
    ),
  );

  Widget _categoryPicker() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Categorias de competicion',
                style: TextStyle(color: burgundy, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Agregar categoria',
              onPressed: _openCategoryDialog,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (selectedCategories.isEmpty)
              const Text(
                'Agrega al menos una categoria.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ...selectedCategories.map(
              (category) => RemovableChip(
                label: category.name,
                onDeleted: () =>
                    setState(() => selectedCategories.remove(category)),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _openCategoryDialog() async {
    final option = await showDialog<CategoryOption>(
      context: context,
      builder: (context) => CategoryPickerDialog(options: availableCategories),
    );
    if (option == null) return;
    final alreadySelected = selectedCategories.any(
      (item) => normalizeText(item.name) == normalizeText(option.name),
    );
    if (alreadySelected) {
      setState(() => message = 'Error: esa categoria ya esta seleccionada.');
      return;
    }
    setState(() {
      availableCategories = mergeCategoryOptions(availableCategories, [option]);
      selectedCategories.add(option);
      message = null;
    });
  }

  Widget _sponsorForm() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: surface2,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: gold),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: includeSponsor,
          onChanged: (value) => setState(() => includeSponsor = value),
          title: const Text('Asignar patrocinador'),
          subtitle: const Text('Selecciona uno existente o registra uno nuevo'),
        ),
        if (includeSponsor) ...[
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Existente'),
                icon: Icon(Icons.business_outlined),
              ),
              ButtonSegment(
                value: true,
                label: Text('Nuevo'),
                icon: Icon(Icons.add_business_outlined),
              ),
            ],
            selected: {createSponsor},
            onSelectionChanged: (value) =>
                setState(() => createSponsor = value.first),
          ),
          const SizedBox(height: 10),
          if (!createSponsor)
            DropdownButtonFormField<String>(
              initialValue: sponsorId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Patrocinador existente',
                border: OutlineInputBorder(),
              ),
              items: widget.sponsors
                  .map(
                    (sponsor) => DropdownMenuItem(
                      value: sponsor.id,
                      child: Text(sponsor.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => sponsorId = value),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: sponsorName,
                    decoration: const InputDecoration(
                      labelText: 'Nombre patrocinador',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: sponsorPhone,
                    decoration: const InputDecoration(
                      labelText: 'Telefono',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: TextField(
                    controller: sponsorEmail,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  initialValue: sponsorContributionType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo aporte',
                    border: OutlineInputBorder(),
                  ),
                  items: const ['Economica', 'Especie']
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => sponsorContributionType = value ?? 'Economica',
                  ),
                ),
              ),
              SizedBox(
                width: 160,
                child: TextField(
                  controller: sponsorAmount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: 320,
                child: TextField(
                  controller: sponsorDescription,
                  decoration: const InputDecoration(
                    labelText: 'Descripcion aporte',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );

  Widget _selectionPanel() => Column(
    children: [
      CardBox(
        title: 'Peliculas seleccionadas',
        subtitle: '${selectedMovies.length} peliculas para la edicion',
        child: _checkList(
          widget.movies
              .map((movie) => (movie.id, '${movie.title} (${movie.year})'))
              .toList(),
          selectedMovies,
        ),
      ),
      const SizedBox(height: 16),
      CardBox(
        title: 'Jurados asignados',
        subtitle: '${selectedJurors.length} miembros para categorias',
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _openJurorDialog,
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Nuevo jurado'),
              ),
            ),
            const SizedBox(height: 10),
            _checkList(
              availableJurors
                  .map((juror) => (juror.id, '${juror.name} - ${juror.role}'))
                  .toList(),
              selectedJurors,
            ),
          ],
        ),
      ),
    ],
  );

  Future<void> _openJurorDialog() async {
    final draft = await showDialog<JuryDraft>(
      context: context,
      builder: (context) => const JuryFormDialog(),
    );
    if (draft == null) return;
    setState(() {
      saving = true;
      message = null;
    });
    try {
      final juror = await DatabaseGateway.createJuror(draft);
      widget.onJurorAdd(juror);
      setState(() {
        availableJurors = mergeJuryMembers(availableJurors, [juror]);
        selectedJurors.add(juror.id);
        saving = false;
        message = 'Jurado "${juror.name}" registrado y asignado.';
      });
    } on DatabaseException catch (error) {
      setState(() {
        saving = false;
        message = 'Error: ${error.friendlyMessage}';
      });
    }
  }

  Widget _checkList(List<(String, String)> items, Set<String> selected) {
    if (items.isEmpty) {
      return const Text('No hay datos disponibles.', style: TextStyle(color: muted));
    }
    return Column(
      children: items.map((item) {
        final checked = selected.contains(item.$1);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: checked ? surface2 : surface,
            borderRadius: BorderRadius.circular(radiusSm),
            border: Border.all(color: checked ? gold : line, width: 1.1),
          ),
          child: CheckboxListTile(
            dense: true,
            value: checked,
            title: Text(
              item.$2,
              style: TextStyle(
                color: text,
                fontWeight: checked ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            onChanged: (value) => setState(() {
              if (value == true) {
                selected.add(item.$1);
              } else {
                selected.remove(item.$1);
              }
            }),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _saveEdition() async {
    if (venueId == null ||
        selectedMovies.isEmpty ||
        selectedJurors.isEmpty ||
        selectedCategories.isEmpty) {
      setState(() {
        message =
            'Error: selecciona sede, peliculas, categorias y al menos un jurado.';
      });
      return;
    }
    if (includeSponsor &&
        ((createSponsor && sponsorName.text.trim().isEmpty) ||
            (!createSponsor && sponsorId == null))) {
      setState(() {
        message =
            'Error: selecciona un patrocinador existente o escribe el nombre del nuevo patrocinador.';
      });
      return;
    }

    setState(() {
      saving = true;
      message = null;
    });

    try {
      final id = await DatabaseGateway.createFestivalEdition(
        FestivalEditionDraft(
          name: name.text.trim(),
          startDate: start.text.trim(),
          endDate: end.text.trim(),
          status: status,
          venueId: venueId!,
          movieIds: selectedMovies.toList(),
          categories: selectedCategories,
          jurorIds: selectedJurors.toList(),
          sponsor: includeSponsor
              ? SponsorDraft(
                  existingSponsorId: createSponsor ? null : sponsorId,
                  newSponsorName:
                      createSponsor ? sponsorName.text.trim() : null,
                  newSponsorPhone:
                      createSponsor ? sponsorPhone.text.trim() : null,
                  newSponsorEmail:
                      createSponsor ? sponsorEmail.text.trim() : null,
                  contributionType: sponsorContributionType,
                  amount: sponsorContributionType == 'Economica'
                      ? double.tryParse(sponsorAmount.text.trim())
                      : null,
                  description: sponsorDescription.text.trim(),
                )
              : null,
        ),
      );
      if (!mounted) return;
      setState(() {
        saving = false;
        message = null;
      });
    } on DatabaseException catch (error) {
      if (!mounted) return;
      setState(() {
        saving = false;
        message = 'Error: ${error.friendlyMessage}';
      });
    }
  }
}

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

class SeatMap extends StatelessWidget {
  const SeatMap({
    super.key,
    required this.occupied,
    required this.selected,
    required this.onTap,
  });

  final List<String> occupied;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
    return Column(
      children: [
        CustomPaint(size: const Size(420, 28), painter: ScreenPainter()),
        const Text(
          'P A N T A L L A',
          style: TextStyle(color: gold, fontSize: 10, letterSpacing: 3),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: rows.map((row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      child: Text(row, style: const TextStyle(color: muted)),
                    ),
                    ...List.generate(12, (i) {
                      final id = '$row${i + 1}';
                      final isOcc = occupied.contains(id);
                      final isSel = selected.contains(id);
                      return Padding(
                        padding: EdgeInsets.only(left: i == 6 ? 14 : 5),
                        child: InkWell(
                          onTap: isOcc ? null : () => onTap(id),
                          child: Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSel
                                  ? gold.withValues(alpha: .22)
                                  : isOcc
                                  ? red.withValues(alpha: .14)
                                  : surface.withValues(alpha: .9),
                              border: Border.all(
                                color: isSel
                                    ? gold
                                    : isOcc
                                    ? red.withValues(alpha: .5)
                                    : line.withValues(alpha: .65),
                                width: 1.4,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              isSel
                                  ? id
                                  : isOcc
                                  ? 'x'
                                  : '${i + 1}',
                              style: TextStyle(
                                color: isSel
                                    ? gold
                                    : isOcc
                                    ? red
                                    : text.withValues(alpha: .72),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(row, style: const TextStyle(color: muted)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        const Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            Legend('Disponible', line, fill: surface),
            Legend('Ocupado', red, mark: 'x'),
            Legend('Seleccionado', gold, fill: Color(0x227c1010)),
          ],
        ),
      ],
    );
  }
}

class ScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gold
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(20, size.height - 4)
      ..quadraticBezierTo(size.width / 2, 2, size.width - 20, size.height - 4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GenericQr extends StatelessWidget {
  const GenericQr({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final seed = label.codeUnits.fold<int>(0, (sum, value) => sum + value);
    return Container(
      width: 92,
      height: 92,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemCount: 81,
        itemBuilder: (context, index) {
          final row = index ~/ 9;
          final col = index % 9;
          final finder = (row < 3 && col < 3) ||
              (row < 3 && col > 5) ||
              (row > 5 && col < 3);
          final filled = finder || ((index * 31 + seed) % 7 < 3);
          return Container(
            margin: const EdgeInsets.all(.7),
            color: filled ? text : Colors.white,
          );
        },
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header(this.title, this.subtitle, {super.key, this.trailing});
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 620,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: text,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: muted)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minWidth = 240,
    this.aspectRatio,
  });
  final List<Widget> children;
  final double minWidth;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final count = (c.maxWidth / minWidth).floor().clamp(1, 4);
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: aspectRatio ?? (count == 1 ? 1.2 : 1.05),
          children: children,
        );
      },
    );
  }
}

class CardBox extends StatelessWidget {
  const CardBox({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.accent,
  });
  final String title;
  final String? subtitle;
  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final tone = accent ?? paletteFor(title);
    final fill = cardFillFor(tone);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone, width: .9),
        boxShadow: [
          BoxShadow(
            color: sidebarBg.withValues(alpha: .08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(radiusSm),
              border: Border.all(color: tone, width: 1.1),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: tone,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: text,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                subtitle!,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard(
    this.label,
    this.value,
    this.sub,
    this.icon,
    this.color, {
    super.key,
    this.trend,
  });
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;
  final int? trend;

  @override
  Widget build(BuildContext context) {
    return CardBox(
      title: label.toUpperCase(),
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BadgeIcon(icon, color, compact: true),
              const Spacer(),
              if (trend != null)
                Text('+$trend%', style: const TextStyle(color: green)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 2,
                style: const TextStyle(
                  color: text,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Text(sub, style: const TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class BadgeIcon extends StatelessWidget {
  const BadgeIcon(
    this.icon,
    this.color, {
    super.key,
    this.compact = false,
    this.background,
    this.borderColor,
  });
  final IconData icon;
  final Color color;
  final bool compact;
  final Color? background;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) => Container(
    width: compact ? 34 : 40,
    height: compact ? 34 : 40,
    decoration: BoxDecoration(
      color:
          background ??
          (color == Colors.white ? Colors.white24 : cardFillFor(color)),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: borderColor ?? (color == Colors.white ? Colors.white : color),
      ),
    ),
    child: Icon(icon, color: color, size: compact ? 18 : 22),
  );
}

class Pill extends StatelessWidget {
  const Pill(this.textValue, {super.key, this.color = gold});
  final String textValue;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radiusSm),
      border: Border.all(color: color, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: sidebarBg.withValues(alpha: .05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Text(
      textValue,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: .3,
      ),
    ),
  );
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, this.color, {super.key});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: color, width: 1.1),
      boxShadow: [
        BoxShadow(
          color: sidebarBg.withValues(alpha: .04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: text, fontSize: 12)),
      ],
    ),
  );
}

class InfoBox extends StatelessWidget {
  const InfoBox({
    super.key,
    required this.title,
    required this.body,
    required this.footer,
    required this.icon,
    required this.color,
  });
  final String title;
  final String body;
  final String footer;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: sidebarPanel,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: peach),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: peach, fontSize: 11, letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: onDark, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, color: color, size: 10),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                footer,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class ProgressRow extends StatelessWidget {
  const ProgressRow(
    this.label,
    this.percent,
    this.color, {
    super.key,
    this.compact = false,
  });
  final String label;
  final int percent;
  final Color color;
  final bool compact;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: compact ? 6 : 12),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: text, fontSize: compact ? 11.5 : 13),
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        SizedBox(height: compact ? 3 : 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent.clamp(0, 100) / 100,
            minHeight: compact ? 5 : 7,
            color: color,
            backgroundColor: surface2,
          ),
        ),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: line),
    ),
    child: Row(
      children: [
        Icon(icon, color: muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: muted, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class StepperPills extends StatelessWidget {
  const StepperPills(this.step, {super.key});
  final int step;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    children: ['Cartelera', 'Horarios', 'Asientos', 'Confirmacion']
        .asMap()
        .entries
        .map(
          (e) => Pill(
            '${e.key + 1}. ${e.value}',
            color: e.key + 1 <= step ? gold : muted,
          ),
        )
        .toList(),
  );
}

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie, required this.onTap});
  final Movie movie;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: CardBox(
      title: movie.title,
      subtitle:
          '${movie.country} - ${movie.genre} - ${movie.duration} min - ${movie.rating}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                movie.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: surface2,
                  child: const Center(
                    child: Icon(
                      Icons.movie_creation_outlined,
                      color: red,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            movie.synopsis,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: muted, height: 1.35),
          ),
          if (movie.director.isNotEmpty || movie.format.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              [
                if (movie.director.isNotEmpty) 'Director: ${movie.director}',
                if (movie.format.isNotEmpty) 'Formato: ${movie.format}',
              ].join(' - '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: text, fontSize: 12),
            ),
          ],
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.chevron_right, color: red),
          ),
        ],
      ),
    ),
  );
}

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.footer,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String footer;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: CardBox(
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BadgeIcon(icon, color, compact: true),
          const SizedBox(height: 8),
          Text(
            footer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: muted, height: 1.2),
          ),
        ],
      ),
    ),
  );
}

class BackLine extends StatelessWidget {
  const BackLine(this.label, this.onBack, {super.key});
  final String label;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      OutlinedButton.icon(
        onPressed: onBack,
        icon: const Icon(Icons.chevron_left),
        label: const Text('Volver'),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: text, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class RemovableChip extends StatefulWidget {
  const RemovableChip({super.key, required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  State<RemovableChip> createState() => _RemovableChipState();
}

class _RemovableChipState extends State<RemovableChip> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: hovering ? surface2 : surface,
          borderRadius: BorderRadius.circular(radiusSm),
          border: Border.all(color: hovering ? burgundy : line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 210),
              child: Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Opacity(
              opacity: hovering ? 1 : 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: hovering ? widget.onDeleted : null,
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: Icon(Icons.close, size: 15, color: burgundy),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryPickerDialog extends StatefulWidget {
  const CategoryPickerDialog({super.key, required this.options});

  final List<CategoryOption> options;

  @override
  State<CategoryPickerDialog> createState() => _CategoryPickerDialogState();
}

class _CategoryPickerDialogState extends State<CategoryPickerDialog> {
  final name = TextEditingController();
  final description = TextEditingController();
  CategoryOption? selected;

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = normalizeText(name.text);
    final matches = widget.options
        .where((item) => query.isEmpty || normalizeText(item.name).contains(query))
        .take(8)
        .toList();
    return AlertDialog(
      title: const Text('Agregar categoria'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Buscar o escribir categoria',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() => selected = null),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: description,
              decoration: const InputDecoration(
                labelText: 'Descripcion',
                helperText: 'Opcional para categorias nuevas',
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: ListView(
                children: matches.map((item) {
                  final active = selected?.id == item.id;
                  return ListTile(
                    dense: true,
                    selected: active,
                    leading: Icon(
                      active ? Icons.check_circle : Icons.emoji_events_outlined,
                      color: active ? burgundy : slate,
                    ),
                    title: Text(item.name),
                    subtitle: item.description.isEmpty
                        ? null
                        : Text(item.description),
                    onTap: () => setState(() {
                      selected = item;
                      name.text = item.name;
                      description.text = item.description;
                    }),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: name.text.trim().isEmpty
              ? null
              : () {
                  final option = selected ??
                      CategoryOption(
                        newLocalId('CC'),
                        toTitleCase(name.text),
                        description: description.text.trim(),
                      );
                  Navigator.pop(context, option);
                },
          icon: const Icon(Icons.add),
          label: const Text('Agregar'),
        ),
      ],
    );
  }
}

class GenrePickerDialog extends StatefulWidget {
  const GenrePickerDialog({super.key, required this.options});

  final List<GenreOption> options;

  @override
  State<GenrePickerDialog> createState() => _GenrePickerDialogState();
}

class _GenrePickerDialogState extends State<GenrePickerDialog> {
  final name = TextEditingController();
  GenreOption? selected;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = normalizeText(name.text);
    final matches = widget.options
        .where((item) => query.isEmpty || normalizeText(item.name).contains(query))
        .take(8)
        .toList();
    return AlertDialog(
      title: const Text('Agregar genero'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Buscar o escribir genero',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() => selected = null),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: ListView(
                children: matches.map((item) {
                  final active = selected?.name == item.name;
                  return ListTile(
                    dense: true,
                    selected: active,
                    leading: Icon(
                      active ? Icons.check_circle : Icons.movie_filter_outlined,
                      color: active ? burgundy : slate,
                    ),
                    title: Text(item.name),
                    onTap: () => setState(() {
                      selected = item;
                      name.text = item.name;
                    }),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: name.text.trim().isEmpty && selected == null
              ? null
              : () => Navigator.pop(
                    context,
                    selected ??
                        GenreOption(newLocalId('GE'), toTitleCase(name.text)),
                  ),
          icon: const Icon(Icons.add),
          label: const Text('Agregar'),
        ),
      ],
    );
  }
}

class DirectorFormDialog extends StatefulWidget {
  const DirectorFormDialog({super.key, required this.people});

  final List<PersonOption> people;

  @override
  State<DirectorFormDialog> createState() => _DirectorFormDialogState();
}

class _DirectorFormDialogState extends State<DirectorFormDialog> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final country = TextEditingController(text: 'Bolivia');
  final bio = TextEditingController();
  PersonOption? selectedPerson;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    country.dispose();
    bio.dispose();
    super.dispose();
  }

  List<PersonOption> _suggestions() {
    final query = normalizeText(name.text);
    final phoneQuery = onlyDigits(phone.text);
    if (query.length < 3 && phoneQuery.length < 3) return const [];
    final matches = widget.people.where((item) {
      final candidateName = normalizeText(item.displayName);
      final candidatePhone = onlyDigits(item.phone);
      final nameMatches = query.length >= 3 &&
          (candidateName == query ||
              candidateName.contains(query) ||
              query.contains(candidateName) ||
              fuzzyScore(candidateName, query) >= 0.72);
      final phoneMatches =
          phoneQuery.length >= 3 && candidatePhone.contains(phoneQuery);
      return nameMatches || phoneMatches;
    }).toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    return matches.take(5).toList();
  }

  void _fillPerson(PersonOption person) {
    setState(() {
      selectedPerson = person;
      name.text = person.displayName;
      if (person.phone.trim().isNotEmpty) phone.text = person.phone;
    });
  }

  Widget _personMatches() {
    final matches = _suggestions();
    if (matches.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Personas encontradas',
          style: TextStyle(
            color: muted,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: matches.map((person) {
            final selected = selectedPerson?.id == person.id;
            final detail = [
              person.id,
              if (person.phone.trim().isNotEmpty) person.phone,
            ].where((part) => part.trim().isNotEmpty).join(' - ');
            return ActionChip(
              avatar: Icon(
                selected
                    ? Icons.check_circle_outline
                    : Icons.person_search_outlined,
                size: 18,
              ),
              label: Text(
                detail.isEmpty
                    ? 'Usar ${person.displayName}'
                    : 'Usar ${person.displayName} ($detail)',
              ),
              onPressed: () => _fillPerson(person),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar director'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              onChanged: (_) => setState(() => selectedPerson = null),
            ),
            _personMatches(),
            const SizedBox(height: 10),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Nro telefono'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: country,
              decoration: const InputDecoration(labelText: 'Pais'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bio,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Biografia'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: name.text.trim().isEmpty
              ? null
              : () => Navigator.pop(
                    context,
                    DirectorOption(
                      newLocalId('PC'),
                      toTitleCase(name.text),
                      country: country.text.trim(),
                      biography: bio.text.trim(),
                      phone: phone.text.trim(),
                    ),
                  ),
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: const Text('Registrar'),
        ),
      ],
    );
  }
}

class JuryFormDialog extends StatefulWidget {
  const JuryFormDialog({super.key});

  @override
  State<JuryFormDialog> createState() => _JuryFormDialogState();
}

class _JuryFormDialogState extends State<JuryFormDialog> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final specialty = TextEditingController();
  String estado = 'Pendiente';
  String tipo = 'Experto';

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
    specialty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo jurado'),
      content: SizedBox(
        width: 520,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 240,
              child: TextField(
                controller: firstName,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(
              width: 240,
              child: TextField(
                controller: lastName,
                decoration: const InputDecoration(labelText: 'Apellido'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(
              width: 240,
              child: TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Correo'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(
              width: 240,
              child: TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Telefono'),
              ),
            ),
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<String>(
                initialValue: estado,
                decoration: const InputDecoration(labelText: 'Estado asistencia'),
                items: const ['Presente', 'Ausente', 'Pendiente']
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => setState(() => estado = value ?? estado),
              ),
            ),
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<String>(
                initialValue: tipo,
                decoration: const InputDecoration(labelText: 'Tipo jurado'),
                items: const ['Experto', 'Critico', 'Director', 'Productor']
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => setState(() => tipo = value ?? tipo),
              ),
            ),
            SizedBox(
              width: 490,
              child: TextField(
                controller: specialty,
                decoration: const InputDecoration(labelText: 'Especialidad'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: firstName.text.trim().isEmpty ||
                  lastName.text.trim().isEmpty ||
                  email.text.trim().isEmpty
              ? null
              : () => Navigator.pop(
                    context,
                    JuryDraft(
                      firstName: firstName.text.trim(),
                      lastName: lastName.text.trim(),
                      email: email.text.trim(),
                      phone: phone.text.trim(),
                      estadoAsistencia: estado,
                      especialidad: specialty.text.trim(),
                      tipoJurado: tipo,
                    ),
                  ),
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: const Text('Crear jurado'),
        ),
      ],
    );
  }
}

class Legend extends StatelessWidget {
  const Legend(this.label, this.color, {super.key, this.fill, this.mark});
  final String label;
  final Color color;
  final Color? fill;
  final String? mark;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(4),
          color: fill ?? color.withValues(alpha: .14),
        ),
        alignment: Alignment.center,
        child: mark == null
            ? null
            : Text(
                mark!,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
        ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: muted, fontSize: 12)),
    ],
  );
}

class AlertBanner extends StatelessWidget {
  const AlertBanner(
    this.message,
    this.color, {
    super.key,
    required this.onClose,
  });
  final String message;
  final Color color;
  final VoidCallback onClose;
  @override
  Widget build(BuildContext context) {
    final isError = color == red;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError ? surface2 : freshSurface,
        border: Border.all(color: isError ? red : sidebarBg),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.info_outline, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: text, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: sidebarBg),
          ),
        ],
      ),
    );
  }
}

class SelectLine extends StatelessWidget {
  const SelectLine(
    this.label,
    this.value,
    this.items,
    this.onChanged, {
    super.key,
  });
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: surface,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    ),
  );
}

int toMinutes(String t) {
  final parts = t.split(':').map(int.parse).toList();
  return parts[0] * 60 + parts[1];
}

class DatabaseException implements Exception {
  const DatabaseException(this.code, this.friendlyMessage);

  final String code;
  final String friendlyMessage;
}

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

class ApiCatalog {
  const ApiCatalog({
    required this.editions,
    required this.movies,
    required this.attendees,
    required this.people,
    required this.schedule,
    required this.rooms,
    required this.movieTitles,
    required this.days,
    required this.venues,
    required this.movieOptions,
    required this.categoryOptions,
    required this.genreOptions,
    required this.directorOptions,
    required this.juryMembers,
    required this.sponsors,
    required this.subscriptionTypes,
    required this.accreditationTypes,
    required this.events,
    required this.roomOptions,
  });

  final List<FestivalEdition> editions;
  final List<Movie> movies;
  final List<Attendee> attendees;
  final List<PersonOption> people;
  final List<ScreeningPlan> schedule;
  final List<String> rooms;
  final List<String> movieTitles;
  final List<String> days;
  final List<VenueOption> venues;
  final List<MovieOption> movieOptions;
  final List<CategoryOption> categoryOptions;
  final List<GenreOption> genreOptions;
  final List<DirectorOption> directorOptions;
  final List<JuryMember> juryMembers;
  final List<SponsorOption> sponsors;
  final List<SubscriptionType> subscriptionTypes;
  final List<AccreditationType> accreditationTypes;
  final List<FestivalEvent> events;
  final List<RoomOption> roomOptions;
}

class DatabaseGateway {
  const DatabaseGateway._();

  static final http.Client _client = http.Client();
  static Map<String, String> _tarifaIds = const {};

  static Future<ApiCatalog> fetchCatalog({String? editionId}) async {
    final editionsData = await _getList('/api/ediciones');
    final editions = editionsData.map(editionFromJson).toList()
      ..sort((a, b) {
        if (a.status == 'Actual' && b.status != 'Actual') return -1;
        if (b.status == 'Actual' && a.status != 'Actual') return 1;
        return b.startDate.compareTo(a.startDate);
      });
    final selectedEditionId = editionId ??
        editions
            .firstWhere(
              (item) => item.status == 'Actual',
              orElse: () => editions.isEmpty ? fallbackEditions.first : editions.first,
            )
            .id;

    final moviesData = await _getList('/api/catalogos/peliculas/$selectedEditionId');
    final projectionsData =
        await _getList('/api/catalogos/proyecciones/$selectedEditionId');
    final rawAttendeesData = await _getList('/api/asistentes');
    final catalogAttendeesData =
        await _getList('/api/catalogos/asistentes/$selectedEditionId');
    final personasData = await _getList('/api/personas');
    final people = personasData.map(personOptionFromJson).toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    final entriesData = await _getList('/api/entradas-individuales');
    final roomsData = await _getList('/api/catalogos/salas/$selectedEditionId');
    final eventsData = await _getList('/api/catalogos/eventos/$selectedEditionId');
    final tarifasData = await _getList('/api/catalogos/tarifas');
    final genresData = await _getList('/api/catalogos/generos');
    final venuesData = await _getList('/api/sedes');
    final allMoviesData = await _getList('/api/peliculas');
    final movieGenresData = await _getList('/api/relaciones/pelicula-generos');
    final participationData = await _getList('/api/participaciones-pelicula');
    final filmStaffData = await _getList('/api/personal-cinematografico');
    final roleData = await _getList('/api/roles-cinematograficos');
    final jurorsData = await _getList('/api/jurados');
    final categoriesData = await _getList('/api/categorias-competicion');
    final sponsorsData = await _getList('/api/patrocinadores');
    final subscriptionTypesData = await _getList('/api/tipo-abonos');
    final accreditationTypesData = await _getList('/api/tipo-acreditaciones');

    _tarifaIds = {
      for (final item in tarifasData)
        _readString(item, 'tipoTarifa'): _readString(item, 'idTarifa'),
    };

    final moviesByTitle = <String, Map<String, dynamic>>{
      for (final item in moviesData) _readString(item, 'titulo'): item,
    };
    final sessionsByTitle = <String, List<Session>>{};
    final schedule = <ScreeningPlan>[];
    final days = <String>{};
    final peopleById = {
      for (final item in personasData) _readString(item, 'idPersona'): item,
    };
    final movieById = {
      for (final item in allMoviesData) _readString(item, 'idPelicula'): item,
    };
    final staffById = {
      for (final item in filmStaffData) _readString(item, 'idPersonal'): item,
    };
    final roleById = {
      for (final item in roleData) _readString(item, 'idRol'): item,
    };
    final genresById = {
      for (final item in genresData) _readString(item, 'idGenero'): item,
    };
    final genresByMovie = genresFromRelations(movieGenresData, genresById);
    final directorsByMovie = directorsFromParticipation(
      participationData,
      staffById,
      roleById,
      peopleById,
    );
    final occupiedSeatsByProjection = occupiedSeatsFromEntries(entriesData);

    for (final item in projectionsData) {
      final title = _readString(item, 'tituloPelicula');
      final dateTime = _readDate(item, 'fechaHoraInicio');
      final day = formatApiDay(dateTime);
      final movieData = moviesByTitle[title];
      final movieEditionId = movieData == null
          ? ''
          : _readString(movieData, 'idPeliculaEdicion');
      final session = Session(
        day,
        formatApiTime(dateTime),
        _readString(item, 'nombreSala'),
        _readBool(item, 'tieneQA'),
        occupiedSeatsByProjection[_readString(item, 'idProyeccion')] ?? [],
        idProyeccion: _readString(item, 'idProyeccion'),
        idSala: _readString(item, 'idSala'),
        capacity: _readInt(item, 'capacidad'),
      );

      sessionsByTitle.putIfAbsent(title, () => []).add(session);
      days.add(day);
      schedule.add(
        ScreeningPlan(
          title,
          session.room,
          day,
          session.time,
          movieData == null ? 100 : _readInt(movieData, 'duracion'),
          session.qa,
          idProyeccion: session.idProyeccion,
          idSala: session.idSala,
          idPeliculaEdicion: movieEditionId,
        ),
      );
    }

    var posterIndex = 0;
    final movies = moviesData.map((item) {
      final title = _readString(item, 'titulo');
      final poster = randomPosterUrls[posterIndex % randomPosterUrls.length];
      final movieBase =
          movieById[_readString(item, 'idPelicula')] ?? const <String, dynamic>{};
      posterIndex += 1;
      return Movie(
        title,
        genresByMovie[_readString(item, 'idPelicula')] ??
            _estadoToGenre(_readString(item, 'estadoFestival')),
        _readInt(item, 'duracion'),
        _readString(movieBase, 'clasEdad').isEmpty
            ? 'ATP'
            : _readString(movieBase, 'clasEdad'),
        _readString(movieBase, 'paisOrigen').isEmpty
            ? 'FestCine'
            : _readString(movieBase, 'paisOrigen'),
        _readString(movieBase, 'sinopsis').isEmpty
            ? 'Pelicula cargada desde el catalogo de la edicion $selectedEditionId.'
            : _readString(movieBase, 'sinopsis'),
        poster,
        sessionsByTitle[title] ?? const [],
        idPelicula: _readString(item, 'idPelicula'),
        idPeliculaEdicion: _readString(item, 'idPeliculaEdicion'),
        director: directorsByMovie[_readString(item, 'idPelicula')] ?? 'Sin director registrado',
        format: _readString(movieBase, 'formatoProyeccion'),
      );
    }).toList();

    final attendeesById = <String, Attendee>{};
    for (final item in catalogAttendeesData) {
      final attendeeItem = attendeeFromJson(item);
      if (attendeeItem.id.isNotEmpty) attendeesById[attendeeItem.id] = attendeeItem;
    }
    for (final item in rawAttendeesData) {
      if (_readString(item, 'idEdicion') != selectedEditionId) continue;
      final person = peopleById[_readString(item, 'idPersona')] ?? <String, dynamic>{};
      final attendeeItem = attendeeFromPersonAndAssistant(person, item);
      if (attendeeItem.id.isNotEmpty) attendeesById[attendeeItem.id] = attendeeItem;
    }
    final attendees = attendeesById.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final roomNames = roomsData
        .map((item) => _readString(item, 'nombreSala'))
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final roomOptions = roomsData.map((item) {
      return RoomOption(
        _readString(item, 'idSala'),
        _readString(item, 'nombreSala'),
        _readString(item, 'nombreSede'),
        _readInt(item, 'capacidad'),
      );
    }).toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    final movieTitles = movies.map((movie) => movie.title).toList()..sort();
    final sortedDays = days.toList()..sort();
    final venues = venuesData.map((item) {
      return VenueOption(
        _readString(item, 'idSede'),
        _readString(item, 'nombreSede'),
        _readString(item, 'ciudad'),
      );
    }).toList();
    final movieOptions = allMoviesData.map((item) {
      return MovieOption(
        _readString(item, 'idPelicula'),
        _readString(item, 'titulo'),
        _readInt(item, 'anioProduccion'),
      );
    }).toList();
    final categoryOptions = mergeCategoryOptions(
      categoriesData.map(categoryOptionFromJson).toList(),
      fallbackCategoryOptions,
    );
    final genreOptions = mergeGenreOptions(
      genresData
          .map(
            (item) => GenreOption(
              _readString(item, 'idGenero'),
              _readString(item, 'nombreGenero'),
            ),
          )
          .where((item) => item.name.isNotEmpty)
          .toList(),
      fallbackGenreOptions,
    );
    final directorOptions = directorsFromStaff(
      participationData,
      staffById,
      roleById,
      peopleById,
    );
    final juryMembers = jurorsData.map((item) {
      final person = peopleById[_readString(item, 'idPersona')] ?? <String, dynamic>{};
      final fullName = '${_readString(person, 'nombre')} ${_readString(person, 'apellido')}'.trim();
      return JuryMember(
        _readString(item, 'idJurado'),
        fullName.isEmpty ? _readString(item, 'idJurado') : fullName,
        _readString(item, 'tipoJurado').isEmpty
            ? _readString(item, 'especialidad')
            : _readString(item, 'tipoJurado'),
      );
    }).toList();
    final sponsors = sponsorsData.map(sponsorFromJson).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final subscriptionTypes = subscriptionTypesData.map(subscriptionTypeFromJson).toList()
      ..sort((a, b) => a.price.compareTo(b.price));
    final accreditationTypes = mergeAccreditationTypes(
      accreditationTypesData.map(accreditationTypeFromJson).toList(),
      fallbackAccreditationTypes,
    );
    final entriesByEvent = entriesSoldByEvent(entriesData);
    final events = eventsData
        .map((item) => festivalEventFromJson(item, entriesByEvent, selectedEditionId))
        .where((item) => item.id.isNotEmpty)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    return ApiCatalog(
      editions: editions,
      movies: movies,
      attendees: attendees,
      people: people,
      schedule: schedule,
      rooms: roomNames,
      movieTitles: movieTitles,
      days: sortedDays,
      venues: venues,
      movieOptions: movieOptions,
      categoryOptions: categoryOptions,
      genreOptions: genreOptions,
      directorOptions: directorOptions,
      juryMembers: juryMembers,
      sponsors: sponsors,
      subscriptionTypes: subscriptionTypes,
      accreditationTypes: accreditationTypes,
      events: events,
      roomOptions: roomOptions,
    );
  }

  static Future<ReportBundle> fetchReportBundle(String editionId) async {
    final dashboardData = await _getMap('/api/dashboard/$editionId');
    final rankingData = await _getList('/api/reportes/ranking/$editionId');
    final awardsData = await _getList('/api/reportes/premiacion/$editionId');
    final financeData = await _getList('/api/reportes/financiero/$editionId');

    return ReportBundle(
      dashboard: dashboardFromJson(dashboardData),
      ranking: rankingData.map(rankingFromJson).toList()
        ..sort(
          (a, b) => b.porcentajeOcupacion.compareTo(a.porcentajeOcupacion),
        ),
      awards: awardsData.map(awardFromJson).toList(),
      finance: financeData.map(financeFromJson).toList(),
    );
  }

  static Future<DashboardBundle> fetchDashboardBundle(String editionId) async {
    final report = await fetchReportBundle(editionId);
    final projectionsData =
        await _getList('/api/catalogos/proyecciones/$editionId');
    final entriesData = await _getList('/api/entradas-individuales');

    final projectionTitleById = <String, String>{};
    final projections = projectionsData.map((item) {
      final id = _readString(item, 'idProyeccion');
      final title = _readString(item, 'tituloPelicula');
      projectionTitleById[id] = title;
      final date = _readDate(item, 'fechaHoraInicio');
      return ProjectionSummary(
        title,
        _readString(item, 'nombreSala'),
        '${formatApiDay(date)} ${formatApiTime(date)}',
      );
    }).toList()
      ..sort((a, b) => a.when.compareTo(b.when));

    final salesByMovie = <String, int>{};
    for (final entry in entriesData) {
      final title = projectionTitleById[_readString(entry, 'idProyeccion')];
      if (title == null || title.isEmpty) continue;
      salesByMovie[title] = (salesByMovie[title] ?? 0) + 1;
    }
    final topSold = salesByMovie.entries
        .map((entry) => SoldMovie(entry.key, entry.value))
        .toList()
      ..sort((a, b) => b.sales.compareTo(a.sales));

    return DashboardBundle(
      dashboard: report.dashboard,
      ranking: report.ranking,
      awards: report.awards,
      finance: report.finance,
      topSold: topSold,
      projections: projections,
    );
  }

  static Future<PurchaseReceipt> p1ComprarEntrada({
    required Movie movie,
    required Session session,
    required Attendee attendee,
    required String tarifa,
    required String metodoPago,
    required String? nit,
    required List<String> seats,
  }) async {
    if (session.idProyeccion.isEmpty) {
      throw const DatabaseException(
        'API_PROYECCION_SIN_ID',
        'La proyeccion seleccionada no tiene ID del backend. Recarga los catalogos e intenta nuevamente.',
      );
    }
    if (seats.length != 1) {
      throw const DatabaseException(
        'P1_BOLETO_INDIVIDUAL',
        'La venta registra un boleto individual. Selecciona un solo asiento.',
      );
    }

    final payload = {
      'idAsistente': attendee.id,
      'idProyeccion': session.idProyeccion,
      'idTarifa': await _idTarifa(tarifa),
      'metodoPago': metodoPago,
      'nit': nit,
      'nombreCompra': attendee.displayName,
      'nroAsiento': seatLabelToNumber(seats.single),
    };

    final data = await _postJson('/api/taquilla/comprar-entrada', payload);
    return PurchaseReceipt(
      idCompra: _readString(data, 'idCompra'),
      idEntrada: _readString(data, 'idEntrada'),
      idFactura: _readString(data, 'idFactura'),
      codigoEntrada: _readString(data, 'codigoEntrada'),
      montoPagado: _readDouble(data, 'montoPagado'),
      metodoPago: metodoPago,
    );
  }

  static Future<List<OwnedPass>> fetchAttendeePasses({
    required String attendeeId,
    required String projectionId,
    required List<SubscriptionType> subscriptionTypes,
  }) async {
    if (attendeeId.isEmpty || projectionId.isEmpty) return const [];
    final abonos = await _getList('/api/abonos-crud');
    final relations = await _getList('/api/relaciones/abono-proyecciones');
    final typeById = {
      for (final item in subscriptionTypes) item.id: item.name,
    };
    final allowedIds = relations
        .where((item) => _readString(item, 'idProyeccion') == projectionId)
        .map((item) => _readString(item, 'idAbono'))
        .where((id) => id.isNotEmpty)
        .toSet();

    final result = abonos
        .where((item) =>
            _readString(item, 'idAsistente') == attendeeId &&
            _readString(item, 'estadoAbono').toLowerCase() != 'anulado')
        .map((item) {
      final id = _readString(item, 'idAbono');
      final typeId = _readString(item, 'idTipoAbono');
      final code = _readString(item, 'codigoAbono').isEmpty
          ? id
          : _readString(item, 'codigoAbono');
      final typeName = typeById[typeId] ?? typeId;
      return OwnedPass(
        id,
        code,
        typeName.isEmpty ? 'Abono' : typeName,
        _readString(item, 'estadoAbono'),
        allowed: allowedIds.contains(id),
      );
    }).toList()
      ..sort((a, b) {
        if (a.allowed != b.allowed) return a.allowed ? -1 : 1;
        return a.label.compareTo(b.label);
      });
    return result;
  }

  static Future<PurchaseReceipt> venderAbono({
    required Attendee attendee,
    required SubscriptionType subscriptionType,
    required String tarifa,
    required String metodoPago,
    required String? nit,
  }) async {
    final data = await _postJson('/api/abonos/vender', {
      'idAsistente': attendee.id,
      'idTipoAbono': subscriptionType.id,
      'idTarifa': await _idTarifa(tarifa),
      'metodoPago': metodoPago,
      'nit': nit,
      'nombreCompra': attendee.displayName,
      'pagoAprobado': true,
    });
    return PurchaseReceipt(
      idCompra: _readString(data, 'idCompra'),
      idEntrada: '',
      idFactura: _readString(data, 'idFactura'),
      codigoEntrada: _readString(data, 'codigoAbono'),
      montoPagado: _readDouble(data, 'montoPagado'),
      metodoPago: metodoPago,
    );
  }

  static Future<PurchaseReceipt> venderEntradaEvento({
    required Attendee attendee,
    required FestivalEvent event,
    required String metodoPago,
    required String? nit,
  }) async {
    final entries = await _getList('/api/entradas-individuales');
    final sold = entries.where((item) => _readString(item, 'idEvento') == event.id).length;
    if (sold >= event.capacity) {
      throw const DatabaseException(
        'API_EVENTO_SIN_AFORO',
        'No hay aforo disponible para este evento.',
      );
    }
    final purchases = await _getList('/api/compras');
    final invoices = await _getList('/api/facturas');
    final idCompra = nextIdFromMapsMin(purchases, 'idCompra', 'CO', 700);
    final idEntrada = nextIdFromMapsMin(entries, 'idEntrada', 'EN', 700);
    final idFactura = nextIdFromMapsMin(invoices, 'idFactura', 'FA', 700);
    final codigoEntrada = 'EVT-$idEntrada';

    await _postJson('/api/compras', {
      'idCompra': idCompra,
      'fechaHoraCompra': DateTime.now().toIso8601String(),
      'metodoPago': metodoPago,
      'idEdicion': event.editionId,
    });

    await _postJson('/api/entradas-individuales', {
      'idEntrada': idEntrada,
      'codigoEntrada': codigoEntrada,
      'nroAsiento': null,
      'precioAplicado': event.cost,
      'idCompra': idCompra,
      'idProyeccion': null,
      'idEvento': event.id,
      'idAsistente': attendee.id,
      'idTarifa': await _idTarifa('General'),
    });

    await _postJson('/api/facturas', {
      'idFactura': idFactura,
      'nit': nit,
      'nombreFactura': attendee.name,
      'fechaEmision': DateTime.now().toIso8601String(),
      'monto': event.cost,
      'estadoFactura': 'Emitida',
      'idCompra': idCompra,
    });

    return PurchaseReceipt(
      idCompra: idCompra,
      idEntrada: idEntrada,
      idFactura: idFactura,
      codigoEntrada: codigoEntrada,
      montoPagado: event.cost,
      metodoPago: metodoPago,
    );
  }

  static Future<ResolvedAttendee> resolveAttendee(
    String editionId,
    AttendeeFormData form,
  ) async {
    final personas = await _getList('/api/personas');
    final asistentes = await _getList('/api/asistentes');
    final email = form.email.trim().toLowerCase();
    final phone = onlyDigits(form.phone);
    final formName = normalizeText('${form.firstName} ${form.lastName}');

    Map<String, dynamic>? person = form.idPersona.trim().isEmpty
        ? null
        : personas.firstWhere(
            (item) => _readString(item, 'idPersona') == form.idPersona.trim(),
            orElse: () => const <String, dynamic>{},
          );
    if (person != null && person.isEmpty) person = null;
    var bestScore = 0;
    if (person == null) {
      for (final item in personas) {
        final candidateEmail = _readString(item, 'correo').toLowerCase();
        final candidatePhone = onlyDigits(_readString(item, 'telefono'));
        final candidateName = normalizeText(
          '${_readString(item, 'nombre')} ${_readString(item, 'apellido')}',
        );

        var score = 0;
        if (formName.length >= 3) {
          if (candidateName == formName) score += 300;
          if (candidateName.contains(formName) || formName.contains(candidateName)) {
            score += 200;
          }
          if (fuzzyScore(candidateName, formName) >= 0.72) score += 120;
        }
        if (email.isNotEmpty && candidateEmail == email) score += 80;
        if (phone.isNotEmpty && candidatePhone == phone) score += 70;

        if (score > bestScore) {
          bestScore = score;
          person = item;
        }
      }
      if (bestScore == 0) person = null;
    }

    var created = false;
    if (person == null) {
      final personId = nextIdFromMaps(personas, 'idPersona', 'PE');
      person = await _postJson('/api/personas', {
        'idPersona': personId,
        'nombre': toTitleCase(form.firstName),
        'apellido': toTitleCase(form.lastName),
        'correo': email,
        'telefono': form.phone.trim().isEmpty ? null : form.phone.trim(),
      });
      created = true;
    }

    final personId = _readString(person, 'idPersona');
    Map<String, dynamic>? assistant;
    for (final item in asistentes) {
      if (_readString(item, 'idPersona') == personId &&
          _readString(item, 'idEdicion') == editionId) {
        assistant = item;
        break;
      }
    }

    if (assistant == null) {
      assistant = await _postJson('/api/asistentes', {
        'idAsistente': nextIdFromMaps(asistentes, 'idAsistente', 'AS'),
        'estadoAsistencia': 'Registrado',
        'fechaRegistro': DateTime.now().toIso8601String(),
        'idEdicion': editionId,
        'idPersona': personId,
      });
      created = true;
    }

    return ResolvedAttendee(
      created: created,
      attendee: attendeeFromPersonAndAssistant(person, assistant),
    );
  }

  static Future<JuryMember> createJuror(JuryDraft draft) async {
    final people = await _getList('/api/personas');
    final jurors = await _getList('/api/jurados');
    final email = draft.email.trim().toLowerCase();

    Map<String, dynamic>? person;
    for (final item in people) {
      final sameEmail = _readString(item, 'correo').toLowerCase() == email;
      final sameName = normalizeText(
            '${_readString(item, 'nombre')} ${_readString(item, 'apellido')}',
          ) ==
          normalizeText('${draft.firstName} ${draft.lastName}');
      if (sameEmail || sameName) {
        person = item;
        break;
      }
    }

    person ??= await _postJson('/api/personas', {
        'idPersona': nextIdFromMaps(people, 'idPersona', 'PE'),
        'nombre': toTitleCase(draft.firstName),
        'apellido': toTitleCase(draft.lastName),
        'correo': email,
        'telefono': emptyToNull(draft.phone),
      });

    final personId = _readString(person, 'idPersona');
    for (final item in jurors) {
      if (_readString(item, 'idPersona') == personId) {
        final fullName =
            '${_readString(person, 'nombre')} ${_readString(person, 'apellido')}'
                .trim();
        return JuryMember(
          _readString(item, 'idJurado'),
          fullName,
          _readString(item, 'tipoJurado').isEmpty
              ? _readString(item, 'especialidad')
              : _readString(item, 'tipoJurado'),
        );
      }
    }

    final juror = await _postJson('/api/jurados', {
      'idJurado': nextIdFromMaps(jurors, 'idJurado', 'JU'),
      'estadoAsistencia': draft.estadoAsistencia,
      'especialidad': emptyToNull(draft.especialidad),
      'tipoJurado': emptyToNull(draft.tipoJurado),
      'idPersona': personId,
    });

    final fullName =
        '${_readString(person, 'nombre')} ${_readString(person, 'apellido')}'
            .trim();
    return JuryMember(
      _readString(juror, 'idJurado'),
      fullName,
      _readString(juror, 'tipoJurado').isEmpty
          ? _readString(juror, 'especialidad')
          : _readString(juror, 'tipoJurado'),
    );
  }

  static Future<Movie> createMovieForEdition(MovieDraft draft) async {
    final movies = await _getList('/api/peliculas');
    final movieEditions = await _getList('/api/pelicula-ediciones');
    final genres = await _getList('/api/catalogos/generos');
    final movieGenres = await _getList('/api/relaciones/pelicula-generos');
    final people = await _getList('/api/personas');
    final staff = await _getList('/api/personal-cinematografico');
    final roles = await _getList('/api/roles-cinematograficos');
    final participations = await _getList('/api/participaciones-pelicula');

    final duplicate = movies.any(
      (item) => normalizeText(_readString(item, 'titulo')) ==
          normalizeText(draft.title),
    );
    if (duplicate) {
      throw DatabaseException(
        'API_PELICULA_DUPLICADA',
        'Ya existe una pelicula registrada con el titulo "${draft.title}".',
      );
    }

    final movieId = nextIdFromMaps(movies, 'idPelicula', 'PL');
    final movieEditionId =
        nextIdFromMaps(movieEditions, 'idPeliculaEdicion', 'PX');

    await _postJson('/api/peliculas', {
      'idPelicula': movieId,
      'titulo': draft.title,
      'anioProduccion': draft.productionYear,
      'duracion': draft.duration,
      'paisOrigen': draft.country,
      'sinopsis': emptyToNull(draft.synopsis),
      'clasEdad': emptyToNull(draft.rating),
      'formatoProyeccion': draft.format,
    });

    await _postJson('/api/pelicula-ediciones', {
      'idPeliculaEdicion': movieEditionId,
      'idPelicula': movieId,
      'idEdicion': draft.editionId,
      'estadoFestival': 'Postulada',
    });

    final resolvedGenres = <GenreOption>[];
    var nextGenreNumber = nextIdNumber(genres, 'idGenero', 'GE');
    for (final genre in draft.genres) {
      var genreId = genre.isLocal ? '' : genre.id;
      final existing = genres.firstWhere(
        (item) => normalizeText(_readString(item, 'nombreGenero')) ==
            normalizeText(genre.name),
        orElse: () => const <String, dynamic>{},
      );
      if (existing.isNotEmpty) genreId = _readString(existing, 'idGenero');
      if (genreId.isEmpty) {
        genreId = 'GE${nextGenreNumber.toString().padLeft(3, '0')}';
        nextGenreNumber += 1;
        await _postJson('/api/generos', {
          'idGenero': genreId,
          'nombreGenero': toTitleCase(genre.name),
        });
      }
      final alreadyLinked = movieGenres.any(
        (item) =>
            _readString(item, 'idPelicula') == movieId &&
            _readString(item, 'idGenero') == genreId,
      );
      if (!alreadyLinked) {
        await _postJson('/api/relaciones/pelicula-generos', {
          'idPelicula': movieId,
          'idGenero': genreId,
        });
      }
      resolvedGenres.add(GenreOption(genreId, toTitleCase(genre.name)));
    }

    final directorId = await _resolveDirectorId(draft.director, people, staff);
    final directorRoleId = await _resolveDirectorRoleId(roles);
    if (directorId.isNotEmpty) {
      final alreadyParticipates = participations.any(
        (item) =>
            _readString(item, 'idPersonal') == directorId &&
            _readString(item, 'idPelicula') == movieId &&
            _readString(item, 'idRol') == directorRoleId,
      );
      if (!alreadyParticipates) {
        await _postJson('/api/participaciones-pelicula', {
          'idPersonal': directorId,
          'idPelicula': movieId,
          'idRol': directorRoleId,
        });
      }
    }

    return Movie(
      draft.title,
      resolvedGenres.map((item) => item.name).join(', '),
      draft.duration,
      draft.rating,
      draft.country,
      draft.synopsis,
      draft.posterUrl,
      const [Session('Proximamente', '20:00', 'Sala A', true, [])],
      idPelicula: movieId,
      idPeliculaEdicion: movieEditionId,
      director: draft.director.name,
      format: draft.format,
    );
  }

  static Future<String> _resolveDirectorId(
    DirectorOption director,
    List<Map<String, dynamic>> people,
    List<Map<String, dynamic>> staff,
  ) async {
    if (!director.isLocal &&
        staff.any((item) => _readString(item, 'idPersonal') == director.id)) {
      return director.id;
    }
    if (director.name.isEmpty || director.name == 'Sin director registrado') {
      return '';
    }

    final parts = splitFullName(director.name);
    final directorName = normalizeText('${parts.$1} ${parts.$2}');
    final directorPhone = onlyDigits(director.phone);
    final peopleById = {
      for (final item in people) _readString(item, 'idPersona'): item,
    };

    for (final item in staff) {
      final person =
          peopleById[_readString(item, 'idPersona')] ?? const <String, dynamic>{};
      final fullName =
          '${_readString(person, 'nombre')} ${_readString(person, 'apellido')}'
              .trim();
      final sameName = normalizeText(fullName) == directorName;
      final samePhone = directorPhone.isNotEmpty &&
          onlyDigits(_readString(person, 'telefono')) == directorPhone;
      if (sameName || samePhone) {
        return _readString(item, 'idPersonal');
      }
    }

    Map<String, dynamic>? person;
    var bestScore = 0;
    for (final item in people) {
      final candidateName = normalizeText(
        '${_readString(item, 'nombre')} ${_readString(item, 'apellido')}',
      );
      final candidatePhone = onlyDigits(_readString(item, 'telefono'));

      var score = 0;
      if (directorName.length >= 3) {
        if (candidateName == directorName) score += 300;
        if (candidateName.contains(directorName) ||
            directorName.contains(candidateName)) {
          score += 200;
        }
        if (fuzzyScore(candidateName, directorName) >= 0.72) score += 120;
      }
      if (directorPhone.isNotEmpty && candidatePhone == directorPhone) {
        score += 90;
      }

      if (score > bestScore) {
        bestScore = score;
        person = item;
      }
    }
    if (bestScore == 0) person = null;

    person ??= await _postJson('/api/personas', {
      'idPersona': nextIdFromMaps(people, 'idPersona', 'PE'),
      'nombre': parts.$1,
      'apellido': parts.$2,
      'correo': '${normalizeText(director.name).replaceAll(' ', '.')}@festcine.local',
      'telefono': emptyToNull(director.phone),
    });

    final personId = _readString(person, 'idPersona');
    for (final item in staff) {
      if (_readString(item, 'idPersona') == personId) {
        return _readString(item, 'idPersonal');
      }
    }

    final staffId = nextIdFromMaps(staff, 'idPersonal', 'PC');
    await _postJson('/api/personal-cinematografico', {
      'idPersonal': staffId,
      'biografia': emptyToNull(director.biography) ??
          'Director registrado desde Gestion de Peliculas.',
      'pais': emptyToNull(director.country),
      'idPersona': personId,
    });
    return staffId;
  }

  static Future<String> _resolveDirectorRoleId(
    List<Map<String, dynamic>> roles,
  ) async {
    for (final role in roles) {
      if (normalizeText(_readString(role, 'nombreRol')) == 'director') {
        return _readString(role, 'idRol');
      }
    }
    final roleId = nextIdFromMaps(roles, 'idRol', 'RC');
    await _postJson('/api/roles-cinematograficos', {
      'idRol': roleId,
      'nombreRol': 'Director',
    });
    return roleId;
  }

  static Future<void> insertProjection({
    required ScreeningPlan projection,
    required List<ScreeningPlan> existing,
  }) async {
    if (projection.idSala.isEmpty || projection.idPeliculaEdicion.isEmpty) {
      throw const DatabaseException(
        'API_PROYECCION_SIN_IDS',
        'La sala o la pelicula no tienen IDs del backend. Recarga los catalogos e intenta nuevamente.',
      );
    }

    await _postJson('/api/agenda/proyecciones', {
      'idProyeccion': projection.idProyeccion,
      'fechaHoraInicio': '${projection.day}T${projection.time}:00',
      'tieneQA': projection.qa,
      'idSala': projection.idSala,
      'idPeliculaEdicion': projection.idPeliculaEdicion,
    });
  }

  static Future<FestivalEvent> createFestivalEvent(EventDraft draft) async {
    final events = await _getList('/api/eventos-paralelos');
    final eventId = nextIdFromMaps(events, 'idEvento', 'EV');
    final dateTime = DateTime.tryParse('${draft.date}T${draft.time}:00');
    if (dateTime == null) {
      throw const DatabaseException(
        'EVENTO_FECHA_INVALIDA',
        'La fecha u hora del evento no tiene un formato valido.',
      );
    }
    await _postJson('/api/agenda/eventos', {
      'idEvento': eventId,
      'nombreEvento': draft.name,
      'tipoEvento': draft.type,
      'descripcion': draft.description,
      'aforo': draft.capacity,
      'costo': draft.cost,
      'fechaHoraInicio': dateTime.toIso8601String(),
      'duracionMinutos': draft.durationMinutes,
      'idEdicion': draft.editionId,
      'idSala': draft.room.id,
    });
    return FestivalEvent(
      id: eventId,
      name: draft.name,
      type: draft.type,
      description: draft.description,
      capacity: draft.capacity,
      cost: draft.cost,
      start: dateTime,
      durationMinutes: draft.durationMinutes,
      editionId: draft.editionId,
      roomId: draft.room.id,
      room: draft.room.name,
    );
  }

  static Future<String> createFestivalEdition(FestivalEditionDraft draft) async {
    final editions = await _getList('/api/ediciones');
    final movieEditions = await _getList('/api/pelicula-ediciones');
    final categories = await _getList('/api/categorias-competicion');
    final sponsors = await _getList('/api/patrocinadores');
    final sponsorships = await _getList('/api/patrocinios');

    final editionId = nextIdFromMaps(editions, 'idEdicion', 'ED');
    await _postJson('/api/ediciones', {
      'idEdicion': editionId,
      'nombreEdicion': draft.name,
      'fechaInicio': draft.startDate,
      'fechaFin': draft.endDate,
      'estadoEdicion': draft.status,
    });

    await _postJson('/api/sede-ediciones', {
      'idSede': draft.venueId,
      'idEdicion': editionId,
    });

    final sponsorDraft = draft.sponsor;
    if (sponsorDraft != null) {
      var sponsorId = sponsorDraft.existingSponsorId ?? '';
      if (sponsorId.isEmpty) {
        sponsorId = nextIdFromMaps(sponsors, 'idPatrocinador', 'PA');
        await _postJson('/api/patrocinadores', {
          'idPatrocinador': sponsorId,
          'nombrePatrocinador': sponsorDraft.newSponsorName,
          'telefono': emptyToNull(sponsorDraft.newSponsorPhone),
          'correo': emptyToNull(sponsorDraft.newSponsorEmail),
        });
      }
      await _postJson('/api/patrocinios', {
        'idPatrocinio': nextIdFromMaps(sponsorships, 'idPatrocinio', 'PT'),
        'idPatrocinador': sponsorId,
        'idEdicion': editionId,
        'tipoAportacion': sponsorDraft.contributionType,
        'monto': sponsorDraft.amount,
        'descripcionAportacion': emptyToNull(sponsorDraft.description),
      });
    }

    var movieEditionIndex = nextIdNumber(movieEditions, 'idPeliculaEdicion', 'PX');
    for (final movieId in draft.movieIds) {
      await _postJson('/api/pelicula-ediciones', {
        'idPeliculaEdicion': 'PX${movieEditionIndex.toString().padLeft(3, '0')}',
        'idPelicula': movieId,
        'idEdicion': editionId,
        'estadoFestival': 'Postulada',
      });
      movieEditionIndex += 1;
    }

    var categoryIndex = nextIdNumber(categories, 'idCategoria', 'CC');
    for (final category in draft.categories) {
      final categoryId = 'CC${categoryIndex.toString().padLeft(3, '0')}';
      await _postJson('/api/categorias-competicion', {
        'idCategoria': categoryId,
        'nombreCategoria': category.name,
        'descripcion': emptyToNull(category.description) ??
            'Categoria agregada desde el panel de ediciones.',
        'idEdicion': editionId,
      });
      for (final jurorId in draft.jurorIds) {
        await _postJson('/api/relaciones/categoria-jurados', {
          'idCategoria': categoryId,
          'idJurado': jurorId,
        });
      }
      categoryIndex += 1;
    }

    return editionId;
  }

  static Future<ActiveAccreditation?> fetchAttendeeAccreditation({
    required String attendeeId,
    required List<AccreditationType> types,
  }) async {
    if (attendeeId.isEmpty) return null;
    final accreditations = await _getList('/api/acreditaciones');
    final typeById = {for (final item in types) item.id: item.name};
    Map<String, dynamic>? selected;
    for (final item in accreditations) {
      if (_readString(item, 'idAsistente') != attendeeId) continue;
      selected ??= item;
      if (_readString(item, 'estadoAcreditacion').toLowerCase() == 'activa') {
        selected = item;
        break;
      }
    }
    if (selected == null) return null;
    return activeAccreditationFromJson(selected, typeById);
  }

  static Future<ActiveAccreditation> ensureAccreditation({
    required Attendee attendee,
    required AccreditationType selectedType,
  }) async {
    final accreditations = await _getList('/api/acreditaciones');
    final typeById = {selectedType.id: selectedType.name};
    Map<String, dynamic>? existing;
    for (final item in accreditations) {
      if (_readString(item, 'idAsistente') == attendee.id) {
        existing = item;
        break;
      }
    }

    final now = DateTime.now().toIso8601String();
    if (existing == null) {
      final created = await _postJson('/api/acreditaciones', {
        'idAcreditacion': nextIdFromMaps(
          accreditations,
          'idAcreditacion',
          'AC',
        ),
        'idAsistente': attendee.id,
        'idTipoAcreditacion': selectedType.id,
        'fechaEmision': now,
        'estadoAcreditacion': 'Activa',
      });
      return activeAccreditationFromJson(created, typeById);
    }

    final id = _readString(existing, 'idAcreditacion');
    final payload = <String, dynamic>{
      'idAcreditacion': id,
      'idAsistente': attendee.id,
      'idTipoAcreditacion': selectedType.id,
      'fechaEmision': _readString(existing, 'fechaEmision').isEmpty
          ? now
          : _readString(existing, 'fechaEmision'),
      'estadoAcreditacion': 'Activa',
    };
    final updated = await _putJson('/api/acreditaciones/$id', payload);
    return activeAccreditationFromJson(
      updated.isEmpty ? payload : updated,
      typeById,
    );
  }

  static Future<String> _idTarifa(String tipoTarifa) async {
    if (_tarifaIds.isEmpty) {
      final tarifas = await _getList('/api/catalogos/tarifas');
      _tarifaIds = {
        for (final item in tarifas)
          _readString(item, 'tipoTarifa'): _readString(item, 'idTarifa'),
      };
    }
    final id = _tarifaIds[tipoTarifa];
    if (id == null || id.isEmpty) {
      throw DatabaseException(
        'API_TARIFA_NO_ENCONTRADA',
        'No se encontro la tarifa "$tipoTarifa" en el backend.',
      );
    }
    return id;
  }

  static Future<Map<String, dynamic>> _getMap(String path) async {
    try {
      final response = await _client.get(_uri(path)).timeout(apiTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DatabaseException(
          'HTTP_${response.statusCode}',
          _friendlyMessage(response),
        );
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) return decoded;
      throw const DatabaseException(
        'API_RESPUESTA_INVALIDA',
        'El backend devolvio datos con formato inesperado.',
      );
    } on DatabaseException {
      rethrow;
    } catch (_) {
      throw const DatabaseException(
        'API_NO_DISPONIBLE',
        'Verifica que el backend este ejecutandose en http://localhost:5075.',
      );
    }
  }

  static Future<List<Map<String, dynamic>>> _getList(String path) async {
    try {
      final response = await _client.get(_uri(path)).timeout(apiTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DatabaseException(
          'HTTP_${response.statusCode}',
          _friendlyMessage(response),
        );
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      throw const DatabaseException(
        'API_RESPUESTA_INVALIDA',
        'El backend devolvio un catalogo con formato inesperado.',
      );
    } on DatabaseException {
      rethrow;
    } catch (_) {
      throw const DatabaseException(
        'API_NO_DISPONIBLE',
        'Verifica que el backend este ejecutandose en http://localhost:5075.',
      );
    }
  }

  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, Object?> payload,
  ) async {
    try {
      final response = await _client
          .post(
            _uri(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(apiTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DatabaseException(
          'HTTP_${response.statusCode}',
          _friendlyMessage(response),
        );
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) return decoded;
      return const <String, dynamic>{};
    } on DatabaseException {
      rethrow;
    } catch (_) {
      throw const DatabaseException(
        'API_NO_DISPONIBLE',
        'No se pudo conectar con el backend. Confirma que dotnet run este activo en http://localhost:5075.',
      );
    }
  }

  static Future<Map<String, dynamic>> _putJson(
    String path,
    Map<String, Object?> payload,
  ) async {
    try {
      final response = await _client
          .put(
            _uri(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(apiTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DatabaseException(
          'HTTP_${response.statusCode}',
          _friendlyMessage(response),
        );
      }
      final body = utf8.decode(response.bodyBytes).trim();
      if (body.isEmpty) return const <String, dynamic>{};
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return const <String, dynamic>{};
    } on DatabaseException {
      rethrow;
    } catch (_) {
      throw const DatabaseException(
        'API_NO_DISPONIBLE',
        'No se pudo conectar con el backend. Confirma que dotnet run este activo en http://localhost:5075.',
      );
    }
  }

  static Uri _uri(String path) => Uri.parse('$apiBaseUrl$path');

  static String _friendlyMessage(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        final message = decoded['mensaje'] ?? decoded['message'] ?? decoded['error'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {
      // Fall back to the raw body below.
    }
    final body = utf8.decode(response.bodyBytes).trim();
    return body.isEmpty
        ? 'El backend rechazo la operacion.'
        : body;
  }
}

const apiTimeout = Duration(seconds: 8);

String _readString(Map<String, dynamic> item, String key) {
  final value = item[key] ?? item[_pascalCase(key)];
  return value?.toString() ?? '';
}

int _readInt(Map<String, dynamic> item, String key) {
  final value = item[key] ?? item[_pascalCase(key)];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

List<int> _readIntList(Map<String, dynamic> item, String key) {
  final value = item[key] ?? item[_pascalCase(key)];
  if (value is List) {
    return value
        .map((item) => item is int ? item : int.tryParse(item.toString()) ?? 0)
        .where((item) => item > 0)
        .toList();
  }
  return const [];
}

double _readDouble(Map<String, dynamic> item, String key) {
  final value = item[key] ?? item[_pascalCase(key)];
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _readBool(Map<String, dynamic> item, String key) {
  final value = item[key] ?? item[_pascalCase(key)];
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

DateTime _readDate(Map<String, dynamic> item, String key) {
  final raw = _readString(item, key);
  return DateTime.tryParse(raw) ?? DateTime.now();
}

DashboardMetrics dashboardFromJson(Map<String, dynamic> item) {
  return DashboardMetrics(
    peliculas: _readInt(item, 'peliculas'),
    proyecciones: _readInt(item, 'proyecciones'),
    asistentes: _readInt(item, 'asistentes'),
    entradasVendidas: _readInt(item, 'entradasVendidas'),
    abonosVendidos: _readInt(item, 'abonosVendidos'),
    totalRecaudado: _readDouble(item, 'totalRecaudado'),
  );
}

RankingItem rankingFromJson(Map<String, dynamic> item) {
  return RankingItem(
    idPelicula: _readString(item, 'idPelicula'),
    titulo: _readString(item, 'titulo'),
    cantidadProyecciones: _readInt(item, 'cantidadProyecciones'),
    capacidadTotal: _readInt(item, 'capacidadTotal'),
    asistentesReales: _readInt(item, 'asistentesReales'),
    porcentajeOcupacion: _readDouble(item, 'porcentajeOcupacion'),
  );
}

AwardItem awardFromJson(Map<String, dynamic> item) {
  return AwardItem(
    nombreCategoria: _readString(item, 'nombreCategoria'),
    nombrePremio: _readString(item, 'nombrePremio'),
    titulo: _readString(item, 'titulo'),
    cantidadEvaluaciones: _readInt(item, 'cantidadEvaluaciones'),
    promedioVotacion: _readDouble(item, 'promedioVotacion'),
  );
}

FinanceItem financeFromJson(Map<String, dynamic> item) {
  return FinanceItem(
    tipoVenta: _readString(item, 'tipoVenta'),
    subtipoVenta: _readString(item, 'subtipoVenta'),
    tipoTarifa: _readString(item, 'tipoTarifa'),
    cantidadVentas: _readInt(item, 'cantidadVentas'),
    totalRecaudado: _readDouble(item, 'totalRecaudado'),
  );
}

SponsorOption sponsorFromJson(Map<String, dynamic> item) {
  return SponsorOption(
    _readString(item, 'idPatrocinador'),
    _readString(item, 'nombrePatrocinador'),
    _readString(item, 'telefono'),
    _readString(item, 'correo'),
  );
}

CategoryOption categoryOptionFromJson(Map<String, dynamic> item) {
  return CategoryOption(
    _readString(item, 'idCategoria'),
    _readString(item, 'nombreCategoria'),
    description: _readString(item, 'descripcion'),
    editionId: _readString(item, 'idEdicion'),
  );
}

SubscriptionType subscriptionTypeFromJson(Map<String, dynamic> item) {
  return SubscriptionType(
    _readString(item, 'idTipoAbono'),
    _readString(item, 'nombreTipoAbono'),
    _readString(item, 'descripcion'),
    _readDouble(item, 'precioBase'),
  );
}

AccreditationType accreditationTypeFromJson(Map<String, dynamic> item) {
  return AccreditationType(
    _readString(item, 'idTipoAcreditacion'),
    _readString(item, 'nombreTipo'),
  );
}

ActiveAccreditation activeAccreditationFromJson(
  Map<String, dynamic> item,
  Map<String, String> typeById,
) {
  final typeId = _readString(item, 'idTipoAcreditacion');
  return ActiveAccreditation(
    _readString(item, 'idAcreditacion'),
    _readString(item, 'idAsistente'),
    typeId,
    typeById[typeId] ?? typeId,
    _readString(item, 'estadoAcreditacion'),
  );
}

FestivalEdition editionFromJson(Map<String, dynamic> item) {
  return FestivalEdition(
    _readString(item, 'idEdicion'),
    _readString(item, 'nombreEdicion'),
    formatApiDay(_readDate(item, 'fechaInicio')),
    formatApiDay(_readDate(item, 'fechaFin')),
    _readString(item, 'estadoEdicion'),
  );
}

String friendlyError(Object? error) {
  if (error is DatabaseException) return error.friendlyMessage;
  final message = error?.toString() ?? '';
  return message.isEmpty
      ? 'No se pudo cargar la informacion solicitada.'
      : message;
}

String _pascalCase(String key) {
  if (key.isEmpty) return key;
  return key[0].toUpperCase() + key.substring(1);
}

Map<String, String> directorsFromParticipation(
  List<Map<String, dynamic>> participationData,
  Map<String, Map<String, dynamic>> staffById,
  Map<String, Map<String, dynamic>> roleById,
  Map<String, Map<String, dynamic>> peopleById,
) {
  final result = <String, String>{};
  for (final item in participationData) {
    final role = roleById[_readString(item, 'idRol')] ?? const <String, dynamic>{};
    final roleName = normalizeText(
      '${_readString(role, 'nombreRol')} ${_readString(role, 'nombre')} ${_readString(role, 'descripcion')}',
    );
    if (!roleName.contains('director') && !roleName.contains('direccion')) {
      continue;
    }
    final staff =
        staffById[_readString(item, 'idPersonal')] ?? const <String, dynamic>{};
    final person =
        peopleById[_readString(staff, 'idPersona')] ?? const <String, dynamic>{};
    final name =
        '${_readString(person, 'nombre')} ${_readString(person, 'apellido')}'
            .trim();
    if (name.isEmpty) continue;
    result[_readString(item, 'idPelicula')] = name;
  }
  return result;
}

List<DirectorOption> directorsFromStaff(
  List<Map<String, dynamic>> participationData,
  Map<String, Map<String, dynamic>> staffById,
  Map<String, Map<String, dynamic>> roleById,
  Map<String, Map<String, dynamic>> peopleById,
) {
  final directorStaffIds = <String>{};
  for (final item in participationData) {
    final role = roleById[_readString(item, 'idRol')] ?? const <String, dynamic>{};
    final roleName = normalizeText(_readString(role, 'nombreRol'));
    if (roleName == 'director' || roleName.contains('direccion')) {
      directorStaffIds.add(_readString(item, 'idPersonal'));
    }
  }
  final result = <DirectorOption>[];
  for (final entry in staffById.entries) {
    if (directorStaffIds.isNotEmpty && !directorStaffIds.contains(entry.key)) {
      continue;
    }
    final person =
        peopleById[_readString(entry.value, 'idPersona')] ?? const <String, dynamic>{};
    final name =
        '${_readString(person, 'nombre')} ${_readString(person, 'apellido')}'
            .trim();
    if (name.isEmpty) continue;
    result.add(
      DirectorOption(
        entry.key,
        name,
        country: _readString(entry.value, 'pais'),
        biography: _readString(entry.value, 'biografia'),
        phone: _readString(person, 'telefono'),
      ),
    );
  }
  return mergeDirectorOptions(result, fallbackDirectorOptions);
}

Map<String, String> genresFromRelations(
  List<Map<String, dynamic>> relations,
  Map<String, Map<String, dynamic>> genresById,
) {
  final grouped = <String, List<String>>{};
  for (final relation in relations) {
    final movieId = _readString(relation, 'idPelicula');
    final genre =
        genresById[_readString(relation, 'idGenero')] ?? const <String, dynamic>{};
    final name = _readString(genre, 'nombreGenero');
    if (movieId.isEmpty || name.isEmpty) continue;
    grouped.putIfAbsent(movieId, () => []).add(name);
  }
  return {
    for (final entry in grouped.entries) entry.key: entry.value.join(', '),
  };
}

String formatApiDay(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String formatApiTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _estadoToGenre(String estado) {
  return estado.isEmpty ? 'Catalogo' : estado;
}

int seatLabelToNumber(String seat) {
  final row = seat.isEmpty ? 'A' : seat[0].toUpperCase();
  final number = int.tryParse(seat.substring(1)) ?? 1;
  final rowIndex = row.codeUnitAt(0) - 'A'.codeUnitAt(0);
  return rowIndex * 12 + number;
}

String seatNumberToLabel(int number) {
  final zeroBased = number - 1;
  final row = String.fromCharCode('A'.codeUnitAt(0) + (zeroBased ~/ 12));
  final column = (zeroBased % 12) + 1;
  return '$row$column';
}

String nextProjectionId(List<ScreeningPlan> schedule) {
  final maxId = schedule
      .map((item) => RegExp(r'^PR(\d{3})$').firstMatch(item.idProyeccion))
      .whereType<RegExpMatch>()
      .map((match) => int.tryParse(match.group(1) ?? '') ?? 0)
      .fold<int>(10, (max, value) => value > max ? value : max);
  final next = (maxId + 1).clamp(1, 999);
  return 'PR${next.toString().padLeft(3, '0')}';
}

String idSalaForRoom(
  String room,
  List<ScreeningPlan> schedule, [
  List<RoomOption> roomCatalog = const [],
]) {
  for (final item in roomCatalog) {
    if ((item.name == room || item.label == room) && item.id.isNotEmpty) {
      return item.id;
    }
  }
  for (final item in schedule) {
    if (item.room == room && item.idSala.isNotEmpty) return item.idSala;
  }
  return fallbackRoomIds[room] ?? '';
}

String idPeliculaEdicionForMovie(
  String movie,
  List<ScreeningPlan> schedule, [
  List<Movie> movies = const [],
]) {
  for (final item in movies) {
    if (item.title == movie && item.idPeliculaEdicion.isNotEmpty) {
      return item.idPeliculaEdicion;
    }
  }
  for (final item in schedule) {
    if (item.movie == movie && item.idPeliculaEdicion.isNotEmpty) {
      return item.idPeliculaEdicion;
    }
  }
  return fallbackMovieEditionIds[movie] ?? '';
}

Attendee attendeeFromJson(Map<String, dynamic> item) {
  final fullNameFromApi = _readString(item, 'nombreCompleto');
  final rawFirstName = _readString(item, 'nombre');
  final rawLastName = _readString(item, 'apellido');
  final cleanFullName = fullNameFromApi.isEmpty
      ? '$rawFirstName $rawLastName'.trim()
      : fullNameFromApi.trim();
  final parts = cleanFullName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  final firstName = rawFirstName.isEmpty && parts.isNotEmpty
      ? parts.first
      : rawFirstName;
  final lastName = rawLastName.isEmpty && parts.length > 1
      ? parts.skip(1).join(' ')
      : rawLastName;
  final displayName = cleanFullName.isEmpty
      ? _readString(item, 'idAsistente')
      : cleanFullName;
  return Attendee(
    _readString(item, 'idAsistente'),
    displayName,
    _readString(item, 'correo'),
    idPersona: _readString(item, 'idPersona'),
    firstName: firstName,
    lastName: lastName,
    phone: _readString(item, 'telefono'),
  );
}

PersonOption personOptionFromJson(Map<String, dynamic> item) {
  return PersonOption(
    id: _readString(item, 'idPersona'),
    firstName: _readString(item, 'nombre'),
    lastName: _readString(item, 'apellido'),
    email: _readString(item, 'correo'),
    phone: _readString(item, 'telefono'),
  );
}


Attendee attendeeFromPersonAndAssistant(
  Map<String, dynamic> person,
  Map<String, dynamic> assistant,
) {
  final firstName = _readString(person, 'nombre');
  final lastName = _readString(person, 'apellido');
  final fullName = '$firstName $lastName'.trim();
  return Attendee(
    _readString(assistant, 'idAsistente'),
    fullName.isEmpty ? _readString(assistant, 'idAsistente') : fullName,
    _readString(person, 'correo'),
    idPersona: _readString(person, 'idPersona'),
    firstName: firstName,
    lastName: lastName,
    phone: _readString(person, 'telefono'),
  );
}

Map<String, List<String>> occupiedSeatsFromEntries(
  List<Map<String, dynamic>> entries,
) {
  final result = <String, List<String>>{};
  for (final entry in entries) {
    final projectionId = _readString(entry, 'idProyeccion');
    final seat = _readInt(entry, 'nroAsiento');
    if (projectionId.isEmpty || seat <= 0) continue;
    result.putIfAbsent(projectionId, () => []).add(seatNumberToLabel(seat));
  }
  return result;
}

FestivalEvent festivalEventFromJson(
  Map<String, dynamic> item,
  Map<String, int> entriesByEvent,
  String fallbackEditionId,
) {
  final eventId = _readString(item, 'idEvento');
  final start = _readDate(item, 'fechaHoraInicio');
  return FestivalEvent(
    id: eventId,
    name: _readString(item, 'nombreEvento'),
    type: _readString(item, 'tipoEvento'),
    description: _readString(item, 'descripcion'),
    capacity: _readInt(item, 'aforo'),
    cost: _readDouble(item, 'costo'),
    start: start,
    durationMinutes: _readInt(item, 'duracionMinutos'),
    editionId: _readString(item, 'idEdicion').isEmpty
        ? fallbackEditionId
        : _readString(item, 'idEdicion'),
    roomId: _readString(item, 'idSala'),
    room: _readString(item, 'nombreSala').isEmpty
        ? _readString(item, 'idSala')
        : _readString(item, 'nombreSala'),
    sold: entriesByEvent[eventId] ?? 0,
  );
}

Map<String, int> entriesSoldByEvent(List<Map<String, dynamic>> entries) {
  final result = <String, int>{};
  for (final entry in entries) {
    final eventId = _readString(entry, 'idEvento');
    if (eventId.isEmpty) continue;
    result[eventId] = (result[eventId] ?? 0) + 1;
  }
  return result;
}

int nextIdNumber(List<Map<String, dynamic>> items, String key, String prefix) {
  final max = items
      .map((item) => _readString(item, key))
      .where((id) => id.startsWith(prefix))
      .map((id) => int.tryParse(id.substring(prefix.length)) ?? 0)
      .fold<int>(0, (max, value) => value > max ? value : max);
  return max + 1;
}

String nextIdFromMaps(List<Map<String, dynamic>> items, String key, String prefix) {
  final next = nextIdNumber(items, key, prefix);
  return '$prefix${next.toString().padLeft(3, '0')}';
}

String nextIdFromMapsMin(
  List<Map<String, dynamic>> items,
  String key,
  String prefix,
  int minNumber,
) {
  final next = nextIdNumber(items, key, prefix);
  final value = next < minNumber ? minNumber : next;
  return '$prefix${value.toString().padLeft(3, '0')}';
}

DateTime? _parseEditionDate(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return null;
  return DateTime.tryParse(clean);
}

bool _editionAllowsEventCreation(FestivalEdition edition) {
  return _editionBlockReason(edition) == null;
}

String? _editionBlockReason(FestivalEdition edition) {
  final status = normalizeText(edition.status);
  if (status == 'finalizada' || status == 'cancelada') {
    return 'No se pueden crear eventos para una edicion ${edition.status.toLowerCase()}.';
  }

  final endDate = _parseEditionDate(edition.endDate);
  if (endDate != null) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final editionEnd = DateTime(endDate.year, endDate.month, endDate.day);
    if (editionEnd.isBefore(today)) {
      return 'No se pueden crear eventos para una edicion pasada.';
    }
  }

  return null;
}

String? _eventDateBlockReason(FestivalEdition edition, DateTime eventDateTime) {
  final startDate = _parseEditionDate(edition.startDate);
  final endDate = _parseEditionDate(edition.endDate);
  final eventDay = DateTime(eventDateTime.year, eventDateTime.month, eventDateTime.day);

  if (startDate != null) {
    final startDay = DateTime(startDate.year, startDate.month, startDate.day);
    if (eventDay.isBefore(startDay)) {
      return 'La fecha del evento debe estar dentro del rango de la edicion.';
    }
  }

  if (endDate != null) {
    final endDay = DateTime(endDate.year, endDate.month, endDate.day);
    if (eventDay.isAfter(endDay)) {
      return 'La fecha del evento debe estar dentro del rango de la edicion.';
    }
  }

  return null;
}

String normalizeText(String value) {
  const replacements = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ñ': 'n',
  };
  var result = value.toLowerCase().trim();
  replacements.forEach((from, to) => result = result.replaceAll(from, to));
  return result.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).join(' ');
}

String onlyDigits(String value) => value.replaceAll(RegExp(r'\D'), '');

String? emptyToNull(String? value) {
  final clean = value?.trim() ?? '';
  return clean.isEmpty ? null : clean;
}

String toTitleCase(String value) {
  return value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) {
        final lower = part.toLowerCase();
        return lower[0].toUpperCase() + lower.substring(1);
      })
      .join(' ');
}

String newLocalId(String prefix) =>
    'NEW_${prefix}_${DateTime.now().microsecondsSinceEpoch}';

(String, String) splitFullName(String value) {
  final parts = toTitleCase(value).split(RegExp(r'\s+'));
  if (parts.isEmpty) return ('Director', 'Registrado');
  if (parts.length == 1) return (parts.first, 'Registrado');
  return (parts.first, parts.skip(1).join(' '));
}

List<CategoryOption> mergeCategoryOptions(
  List<CategoryOption> base,
  List<CategoryOption> incoming,
) {
  final byName = <String, CategoryOption>{};
  for (final item in [...base, ...incoming]) {
    if (item.name.trim().isEmpty) continue;
    byName.putIfAbsent(normalizeText(item.name), () => item);
  }
  return byName.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}

List<GenreOption> mergeGenreOptions(
  List<GenreOption> base,
  List<GenreOption> incoming,
) {
  final byName = <String, GenreOption>{};
  for (final item in [...base, ...incoming]) {
    if (item.name.trim().isEmpty) continue;
    byName.putIfAbsent(normalizeText(item.name), () => item);
  }
  return byName.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}

List<DirectorOption> mergeDirectorOptions(
  List<DirectorOption> base,
  List<DirectorOption> incoming,
) {
  final byName = <String, DirectorOption>{};
  for (final item in [...base, ...incoming]) {
    if (item.name.trim().isEmpty) continue;
    byName.putIfAbsent(normalizeText(item.name), () => item);
  }
  return byName.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}

List<AccreditationType> mergeAccreditationTypes(
  List<AccreditationType> base,
  List<AccreditationType> incoming,
) {
  final byName = <String, AccreditationType>{};
  for (final item in [...base, ...incoming]) {
    if (item.name.trim().isEmpty) continue;
    byName.putIfAbsent(normalizeText(item.name), () => item);
  }
  return byName.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}

List<JuryMember> mergeJuryMembers(
  List<JuryMember> base,
  List<JuryMember> incoming,
) {
  final byId = <String, JuryMember>{};
  for (final item in [...base, ...incoming]) {
    if (item.id.trim().isEmpty) continue;
    byId[item.id] = item;
  }
  return byId.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}

double fuzzyScore(String a, String b) {
  if (a.isEmpty || b.isEmpty) return 0;
  final aTokens = a.split(' ').toSet();
  final bTokens = b.split(' ').toSet();
  final intersection = aTokens.intersection(bTokens).length;
  final union = aTokens.union(bTokens).length;
  return union == 0 ? 0 : intersection / union;
}

Color roomColor(String room) => switch (room) {
  'Sala Principal' => gold,
  'Sala Norte' => purple,
  'Auditorio Oriente' => green,
  'Sala Experimental' => blue,
  'Sala Historica' => red,
  'Sala A' => gold,
  'Sala B' => purple,
  'Sala C' => green,
  'Sala D' => blue,
  'Sala VIP' => red,
  _ => const Color(0xffe08c4f),
};

Color paletteFor(String seed) {
  const palette = [gold, slate, green, line, burgundy];
  final index = seed.codeUnits.fold<int>(0, (sum, value) => sum + value) %
      palette.length;
  return palette[index];
}

Color cardFillFor(Color color) {
  if (color == gold || color == red || color == burgundy || color == purple) {
    return const Color(0xffeee9dd);
  }
  if (color == green || color == sidebarBg) return const Color(0xffe9e5dc);
  if (color == blue || color == slate || color == line) {
    return const Color(0xfff5f3ed);
  }
  return surface;
}

int roomCapacity(String room) => switch (room) {
  'Sala Principal' => 80,
  'Sala Norte' => 50,
  'Auditorio Oriente' => 120,
  'Sala Experimental' => 30,
  'Sala Historica' => 60,
  'Sala A' => 120,
  'Sala B' => 110,
  'Sala C' => 90,
  'Sala D' => 80,
  'Sala VIP' => 50,
  'Sala E' => 70,
  _ => 100,
};

class Movie {
  const Movie(
    this.title,
    this.genre,
    this.duration,
    this.rating,
    this.country,
    this.synopsis,
    this.posterUrl,
    this.sessions,
    {
    this.idPelicula = '',
    this.idPeliculaEdicion = '',
    this.director = '',
    this.format = '',
  });
  final String title;
  final String genre;
  final int duration;
  final String rating;
  final String country;
  final String synopsis;
  final String posterUrl;
  final List<Session> sessions;
  final String idPelicula;
  final String idPeliculaEdicion;
  final String director;
  final String format;
}

class Session {
  const Session(
    this.date,
    this.time,
    this.room,
    this.qa,
    this.occupied, {
    this.idProyeccion = '',
    this.idSala = '',
    this.capacity = 100,
  });
  final String date;
  final String time;
  final String room;
  final bool qa;
  final List<String> occupied;
  final String idProyeccion;
  final String idSala;
  final int capacity;
}

class ScreeningPlan {
  const ScreeningPlan(
    this.movie,
    this.room,
    this.day,
    this.time,
    this.duration,
    this.qa,
    {
    this.idProyeccion = '',
    this.idSala = '',
    this.idPeliculaEdicion = '',
  });
  final String movie;
  final String room;
  final String day;
  final String time;
  final int duration;
  final bool qa;
  final String idProyeccion;
  final String idSala;
  final String idPeliculaEdicion;
}

class RoomOption {
  const RoomOption(this.id, this.name, this.venueName, this.capacity);

  final String id;
  final String name;
  final String venueName;
  final int capacity;

  String get label => venueName.isEmpty ? name : '$name - $venueName';
}

class FestivalEvent {
  const FestivalEvent({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.capacity,
    required this.cost,
    required this.start,
    required this.durationMinutes,
    required this.editionId,
    required this.roomId,
    required this.room,
    this.sold = 0,
  });

  final String id;
  final String name;
  final String type;
  final String description;
  final int capacity;
  final double cost;
  final DateTime start;
  final int durationMinutes;
  final String editionId;
  final String roomId;
  final String room;
  final int sold;

  String get dateLabel => start.toIso8601String().split('T').first;
  String get timeLabel {
    final hour = start.hour.toString().padLeft(2, '0');
    final minute = start.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  FestivalEvent copyWith({int? sold}) => FestivalEvent(
        id: id,
        name: name,
        type: type,
        description: description,
        capacity: capacity,
        cost: cost,
        start: start,
        durationMinutes: durationMinutes,
        editionId: editionId,
        roomId: roomId,
        room: room,
        sold: sold ?? this.sold,
      );
}

class EventDraft {
  const EventDraft({
    required this.name,
    required this.type,
    required this.description,
    required this.capacity,
    required this.cost,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.editionId,
    required this.room,
  });

  final String name;
  final String type;
  final String description;
  final int capacity;
  final double cost;
  final String date;
  final String time;
  final int durationMinutes;
  final String editionId;
  final RoomOption room;
}

class Attendee {
  const Attendee(
    this.id,
    this.name,
    this.email, {
    this.idPersona = '',
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
  });

  final String id;
  final String name;
  final String email;
  final String idPersona;
  final String firstName;
  final String lastName;
  final String phone;

  String get personCode => idPersona.isNotEmpty ? idPersona : id;

  String get displayName => '$name ($personCode)';
}

class PersonOption {
  const PersonOption({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  factory PersonOption.fromAttendee(Attendee attendee) {
    final parts = attendee.name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    return PersonOption(
      id: attendee.idPersona.isEmpty ? attendee.id : attendee.idPersona,
      firstName: attendee.firstName.isEmpty && parts.isNotEmpty
          ? parts.first
          : attendee.firstName,
      lastName: attendee.lastName.isEmpty && parts.length > 1
          ? parts.skip(1).join(' ')
          : attendee.lastName,
      email: attendee.email,
      phone: attendee.phone,
    );
  }

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  String get displayName {
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? id : fullName;
  }
}

class PersonMatch {
  const PersonMatch(this.person, this.attendee);

  final PersonOption person;
  final Attendee? attendee;
}

class ResolvedAttendee {
  const ResolvedAttendee({required this.created, required this.attendee});

  final bool created;
  final Attendee attendee;
}

class AttendeeFormData {
  const AttendeeFormData({
    this.idPersona = '',
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  final String idPersona;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
}

class VenueOption {
  const VenueOption(this.id, this.name, this.city);

  final String id;
  final String name;
  final String city;
}

class MovieOption {
  const MovieOption(this.id, this.title, this.year);

  final String id;
  final String title;
  final int year;
}

class CategoryOption {
  const CategoryOption(
    this.id,
    this.name, {
    this.description = '',
    this.editionId = '',
  });

  final String id;
  final String name;
  final String description;
  final String editionId;
}

class GenreOption {
  const GenreOption(this.id, this.name);

  final String id;
  final String name;

  bool get isLocal => id.startsWith('NEW_') || id.isEmpty;
}

class DirectorOption {
  const DirectorOption(
    this.id,
    this.name, {
    this.country = '',
    this.biography = '',
    this.phone = '',
  });

  final String id;
  final String name;
  final String country;
  final String biography;
  final String phone;

  bool get isLocal => id.startsWith('NEW_') || id.isEmpty;
}

class MovieDraft {
  const MovieDraft({
    required this.title,
    required this.productionYear,
    required this.duration,
    required this.rating,
    required this.country,
    required this.synopsis,
    required this.posterUrl,
    required this.format,
    required this.editionId,
    required this.genres,
    required this.director,
  });

  final String title;
  final int productionYear;
  final int duration;
  final String rating;
  final String country;
  final String synopsis;
  final String posterUrl;
  final String format;
  final String editionId;
  final List<GenreOption> genres;
  final DirectorOption director;
}

class JuryMember {
  const JuryMember(this.id, this.name, this.role);

  final String id;
  final String name;
  final String role;
}

class JuryDraft {
  const JuryDraft({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.estadoAsistencia,
    required this.especialidad,
    required this.tipoJurado,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String estadoAsistencia;
  final String especialidad;
  final String tipoJurado;
}

class SponsorOption {
  const SponsorOption(this.id, this.name, this.phone, this.email);

  final String id;
  final String name;
  final String phone;
  final String email;
}

class SubscriptionType {
  const SubscriptionType(this.id, this.name, this.description, this.price);

  final String id;
  final String name;
  final String description;
  final double price;
}

class AccreditationType {
  const AccreditationType(this.id, this.name);

  final String id;
  final String name;
}

class ActiveAccreditation {
  const ActiveAccreditation(
    this.id,
    this.attendeeId,
    this.typeId,
    this.typeName,
    this.status,
  );

  final String id;
  final String attendeeId;
  final String typeId;
  final String typeName;
  final String status;
}

class OwnedPass {
  const OwnedPass(
    this.id,
    this.code,
    this.typeName,
    this.status, {
    required this.allowed,
  });

  const OwnedPass.empty()
      : id = '',
        code = '',
        typeName = '',
        status = '',
        allowed = false;

  final String id;
  final String code;
  final String typeName;
  final String status;
  final bool allowed;

  String get label => '$code / $typeName';
}

class FestivalEdition {
  const FestivalEdition(
    this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.status,
  );

  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final String status;

  String get dateRange => '$startDate - $endDate';
}

class FestivalEditionDraft {
  const FestivalEditionDraft({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.venueId,
    required this.movieIds,
    required this.categories,
    required this.jurorIds,
    this.sponsor,
  });

  final String name;
  final String startDate;
  final String endDate;
  final String status;
  final String venueId;
  final List<String> movieIds;
  final List<CategoryOption> categories;
  final List<String> jurorIds;
  final SponsorDraft? sponsor;
}

class SponsorDraft {
  const SponsorDraft({
    required this.existingSponsorId,
    required this.newSponsorName,
    required this.newSponsorPhone,
    required this.newSponsorEmail,
    required this.contributionType,
    required this.amount,
    required this.description,
  });

  final String? existingSponsorId;
  final String? newSponsorName;
  final String? newSponsorPhone;
  final String? newSponsorEmail;
  final String contributionType;
  final double? amount;
  final String description;
}

const fallbackAttendees = [
  Attendee(
    'AS005',
    'Adriana Ribera',
    'adriana.ribera@festcine.com',
    firstName: 'Adriana',
    lastName: 'Ribera',
    phone: '72110025',
  ),
  Attendee(
    'AS006',
    'Oscar Benitez',
    'oscar.benitez@festcine.com',
    firstName: 'Oscar',
    lastName: 'Benitez',
    phone: '72110026',
  ),
  Attendee(
    'AS010',
    'Fernando Medina',
    'fernando.medina@festcine.com',
    firstName: 'Fernando',
    lastName: 'Medina',
    phone: '72110030',
  ),
];

final fallbackPeople = fallbackAttendees.map(PersonOption.fromAttendee).toList();

const fallbackVenues = [
  VenueOption('SE001', 'Cineteca Central', 'La Paz'),
  VenueOption('SE002', 'Centro Cultural Oriente', 'Santa Cruz'),
];

const fallbackMovieOptions = [
  MovieOption('PL001', 'La Ultima Luz', 2024),
  MovieOption('PL002', 'Rio Seco', 2023),
  MovieOption('PL003', 'El Eco del Viento', 2024),
  MovieOption('PL004', 'Sombras del Mercado', 2022),
];

const fallbackCategoryOptions = [
  CategoryOption(
    'CC001',
    'Mejor Cortometraje',
    description: 'Premia la mejor obra corta de la edicion.',
    editionId: 'ED003',
  ),
  CategoryOption(
    'CC002',
    'Mejor Director',
    description: 'Reconoce la mejor direccion cinematografica.',
    editionId: 'ED003',
  ),
  CategoryOption(
    'CC003',
    'Premio del Publico',
    description: 'Reconocimiento segun recepcion del publico.',
    editionId: 'ED003',
  ),
];

const fallbackJuryMembers = [
  JuryMember('JU001', 'Valeria Montes', 'Critica'),
  JuryMember('JU002', 'Hector Salazar', 'Director'),
  JuryMember('JU003', 'Camila Rojas', 'Productora'),
];

const fallbackGenreOptions = [
  GenreOption('GE001', 'Drama'),
  GenreOption('GE002', 'Documental'),
  GenreOption('GE003', 'Ciencia Ficcion'),
  GenreOption('GE004', 'Suspenso'),
  GenreOption('GE005', 'Social'),
];

const fallbackDirectorOptions = [
  DirectorOption('PC001', 'Laura Mendez', country: 'Bolivia'),
  DirectorOption('PC003', 'Ana Rojas', country: 'Chile'),
  DirectorOption('PC005', 'Sofia Rivera', country: 'Mexico'),
  DirectorOption('PC006', 'Carlos Quiroga', country: 'Colombia'),
  DirectorOption('NEW_DIRECTOR_INVITADO', 'Director Invitado'),
];

const projectionFormatOptions = [
  'Digital',
  '35mm',
  'IMAX',
];

const fallbackSponsors = [
  SponsorOption('PA001', 'Cine Bolivia', '3331001', 'contacto@cinebolivia.com'),
  SponsorOption('PA002', 'Luz Media', '3331002', 'marketing@luzmedia.com'),
  SponsorOption('PA003', 'Hotel Centro', '3331003', 'reservas@hotelcentro.com'),
];

const fallbackSubscriptionTypes = [
  SubscriptionType(
    'TB001',
    'Abono Fin de Semana',
    'Acceso a proyecciones seleccionadas de fin de semana.',
    120,
  ),
  SubscriptionType(
    'TB002',
    'Abono Total',
    'Acceso total a las proyecciones de la edicion actual.',
    200,
  ),
  SubscriptionType(
    'TB003',
    'Abono Prensa',
    'Abono gratuito para prensa acreditada.',
    0,
  ),
  SubscriptionType(
    'TB004',
    'Abono VIP',
    'Acceso preferencial para invitados VIP.',
    0,
  ),
  SubscriptionType(
    'TB005',
    'Abono Jurado',
    'Acceso total para miembros del jurado.',
    0,
  ),
];

const fallbackRoomOptions = [
  RoomOption('SA001', 'Sala Principal', 'Cineteca Central', 80),
  RoomOption('SA002', 'Auditorio Oriente', 'Centro Cultural Oriente', 120),
  RoomOption('SA003', 'Sala Norte', 'Cineteca Central', 50),
];

final fallbackFestivalEvents = [
  FestivalEvent(
    id: 'EV001',
    name: 'Miradas del Cine Social',
    type: 'Masterclass',
    description: 'Dialogo con realizadores invitados.',
    capacity: 100,
    cost: 40,
    start: DateTime(2026, 8, 10, 13),
    durationMinutes: 90,
    editionId: 'ED003',
    roomId: 'SA003',
    room: 'SA003',
    sold: 1,
  ),
  FestivalEvent(
    id: 'EV002',
    name: 'Distribuye tu Pelicula',
    type: 'Taller',
    description: 'Taller de distribucion y mercados.',
    capacity: 40,
    cost: 60,
    start: DateTime(2026, 8, 11, 15),
    durationMinutes: 120,
    editionId: 'ED003',
    roomId: 'SA002',
    room: 'SA002',
    sold: 2,
  ),
  FestivalEvent(
    id: 'EV003',
    name: 'Noche de Industria',
    type: 'Coctel',
    description: 'Encuentro de invitados y productores.',
    capacity: 80,
    cost: 0,
    start: DateTime(2026, 8, 12, 20, 30),
    durationMinutes: 120,
    editionId: 'ED003',
    roomId: 'SA003',
    room: 'SA003',
    sold: 1,
  ),
  FestivalEvent(
    id: 'EV101',
    name: 'Laboratorio FestCine 2027',
    type: 'Taller',
    description: 'Evento de la edicion 2027.',
    capacity: 50,
    cost: 30,
    start: DateTime(2027, 8, 9, 16),
    durationMinutes: 120,
    editionId: 'ED004',
    roomId: 'SA001',
    room: 'SA001',
  ),
];

const fallbackAccreditationTypes = [
  AccreditationType('AT001', 'Prensa'),
  AccreditationType('AT002', 'Industria'),
  AccreditationType('AT003', 'VIP'),
  AccreditationType('AT004', 'Jurado'),
];

const fallbackEditions = [
  FestivalEdition(
    'ED003',
    'FestCine Internacional 2026',
    '2026-08-08',
    '2026-08-16',
    'Actual',
  ),
  FestivalEdition(
    'ED004',
    'FestCine Internacional 2027',
    '2027-08-07',
    '2027-08-15',
    'Planificada',
  ),
  FestivalEdition(
    'ED002',
    'FestCine Internacional 2025',
    '2025-08-09',
    '2025-08-17',
    'Finalizada',
  ),
];

const fallbackRoomIds = {
  'Sala Principal': 'SA001',
  'Sala Norte': 'SA002',
  'Auditorio Oriente': 'SA003',
  'Sala Experimental': 'SA004',
  'Sala Historica': 'SA005',
  'Sala A': 'SA001',
  'Sala B': 'SA002',
  'Sala C': 'SA003',
  'Sala D': 'SA004',
  'Sala VIP': 'SA003',
  'Sala E': 'SA004',
};

const fallbackMovieEditionIds = {
  'La Ultima Luz': 'PX001',
  'Rio Seco': 'PX002',
  'El Eco del Viento': 'PX003',
  'Sombras del Mercado': 'PX004',
  'Niebla en Agosto': 'PX005',
  'Frontera Lunar': 'PX007',
  'Voces de Tierra': 'PX008',
  'El Ultimo Fotograma': 'PX001',
  'Luz de Invierno': 'PX002',
  'Marea Roja': 'PX003',
  'Vuelo Ciego': 'PX004',
  'Sal y Ceniza': 'PX005',
  'El Eco del Silencio': 'PX003',
  'Fronteras del Sur': 'PX007',
  'Noche de Hierro': 'PX008',
};

const rooms = [
  'Sala Principal',
  'Sala Norte',
  'Auditorio Oriente',
  'Sala Experimental',
];
const festivalDays = [
  '2026-08-09',
  '2026-08-10',
  '2026-08-11',
  '2026-08-12',
  '2026-08-13',
  '2026-08-14',
  '2026-08-15',
];
const movieTitles = [
  'La Ultima Luz',
  'Rio Seco',
  'El Eco del Viento',
  'Sombras del Mercado',
  'Niebla en Agosto',
  'Frontera Lunar',
  'Voces de Tierra',
];
const movieDuration = {
  'La Ultima Luz': 95,
  'Rio Seco': 88,
  'El Eco del Viento': 102,
  'Sombras del Mercado': 76,
  'Niebla en Agosto': 110,
  'Frontera Lunar': 98,
  'Voces de Tierra': 70,
  'El Ultimo Fotograma': 112,
  'Luz de Invierno': 88,
  'Marea Roja': 127,
  'Vuelo Ciego': 95,
  'Sal y Ceniza': 105,
  'El Eco del Silencio': 98,
  'Fronteras del Sur': 134,
  'Noche de Hierro': 118,
};

const randomPosterUrls = [
  'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=900&h=560&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=900&h=560&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=900&h=560&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=900&h=560&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1542204165-65bf26472b9b?w=900&h=560&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?w=900&h=560&fit=crop&auto=format',
  'https://picsum.photos/seed/festcine-premiere/900/560',
  'https://picsum.photos/seed/festcine-red-carpet/900/560',
];

const initialMovies = [
  Movie(
    'El Ultimo Fotograma',
    'Drama',
    112,
    '+16',
    'Argentina',
    'Una directora de fotografia busca el encuadre perfecto en su ultima pelicula antes de perder la vista.',
    'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=900&h=560&fit=crop&auto=format',
    [
      Session('Sab 14 Jun', '16:00', 'Sala A', false, [
        'A1',
        'A2',
        'A3',
        'B4',
        'B5',
        'C1',
        'C2',
        'D3',
        'E6',
      ]),
      Session('Sab 14 Jun', '19:30', 'Sala A', true, [
        'A1',
        'A2',
        'A3',
        'A4',
        'B1',
        'B2',
        'B3',
        'C1',
        'D1',
        'E1',
        'F1',
        'G1',
        'H1',
        'I1',
        'J1',
      ]),
    ],
  ),
  Movie(
    'Luz de Invierno',
    'Documental',
    88,
    'ATP',
    'Islandia',
    'Un fotografo recorre el Artico durante el solsticio documentando tribus nomadas.',
    'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=900&h=560&fit=crop&auto=format',
    [
      Session('Sab 14 Jun', '14:00', 'Sala B', false, [
        'A1',
        'B2',
        'C3',
        'D4',
        'E5',
      ]),
      Session('Mar 17 Jun', '16:30', 'Sala D', false, []),
    ],
  ),
  Movie(
    'Marea Roja',
    'Thriller',
    127,
    '+18',
    'Brasil',
    'Un fiscal descubre una conspiracion petrolera durante una marea imposible.',
    'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=900&h=560&fit=crop&auto=format',
    [
      Session('Dom 15 Jun', '22:00', 'Sala VIP', false, [
        'A1',
        'A2',
        'A3',
        'B1',
        'B2',
        'B3',
        'C1',
        'C2',
        'D1',
        'D2',
        'E1',
        'E2',
      ]),
    ],
  ),
  Movie(
    'Vuelo Ciego',
    'Suspenso',
    95,
    '+14',
    'Mexico',
    'Una piloto ciega y su copiloto sordo deben aterrizar en oscuridad total.',
    'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=900&h=560&fit=crop&auto=format',
    [
      Session('Vie 13 Jun', '19:15', 'Sala D', false, [
        'A1',
        'B2',
        'C3',
        'D4',
        'A5',
      ]),
      Session('Vie 13 Jun', '22:00', 'Sala D', false, []),
    ],
  ),
  Movie(
    'Sal y Ceniza',
    'Romance',
    105,
    '+13',
    'Espana',
    'Dos desconocidos se encuentran en las ruinas de un festival abandonado.',
    'https://images.unsplash.com/photo-1542204165-65bf26472b9b?w=900&h=560&fit=crop&auto=format',
    [
      Session('Vie 13 Jun', '17:00', 'Sala E', false, ['A1', 'A2', 'B1', 'C1']),
    ],
  ),
  Movie(
    'El Eco del Silencio',
    'Terror',
    98,
    '+18',
    'Corea',
    'Un equipo de sonido registra un eco imposible en una mansion abandonada.',
    'https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?w=900&h=560&fit=crop&auto=format',
    [
      Session('Sab 14 Jun', '23:00', 'Sala B', false, [
        'A1',
        'A2',
        'A3',
        'B1',
        'B2',
      ]),
    ],
  ),
];

const baseSchedule = [
  ScreeningPlan(
    'El Ultimo Fotograma',
    'Sala A',
    '2026-06-13',
    '16:00',
    112,
    false,
  ),
  ScreeningPlan(
    'El Ultimo Fotograma',
    'Sala A',
    '2026-06-13',
    '19:30',
    112,
    true,
  ),
  ScreeningPlan('Luz de Invierno', 'Sala B', '2026-06-13', '14:00', 88, false),
  ScreeningPlan('Luz de Invierno', 'Sala B', '2026-06-13', '20:00', 88, true),
  ScreeningPlan('Marea Roja', 'Sala VIP', '2026-06-13', '20:00', 127, false),
  ScreeningPlan('Vuelo Ciego', 'Sala D', '2026-06-13', '15:00', 95, false),
  ScreeningPlan('Sal y Ceniza', 'Sala E', '2026-06-13', '17:00', 105, false),
  ScreeningPlan(
    'El Eco del Silencio',
    'Sala B',
    '2026-06-13',
    '23:00',
    98,
    false,
  ),
  ScreeningPlan(
    'Fronteras del Sur',
    'Sala C',
    '2026-06-14',
    '15:30',
    134,
    true,
  ),
  ScreeningPlan('Vuelo Ciego', 'Sala D', '2026-06-14', '22:00', 95, false),
];
