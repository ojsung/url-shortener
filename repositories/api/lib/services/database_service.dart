import 'package:url_shortener_server/shared/interfaces/migration.dart';
import 'package:url_shortener_server/shared/query_result.dart' show QueryResult;

abstract class DatabaseService {
  List<Migration> get migrations;
  Future<void> closeAllConnections();
  /// Executes a query on the database with a retry strategy and exponential backoff
  Future<QueryResult> execute(String sql, [List<Object?>? values]);
  Future<bool> commitMigrations();
  Future<bool> rollbackMigrations();
}
