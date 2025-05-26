import 'package:synchronized/synchronized.dart';

import '../../../prf.dart';

/// An abstract base class for tracking values with expiration logic.
@Deprecated(
    'BaseTracker has been moved to the track package. Please update your imports to use the new package.')
abstract class BaseTracker<T> extends BaseServiceObject {
  /// The cached value with optional in-memory caching.
  final Prf<T> _valueWithCache;

  /// The cached last update timestamp with optional in-memory caching.
  final Prf<DateTime> _lastUpdateWithCache;

  /// A lock to ensure thread-safe operations.
  final _lock = Lock();

  /// Provides access to the tracked value, considering the caching strategy.
  ///
  /// Returns a [BasePrfObject] that either uses in-memory caching or
  /// reads directly from disk based on the [useCache] flag.
  BasePrfObject<T> get value =>
      useCache ? _valueWithCache : _valueWithCache.isolated;

  /// Provides access to the last update timestamp, considering the caching strategy.
  ///
  /// Returns a [BasePrfObject] that either uses in-memory caching or
  /// reads directly from disk based on the [useCache] flag.
  BasePrfObject<DateTime> get lastUpdate =>
      useCache ? _lastUpdateWithCache : _lastUpdateWithCache.isolated;

  /// Constructs a [BaseTracker] with the specified [key] and [suffix].
  ///
  /// The [useCache] parameter determines whether to use in-memory caching.
  @Deprecated(
      'The constructor of BaseTracker is deprecated. Please update your code to use the new package.')
  BaseTracker(String key, {required String suffix, super.useCache})
      : _valueWithCache = Prf<T>('${key}_$suffix', defaultValue: null),
        _lastUpdateWithCache = Prf<DateTime>('${key}_last_$suffix');

  /// Retrieves the tracked value, resetting it if expired.
  ///
  /// This method ensures that the value is fresh by checking its expiration
  /// status and resetting it if necessary.
  Future<T> get() => _lock.synchronized(() => _ensureFresh());

  /// Checks if either the value or timestamp exists in SharedPreferences.
  ///
  /// Returns `true` if any state is present, otherwise `false`.
  Future<bool> hasState() async {
    final results = await Future.wait([
      value.existsOnPrefs(),
      lastUpdate.existsOnPrefs(),
    ]);
    return results.any((e) => e);
  }

  /// Clears both the value and last update timestamp from storage.
  ///
  /// This method removes the tracked value and its associated timestamp
  /// from persistent storage.
  Future<void> clear() async {
    await Future.wait([
      value.remove(),
      lastUpdate.remove(),
    ]);
  }

  /// Determines if the tracker is currently expired.
  ///
  /// Returns `true` if the tracked value is expired, otherwise `false`.
  Future<bool> isCurrentlyExpired() async {
    final last = await lastUpdate.get();
    return isExpired(DateTime.now(), last);
  }

  /// Retrieves the last update time, or `null` if never updated.
  ///
  /// This method returns the timestamp of the last update or `null` if
  /// the value has never been updated.
  Future<DateTime?> getLastUpdateTime() => lastUpdate.get();

  /// Calculates the duration since the last update, or `null` if never updated.
  ///
  /// Returns the time elapsed since the last update or `null` if the value
  /// has never been updated.
  Future<Duration?> timeSinceLastUpdate() async {
    final last = await lastUpdate.get();
    return last == null ? null : DateTime.now().difference(last);
  }

  /// Retrieves the value without resetting or updating it.
  ///
  /// This method returns the current value without triggering any expiration
  /// checks or updates.
  Future<T> peek() => value.getOrFallback(fallbackValue());

  /// Ensures the tracked value is fresh by checking its expiration status.
  ///
  /// If the value is expired or has never been updated, it is reset.
  Future<T> _ensureFresh() async {
    final now = DateTime.now();
    final last = await lastUpdate.get();
    if (last == null || isExpired(now, last)) {
      await reset();
    }
    return await value.getOrFallback(fallbackValue());
  }

  /// Determines if the tracked value is expired based on the current and last update times.
  ///
  /// This method must be implemented by subclasses to define the expiration logic.
  bool isExpired(DateTime now, DateTime? last);

  /// Resets the tracked value to its initial state.
  ///
  /// This method must be implemented by subclasses to define the reset logic.
  Future<void> reset();

  /// Provides the fallback value for the tracked value.
  ///
  /// This method must be implemented by subclasses to define the default value.
  T fallbackValue();
}
