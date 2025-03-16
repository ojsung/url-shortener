import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:url_shortener_server/middlewares/middlewares_library.dart';
import 'package:url_shortener_server/shared/interfaces/controller.dart';
import 'package:url_shortener_server/shared/interfaces/custom_middleware.dart';
import 'package:url_shortener_server/validators/validators_library.dart';

abstract class RouteRegistry {
  final String namespace;
  final Map<LibraryMiddleware, CustomMiddleware> middlewares;
  final Map<Validator, CustomMiddleware> validators;
  Controller get controller;
  RouteRegistry({required this.namespace, required this.middlewares, required this.validators});
  Router registerRoutes(Router router);
}

extension MiddlewaresExtension on Pipeline {
  Pipeline addMiddlewares(Map<dynamic, CustomMiddleware> middlewares) =>
      middlewares.values.fold(this, (pipeline, middleware) => pipeline.addMiddleware(middleware.middleware));
  Pipeline tryAddMiddleware(Middleware? middlewareOrNull) {
    if (middlewareOrNull == null) {
      return this;
    }
    return addMiddleware(middlewareOrNull);
  }
}
