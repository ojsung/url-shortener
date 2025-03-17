import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:url_shortener_server/shared/globals.dart' show characters;
import 'dart:convert';

import 'package:url_shortener_server/shared/multi_part_string.dart';

class TokenManager {
  const TokenManager({required this.hashRounds});
  final int hashRounds;
  static const String _characters = characters;

  /// Generate a somewhat random string of a given length
  static String generateRandomString(int length) {
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _characters.codeUnitAt(random.nextInt(_characters.length)),
      ),
    );
  }

  /// Encrypt a string. If a key or salt are provided, use those. Otherwise, generate them.
  MultiPartString encryptString(
    String subject, {
    String key = '',
    int? rounds,
    String? salt,
  }) {
    final hashRounds = rounds ?? this.hashRounds;
    // Todo: Max pass length is validated at 40. Salt will always be at least 20 char
    salt ??= generateRandomString(60 - subject.length);

    final encryptedSubject = hashWithKey(subject + salt, key, hashRounds);
    return MultiPartString([salt, encryptedSubject]);
  }

  String removeSalt(String hashedSubject) {
    return hashedSubject.split(':').last;
  }

  /// Hash a string with a key a given number of times. Uses SHA-256.
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

  /// Compare a hashed string to a plain text string by hashing the plain text string
  bool isTokenEqualToString({
    required String hashedSubject,
    required String salt,
    required String key,
    required String subject,
    int? rounds,
  }) {
    int hashRounds = rounds ?? this.hashRounds;
    final MultiPartString saltedPassword = encryptString(
      subject,
      key: key,
      salt: salt,
      rounds: hashRounds,
    );
    final MultiPartString saltedHash = MultiPartString([salt, hashedSubject]);
    return saltedPassword == saltedHash;
  }
}
