part of 'middlewares_library.dart';

class AuthenticationMiddleware extends MiddlewareLibrary implements CustomMiddleware {
  final AuthService authService;

  AuthenticationMiddleware(this.authService);

  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden('Missing or invalid Authorization header');
      }

      final base64Token = authHeader.substring(7);
      final JsonToken jsonToken = JsonToken.fromBearerToken(base64Token);
      final int? userId = jsonToken.userId;
      final String? authToken = jsonToken.token;
      if (userId == null || authToken == null) {
        return Response.forbidden('Missing auth header');
      }

      final isValid = await authService.verifyAuthToken(authToken, userId);
      if (!isValid) {
        return Response.forbidden('Invalid token');
      }
      request.change(context: {"userId": userId});

      return handler(request);
    };
  }
}
