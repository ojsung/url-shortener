part of 'exceptions.dart';
class UnknownDatabaseException implements Exception {
  final String message;
  const UnknownDatabaseException([this.message = 'An unknown database error occurred']);

  @override
  String toString() => 'UnknownDatabaseException: $message';
}