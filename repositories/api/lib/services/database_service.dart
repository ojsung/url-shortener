import 'package:mysql_client/mysql_client.dart';
import 'package:url_shortener_server/shared/interfaces/migration.dart';

// todo: If I have time, come back and create proper interfaces for the connection and result set
// it should not have to use the imported IResultSet, but that's a problem to tackle if I have extra time
abstract class DatabaseService {
  List<Migration> get migrations;
  Future<void> closeAllConnections();
  Future<IResultSet> execute(String sql, [List<Object?>? values]);
  Future<bool> commitMigrations();
  Future<bool> rollbackMigrations();
}
