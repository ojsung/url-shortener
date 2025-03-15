import 'dart:convert' show json;

import 'package:mysql1/mysql1.dart';
import 'package:url_shortener_server/models/user_partial.dart' show UserPartial;
import 'package:url_shortener_server/services/database_service.dart'
    show DatabaseService;
import 'package:url_shortener_server/shared/globals.dart';
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
      deletedAt =
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'])
              : null;
  User.fromRow(ResultRow row)
    : id = row[0] as int,
      username = row[1] as String,
      password = row[2] as String,
      createdAt = row[3] as DateTime,
      modifiedAt = row[4] as DateTime,
      deletedAt = row[5] as DateTime?;

  static Future<List<User>> create(UserPartial model) async {
    final username = model.username;
    final password = model.password;
    if (username == null) {
      throw Exception('Username is required to create a User');
    }
    if (password == null) {
      throw Exception('Password is required to create a User');
    }
    MySqlConnection connection =
        await getIt<DatabaseService>().createConnection();
    Results query = await connection.query(
      '''
      INSERT INTO users (username, password)
      VALUES (?, ?)
    ''',
      [username, password],
    );

    final List<User> createdUsers = query.map(User.fromRow).toList();
    print('created users: $createdUsers');
    return createdUsers;
  }

  static Future<List<User>> read(UserPartial model) async {
    final WhereClause whereClause = _buildWhereClause(model);
    MySqlConnection connection = await Model.databaseService.createConnection();
    Results query = await connection.query('''
      SELECT * FROM users
      WHERE ${whereClause.where.join(' AND ')}
    ''', whereClause.values);
    Model.databaseService.releaseConnection(connection);
    return query.map(User.fromRow).toList();
  }

  static Future<List<User>> delete(UserPartial model) async {
    final WhereClause whereClause = _buildWhereClause(model);
    MySqlConnection connection =
        await getIt<DatabaseService>().createConnection();
    Results results = await connection.query('''
      DELETE FROM users
      WHERE ${whereClause.where.join(' AND ')}
    ''', whereClause.values);
    return results.map(User.fromRow).toList();
  }

  static Future<List<User>> update(UserPartial model) async {
    final id = model.id;
    if (id == null) {
      throw Exception('ID is required to update a User');
    }
    if (model.username == null && model.password == null) {
      throw Exception('At least one field is required to update a User');
    }
    UserPartial partial = UserPartial(
      username: model.username,
      password: model.password,
    );
    final WhereClause whereClause = _buildWhereClause(partial);
    MySqlConnection connection =
        await getIt<DatabaseService>().createConnection();
    Results query = await connection.query(
      '''
      UPDATE users
      SET ${whereClause.where.join(', ')}
      WHERE id = ?
    ''',
      [...whereClause.values, id],
    );
    return query.map(User.fromRow).toList();
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
}
