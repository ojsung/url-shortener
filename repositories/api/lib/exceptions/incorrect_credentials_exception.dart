part of 'exceptions.dart';
class IncorrectCredentialsException implements Exception {
  final String message;
  const IncorrectCredentialsException([this.message = 'The username or password is incorrect']);

  @override
  String toString() => 'IncorrectCredentialsException: $message';
}