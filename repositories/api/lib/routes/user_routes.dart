import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' show Router;
import 'package:url_shortener_server/controllers/url_controller.dart' show UrlController;
import 'package:url_shortener_server/shared/interfaces/route_registry.dart';
import 'package:url_shortener_server/shared/response_body.dart';

class UserRoutes extends RouteRegistry {
  @override
  final UrlController controller;
  UserRoutes({
    required super.namespace,
    required super.exceptionHandlers,
    required super.middlewares,
    required super.validators,
    required this.controller,
  });
  @override
  Router registerRoutes(Router router) {
    final router =
        Router()
          ..get('/', (request) => Response.ok(withMessage('Welcome back user')))
          ..get('/urls', (request) => Response.ok(withMessage('Found', {'urls': List.filled(10, 'b')})))
          ..post('/urls', (request) => Response(201))
          ..put('/urls', (request) => Response.ok('Done'))
          ..delete('/urls', (request) => Response.ok('Deleted'))
          ..get('/urls/<id>', (request, url) => Response.found('Found url: $url'));

    return router..mount(namespace, Pipeline().addMiddlewares(exceptionHandlers).addMiddlewares(middlewares).addMiddlewares(validators).addHandler(router.call));
  }
}
