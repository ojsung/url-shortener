import 'package:mysql1/mysql1.dart';
import 'package:url_shortener_server/shared/backoff_retry.dart';
import '../migrations/001_create_users_table.dart';
import '../migrations/002_create_urls_table.dart';
import '../migrations/003_create_users_urls_table.dart';

class Db {
  const Db({
    required String host,
    required int port,
    required String password,
    required String database,
  }) : _host = host,
       _port = port,
       _password = password,
       _database = database;
  final String _host;
  final int _port;
  final String _password;
  final String _database;
  Future<MySqlConnection> createConnection() async {
    final settings = ConnectionSettings(
      host: _host,
      port: _port,
      user: 'mysql',
      password: _password,
      db: _database,
    );
    final conn = BackoffRetry(fn: () async => await MySqlConnection.connect(settings));
    return await conn.call('Create Connection');
  }

  Future<bool> runMigrations(MySqlConnection conn) async {
    // Todo: Would be nice to have an actual migration function. This will do for now.
    while ((await conn.query('SHOW TABLES')).isEmpty) {
      BackoffRetry(fn: CreateUsersTable(conn: conn).up)('CreateUsersTable');
      BackoffRetry(fn: CreateUrlsTable(conn: conn).up)('CreateUrlsTable');
      BackoffRetry(fn: CreateUsersUrlsTable(conn: conn).up)('CreateUsersUrlsTable');
    }
    return true;
  }
}
