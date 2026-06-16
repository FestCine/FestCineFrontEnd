part of '../../main.dart';

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

