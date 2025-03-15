import 'package:mysql1/mysql1.dart' show MySqlConnection, Results;

typedef Querent = Future<Results> Function(String sql, [List<Object?>? values]);

// todo: If I have time, come back and create proper interfaces for the connection
// and replace MySqlConnection with the interface
abstract class DatabaseService {
  Future<MySqlConnection> createConnection();
  void releaseConnection(MySqlConnection connection);
  Future<void> closeAllConnections();
  Future<Results> query(String sql, [List<Object?>? values]);
}
