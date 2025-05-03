import 'package:prf/prf.dart';
import 'package:synchronized/synchronized.dart';

/// A persistent counter that automatically resets at the start of each aligned time period.
///
/// `PrfPeriodicCounter` is designed to track integer counters that reset periodically
/// based on a specified [TrackerPeriod]. It ensures thread-safe operations using a lock
/// and provides methods to check expiration, reset the counter, and calculate time-related
/// metrics for the current period. This is ideal for scenarios where counters need to be
/// reset at regular intervals, such as daily or weekly counters.
@Deprecated(
    'PrfPeriodicCounter has been moved to the track package. Please update your imports to use the new package.')
class PrfPeriodicCounter extends BaseCounterTracker {
  /// The period for which the counter is valid.
  final TrackerPeriod period;

  /// Constructs a [PrfPeriodicCounter] with the specified [key], [period], and optional [useCache].
  ///
  /// - [key]: A unique identifier for the counter.
  /// - [period]: Defines the duration and alignment of the counter's validity.
  /// - [useCache]: A boolean flag indicating whether to use in-memory caching.
  PrfPeriodicCounter(super.key, {required this.period, super.useCache})
      : super(suffix: 'period');

  final _lock = Lock();

  /// Determines if the counter is expired based on the current time [now] and the [last] update time.
  ///
  /// Returns `true` if the counter is expired, otherwise `false`.
  @override
  bool isExpired(DateTime now, DateTime? last) {
    final aligned = period.alignedStart(now);
    return last == null || last.isBefore(aligned);
  }

  /// Resets the counter value to zero and updates the last update timestamp to the start of the current period.
  ///
  /// This method ensures thread-safe operation using a lock.
  @override
  Future<void> reset() => _lock.synchronized(() async {
        await Future.wait([
          value.set(0),
          lastUpdate.set(period.alignedStart(DateTime.now())),
        ]);
      });

  /// Returns the aligned start of the current period (e.g., today at 00:00).
  DateTime get currentPeriodStart => period.alignedStart(DateTime.now());

  /// Returns the `DateTime` of the next period start.
  DateTime get nextPeriodStart =>
      period.alignedStart(DateTime.now()).add(period.duration);

  /// Returns the duration until the next period begins.
  Duration get timeUntilNextPeriod =>
      nextPeriodStart.difference(DateTime.now());

  /// Returns the duration that has elapsed in the current period.
  Duration get elapsedInCurrentPeriod =>
      DateTime.now().difference(currentPeriodStart);

  /// Returns the percentage of the period that has elapsed, as a value between 0.0 and 1.0.
  double get percentElapsed {
    final elapsed = elapsedInCurrentPeriod.inMilliseconds;
    final total = period.duration.inMilliseconds;
    return total == 0 ? 1.0 : (elapsed / total).clamp(0.0, 1.0);
  }
}
