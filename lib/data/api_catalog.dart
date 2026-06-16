part of '../main.dart';

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

