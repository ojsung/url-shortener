import 'dart:convert';

import 'package:url_shortener_server/models/user_model.dart';
import 'package:url_shortener_server/models/user_partial.dart' show UserPartial;
import 'package:url_shortener_server/services/auth_service.dart' show AuthService;
import 'package:url_shortener_server/shared/hash_keys.dart';
import 'package:url_shortener_server/shared/token_manager.dart';
import 'package:url_shortener_server/shared/multi_part_string.dart';

class AuthServiceImpl implements AuthService {
  final TokenManager tokenManager;
  final HashKeys hashKeys;
  final String createKey;
  const AuthServiceImpl(this.tokenManager, this.hashKeys, this.createKey);

  @override
  String generateAuthToken(String username, int userId) {
    final currentMinute = DateTime.now().minute;
    final key = hashKeys.getKey(currentMinute);

    final MultiPartString saltedPassword = tokenManager.encryptString(username, key: key);
    saltedPassword.insert(0, currentMinute.toString());
    final String jsonString = json.encode({'token': saltedPassword.toString(), 'userId': userId});
    final String authToken = utf8.fuse(base64).encode(jsonString);
    return authToken;
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
      hashedSubject: saltedToken[2],
      key: key,
      salt: saltedToken[1],
      subject: storedUsername,
    );
  }

  @override
  Future<bool> verifyPasswordById(String password, int userId) async {
    final List<User> users = await User.read(UserPartial(id: userId));
    if (users.isEmpty) {
      return false;
    }
    final User user = users.first;
    return verifyPassword(user.password, password);
  }

  @override
  bool verifyPassword(String hash, String password) {
    MultiPartString saltedPassword = MultiPartString.fromString(hash);
    return tokenManager.isTokenEqualToString(
      hashedSubject: saltedPassword[1],
      key: createKey,
      salt: saltedPassword[0],
      subject: password,
    );
  }

  @override
  MultiPartString hashPassword(String password) {
    return tokenManager.encryptString(password, key: createKey);
  }
}
