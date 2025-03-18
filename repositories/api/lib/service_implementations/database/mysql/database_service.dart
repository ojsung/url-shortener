import 'dart:async';

import 'package:mysql_client/mysql_client.dart';
import 'package:url_shortener_server/shared/backoff_retry.dart';
import 'package:url_shortener_server/services/database_service.dart';
import 'package:url_shortener_server/shared/interfaces/migration.dart';
import 'package:url_shortener_server/shared/query_result.dart' show QueryResult, QueryRow;

class DatabaseServiceImpl implements DatabaseService {
  final BackoffRetry<IResultSet> _backoffExecutor = BackoffRetry(maxRetries: 4);
  final MySQLConnectionPool _connectionPool;
  @override
  final List<Migration> migrations;
  DatabaseServiceImpl({
    required String host,
    required int port,
    required String user,
    required String password,
    required String database,
    required this.migrations,
  }) : _connectionPool = MySQLConnectionPool(
         host: host,
         port: port,
         userName: user,
         password: password,
         databaseName: database,
         maxConnections: 10,
       );

  @override
  Future<QueryResult> execute(String query, [List<Object?>? params]) async {
    final FutureOr<IResultSet> Function() querent;
    if (params != null) {
      querent = () => _executeWithQueryParams(query, params);
    } else {
      querent = () => _connectionPool.execute(query);
    }
    final IResultSet results = await _backoffExecutor.call(querent, 'Query Execution');
    return _resultSetToQueryResult(results);
  }

  @override
  Future<void> closeAllConnections() async {
    return await _connectionPool.close();
  }

  @override
  Future<bool> commitMigrations() async {
    // Would love to have an actual way to properly run these migrations, but I dont' have time I'm afraid
    int counter = 1;
    final int migrationLength = migrations.length;
    try {
      print('Running migrations! ($migrationLength)');
      for (final migration in migrations) {
        print('Executing migration $counter/$migrationLength');
        await execute(migration.up());
        counter++;
      }
      return true;
    } catch (e) {
      print('Failed on migration $counter/$migrationLength: $e');
      return false;
    }
  }

  @override
  Future<bool> rollbackMigrations() async {
    final int migrationLength = migrations.length;
    int counter = migrationLength;
    try {
      print('Rolling back migrations! ($migrationLength)');
      for (final migration in migrations.reversed) {
        print('Rolling back migration $counter/$migrationLength');
        await execute(migration.down());
        counter--;
      }
      return true;
    } catch (e) {
      print('Failed on migration $counter/$migrationLength: $e');
      return false;
    }
  }

  Future<IResultSet> _executeWithQueryParams(String query, List<Object?> params) async {
    PreparedStmt preparedStatement = await _connectionPool.prepare(query);
    IResultSet resultSet = await preparedStatement.execute(params);
    await preparedStatement.deallocate();
    return resultSet;
  }

  QueryResult _resultSetToQueryResult(
    IResultSet resultSet,
  ) {
    return QueryResult(
      resultSet.rows.map<QueryRow>((row) => row.assoc()).toList(),
      lastInsertId: resultSet.lastInsertID,
      affectedRows: resultSet.affectedRows,
    );
  }
}
