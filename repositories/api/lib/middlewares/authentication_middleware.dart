part of 'middlewares_library.dart';

class AuthenticationMiddleware extends MiddlewareLibrary
    implements CustomMiddleware {
  final AuthService authService;

  AuthenticationMiddleware(this.authService);

  @override
  FutureOr<Response> Function(Request) middleware(Handler handler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        throw InvalidAuthorizationHeaderException();
      }

      final base64Token = authHeader.substring(7);
      final JsonToken jsonToken = JsonToken.fromBearerToken(base64Token);
      final int? userId = jsonToken.userId;
      final String? authToken = jsonToken.token;
      if (userId == null || authToken == null) {
        throw BrokenAuthorizationHeaderException(
          'Authorization header is missing authorization data',
        );
      }

      final isValid = await authService.verifyAuthToken(authToken, userId);
      if (!isValid) {
        throw InvalidAuthorizationHeaderException('The token is invalid');
      }
      
      final Request requestWithUserId = request.change(context: {"userId": userId});
      return handler(requestWithUserId);
    };
  }
}
