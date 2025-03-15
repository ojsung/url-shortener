import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' show Router;
import 'package:url_shortener_server/shared/interfaces/route_registry.dart';
import 'package:url_shortener_server/controllers/auth_controller.dart';

class AuthRoutes extends RouteRegistry {
  @override
  final AuthController controller;
  AuthRoutes({
    required super.namespace,
    required super.middlewares,
    required this.controller,
  });
  @override
  Router registerRoutes(Router router) {
    final authRouter =
        Router()
          ..post('/signup', controller.postSignupHandler)
          ..post('/login', controller.postLoginHandler);

    router.mount(
      namespace,
      Pipeline().addMiddleware(middlewares[0]).addHandler(authRouter.call),
    );
    return router;
  }
}
