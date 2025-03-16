part of 'exceptions.dart';
class DuplicateUserException implements Exception {
  final String message;
  const DuplicateUserException([this.message = 'A user with that username already exists']);

  @override
  String toString() => 'DuplicateUserException: $message';
}
