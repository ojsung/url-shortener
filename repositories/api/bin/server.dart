import 'dart:io';

import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart' show Pipeline, logRequests;
import 'package:shelf/shelf_io.dart' show serve;
import 'package:shelf_router/shelf_router.dart' show Router;
import 'package:url_shortener_server/migrations/001_create_users_table.dart';
import 'package:url_shortener_server/migrations/002_create_urls_table.dart';
import 'package:url_shortener_server/migrations/003_create_users_urls_table.dart';
import 'package:url_shortener_server/routes/auth_routes.dart' show AuthRoutes;
import 'package:url_shortener_server/shared/globals.dart' show getIt;
import 'package:url_shortener_server/shared/interfaces/migration.dart' show Migration;
import './injector.dart' as di;
import 'package:url_shortener_server/shared/env.dart' show Env;
import 'package:url_shortener_server/services/database_service.dart'
    show DatabaseService;

void main(List<String> args) async {
  di.setupInjector();
  final env = getIt.get<Env>();

  try {
    // Set up the database and run migrations
    final db = getIt.get<DatabaseService>();
    // todo: It's fine for this to live here, but if I have time, come back and put it elsewhere
    final List<Migration> migrations = [
      CreateUsersTable(),
      CreateUrlsTable(),
      CreateUsersUrlsTable(),
    ];
    for (final migration in migrations) {
      final MySqlConnection connection = await db.createConnection();
      await connection.query(migration.up());
      db.releaseConnection(connection);
    }

    print('Migrations complete');
  } catch (e) {
    print('Failed to create database connection: $e');
  }

  final ip = InternetAddress.anyIPv4;

  // Set up the router and routes
  final Router rootRouter = getIt<Router>();

  final AuthRoutes authRoutes = getIt<AuthRoutes>();

  authRoutes.registerRoutes(rootRouter);
  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(rootRouter.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(env.port, radix: 10);
  final server = await serve(handler, ip, port);
  print(
    '${env.env == 'development' ? 'Dev server' : 'server'} listening on port ${server.port}',
  );
}
