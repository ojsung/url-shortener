import 'package:mysql1/mysql1.dart';

abstract class Migration {
  const Migration({required this.conn});
  final MySqlConnection conn;
  Future<Results> up();
  Future<Results> down();
}
