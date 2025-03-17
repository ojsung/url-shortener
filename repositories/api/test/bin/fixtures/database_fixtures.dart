// filepath: /home/admin/dev/url-shortener/repositories/api/test/bin/fixtures/database_fixtures.dart
import 'package:url_shortener_server/services/database_service.dart';
import 'package:url_shortener_server/shared/interfaces/migration.dart';
import 'package:url_shortener_server/shared/query_result.dart';

class MockDatabaseService implements DatabaseService {
  final Map<String, List<Map<String, dynamic>>> _tables = {
    'users': [],
    'urls': [],
    'users_urls': [],
  };

  @override
  Future<QueryResult> execute(String query, [List<dynamic>? values]) async {
    // Mock implementation of the execute method
    // You can add more sophisticated query parsing and handling here
    if (query.startsWith('INSERT INTO')) {
      return _handleInsert(query, values);
    } else if (query.startsWith('SELECT')) {
      return _handleSelect(query, values);
    } else if (query.startsWith('UPDATE')) {
      return _handleUpdate(query, values);
    } else if (query.startsWith('DELETE')) {
      return _handleDelete(query, values);
    }
    throw UnimplementedError('Query not supported in mock database');
  }

  QueryResult _handleInsert(String query, List<dynamic>? values) {
    final tableName = _getTableName(query);
    final table = _tables[tableName];
    if (table == null) {
      throw Exception('Table $tableName does not exist');
    }
    final id = table.length + 1;
    final newRow = {'id': id.toString()};
    for (var i = 0; i < values!.length; i++) {
      newRow['column$i'] = values[i];
    }
    table.add(newRow);
    return QueryResult([newRow], lastInsertId: BigInt.from(id), affectedRows: BigInt.from(1));
  }

  QueryResult _handleSelect(String query, List<dynamic>? values) {
    final tableName = _getTableName(query);
    final table = _tables[tableName];
    if (table == null) {
      throw Exception('Table $tableName does not exist');
    }
    return QueryResult(table, affectedRows: BigInt.zero, lastInsertId: BigInt.zero);
  }

  QueryResult _handleUpdate(String query, List<dynamic>? values) {
    final tableName = _getTableName(query);
    final table = _tables[tableName];
    if (table == null) {
      throw Exception('Table $tableName does not exist');
    }

    final whereClause = query.split('WHERE').last.trim();
    final whereParts = whereClause.split('=');
    final columnName = whereParts[0].trim();
    final columnValue = whereParts[1].trim().replaceAll("'", "");

    int updatedRows = 0;
    for (var row in table) {
      if (row[columnName] == columnValue) {
      for (var i = 0; i < values!.length; i++) {
        row['column$i'] = values[i];
      }
      updatedRows++;
      }
    }

    return QueryResult([], affectedRows: BigInt.from(updatedRows), lastInsertId: BigInt.zero);
  }

  QueryResult _handleDelete(String query, List<dynamic>? values) {
    final tableName = _getTableName(query);
    final table = _tables[tableName];
    if (table == null) {
      throw Exception('Table $tableName does not exist');
    }

    final whereClause = query.split('WHERE').last.trim();
    final whereParts = whereClause.split('=');
    final columnName = whereParts[0].trim();
    final columnValue = whereParts[1].trim().replaceAll("'", "");

    int deletedRows = 0;
    table.removeWhere((row) {
      if (row[columnName] == columnValue) {
        deletedRows++;
        return true;
      }
      return false;
    });

    return QueryResult([], affectedRows: BigInt.from(deletedRows), lastInsertId: BigInt.zero);
  }

  String _getTableName(String query) {
    final regex = RegExp(r'FROM `(\w+)`');
    final match = regex.firstMatch(query);
    if (match == null) {
      throw Exception('Table name not found in query');
    }
    return match.group(1)!;
  }

  @override
  Future<void> closeAllConnections() {
    // TODO: implement closeAllConnections
    return Future.value();
  }

  @override
  Future<bool> commitMigrations() {
    // TODO: implement commitMigrations
    return Future.value(true);
  }

  @override
  // TODO: implement migrations
  List<Migration> get migrations => throw UnimplementedError();

  @override
  Future<bool> rollbackMigrations() {
    // TODO: implement rollbackMigrations
    return Future.value(true);
  }
}

