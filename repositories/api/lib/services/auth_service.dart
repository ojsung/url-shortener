import 'package:url_shortener_server/shared/multi_part_string.dart';

abstract class AuthService {
  String generateAuthToken(String username, int userId);
  Future<bool> verifyAuthToken(String token, int userId);
  Future<bool> verifyPasswordById(String password, int userId);
  bool verifyPassword(String hash, String password);
  MultiPartString hashPassword(String password);
}
