import 'package:mysql1/mysql1.dart';
import '../migrations/001_create_users_table.dart';
import '../migrations/002_create_urls_table.dart';
import '../migrations/003_create_users_urls_table.dart';

class Db {
  const Db({required String host, required int port, required String password, required String database})
    : _host = host,
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
      user: 'root',
      password: _password,
      db: _database,
    );
    final conn = await MySqlConnection.connect(settings);
    return conn;
  }

  Future<bool> runMigrations(MySqlConnection conn) async {
    final migrations = [
      CreateUsersTable(conn: conn).up,
      CreateUrlsTable(conn: conn).up,
      CreateUsersUrlsTable(conn: conn).up,
    ];
    try {
      for (final migration in migrations) {
        await migration();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
