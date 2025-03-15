import 'package:url_shortener_server/shared/interfaces/migration.dart';

class CreateUrlsTable implements Migration {
  const CreateUrlsTable();

  @override
  String up() {
    return '''
      CREATE TABLE IF NOT EXISTS urls (
        id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        url VARCHAR(255) NOT NULL,
        shortened_url VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP DEFAULT NULL
      )
    ''';
  }

  @override
  String down() {
    return 'DROP TABLE IF EXISTS urls';
  }
}
