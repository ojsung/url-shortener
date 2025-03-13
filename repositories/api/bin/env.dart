import 'dart:io';

class Env {
  final String port;
  final String host;
  final String mysqlRootPassword;
  final String mysqlDatabase;
  final String mysqlHost;
  final String mysqlPort;
  final String env;

  const Env({
    required this.port,
    required this.host,
    required this.mysqlRootPassword,
    required this.mysqlDatabase,
    required this.mysqlHost,
    required this.mysqlPort,
    required this.env,
  });

  @override
  String toString() {
    return '''
  port: $port
  host: $host
  mysqlRootPassword: $mysqlRootPassword
  mysqlDatabase: $mysqlDatabase
  mysqlHost: $mysqlHost
  mysqlPort: $mysqlPort
  env: $env
  ''';
  }
}

Env getEnv() {
  final platformEnv = Platform.environment;
  final port = platformEnv['PORT'] ?? '5000';
  final host = platformEnv['HOST'] ?? 'localhost';
  final mysqlRootPassword = platformEnv['MYSQL_ROOT_PASSWORD'];
  final mysqlDatabase = platformEnv['MYSQL_DATABASE'];
  final mysqlHost = platformEnv['MYSQL_HOST'];
  final mysqlPort = platformEnv['MYSQL_PORT'];
  final env = platformEnv['ENV'];
  if (mysqlRootPassword == null ||
      mysqlRootPassword.isEmpty ||
      mysqlDatabase == null ||
      mysqlDatabase.isEmpty ||
      mysqlHost == null ||
      mysqlHost.isEmpty ||
      mysqlPort == null ||
      mysqlPort.isEmpty ||
      env == null ||
      env.isEmpty) {
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
    env: env,
  );
}
