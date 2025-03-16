import 'dart:convert' show json;

import 'package:url_shortener_server/exceptions/exceptions.dart';
import 'package:url_shortener_server/models/url_partial.dart' show UrlPartial;
import 'package:url_shortener_server/shared/globals.dart' show characters;
import 'package:url_shortener_server/shared/interfaces/model.dart';
import 'package:url_shortener_server/shared/query_result.dart';
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
    : id = int.parse(json['id']),
      url = json['url'],
      shortenedUrl = json['shortened_url'],
      createdAt = DateTime.parse(json['created_at']),
      modifiedAt = DateTime.parse(json['modified_at']),
      deletedAt = json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null;

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

  static Future<Url> create(UrlPartial model) async {
    final url = model.url;
    if (url == null) {
      throw IncompleteDataException('URL is required to create a Url');
    }
    final int latestId = await findLatest();
    final String nextUrl = _base10ToBase62(latestId + 1, characters);
    QueryResult query = await Model.databaseService.execute(
      '''
      INSERT INTO `urls` (`url`, `shortened_url`)
      VALUES (?, ?)
    ''',
      [url, nextUrl],
    );
    final BigInt lastInsertId = query.lastInsertId;
    if (lastInsertId == BigInt.zero) {
      throw UnknownInsertException("Failed to insert. No lastInsertId returned");
    }
    return (await read(UrlPartial(id: lastInsertId.toInt()))).first;
  }

  static Future<List<Url>> read(UrlPartial model) async {
    final WhereClause whereClause = _buildWhereClause(model);
    QueryResult query = await Model.databaseService.execute('''
      SELECT * FROM `urls`
      WHERE ${whereClause.where.join(' AND ')}
    ''', whereClause.values);
    List<Url> results = query.toModels();
    return results;
  }

  static Future<List<Url>> delete(UrlPartial model, [hard = false]) async {
    final WhereClause whereClause = _buildWhereClause(model);
    final QueryResult results;
    final int? modelId = model.id;
    if (modelId == null) {
      throw MissingIdException('ID must not be null for deletion');
    }
    if (hard) {
      results = await Model.databaseService.execute('''
      DELETE FROM `urls`
      WHERE ${whereClause.where.join(' AND ')}
    ''', whereClause.values);
    } else {
      results = await Model.databaseService.execute(
        '''
      UPDATE `urls`
      SET `deleted` = ?
      WHERE `id` = ?
      ''',
        [DateTime.now(), modelId],
      );
    }

    return results.toModels();
  }

  static Future<List<Url>> update(UrlPartial model) async {
    final id = model.id;
    if (id == null) {
      throw MissingIdException('ID is required to update a Url');
    }
    if (model.url == null && model.shortenedUrl == null) {
      throw IncompleteDataException('At least one field is required to update a Url');
    }
    UrlPartial partial = UrlPartial(url: model.url, shortenedUrl: model.shortenedUrl);
    final WhereClause whereClause = _buildWhereClause(partial);
    QueryResult query = await Model.databaseService.execute(
      '''
      UPDATE `urls`
      SET ${whereClause.where.join(', ')}
      WHERE `id` = ?
    ''',
      [...whereClause.values, id],
    );
    return query.toModels();
  }

  static Future<int> findLatest() async {
    QueryResult result = await Model.databaseService.execute('''
    SELECT `id` FROM `urls`
    ORDER BY `id` DESC
    LIMIT 1
    ''');
    final String? stringId = result.firstOrNull?['id'];
    final int id = int.parse(stringId ?? '0');
    return id;
  }

  static WhereClause _buildWhereClause(UrlPartial model) {
    List<String> where = [];
    List<dynamic> values = [];
    if (model.id != null) {
      where.add('`id` = ?');
      values.add(model.id);
    }
    if (model.url != null) {
      where.add('`url` = ?');
      values.add(model.url);
    }
    if (model.shortenedUrl != null) {
      where.add('`shortened_url` = ?');
      values.add(model.shortenedUrl);
    }
    return WhereClause(where: where, values: values);
  }

  @override
  String toJsonString() {
    return json.encode({'id': id, 'url': url, 'shortenedUrl': shortenedUrl});
  }

  /*
  Wholly unnecessary, but very fun
  */
  static String _base10ToBase62(int number, String characters) {
    if (number == 0) return characters[0];

    String result = '';
    while (number > 0) {
      result = characters[number % 62] + result;
      number = number ~/ 62;
    }
    return result;
  }
}

extension on QueryResult {
  List<Url> toModels() {
    return map(Url.fromJson).toList();
  }
}
