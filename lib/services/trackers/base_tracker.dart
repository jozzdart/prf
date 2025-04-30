import 'package:prf/prf.dart';

abstract class BaseTracker<T> {
  final PrfIso<T> value;
  final PrfIso<DateTime> lastUpdate;

  BaseTracker(String key, {required String suffix})
      : value = Prf<T>('${key}_$suffix', defaultValue: null).isolated,
        lastUpdate = Prf<DateTime>('${key}_last_$suffix').isolated;

  /// Returns the tracked value, resetting it first if expired.
  Future<T> get() => _ensureFresh();

  /// Returns true if either the value or timestamp exist in SharedPreferences.
  Future<bool> hasState() async {
    final results = await Future.wait([
      value.existsOnPrefs(),
      lastUpdate.existsOnPrefs(),
    ]);
    return results.any((e) => e);
  }

  /// Clears both the value and last update timestamp from storage.
  Future<void> clear() async {
    await Future.wait([
      value.remove(),
      lastUpdate.remove(),
    ]);
  }

  /// Returns true if the tracker is currently expired.
  Future<bool> isCurrentlyExpired() async {
    final last = await lastUpdate.get();
    return isExpired(DateTime.now(), last);
  }

  /// Returns the last update time, or null if never updated.
  Future<DateTime?> getLastUpdateTime() => lastUpdate.get();

  /// Returns how much time has passed since the last update (or null).
  Future<Duration?> timeSinceLastUpdate() async {
    final last = await lastUpdate.get();
    return last == null ? null : DateTime.now().difference(last);
  }

  /// Returns the value without calling reset or updating anything.
  Future<T> peek() => value.getOrFallback(fallbackValue());

  Future<T> _ensureFresh() async {
    final now = DateTime.now();
    final last = await lastUpdate.get();
    if (last == null || isExpired(now, last)) {
      await reset();
    }
    return await value.getOrFallback(fallbackValue());
  }

  bool isExpired(DateTime now, DateTime? last);
  Future<void> reset();
  T fallbackValue();
}
