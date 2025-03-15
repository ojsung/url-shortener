import 'dart:io';

class Env {
  final String port;
  final String host;
  final String mysqlUser;
  final String mysqlPassword;
  final String mysqlDatabase;
  final String mysqlHost;
  final String mysqlPort;
  final String env;
  final int hashRounds;
  final String createKey;
  final String? passwordKey;

  const Env({
    required this.port,
    required this.host,
    required this.mysqlUser,
    required this.mysqlPassword,
    required this.mysqlDatabase,
    required this.mysqlHost,
    required this.mysqlPort,
    required this.env,
    required this.hashRounds,
    required this.createKey,
    this.passwordKey,
  });

  Env.init()
    : port = Platform.environment['PORT'] ?? '5000',
      host = Platform.environment['HOST'] ?? 'localhost',
      mysqlUser = Platform.environment['MYSQL_USER'] ?? '',
      mysqlPassword = Platform.environment['MYSQL_PASSWORD'] ?? '',
      mysqlDatabase = Platform.environment['MYSQL_DATABASE'] ?? '',
      mysqlHost = Platform.environment['MYSQL_HOST'] ?? '',
      mysqlPort = Platform.environment['MYSQL_PORT'] ?? '',
      env = Platform.environment['ENV'] ?? '',
      hashRounds = int.parse(Platform.environment['HASH_ROUNDS'] ?? '5'),
      createKey = Platform.environment['CREATE_KEY'] ?? '',
      passwordKey =
          Platform.environment['PASSWORD_KEY']?.isEmpty == true
              ? null
              : Platform.environment['PASSWORD_KEY'] {
    if (mysqlUser.isEmpty ||
        mysqlPassword.isEmpty ||
        mysqlDatabase.isEmpty ||
        mysqlHost.isEmpty ||
        mysqlPort.isEmpty ||
        env.isEmpty ||
        createKey.isEmpty) {
      throw Exception(
        'MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE, MYSQL_HOST, MYSQL_PORT, ENV, and CREATE_KEY must be set: \n$this',
      );
    }
  }

  @override
  String toString() {
    return '''
  port: $port
  host: $host
  mysqlUser: $mysqlUser
  mysqlPassword: $mysqlPassword
  mysqlDatabase: $mysqlDatabase
  mysqlHost: $mysqlHost
  mysqlPort: $mysqlPort
  env: $env
  hashRounds: $hashRounds
  createKey: $createKey
  passwordKey: ${passwordKey ?? 'null'}
  ''';
  }
}
