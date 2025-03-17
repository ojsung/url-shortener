part of 'exceptions.dart';

class NotFoundException extends HttpException {
  @override
  const NotFoundException([super.message = 'Url not found']);

  @override
  String toString() => 'NotFoundException: $message';
}
