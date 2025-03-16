import 'package:mysql_client/mysql_client.dart';
import 'package:url_shortener_server/services/database_service.dart' show DatabaseService;
import 'package:url_shortener_server/shared/globals.dart';
import 'package:url_shortener_server/shared/interfaces/partial.dart';

abstract class Model<T extends Model<T, U>, U extends Partial<T, U>> {
  static String get tableName => throw UnimplementedError();
  static DatabaseService get databaseService => getIt<DatabaseService>();

  Model();

  factory Model.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  factory Model.fromRow(ResultSetRow row) => throw UnimplementedError();
  T copyWithJson(Map<String, dynamic> json);
  T copyWithPartial(U partial);
  String toJsonString();
}
