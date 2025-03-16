import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' show Router;
import 'package:url_shortener_server/controllers/url_controller.dart' show UrlController;
import 'package:url_shortener_server/shared/interfaces/route_registry.dart';

class ShortenedUrlRoutes extends RouteRegistry {
  @override
  final UrlController controller;
  ShortenedUrlRoutes({
    required super.namespace,
    required super.exceptionHandlers,
    required super.middlewares,
    required super.validators,
    required this.controller,
  });
  @override
  Router registerRoutes(Router router) {
    final getRouter = Router()..get('/<shortened_url>', controller.getHandler);

    return router..mount(namespace, Pipeline().addMiddlewares(middlewares).addMiddlewares(validators).addHandler(getRouter.call));
  }
}
