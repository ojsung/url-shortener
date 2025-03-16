import 'dart:async' show FutureOr;
import 'package:shelf/shelf.dart' show Handler, Request, Response;
import 'package:url_shortener_server/shared/response_body.dart' as body;

abstract class CustomMiddleware {
  FutureOr<Response> Function(Request, [String?]) middleware(Handler handler);
}

extension Body on CustomMiddleware {
  String Function (String message, [Map<String, dynamic>? fields]) get withMessage => body.withMessage;
  String Function(String errorMessage, [Map<String, dynamic>? fields]) get withError => body.withError;
}
