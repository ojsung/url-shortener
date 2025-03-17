import 'dart:convert' show json;

import 'package:url_shortener_server/exceptions/exceptions.dart';
import 'package:url_shortener_server/models/url_model.dart';
import 'package:url_shortener_server/models/user_url_partial.dart';
import 'package:url_shortener_server/services/database_service.dart'
    show DatabaseService;
import 'package:url_shortener_server/shared/interfaces/model.dart';
import 'package:url_shortener_server/shared/query_result.dart';
import 'package:url_shortener_server/shared/where_clause.dart';

class UserUrl extends Model<UserUrl, UserUrlPartial> {
  static const String tableName = 'users_urls';
  final int id;
  final int userId;
  final int urlId;
  List<Url>? _urls;

  UserUrl({required this.id, required this.userId, required this.urlId});

  UserUrl.fromJson(Map<String, dynamic> json)
    : id = int.parse(json['id']),
      userId = int.parse(json['user_id']),
      urlId = int.parse(json['url_id']);

  static Future<QueryResult> create(UserUrlPartial model) async {
    final userId = model.userId;
    final urlId = model.urlId;
    if (userId == null) {
      throw IncompleteDataException('User ID is required to create a UserUrl');
    }
    if (urlId == null) {
      throw IncompleteDataException('URL ID is required to create a UserUrl');
    }
    QueryResult results = await Model.databaseService.execute(
      '''
          INSERT INTO users_urls (user_id, url_id)
          VALUES (?, ?)
        ''',
      [userId, urlId],
    );

    if (results.lastInsertId == BigInt.zero) {
      throw UnknownInsertException('Unable to create new model');
    }
    return results;
  }

  static Future<List<UserUrl>> read(UserUrlPartial model) async {
    final WhereClause whereClause = _buildWhereClause(model);
    DatabaseService db = Model.databaseService;
    QueryResult results = await db.execute('''
          SELECT * FROM users_urls
          WHERE ${whereClause.where.join(' AND ')}
        ''', whereClause.values);
    Iterable<UserUrl> userUrlsFromRows = results.toModels();
    return userUrlsFromRows.toList();
  }

  static Future<QueryResult> delete(UserUrlPartial model) async {
    final WhereClause whereClause = _buildWhereClause(model);
    final DatabaseService db = Model.databaseService;
    QueryResult results;
    results = await db.execute('''
    DELETE FROM users_urls
    WHERE ${whereClause.where.join(' AND ')}
''', whereClause.values);

    return results;
  }

  Future<List<Url>> getUrls([forceRefresh = false]) async {
    final List<Url>? cachedUrls = _urls;
    if (!forceRefresh && cachedUrls != null) {
      return cachedUrls;
    }
    final List<Url> urls = await UserUrl.getUrlsByUserId(userId);
    _urls = urls;
    return urls;
  }

  @override
  String toString() {
    return 'UserUrl(id: $id, userId: $userId, urlId: $urlId)';
  }

  @override
  String toJsonString() {
    return json.encode({id: id, userId: userId, urlId: urlId});
  }

  @override
  UserUrl copyWithJson(Map<String, dynamic> changes) {
    return UserUrl(
      id: changes['id'] ?? id,
      userId: changes['user_id'] ?? userId,
      urlId: changes['url_id'] ?? urlId,
    );
  }

  @override
  UserUrl copyWithPartial(UserUrlPartial partial) {
    return UserUrl(
      id: partial.id ?? id,
      userId: partial.userId ?? userId,
      urlId: partial.urlId ?? urlId,
    );
  }

  static WhereClause _buildWhereClause(UserUrlPartial model) {
    List<String> where = [];
    List<dynamic> values = [];
    if (model.id != null) {
      where.add('id = ?');
      values.add(model.id);
    }
    if (model.userId != null) {
      where.add('user_id = ?');
      values.add(model.userId);
    }
    if (model.urlId != null) {
      where.add('url_id = ?');
      values.add(model.urlId);
    }
    return WhereClause(where: where, values: values);
  }

  /// Get all URLs associated with a user that are not deleted
  static Future<List<Url>> getUrlsByUserId(int userId) async {
    DatabaseService db = Model.databaseService;
    QueryResult results = await db.execute(
      '''
      SELECT urls.* FROM users_urls
      JOIN urls ON users_urls.url_id = urls.id
      WHERE users_urls.user_id = ?
      AND urls.deleted_at IS NULL
        ''',
      [userId],
    );
    final mappedUrls = results.map(Url.fromJson).toList();
    return mappedUrls;
  }
}

extension on QueryResult {
  Iterable<UserUrl> toModels() {
    return map(UserUrl.fromJson);
  }
}
