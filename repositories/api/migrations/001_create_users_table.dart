import 'package:mysql1/mysql1.dart';

import 'package:url_shortener_server/models/migration.dart';

class CreateUsersTable implements Migration {
  const CreateUsersTable({required this.conn});

  @override
  final MySqlConnection conn;

  @override
  Future<Results> up() async {
    return await conn.query('''
    CREATE TABLE IF NOT EXISTS users (
      id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
      username VARCHAR(64) NOT NULL,
      password VARCHAR(255) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      deleted_at TIMESTAMP DEFAULT NULL
    )
  ''');
  }

  @override
  Future<Results> down() async {
    return await conn.query('DROP TABLE IF EXISTS users');
  }
}
