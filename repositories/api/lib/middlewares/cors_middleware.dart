part of 'middlewares_library.dart';

/// Allows Cross-Origin Resource Sharing (CORS) requests
/// It is not set up to allow authorization headers
class CorsMiddleware extends MiddlewareLibrary implements CustomMiddleware {
  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }
      final Response response = await handler(request);
      return response.change(headers: _corsHeaders);
    };
  }

  final Map<String, String> _corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
  };
}
