part of 'exceptions.dart';
class UnknownInsertException implements Exception {
  final String message;
  const UnknownInsertException([this.message = 'An unknown error occurred at insert']);

  @override
  String toString() => 'UnknownInsertException: $message';
}