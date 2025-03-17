part of 'exceptions.dart';

class InvalidAuthorizationHeaderException implements Exception {
  final String message;
  const InvalidAuthorizationHeaderException([this.message = 'The authorization header is invalid']);

  @override
  String toString() => 'InvalidAuthorizationHeaderException: $message';
}
