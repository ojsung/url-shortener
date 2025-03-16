/*
Let x, p, and k be elements of the Whole numbers, and t an element of the Reals.
Then, we define our default backoff strategy as t_retry = x^p, with p increasing on every retry.
We also define our cooldown strategy as t_cooldown = k * x^p, such that on every interval t_cooldown where p did not increase,
p_new is the greater value of (p_old - 1) and 0
 */
import 'dart:async';
import 'dart:math';

// I really only need exponential but why not do all three? I'm definitely not going to regret this later when I run out of time
enum Strategy { exponential, linear, constant }

class BackoffRetry<Return extends dynamic> {
  // Dart doesn't have a destructor. Instead, they have Finalizer. This will end my timer if it is running when the instance
  // becomes unreachable
  static final Finalizer<Timer?> _finalizer = Finalizer((Timer? timer) => timer?.cancel());
  final int base;
  final int maxRetries;
  final int cooldownCoefficient;
  Timer? cooldown;
  final Strategy strategy;
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
    this.strategy = Strategy.exponential,
  });

  Future<Return> call(FutureOr<Return> Function() fn, [String? id]) async {
    try {
      if (retries == 0) {
        return await fn();
      }
      return await Future.delayed(Duration(seconds: retries), () async {
        return await fn();
      });
    } catch (_) {
      if (retries >= maxRetries) {
        cooldown?.cancel();
        rethrow;
      }
    }
    print("Failed to call $id - Retry $retries");
    ++retries;
    return await call(fn, id);
  }

  void cool() {
    if (cooldown != null && cooldown?.isActive == true) {
      cooldown?.cancel();
    }
    cooldown = Timer(Duration(seconds: (cooldownCoefficient * calculateTimeoutByStrategy(retries + 1)).floor()), () => retries--);
    _finalizer.attach(this, cooldown, detach: this);
  }

  int calculateTimeoutByStrategy(int subject) {
    return switch (this.strategy) {
      Strategy.constant => base,
      Strategy.linear => (subject * base).floor(),
      Strategy.exponential => pow(base, subject).floor(),
    };
  }
}
