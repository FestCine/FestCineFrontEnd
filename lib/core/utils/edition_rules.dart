part of '../../main.dart';

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

