// filepath: /home/admin/dev/url-shortener/repositories/api/lib/middlewares/auth_middleware.dart
import 'package:shelf/shelf.dart';
import 'package:url_shortener_server/dtos/json_token.dart';
import 'package:url_shortener_server/services/auth_service.dart' show AuthService;

class AuthenticationMiddleware {
  final AuthService authService;

  AuthenticationMiddleware(this.authService);

  Middleware get middleware {
    return (Handler handler) {
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

        return handler(request);
      };
    };
  }
}
