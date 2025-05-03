import 'package:prf/prf.dart';
import 'package:synchronized/synchronized.dart';

/// A persistent streak tracker for managing activity streaks with automatic expiration logic.
///
/// `PrfStreakTracker` is designed to track streaks over aligned time periods (e.g., daily, weekly).
/// It automatically resets if a full period is missed and persists streak progress across sessions
/// and isolates. This class is ideal for scenarios like daily check-ins, learning streaks, or workout chains.
@Deprecated(
    'PrfStreakTracker has been moved to the track package. Please update your imports to use the new package.')
class PrfStreakTracker extends BaseTracker<int> {
  /// The period for which the streak is tracked.
  final TrackerPeriod period;
  final _lock = Lock();

  /// Constructs a [PrfStreakTracker] with the specified [key], [period], and optional [useCache].
  ///
  /// - [key]: A unique identifier for the streak tracker.
  /// - [period]: Defines the duration and alignment of the streak's validity.
  /// - [useCache]: A boolean flag indicating whether to use in-memory caching.
  PrfStreakTracker(super.key, {required this.period, super.useCache})
      : super(suffix: 'streak');

  /// Determines if the streak is expired based on the current time [now] and the [last] update time.
  ///
  /// Returns `true` if the streak is expired, otherwise `false`.
  @override
  bool isExpired(DateTime now, DateTime? last) {
    if (last == null) return true;
    final alignedNow = period.alignedStart(now);
    final alignedLast = period.alignedStart(last);
    return alignedNow.difference(alignedLast) >= period.duration * 2;
  }

  /// Resets the streak value to zero and removes the last update timestamp.
  ///
  /// This operation is synchronized to ensure thread safety.
  @override
  Future<void> reset() => _lock.synchronized(() async {
        await Future.wait([
          value.set(0),
          lastUpdate.remove(),
        ]);
      });

  /// Provides a fallback value of zero for the streak.
  @override
  int fallbackValue() => 0;

  /// Marks a completed period and increments the streak by [amount] (default: 1).
  ///
  /// This method ensures thread-safe operation using a lock.
  Future<int> bump([int amount = 1]) => _lock.synchronized(() async {
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
      });

  /// Checks if the streak has been broken (a period was missed).
  ///
  /// Returns `true` if the streak is broken, otherwise `false`.
  Future<bool> isStreakBroken() async {
    final last = await lastUpdate.get();
    return last == null || isExpired(DateTime.now(), last);
  }

  /// Returns the duration since the last streak update.
  ///
  /// Returns a [Duration] or `null` if the last update time is not available.
  Future<Duration?> streakAge() async {
    final last = await lastUpdate.get();
    return last == null ? null : DateTime.now().difference(last);
  }

  /// Returns the current streak value.
  Future<int> currentStreak() => get();

  /// Calculates and returns the [DateTime] when the streak will next reset if not continued.
  ///
  /// Returns a [DateTime] or `null` if the last update time is not available.
  Future<DateTime?> nextResetTime() async {
    final last = await lastUpdate.get();
    if (last == null) return null;
    return period.alignedStart(last).add(period.duration * 2);
  }

  /// Returns a percentage (0.0–1.0) of the time remaining before the streak breaks.
  ///
  /// Returns a [double] or `null` if the last update time is not available.
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
