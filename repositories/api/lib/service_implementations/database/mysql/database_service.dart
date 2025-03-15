import 'package:mysql1/mysql1.dart';
import 'package:url_shortener_server/shared/backoff_retry.dart';
import 'package:url_shortener_server/services/database_service.dart';
import 'package:url_shortener_server/service_implementations/database/mysql/mysql_connection_pool_service.dart';

class DatabaseServiceImpl implements DatabaseService {
  DatabaseServiceImpl({
    required String host,
    required int port,
    required String user,
    required String password,
    required String database,
  }) : _connectionPool = MySqlConnectionPool(
         host: host,
         port: port,
         user: user,
         password: password,
         database: database,
       );
  final MySqlConnectionPool _connectionPool;

  @override
  Future<MySqlConnection> createConnection() async {
    return await _connectionPool.getConnection();
  }

  @override
  void releaseConnection(MySqlConnection connection) {
    _connectionPool.releaseConnection(connection);
  }

  @override
  Future<void> closeAllConnections() async {
    await _connectionPool.closeAllConnections();
  }

  @override
  Future<Results> query(String sql, [List<Object?>? values]) {
    return BackoffRetry(
      fn: () async {
        MySqlConnection? connection;
        try {
          connection = await createConnection();
          return await connection.query(sql, values);
        } catch (e) {
          rethrow;
        } finally {
          if (connection != null) {
            releaseConnection(connection);
          }
        }
      }, maxRetries: 3,
    ).call('Querying the database');
  }
}
