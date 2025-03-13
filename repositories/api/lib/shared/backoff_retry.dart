// t = b^c, and allow c to decrease every k*b^(c+1) seconds, with a maximum of 10 retries.
import 'dart:async';
import 'dart:math';

class BackoffRetry<Return extends FutureOr<dynamic>> {
  // ignore: unused_field
  static final Finalizer<Timer?> _finalizer = Finalizer(
    (Timer? timer) => timer?.cancel(),
  );
  final int base;
  final int maxRetries;
  final FutureOr<Return> Function() fn;
  final int cooldownCoefficient;
  Timer? cooldown;
  int get retries => _retries;
  set retries(int value) {
    _retries = max(value, 0);
    if (_retries > 0) cool();
  }

  int _retries = 0;
  BackoffRetry({
    this.base = 2,
    this.maxRetries = 10,
    this.cooldownCoefficient = 1,
    required this.fn,
  });

  Future<Return> call([String? id]) async {
    try {
      if (retries == 0) {
        return await fn();
      }
      return await Future.delayed(
        Duration(seconds: pow(base, retries).floor()),
        () async {
          return await fn();
        },
      );
    } catch (_) {
      if (retries < maxRetries) {
        print("Failed to call $id - Retry $retries");
        ++retries;
        return await call(id);
      } else {
        cooldown?.cancel();
        rethrow;
      }
    }
  }

  void cool() {
    if (cooldown != null && cooldown?.isActive == true) {
      cooldown?.cancel();
    }
    cooldown = Timer(
      Duration(seconds: cooldownCoefficient * pow(base, (retries + 1)).floor()),
      () => retries--,
    );
    _finalizer.attach(this, cooldown, detach: this);
  }
}
