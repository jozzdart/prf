import 'package:prf/prf.dart';

class PrfStreakTracker extends BaseTracker<int> {
  final TrackerPeriod period;

  PrfStreakTracker(super.key, {required this.period}) : super(suffix: 'streak');

  @override
  bool isExpired(DateTime now, DateTime? last) {
    if (last == null) return true;
    final alignedNow = period.alignedStart(now);
    final alignedLast = period.alignedStart(last);
    return alignedNow.difference(alignedLast) >= period.duration * 2;
  }

  @override
  Future<void> reset() async {
    await Future.wait([
      value.set(0),
      lastUpdate.remove(), // don't preserve period alignment after reset
    ]);
  }

  @override
  int fallbackValue() => 0;

  /// Marks a completed period and bumps the streak by [amount] (default: 1)
  Future<int> bump([int amount = 1]) async {
    final now = DateTime.now();
    final alignedNow = period.alignedStart(now);
    final last = await lastUpdate.get();

    if (last == null || isExpired(now, last)) {
      await value.set(0); // streak broken
    }

    final updated = (await value.getOrFallback(0)) + amount;
    await Future.wait([
      value.set(updated),
      lastUpdate.set(alignedNow),
    ]);
    return updated;
  }

  Future<bool> isStreakBroken() async {
    final last = await lastUpdate.get();
    return last == null || isExpired(DateTime.now(), last);
  }

  Future<Duration?> streakAge() async {
    final last = await lastUpdate.get();
    return last == null ? null : DateTime.now().difference(last);
  }

  Future<int> currentStreak() => get();

  Future<DateTime?> nextResetTime() async {
    final last = await lastUpdate.get();
    if (last == null) return null;
    return period.alignedStart(last).add(period.duration * 2);
  }

  /// Returns a percentage (0.0–1.0) of the time remaining before streak breaks
  Future<double?> percentRemaining() async {
    final last = await lastUpdate.get();
    if (last == null) return null;
    final end = period.alignedStart(last).add(period.duration * 2);
    final total = period.duration * 2;
    final remaining = end.difference(DateTime.now());
    return remaining.inMilliseconds.clamp(0, total.inMilliseconds) /
        total.inMilliseconds;
  }
}
