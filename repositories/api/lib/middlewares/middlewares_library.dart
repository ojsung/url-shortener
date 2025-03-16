import 'dart:async' show FutureOr;

import 'package:shelf/shelf.dart';
import 'package:url_shortener_server/dtos/json_token.dart';
import 'package:url_shortener_server/exceptions/exceptions.dart';
import 'package:url_shortener_server/services/auth_service.dart' show AuthService;
import 'package:url_shortener_server/shared/interfaces/custom_middleware.dart';
part 'authentication_middleware.dart';
part 'cors_middleware.dart';
part 'auth_exception_middleware.dart';
part 'url_exception_middleware.dart';

sealed class MiddlewareLibrary {}
