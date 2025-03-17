part of 'validators_library.dart';

class UrlFieldValidator extends ValidatorLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      final Object? requestJson = request.context['requestJson'];
      if (requestJson is! Map<String, dynamic>) {
        throw Exception(
          'UrlFieldValidator. Request json is missing. Did you forget to add SetRequestStringMiddleware?',
        );
      }
      final String? url = requestJson['longUrl'];
      if (url == null || url.isEmpty) {
        throw IncompleteDataException('Url must not be empty');
      }
      print(requestJson);
      final requestWithUrl = request.change(
        context: {'longUrl': url},
      );

      // If validation passes, call the next handler
      return handler(requestWithUrl);
    };
  }
}
