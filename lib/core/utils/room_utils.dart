part of '../../main.dart';

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

