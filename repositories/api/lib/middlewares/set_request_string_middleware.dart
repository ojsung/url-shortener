part of 'middlewares_library.dart';

class SetRequestStringMiddleware extends MiddlewareLibrary
    implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      if (request.method == 'GET') {
        return handler(request);
      }
      final String requestString;
      if (request.context['requestString'] == null) {
        requestString = await request.readAsString();
      } else {
        requestString = request.context['requestString'] as String;
      }

      final requestWithRequestString = request.change(
        context: {
          'requestString': requestString,
          'requestJson': json.decode(requestString),
        },
      );
      return handler(requestWithRequestString);
    };
  }
}
