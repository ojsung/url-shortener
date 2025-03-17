import 'dart:io';

import 'package:shelf/shelf.dart' show Pipeline, logRequests;
import 'package:shelf/shelf_io.dart' show serve;
import 'package:shelf_router/shelf_router.dart' show Router;
import 'package:url_shortener_server/routes/auth_routes.dart' show AuthRoutes;
import 'package:url_shortener_server/routes/shortened_url_routes.dart';
import 'package:url_shortener_server/routes/url_routes.dart';
import 'package:url_shortener_server/routes/user_routes.dart';
import 'package:url_shortener_server/services/database_service.dart';
import 'package:url_shortener_server/shared/globals.dart' show getIt;
import './injector.dart' as di;
import 'package:url_shortener_server/shared/env.dart' show Env;

void main(List<String> args) async {
  di.setupInjector();
  final env = getIt.get<Env>();
  final db = getIt.get<DatabaseService>();
  try {
    await db.commitMigrations();
  } catch (e) {
    print('App initialization failed!');
    rethrow;
  }

  final ip = InternetAddress.anyIPv4;

  // Set up the router and routes
  final Router rootRouter = getIt<Router>();

  final AuthRoutes authRoutes = getIt<AuthRoutes>();
  final UrlRoutes urlRoutes = getIt<UrlRoutes>();
  final ShortenedUrlRoutes shortenedRoutes = getIt<ShortenedUrlRoutes>();
  final UserRoutes userRoutes = getIt<UserRoutes>();
  authRoutes.registerRoutes(rootRouter);
  urlRoutes.registerRoutes(rootRouter);
  shortenedRoutes.registerRoutes(rootRouter);
  userRoutes.registerRoutes(rootRouter);
  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(rootRouter.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(env.port, radix: 10);
  final server = await serve(handler, ip, port);
  print('${env.env == 'development' ? 'Dev server' : 'server'} listening on port ${server.port}');
}
