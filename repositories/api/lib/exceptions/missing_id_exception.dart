part of 'exceptions.dart';
class MissingIdException implements Exception {
  final String message;
  const MissingIdException([this.message = 'ID is missing and must be provided']);

  @override
  String toString() => 'MissingIdException: $message';
}
