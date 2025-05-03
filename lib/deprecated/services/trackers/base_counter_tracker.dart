import 'package:prf/prf.dart';
import 'package:synchronized/synchronized.dart';

@Deprecated(
    'BaseCounterTracker has been moved to the track package. Please update your imports to use the new package.')
abstract class BaseCounterTracker extends BaseTracker<int> {
  @Deprecated(
      'BaseCounterTracker has been moved to the track package. Please update your imports to use the new package.')
  BaseCounterTracker(super.key, {required super.suffix, super.useCache});

  final _lock = Lock();

  /// Increments the counter by [amount] (default is 1).
  ///
  /// This method increases the current counter value by the specified [amount].
  /// It ensures that the operation is thread-safe by using a lock.
  ///
  /// Returns the updated counter value.
  Future<int> increment([int amount = 1]) {
    return _lock.synchronized(() async {
      final current = await get(); // already calls _ensureFresh inside lock
      final updated = current + amount;
      await value.set(updated);
      return updated;
    });
  }

  /// Checks if the counter value is greater than zero.
  ///
  /// Returns `true` if the current counter value is greater than zero,
  /// otherwise returns `false`.
  Future<bool> isNonZero() async => (await peek()) > 0;

  /// Resets the counter value to its fallback value but retains the last update timestamp.
  ///
  /// This method sets the counter value to the fallback value, which is
  /// defined as zero, without altering the last update timestamp.
  Future<void> clearValueOnly() => value.set(fallbackValue());

  /// Retrieves the current raw counter value without checking expiration.
  ///
  /// This method returns the current counter value directly, bypassing any
  /// expiration logic.
  ///
  /// Returns the current counter value.
  Future<int> raw() => value.getOrFallback(fallbackValue());

  /// Provides the fallback value for the counter, which is zero.
  ///
  /// This method returns the default value for the counter when it is reset
  /// or when no value is present.
  @override
  int fallbackValue() => 0;
}
