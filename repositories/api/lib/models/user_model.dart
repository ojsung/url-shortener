import 'dart:convert' show json;

import 'package:mysql_client/mysql_client.dart';
import 'package:url_shortener_server/models/user_partial.dart' show UserPartial;
import 'package:url_shortener_server/services/database_service.dart' show DatabaseService;
import 'package:url_shortener_server/shared/interfaces/insert_result.dart';
import 'package:url_shortener_server/shared/interfaces/model.dart';
import 'package:url_shortener_server/shared/where_clause.dart';

class User extends Model<User, UserPartial> implements UserPartial {
  static const String tableName = 'users';
  @override
  final int id;
  @override
  final String username;
  @override
  final String password;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deletedAt;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.createdAt,
    required this.modifiedAt,
    this.deletedAt,
  });

  User.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      username = json['username'],
      password = json['password'],
      createdAt = DateTime.parse(json['created_at']),
      modifiedAt = DateTime.parse(json['modified_at']),
      deletedAt = json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null;
  User.fromRow(ResultSetRow row)
    : id = int.parse(row.colAt(0) as String),
      username = row.colAt(1) as String,
      password = row.colAt(2) as String,
      createdAt = DateTime.parse(row.colAt(3) as String),
      modifiedAt = DateTime.parse(row.colAt(4) as String),
      deletedAt = row.colAt(5) == null ? null : DateTime.parse(row.colAt(5) as String);

  static Future<InsertResult> create(UserPartial model) async {
    final username = model.username;
    final password = model.password;
    if (username == null) {
      throw Exception('Username is required to create a User');
    }
    if (password == null) {
      throw Exception('Password is required to create a User');
    }
    ResultSetRow? existingUser = await _findFirstbyUsername(username);
    if (existingUser != null) {
      throw Exception('A user with that uesrname already exists');
    }
    IResultSet results = await Model.databaseService.execute(
      '''
          INSERT INTO users (username, password)
          VALUES (?, ?)
        ''',
      [username, password],
    );

    final BigInt affectedRows = results.affectedRows;
    final BigInt lastInsertId = results.lastInsertID;
    return InsertResult(lastInsertId: lastInsertId, affectedRows: affectedRows);
  }

  static Future<List<User>> read(UserPartial model) async {
    final WhereClause whereClause = _buildWhereClause(model);
    DatabaseService db = Model.databaseService;
    IResultSet results = await db.execute('''
          SELECT * FROM users
          WHERE ${whereClause.where.join(' AND ')}
          AND deleted_at IS NULL
        ''', whereClause.values);
    Iterable<User> usersFromRows = results.rows.map<User>(User.fromRow);
    return usersFromRows.toList();
  }

  static Future<List<User>> update(UserPartial model) async {
    final id = model.id;
    if (id == null) {
      throw Exception('ID is required to update a User');
    }
    if (model.username == null && model.password == null) {
      throw Exception('At least one field is required to update a User');
    }
    UserPartial partial = UserPartial(username: model.username, password: model.password);
    final WhereClause whereClause = _buildWhereClause(partial);
    DatabaseService db = Model.databaseService;
    IResultSet results = await db.execute(
      '''
          UPDATE users
          SET ${whereClause.where.join(', ')}
          WHERE id = ?
        ''',
      [...whereClause.values, id],
    );
    Iterable<User> usersFromRows = results.rows.map<User>(User.fromRow);
    return usersFromRows.toList();
  }

  static Future<List<User>> delete(UserPartial model, [hard = false]) async {
    final WhereClause whereClause = _buildWhereClause(model);
    final DatabaseService db = Model.databaseService;
    IResultSet results;
    if (hard) {
      results = await db.execute('''
    DELETE FROM users
    WHERE ${whereClause.where.join(' AND ')}
''', whereClause.values);
    } else {
      results = await db.execute(
        '''
          UPDATE users
          SET deleted_at = ?
          WHERE ${whereClause.where.join(' AND ')}
        ''',
        [DateTime.now(), ...whereClause.values],
      );
    }
    Iterable<User> usersFromRows = results.rows.map<User>(User.fromRow);
    return usersFromRows.toList();
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, password: $password, createdAt: $createdAt, modifiedAt: $modifiedAt, deletedAt: $deletedAt)';
  }

  @override
  String toJsonString() {
    return json.encode({id: id, username: username, password: password});
  }

  @override
  User copyWithJson(Map<String, dynamic> changes) {
    return User(
      id: changes['id'] ?? id,
      username: changes['username'] ?? username,
      password: changes['password'] ?? password,
      createdAt: changes['createdAt'] ?? createdAt,
      modifiedAt: changes['modifiedAt'] ?? modifiedAt,
      deletedAt: changes['deletedAt'] ?? deletedAt,
    );
  }

  @override
  User copyWithPartial(UserPartial partial) {
    return User(
      id: partial.id ?? id,
      username: partial.username ?? username,
      password: partial.password ?? password,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      deletedAt: deletedAt,
    );
  }

  @override
  UserPartial toPartial() {
    return UserPartial(id: id, username: username, password: password);
  }

  static WhereClause _buildWhereClause(UserPartial model) {
    List<String> where = [];
    List<dynamic> values = [];
    if (model.id != null) {
      where.add('id = ?');
      values.add(model.id);
    }
    if (model.username != null) {
      where.add('username = ?');
      values.add(model.username);
    }
    if (model.password != null) {
      where.add('password = ?');
      values.add(model.password);
    }
    return WhereClause(where: where, values: values);
  }

  static Future<ResultSetRow?> _findFirstbyUsername(String username) async {
    IResultSet result = await Model.databaseService.execute(
      '''
      SELECT *
        FROM `users`
        WHERE `users`.`username` = ?
        AND `users`.`deleted_at` IS NULL;
      ''',
      [username],
    );
    return result.rows.firstOrNull;
  }
}
