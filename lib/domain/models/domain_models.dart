part of '../../main.dart';

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

    this.status = '',

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

  final String status;

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

  const MovieOption(
    this.id,
    this.title,
    this.year, {
    this.idPeliculaEdicion = '',
    this.status = '',
  });



  final String id;

  final String title;

  final int year;

  final String idPeliculaEdicion;

  final String status;

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

    this.addToCartelera = true,

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

  final bool addToCartelera;

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

