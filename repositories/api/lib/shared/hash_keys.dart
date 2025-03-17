import 'dart:async';

import 'package:url_shortener_server/shared/token_manager.dart';

class HashKeys {
  /// On app initialization, fill the map with 60 keys
  final Map<int, String> _map = {
    for (var i = 0; i < 60; i++) i: TokenManager.generateRandomString(20),
  };
  late final Timer timer;

  HashKeys([String? key]) {
    if (key != null) {
      // If PASSWORD_KEY is stored in the environment, all keys will be replaced with it.
      // This is only for dev, don't do this in production.
      _map.updateAll((mapKey, value) => key);
      timer = Timer(Duration(seconds: 0), () {});
    } else {
      // Every minute, generate a new 20 character string and replace the existing key
      timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
        final int currentMinute = DateTime.now().minute;
        _map[currentMinute] = TokenManager.generateRandomString(20);
      });
    }
  }
  /// Retrieve a key based on the minute it was generated
  /// If the key is over an hour old, it will not match the retrieved key
  String getKey(int minute) {
    String? key = _map[minute];
    if (key == null) {
      throw ArgumentError('Invalid minute. Must be between 0 and 59');
    }
    return key;
  }

  void dispose() {
    timer.cancel();
  }
}
