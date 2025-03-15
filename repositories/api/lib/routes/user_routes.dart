// import 'package:shelf/shelf.dart';
// import 'package:shelf_router/shelf_router.dart';
// import 'package:url_shortener_server/shared/route_registry.dart';

// class UserRoutes extends RouteRegistry{
//   UserRoutes({required super.router, required super.middlewares }) : super(namespace: '/users');

//   @override
//   Router registerRoutes() {
//     router.get('/', _getProfileHandler);
//     router.get('/echo/<message>', _getUrlsHandler);
//     return router;
//   }

//   Response _getProfileHandler(Request req) {
//     return Response.ok('Hello, World!\n');
//   }

//   Response _getUrlsHandler(Request request) {
//     final message = request.params['message'];
//     return Response.ok('$message\n');
//   }
// }
