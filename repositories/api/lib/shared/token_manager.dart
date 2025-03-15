import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:url_shortener_server/shared/multi_part_string.dart';

class TokenManager {
  const TokenManager({required this.hashRounds});
  final int hashRounds;
  static const String _characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  /// It doesn't create a truly random string. But it is random enough for a project like this.
  static String generateRandomString(int length) {
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _characters.codeUnitAt(random.nextInt(_characters.length)),
      ),
    );
  }

  MultiPartString encryptString(String password, {String? key, int? rounds}) {
    final hashRounds = rounds ?? this.hashRounds;
    final String salt;
    if (key == null) {
      salt = generateRandomString(60 - password.length);
    } else if (password.length + key.length >= 60) {
      salt = key;
    } else {
      salt = key + generateRandomString(60 - password.length - key.length);
    }
    final encryptedKey = hashWithKey(password + salt, salt, hashRounds);
    return MultiPartString([salt, encryptedKey]);
  }

  String removeSalt(String password) {
    return password.split(':').last;
  }

  String hashWithKey(String input, String key, [int? rounds]) {
    int hashRounds = rounds ?? this.hashRounds;
    if (hashRounds < 1) {
      throw ArgumentError('rounds must be greater than 0');
    }
    final keyBytes = utf8.encode(key);
    Uint8List bytes = utf8.encode(input);
    Digest digest = sha256.convert([]);
    int hashesLeft = hashRounds;
    final hmacSha256 = Hmac(sha256, keyBytes);
    while (hashesLeft > 0) {
      digest = hmacSha256.convert(bytes);
      bytes = utf8.encode(digest.toString());
      hashesLeft--;
    }
    return digest.toString();
  }

  bool isTokenEqualToString(
    String hash,
    String key,
    String password, [
    int? rounds,
  ]) {
    int hashRounds = rounds ?? this.hashRounds;
    final MultiPartString saltedPassword = encryptString(
      password,
      key: key,
      rounds: hashRounds,
    );
    final MultiPartString saltedHash = MultiPartString.fromString(hash);
    return saltedPassword == saltedHash;
  }
}
