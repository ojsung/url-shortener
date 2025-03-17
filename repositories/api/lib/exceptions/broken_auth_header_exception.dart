part of 'exceptions.dart';

class BrokenAuthorizationHeaderException implements Exception {
  final String message;
  const BrokenAuthorizationHeaderException([this.message = 'The authorization header is missing or invalid']);

  @override
  String toString() => 'BrokenAuthorizationHeader: $message';
}
