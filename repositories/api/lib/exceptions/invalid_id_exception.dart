part of 'exceptions.dart';

class InvalidIdException implements Exception {
  final String message;
  const InvalidIdException([
    this.message = 'ID is missing or invalid',
  ]);

  @override
  String toString() => 'InvalidIdException: $message';
}
