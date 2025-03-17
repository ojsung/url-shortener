import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' show Router;
import 'package:url_shortener_server/controllers/user_controller.dart';
import 'package:url_shortener_server/middlewares/middlewares_library.dart';
import 'package:url_shortener_server/shared/interfaces/route_registry.dart';
import 'package:url_shortener_server/validators/validators_library.dart';

class UserRoutes extends RouteRegistry {
  @override
  final UserController controller;
  UserRoutes({
    required super.namespace,
    required super.exceptionHandlers,
    required super.middlewares,
    required super.validators,
    required this.controller,
  });
  @override
  Router registerRoutes(Router router) {
    router
      ..get(
        '/user',
        Pipeline()
            .addMiddlewares(exceptionHandlers)
            .addMiddlewares(middlewares)
            .addMiddleware(
              MiddlewareLibrary.get<AuthenticationMiddleware>().middleware,
            )
            .addHandler(controller.getHandler),
      )
      ..get('/user/urls', Pipeline()
            .addMiddlewares(exceptionHandlers)
            .addMiddlewares(middlewares)
            .addMiddleware(
              MiddlewareLibrary.get<AuthenticationMiddleware>().middleware,
            )
            .addHandler(controller.urlGetHandler),
      )
      ..post(
        '/user/urls',
        Pipeline()
            .addMiddlewares(exceptionHandlers)
            .addMiddlewares(middlewares)
            .addMiddleware(
              MiddlewareLibrary.get<AuthenticationMiddleware>().middleware,
            )
            .addMiddleware(ValidatorLibrary.get<UrlFieldValidator>().middleware)
            .addMiddleware(
              ValidatorLibrary.get<UrlContentValidator>().middleware,
            )
            .addHandler(controller.urlPostHandler),
      )
      ..put(
        '/user/urls',
        Pipeline()
            .addMiddlewares(exceptionHandlers)
            .addMiddlewares(middlewares)
            .addMiddleware(
              MiddlewareLibrary.get<AuthenticationMiddleware>().middleware,
            )
            .addMiddleware(ValidatorLibrary.get<UrlFieldValidator>().middleware)
            .addMiddleware(ValidatorLibrary.get<IdFieldValidator>().middleware)
            .addMiddleware(
              ValidatorLibrary.get<UrlContentValidator>().middleware,
            )
            .addHandler(controller.urlPutHandler),
      )
      ..delete(
        '/user/urls',
        Pipeline()
            .addMiddlewares(exceptionHandlers)
            .addMiddlewares(middlewares)
            .addMiddleware(
              MiddlewareLibrary.get<AuthenticationMiddleware>().middleware,
            )
            .addMiddleware(ValidatorLibrary.get<IdFieldValidator>().middleware)
            .addHandler(controller.urlDeleteHandler),
      );
    return router;
  }
}
