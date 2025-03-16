import 'dart:convert' show json;

import 'package:mysql_client/mysql_client.dart';
import 'package:url_shortener_server/models/url_partial.dart' show UrlPartial;
import 'package:url_shortener_server/shared/interfaces/model.dart';
import 'package:url_shortener_server/shared/where_clause.dart';

class Url implements Model<Url, UrlPartial>, UrlPartial {
  static const String tableName = 'urls';
  @override
  final int id;
  @override
  final String url;
  @override
  final String shortenedUrl;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deletedAt;

  Url({
    required this.id,
    required this.url,
    required this.shortenedUrl,
    required this.createdAt,
    required this.modifiedAt,
    this.deletedAt,
  });

  Url.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      url = json['url'],
      shortenedUrl = json['shortened_url'],
      createdAt = DateTime.parse(json['created_at']),
      modifiedAt = DateTime.parse(json['modified_at']),
      deletedAt =
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'])
              : null;
  Url.fromRow(ResultSetRow row)
    : id = row.typedColAt<int>(0) as int,
      url = row.typedColAt<String>(1) as String,
      shortenedUrl = row.typedColAt<String>(2) as String,
      createdAt = row.typedColAt<DateTime>(3) as DateTime,
      modifiedAt = row.typedColAt<DateTime>(4) as DateTime,
      deletedAt = row.typedColAt<DateTime>(5);

  @override
  Url copyWithJson(Map<String, dynamic> changes) {
    return Url(
      id: changes['id'] ?? id,
      url: changes['url'] ?? url,
      shortenedUrl: changes['shortenedUrl'] ?? shortenedUrl,
      createdAt: changes['createdAt'] ?? createdAt,
      modifiedAt: changes['modifiedAt'] ?? modifiedAt,
      deletedAt: changes['deletedAt'] ?? deletedAt,
    );
  }

  @override
  Url copyWithPartial(UrlPartial partial) {
    return Url(
      id: partial.id ?? id,
      url: partial.url ?? url,
      shortenedUrl: partial.shortenedUrl ?? shortenedUrl,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      deletedAt: deletedAt,
    );
  }

  @override
  UrlPartial toPartial() {
    return UrlPartial(id: id, url: url, shortenedUrl: shortenedUrl);
  }

  static Future<List<Url>> create(UrlPartial model) async {
    final url = model.url;
    final shortenedUrl = model.shortenedUrl;
    if (url == null) {
      throw Exception('URL is required to create a Url');
    }
    if (shortenedUrl == null) {
      throw Exception('Shortened URL is required to create a Url');
    }
    IResultSet query = await Model.databaseService.execute(
      '''
      INSERT INTO urls (url, shortened_url)
      VALUES (?, ?)
    ''',
      [url, shortenedUrl],
    );
    return query.rows.map(Url.fromRow).toList();
  }

  static Future<List<Url>> read(UrlPartial model) async {
    final WhereClause whereClause = _buildWhereClause(model);
    IResultSet query = await Model.databaseService.execute('''
      SELECT * FROM urls
      WHERE ${whereClause.where.join(' AND ')}
    ''', whereClause.values);
    List<Url> results = query.rows.map(Url.fromRow).toList();
    return results;
  }

  static Future<List<Url>> delete(UrlPartial model) async {
    final WhereClause whereClause = _buildWhereClause(model);
    IResultSet results = await Model.databaseService.execute('''
      DELETE FROM urls
      WHERE ${whereClause.where.join(' AND ')}
    ''', whereClause.values);
    return results.rows.map(Url.fromRow).toList();
  }

  static Future<List<Url>> update(UrlPartial model) async {
    final id = model.id;
    if (id == null) {
      throw Exception('ID is required to update a Url');
    }
    if (model.url == null && model.shortenedUrl == null) {
      throw Exception('At least one field is required to update a Url');
    }
    UrlPartial partial = UrlPartial(
      url: model.url,
      shortenedUrl: model.shortenedUrl,
    );
    final WhereClause whereClause = _buildWhereClause(partial);
    IResultSet query = await Model.databaseService.execute(
      '''
      UPDATE urls
      SET ${whereClause.where.join(', ')}
      WHERE id = ?
    ''',
      [...whereClause.values, id],
    );
    return query.rows.map(Url.fromRow).toList();
  }

  static WhereClause _buildWhereClause(UrlPartial model) {
    List<String> where = [];
    List<dynamic> values = [];
    if (model.id != null) {
      where.add('id = ?');
      values.add(model.id);
    }
    if (model.url != null) {
      where.add('url = ?');
      values.add(model.url);
    }
    if (model.shortenedUrl != null) {
      where.add('shortened_url = ?');
      values.add(model.shortenedUrl);
    }
    return WhereClause(where: where, values: values);
  }

  @override
  String toJsonString() {
    return json.encode({'id': id, 'url': url, 'shortenedUrl': shortenedUrl});
  }
}
