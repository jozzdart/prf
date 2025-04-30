import 'package:prf/prf.dart';
import 'package:synchronized/synchronized.dart';

abstract class BaseCounterTracker extends BaseTracker<int> {
  BaseCounterTracker(super.key, {required super.suffix, super.useCache});
  final _lock = Lock();

  /// Increments the counter by [amount] (default 1).
  Future<int> increment([int amount = 1]) {
    return _lock.synchronized(() async {
      final current = await get(); // already calls _ensureFresh inside lock
      final updated = current + amount;
      await value.set(updated);
      return updated;
    });
  }

  /// Returns true if the value is greater than zero.
  Future<bool> isNonZero() async => (await peek()) > 0;

  /// Resets the value but keeps the last update timestamp.
  Future<void> clearValueOnly() => value.set(fallbackValue());

  /// Returns current raw value (bypasses expiration).
  Future<int> raw() => value.getOrFallback(fallbackValue());

  @override
  int fallbackValue() => 0;
}
