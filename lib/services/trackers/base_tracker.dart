import 'package:prf/prf.dart';

abstract class BaseTracker<T> {
  final PrfIso<T> value;
  final PrfIso<DateTime> lastUpdate;

  BaseTracker(String key, {required String suffix})
      : value = Prf<T>('${key}_$suffix', defaultValue: null).isolated,
        lastUpdate = Prf<DateTime>('${key}_last_$suffix').isolated;

  Future<T> get() => _ensureFresh();

  Future<bool> hasState() async {
    final results = await Future.wait([
      value.existsOnPrefs(),
      lastUpdate.existsOnPrefs(),
    ]);
    return results.any((e) => e);
  }

  Future<void> clear() async {
    await Future.wait([
      value.remove(),
      lastUpdate.remove(),
    ]);
  }

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
