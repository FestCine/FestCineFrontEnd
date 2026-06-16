part of '../main.dart';

String _readString(Map<String, dynamic> item, String key) {

  final value = item[key] ?? item[_pascalCase(key)];

  return value?.toString() ?? '';

}



int _readInt(Map<String, dynamic> item, String key) {

  final value = item[key] ?? item[_pascalCase(key)];

  if (value is int) return value;

  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;

}



double _readDouble(Map<String, dynamic> item, String key) {

  final value = item[key] ?? item[_pascalCase(key)];

  if (value is double) return value;

  if (value is num) return value.toDouble();

  return double.tryParse(value?.toString() ?? '') ?? 0;

}



bool _readBool(Map<String, dynamic> item, String key) {

  final value = item[key] ?? item[_pascalCase(key)];

  if (value is bool) return value;

  if (value is num) return value != 0;

  return value?.toString().toLowerCase() == 'true';

}



DateTime _readDate(Map<String, dynamic> item, String key) {

  final raw = _readString(item, key);

  return DateTime.tryParse(raw) ?? DateTime.now();

}

