part of '../main.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:5075',
);

const apiTimeout = Duration(seconds: 8);

