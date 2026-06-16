part of '../main.dart';

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

String _estadoToGenre(String estado) {
  return estado.isEmpty ? 'Catalogo' : estado;
}

bool _isCarteleraStatus(String estado) {
  final normalized = normalizeText(estado);
  return normalized == 'seleccionada' || normalized == 'premiada';
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

