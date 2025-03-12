import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'env.dart';
import 'db.dart';

final env = getEnv();
final db = Db(
  host: env.mysqlHost,
  port: int.parse(env.mysqlPort, radix: 10),
  password: env.mysqlRootPassword,
  database: env.mysqlDatabase,
);

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
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  final conn = await db.createConnection();
  final isRanMigrations = await db.runMigrations(conn);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(env.port, radix: 10);
  final server = await serve(handler, ip, port);
  if (!isRanMigrations) {
    print('Failed to run migrations. This probably isn\'t a problem.');
  }
  print('Server listening on port ${server.port}');
}
