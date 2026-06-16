part of '../../main.dart';

String nextProjectionId(List<ScreeningPlan> schedule) {
  final maxId = schedule
      .map((item) => RegExp(r'^PR(\d{3})$').firstMatch(item.idProyeccion))
      .whereType<RegExpMatch>()
      .map((match) => int.tryParse(match.group(1) ?? '') ?? 0)
      .fold<int>(10, (max, value) => value > max ? value : max);
  final next = (maxId + 1).clamp(1, 999);
  return 'PR${next.toString().padLeft(3, '0')}';
}

String idSalaForRoom(
  String room,
  List<ScreeningPlan> schedule, [
  List<RoomOption> roomCatalog = const [],
]) {
  for (final item in roomCatalog) {
    if ((item.name == room || item.label == room) && item.id.isNotEmpty) {
      return item.id;
    }
  }
  for (final item in schedule) {
    if (item.room == room && item.idSala.isNotEmpty) return item.idSala;
  }
  return fallbackRoomIds[room] ?? '';
}

String idPeliculaEdicionForMovie(
  String movie,
  List<ScreeningPlan> schedule, [
  List<Movie> movies = const [],
]) {
  for (final item in movies) {
    if (item.title == movie && item.idPeliculaEdicion.isNotEmpty) {
      return item.idPeliculaEdicion;
    }
  }
  for (final item in schedule) {
    if (item.movie == movie && item.idPeliculaEdicion.isNotEmpty) {
      return item.idPeliculaEdicion;
    }
  }
  return fallbackMovieEditionIds[movie] ?? '';
}

int nextIdNumber(List<Map<String, dynamic>> items, String key, String prefix) {
  final max = items
      .map((item) => _readString(item, key))
      .where((id) => id.startsWith(prefix))
      .map((id) => int.tryParse(id.substring(prefix.length)) ?? 0)
      .fold<int>(0, (max, value) => value > max ? value : max);
  return max + 1;
}

String nextIdFromMaps(List<Map<String, dynamic>> items, String key, String prefix) {
  final next = nextIdNumber(items, key, prefix);
  return '$prefix${next.toString().padLeft(3, '0')}';
}

String nextIdFromMapsMin(
  List<Map<String, dynamic>> items,
  String key,
  String prefix,
  int minNumber,
) {
  final next = nextIdNumber(items, key, prefix);
  final value = next < minNumber ? minNumber : next;
  return '$prefix${value.toString().padLeft(3, '0')}';
}

