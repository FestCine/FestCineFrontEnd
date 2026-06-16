part of '../../main.dart';

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

