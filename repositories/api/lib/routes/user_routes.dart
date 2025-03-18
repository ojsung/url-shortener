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
    final userRouter = Router();
    userRouter.options('/urls/<urlId>', (Request request) {
      return Response.ok(
        '',
        headers:
            (MiddlewareLibrary.get<CorsMiddleware>() as CorsMiddleware)
                .corsHeaders,
      );
    });
    userRouter.options('/urls', (Request request) {
      return Response.ok(
        '',
        headers:
            (MiddlewareLibrary.get<CorsMiddleware>() as CorsMiddleware)
                .corsHeaders,
      );
    });
    userRouter.options('/', (Request request) {
      return Response.ok(
        '',
        headers:
            (MiddlewareLibrary.get<CorsMiddleware>() as CorsMiddleware)
                .corsHeaders,
      );
    });
    userRouter.post(
      '/urls',
      Pipeline()
          .addMiddlewares(exceptionHandlers)
          .addMiddlewares(middlewares)
          .addMiddleware(
            MiddlewareLibrary.get<AuthenticationMiddleware>().middleware,
          )
          .addMiddleware(ValidatorLibrary.get<UrlFieldValidator>().middleware)
          .addMiddleware(ValidatorLibrary.get<UrlContentValidator>().middleware)
          .addHandler(controller.urlPostHandler),
    );

    userRouter.put(
      '/urls/<urlId>',
      Pipeline()
          .addMiddlewares(exceptionHandlers)
          .addMiddlewares(middlewares)
          .addMiddleware(
            MiddlewareLibrary.get<AuthenticationMiddleware>().middleware,
          )
          .addMiddleware(ValidatorLibrary.get<UrlFieldValidator>().middleware)
          .addMiddleware(ValidatorLibrary.get<UrlIdParamValidator>().middleware)
          .addMiddleware(ValidatorLibrary.get<UrlContentValidator>().middleware)
          .addHandler(controller.urlPutHandler),
    );

    userRouter.delete(
      '/urls/<urlId>',
      Pipeline()
          .addMiddlewares(exceptionHandlers)
          .addMiddlewares(middlewares)
          .addMiddleware(
            MiddlewareLibrary.get<AuthenticationMiddleware>().middleware,
          )
          .addMiddleware(ValidatorLibrary.get<UrlIdParamValidator>().middleware)
          .addHandler(controller.urlDeleteHandler),
    );

    userRouter.get(
      '/urls',
      Pipeline()
          .addMiddlewares(exceptionHandlers)
          .addMiddlewares(middlewares)
          .addMiddleware(
            MiddlewareLibrary.get<AuthenticationMiddleware>().middleware,
          )
          .addHandler(controller.urlGetHandler),
    );
    userRouter.get(
      '/',
      Pipeline()
          .addMiddlewares(exceptionHandlers)
          .addMiddlewares(middlewares)
          .addMiddleware(
            MiddlewareLibrary.get<AuthenticationMiddleware>().middleware,
          )
          .addHandler(controller.getHandler),
    );

    router.mount(namespace, userRouter.call);

    return router;
  }
}
