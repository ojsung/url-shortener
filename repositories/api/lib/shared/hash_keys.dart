import 'dart:async';

import 'package:url_shortener_server/shared/token_manager.dart';

class HashKeys {
  final Map<int, String> _map = {
    for (var i = 0; i < 60; i++) i: TokenManager.generateRandomString(20),
  };
  late final Timer timer;

  HashKeys([String? key]) {
    if (key != null) {
      _map.updateAll((mapKey, value) => key);
      timer = Timer(Duration(seconds: 0), () {});
    } else {
      timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
        final int currentMinute = DateTime.now().minute;
        _map[currentMinute] = TokenManager.generateRandomString(20);
      });
    }
  }

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
