import 'dart:io';
import 'dart:math';

import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:url_shortener_server/shared/backoff_retry.dart';

import 'env.dart';
import 'db.dart';

// Configure routes.
final _router =
    Router()
      ..get('/', _rootHandler)
      ..get('/echo/<message>', _echoHandler);

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

void main(List<String> args) async {
  final env = getEnv();

  Db db;
  try {
    db = Db(
      host: env.mysqlHost,
      port: int.parse(env.mysqlPort),
      password: env.mysqlRootPassword,
      database: env.mysqlDatabase,
    );
    final conn = await db.createConnection();
    final isRanMigrations = await db.runMigrations(conn);
    if (!isRanMigrations) {
      print('Failed to run migrations. This probably isn\'t a problem.');
    }
  } catch (e) {
    print('Failed to create database connection: $e');
  }

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(env.port, radix: 10);
  final server = await serve(handler, ip, port);
  print(
    '${env.env == 'development' ? 'Dev server' : 'server'} listening on port ${server.port}',
  );
}
