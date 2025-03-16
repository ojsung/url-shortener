import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:url_shortener_server/shared/interfaces/controller.dart';
import 'package:url_shortener_server/shared/interfaces/custom_middleware.dart';

abstract class RouteRegistry {
  final String namespace;
  final List<CustomMiddleware> exceptionHandlers;
  final List<CustomMiddleware> middlewares;
  final List<CustomMiddleware> validators;
  Controller get controller;
  RouteRegistry({required this.namespace, required this.exceptionHandlers, required this.middlewares, required this.validators});
  Router registerRoutes(Router router);
}

extension MiddlewaresExtension on Pipeline {
  Pipeline addMiddlewares(List<CustomMiddleware> middlewares) =>
      middlewares.fold(this, (pipeline, middleware) => pipeline.addMiddleware(middleware.middleware));
  Pipeline tryAddMiddleware(Middleware? middlewareOrNull) {
    if (middlewareOrNull == null) {
      return this;
    }
    return addMiddleware(middlewareOrNull);
  }
}
