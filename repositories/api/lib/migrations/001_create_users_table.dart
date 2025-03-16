import 'package:url_shortener_server/shared/interfaces/migration.dart';

class CreateUsersTable implements Migration {
  const CreateUsersTable();
  // We index username, because anytime we're doing a login, we need to look them up by username
  @override
  String up() {
    return '''
    CREATE TABLE IF NOT EXISTS users (
      id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
      username VARCHAR(30) UNIQUE NOT NULL,
      password VARCHAR(255) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      deleted_at TIMESTAMP DEFAULT NULL
    )
  ''';
  }

  @override
  String down() {
    return 'DROP TABLE IF EXISTS users';
  }
}
