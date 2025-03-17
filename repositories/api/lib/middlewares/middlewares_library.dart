import 'dart:async' show FutureOr;
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:url_shortener_server/dtos/json_token.dart';
import 'package:url_shortener_server/exceptions/exceptions.dart';
import 'package:url_shortener_server/services/auth_service.dart'
    show AuthService;
import 'package:url_shortener_server/shared/interfaces/custom_middleware.dart';
import 'package:url_shortener_server/shared/globals.dart' show getIt;
part 'authentication_middleware.dart';
part 'cors_middleware.dart';
part 'auth_exception_middleware.dart';
part 'url_exception_middleware.dart';
part 'set_request_string_middleware.dart';

sealed class MiddlewareLibrary {
  static CustomMiddleware get<Middleware extends MiddlewareLibrary>() {
    switch (Middleware) {
      case const (AuthenticationMiddleware):
        return getIt<AuthenticationMiddleware>();
      case const (CorsMiddleware):
        return getIt<CorsMiddleware>();
      case const (AuthExceptionMiddleware):
        return getIt<AuthExceptionMiddleware>();
      case const (UrlExceptionMiddleware):
        return getIt<UrlExceptionMiddleware>();
      case const (SetRequestStringMiddleware):
        return getIt<SetRequestStringMiddleware>();
      default:
        throw Exception('Middleware not found');
    }
  }
}
