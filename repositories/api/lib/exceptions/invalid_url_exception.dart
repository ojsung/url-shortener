part of 'exceptions.dart';
class InvalidUrlException implements Exception {
  final String message;
  const InvalidUrlException([this.message = 'Not a valid url']);

  @override
  String toString() => 'InvalidUrlException: $message';
}