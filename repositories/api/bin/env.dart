import 'dart:io';

class Env {
  final String port;
  final String host;
  final String mysqlRootPassword;
  final String mysqlDatabase;
  final String mysqlHost;
  final String mysqlPort;

  Env({
    required this.port,
    required this.host,
    required this.mysqlRootPassword,
    required this.mysqlDatabase,
    required this.mysqlHost,
    required this.mysqlPort,
  });
}

Env getEnv() {
  final env = Platform.environment;
  final port = env['PORT'] ?? '5000';
  final host = env['HOST'] ?? 'localhost';
  final mysqlRootPassword = env['MYSQL_ROOT_PASSWORD'];
  final mysqlDatabase = env['MYSQL_DATABASE'];
  final mysqlHost = env['MYSQL_HOST'];
  final mysqlPort = env['MYSQL_PORT'];
  if (mysqlRootPassword == null ||
      mysqlRootPassword.isEmpty ||
      mysqlDatabase == null ||
      mysqlDatabase.isEmpty ||
      mysqlHost == null ||
      mysqlHost.isEmpty ||
      mysqlPort == null ||
      mysqlPort.isEmpty) {
    throw Exception(
      'MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, and MYSQL_HOST must be set',
    );
  }

  return Env(
    port: port,
    host: host,
    mysqlRootPassword: mysqlRootPassword,
    mysqlDatabase: mysqlDatabase,
    mysqlHost: mysqlHost,
    mysqlPort: mysqlPort,
  );
}
