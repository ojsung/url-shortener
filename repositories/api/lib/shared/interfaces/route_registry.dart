import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:url_shortener_server/shared/interfaces/controller.dart';

abstract class RouteRegistry {
  final String namespace;
  final List<Middleware> middlewares;
  Controller get controller;
  RouteRegistry({required this.namespace, required this.middlewares});
  Router registerRoutes(Router router);
}
