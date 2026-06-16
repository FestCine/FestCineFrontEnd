part of '../../main.dart';

List<CategoryOption> mergeCategoryOptions(

  List<CategoryOption> base,

  List<CategoryOption> incoming,

) {

  final byName = <String, CategoryOption>{};

  for (final item in [...base, ...incoming]) {

    if (item.name.trim().isEmpty) continue;

    byName.putIfAbsent(normalizeText(item.name), () => item);

  }

  return byName.values.toList()..sort((a, b) => a.name.compareTo(b.name));

}



List<GenreOption> mergeGenreOptions(

  List<GenreOption> base,

  List<GenreOption> incoming,

) {

  final byName = <String, GenreOption>{};

  for (final item in [...base, ...incoming]) {

    if (item.name.trim().isEmpty) continue;

    byName.putIfAbsent(normalizeText(item.name), () => item);

  }

  return byName.values.toList()..sort((a, b) => a.name.compareTo(b.name));

}



List<DirectorOption> mergeDirectorOptions(

  List<DirectorOption> base,

  List<DirectorOption> incoming,

) {

  final byName = <String, DirectorOption>{};

  for (final item in [...base, ...incoming]) {

    if (item.name.trim().isEmpty) continue;

    byName.putIfAbsent(normalizeText(item.name), () => item);

  }

  return byName.values.toList()..sort((a, b) => a.name.compareTo(b.name));

}



List<AccreditationType> mergeAccreditationTypes(

  List<AccreditationType> base,

  List<AccreditationType> incoming,

) {

  final byName = <String, AccreditationType>{};

  for (final item in [...base, ...incoming]) {

    if (item.name.trim().isEmpty) continue;

    byName.putIfAbsent(normalizeText(item.name), () => item);

  }

  return byName.values.toList()..sort((a, b) => a.name.compareTo(b.name));

}



List<JuryMember> mergeJuryMembers(

  List<JuryMember> base,

  List<JuryMember> incoming,

) {

  final byId = <String, JuryMember>{};

  for (final item in [...base, ...incoming]) {

    if (item.id.trim().isEmpty) continue;

    byId[item.id] = item;

  }

  return byId.values.toList()..sort((a, b) => a.name.compareTo(b.name));

}

