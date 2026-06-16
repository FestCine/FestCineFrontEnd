part of '../main.dart';

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



    final rawMoviesData =
        await _getList('/api/catalogos/peliculas/$selectedEditionId');
    final moviesData = rawMoviesData
        .where((item) => _isCarteleraStatus(_readString(item, 'estadoFestival')))
        .toList();

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

    final movieEditionsData = await _getList('/api/pelicula-ediciones');

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
    final movieEditionByMovieId = <String, Map<String, dynamic>>{};
    for (final item in movieEditionsData) {
      if (_readString(item, 'idEdicion') != selectedEditionId) continue;
      final movieId = _readString(item, 'idPelicula');
      final current = movieEditionByMovieId[movieId];
      if (current == null ||
          _isCarteleraStatus(_readString(item, 'estadoFestival'))) {
        movieEditionByMovieId[movieId] = item;
      }
    }

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

      if (movieData == null) continue;

      final movieEditionId = _readString(movieData, 'idPeliculaEdicion');

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

          _readInt(movieData, 'duracion'),

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

        status: _readString(item, 'estadoFestival'),

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

      final movieId = _readString(item, 'idPelicula');
      final relation = movieEditionByMovieId[movieId];
      return MovieOption(

        movieId,

        _readString(item, 'titulo'),

        _readInt(item, 'anioProduccion'),

        idPeliculaEdicion:
            relation == null ? '' : _readString(relation, 'idPeliculaEdicion'),

        status: relation == null ? '' : _readString(relation, 'estadoFestival'),

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

    final movieEditionId = draft.addToCartelera
        ? nextIdFromMaps(movieEditions, 'idPeliculaEdicion', 'PX')
        : '';



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



    if (draft.addToCartelera) {
      await _postJson('/api/pelicula-ediciones', {

        'idPeliculaEdicion': movieEditionId,

        'idPelicula': movieId,

        'idEdicion': draft.editionId,

        'estadoFestival': 'Seleccionada',

      });
    }



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

      const [],

      idPelicula: movieId,

      idPeliculaEdicion: movieEditionId,

      director: draft.director.name,

      format: draft.format,

      status: draft.addToCartelera ? 'Seleccionada' : '',

    );

  }

  static Future<String> addExistingMovieToCartelera({
    required MovieOption movie,
    required String editionId,
  }) async {
    final movieEditions = await _getList('/api/pelicula-ediciones');
    final existing = movieEditions.firstWhere(
      (item) =>
          _readString(item, 'idPelicula') == movie.id &&
          _readString(item, 'idEdicion') == editionId,
      orElse: () => const <String, dynamic>{},
    );

    if (existing.isNotEmpty) {
      final status = _readString(existing, 'estadoFestival');
      if (_isCarteleraStatus(status)) {
        return 'Esta película ya se encuentra en cartelera.';
      }

      final relationId = _readString(existing, 'idPeliculaEdicion');
      await _putJson('/api/pelicula-ediciones/$relationId', {
        'idPeliculaEdicion': relationId,
        'idPelicula': movie.id,
        'idEdicion': editionId,
        'estadoFestival': 'Seleccionada',
      });
      return 'Película añadida nuevamente a cartelera.';
    }

    await _postJson('/api/pelicula-ediciones', {
      'idPeliculaEdicion':
          nextIdFromMaps(movieEditions, 'idPeliculaEdicion', 'PX'),
      'idPelicula': movie.id,
      'idEdicion': editionId,
      'estadoFestival': 'Seleccionada',
    });
    return 'Película existente añadida a la cartelera de la edición actual.';
  }

  static Future<void> retireMovieFromCartelera({
    required Movie movie,
    required String editionId,
  }) async {
    var relationId = movie.idPeliculaEdicion;
    var movieId = movie.idPelicula;
    Map<String, dynamic> relation = const <String, dynamic>{};

    if (relationId.isEmpty || movieId.isEmpty) {
      final movieEditions = await _getList('/api/pelicula-ediciones');
      relation = movieEditions.firstWhere(
        (item) {
          final sameRelation = relationId.isNotEmpty &&
              _readString(item, 'idPeliculaEdicion') == relationId;
          final sameMovie = movieId.isNotEmpty &&
              _readString(item, 'idPelicula') == movieId &&
              _readString(item, 'idEdicion') == editionId;
          return sameRelation || sameMovie;
        },
        orElse: () => const <String, dynamic>{},
      );
      relationId = _readString(relation, 'idPeliculaEdicion');
      movieId = _readString(relation, 'idPelicula');
    }

    if (relationId.isEmpty || movieId.isEmpty) {
      throw const DatabaseException(
        'API_PELICULA_EDICION_NO_ENCONTRADA',
        'No se encontro la relacion de esta pelicula con la edicion actual.',
      );
    }

    await _putJson('/api/pelicula-ediciones/$relationId', {
      'idPeliculaEdicion': relationId,
      'idPelicula': movieId,
      'idEdicion': editionId,
      'estadoFestival': 'Rechazada',
    });
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

