part of 'exceptions.dart';
class IncompleteDataException implements Exception {
  final String message;
  const IncompleteDataException([this.message = 'The provided data is incomplete']);

  @override
  String toString() => 'IncompleteDataException: $message';
}