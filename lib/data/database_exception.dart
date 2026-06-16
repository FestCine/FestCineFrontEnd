part of '../main.dart';

class DatabaseException implements Exception {

  const DatabaseException(this.code, this.friendlyMessage);



  final String code;

  final String friendlyMessage;

}

