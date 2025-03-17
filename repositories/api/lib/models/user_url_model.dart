import 'dart:convert' show json;

import 'package:url_shortener_server/exceptions/exceptions.dart';
import 'package:url_shortener_server/models/user_partial.dart' show UserPartial;
import 'package:url_shortener_server/models/user_url_partial.dart';
import 'package:url_shortener_server/services/database_service.dart' show DatabaseService;
import 'package:url_shortener_server/shared/interfaces/model.dart';
import 'package:url_shortener_server/shared/interfaces/partial.dart';
import 'package:url_shortener_server/shared/query_result.dart';
import 'package:url_shortener_server/shared/where_clause.dart';

class UserUrl extends Model<UserUrl, UserUrlPartial> {
  static const String tableName = 'users';
  final int id;
  final int userId;
  final int urlId;

  UserUrl({
    required this.id,
    required this.userId,
    required this.urlId,
  });

  UserUrl.fromJson(Map<String, dynamic> json)
    : id = int.parse(json['id']),
      userId = int.parse(json['user_id']),
      urlId = int.parse(json['url_id']);

  static Future<QueryResult> create(UserPartial model) async {
    final username = model.username;
    final password = model.password;
    if (username == null) {
      throw IncompleteDataException('Username is required to create a User');
    }
    if (password == null) {
      throw IncompleteDataException('Password is required to create a User');
    }
    QueryResult existingUser = await _findFirstbyUsername(username);
    if (existingUser.isNotEmpty) {
      throw DuplicateUserException();
    }
    QueryResult results = await Model.databaseService.execute(
      '''
          INSERT INTO users (username, password)
          VALUES (?, ?)
        ''',
      [username, password],
    );

    if (results.lastInsertId == BigInt.zero) {
      throw UnknownInsertException('Unable to create new model');
    }
    return results;
  }

  static Future<List<User>> read(UserPartial model) async {
    final WhereClause whereClause = _buildWhereClause(model);
    DatabaseService db = Model.databaseService;
    QueryResult results = await db.execute('''
          SELECT * FROM users
          WHERE ${whereClause.where.join(' AND ')}
          AND deleted_at IS NULL
        ''', whereClause.values);
    Iterable<User> usersFromRows = results.toModels();
    return usersFromRows.toList();
  }

  static Future<QueryResult> update(UserPartial model) async {
    final id = model.id;
    if (id == null) {
      throw MissingIdException('ID is required to update a User');
    }
    if (model.username == null && model.password == null) {
      throw IncompleteDataException('At least one field is required to update a User');
    }
    UserPartial partial = UserPartial(username: model.username, password: model.password);
    final WhereClause whereClause = _buildWhereClause(partial);
    DatabaseService db = Model.databaseService;
    QueryResult results = await db.execute(
      '''
          UPDATE users
          SET ${whereClause.where.join(', ')}
          WHERE id = ?
        ''',
      [...whereClause.values, id],
    );
    return results;
  }

  static Future<QueryResult> delete(UserPartial model, [hard = false]) async {
    final WhereClause whereClause = _buildWhereClause(model);
    final DatabaseService db = Model.databaseService;
    QueryResult results;
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
    return results;
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

  static Future<QueryResult> _findFirstbyUsername(String username) async {
    QueryResult result = await Model.databaseService.execute(
      '''
      SELECT *
        FROM `users`
        WHERE `users`.`username` = ?
        AND `users`.`deleted_at` IS NULL;
      ''',
      [username],
    );
    return result;
  }
}

extension on QueryResult {
  Iterable<User> toModels() {
    return map(User.fromJson);
  }
}
