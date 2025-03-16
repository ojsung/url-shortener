import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' show Router;
import 'package:url_shortener_server/shared/interfaces/route_registry.dart' show RouteRegistry, MiddlewaresExtension;
import 'package:url_shortener_server/controllers/auth_controller.dart';

class AuthRoutes extends RouteRegistry {
  @override
  final AuthController controller;
  AuthRoutes({
    required super.namespace,
    required super.exceptionHandlers,
    required super.middlewares,
    required super.validators,
    required this.controller,
  });
  @override
  Router registerRoutes(Router router) {
    final authRouter =
        Router()
          ..post('/signup', controller.signupPostHandler)
          ..post('/login', controller.loginPostHandler);

    router.mount(
      namespace,
      Pipeline().addMiddlewares(middlewares).addMiddlewares(validators).addHandler(authRouter.call),
    );
    return router;
  }
}
