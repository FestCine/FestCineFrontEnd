part of '../../main.dart';

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

