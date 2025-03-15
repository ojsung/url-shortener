import 'package:url_shortener_server/models/user_model.dart';
import 'package:url_shortener_server/models/user_partial.dart' show UserPartial;
import 'package:url_shortener_server/services/auth_service.dart'
    show AuthService;
import 'package:url_shortener_server/shared/hash_keys.dart';
import 'package:url_shortener_server/shared/token_manager.dart';
import 'package:url_shortener_server/shared/multi_part_string.dart';

class AuthServiceImpl implements AuthService {
  final TokenManager tokenManager;
  final HashKeys hashKeys;
  final String createKey;
  const AuthServiceImpl(this.tokenManager, this.hashKeys, this.createKey);

  @override
  String generateAuthToken(String username) {
    final currentMinute = DateTime.now().minute;
    final key = hashKeys.getKey(currentMinute);

    final MultiPartString saltedPassword = tokenManager.encryptString(
      username,
      key: key,
    );
    saltedPassword.insert(0, currentMinute.toString());
    return saltedPassword.toString();
  }

  @override
  Future<bool> verifyAuthToken(String token, int userId) async {
    final MultiPartString saltedToken = MultiPartString.fromString(token);
    final int? minute = int.tryParse(saltedToken.removeAt(0));
    if (minute == null) {
      throw ArgumentError('Invalid token');
    }
    final key = hashKeys.getKey(minute);
    final List<User> users = await User.read(UserPartial(id: userId));
    if (users.isEmpty) {
      return false;
    }
    final User user = users.first;
    final String storedUsername = user.username;
    return tokenManager.isTokenEqualToString(
      saltedToken.toString(),
      key,
      storedUsername,
    );
  }

  @override
  Future<bool> verifyPasswordById(String password, int userId) async {
    final List<User> users = await User.read(UserPartial(id: userId));
    if (users.isEmpty) {
      return false;
    }
    final User user = users.first;
    final String hashedPassword = user.password;
    return verifyPassword(hashedPassword, password);
  }

  @override
  bool verifyPassword(String hash, String password) {
    return tokenManager.isTokenEqualToString(hash, createKey, password);
  }
}
