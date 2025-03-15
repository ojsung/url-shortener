import 'package:url_shortener_server/shared/interfaces/migration.dart';

class CreateUsersUrlsTable implements Migration {
  const CreateUsersUrlsTable();

  @override
  String up() {
    return '''
      CREATE TABLE IF NOT EXISTS users_urls (
        id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        url_id INT NOT NULL,
        can_manage_url BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP DEFAULT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (url_id) REFERENCES urls(id) ON DELETE CASCADE
      )
    ''';
  }

  @override
  String down() {
    return 'DROP TABLE IF EXISTS users_urls';
  }
}
