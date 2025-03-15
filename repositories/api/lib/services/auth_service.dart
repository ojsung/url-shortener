abstract class AuthService {
  String generateAuthToken(String username);
  Future<bool> verifyAuthToken(String token, int userId);
  Future<bool> verifyPasswordById(String password, int userId);
  bool verifyPassword(String hash, String password);
}
