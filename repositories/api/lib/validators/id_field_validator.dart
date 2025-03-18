part of 'validators_library.dart';

class IdFieldValidator extends ValidatorLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      final Object? responseJson = request.context['requestJson'];
      if (responseJson is! Map<String, dynamic>) {
        throw Exception('Request JSON is missing');
      }
      final Object? id = responseJson['urlId'];
      if (id is! int) {
        throw InvalidIdException('ID is required');
      }
      final requestWithId = request.change(context: {'urlId': id});
      return handler(requestWithId);
    };
  }
}
