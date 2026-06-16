part of '../../main.dart';

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

