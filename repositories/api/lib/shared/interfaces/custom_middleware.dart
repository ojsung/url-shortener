import 'dart:async' show FutureOr;
import 'package:shelf/shelf.dart' show Handler, Request, Response;

abstract class CustomMiddleware {
  FutureOr<Response> Function(Request) middleware(Handler handler);
}
