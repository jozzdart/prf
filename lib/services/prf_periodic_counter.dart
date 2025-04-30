import 'package:prf/prf.dart';
import 'package:synchronized/synchronized.dart';

class PrfPeriodicCounter extends BaseCounterTracker {
  final TrackerPeriod period;

  PrfPeriodicCounter(super.key, {required this.period, super.useCache})
      : super(suffix: 'period');

  final _lock = Lock();

  @override
  bool isExpired(DateTime now, DateTime? last) {
    final aligned = period.alignedStart(now);
    return last == null || last.isBefore(aligned);
  }

  @override
  Future<void> reset() => _lock.synchronized(() async {
        await Future.wait([
          value.set(0),
          lastUpdate.set(period.alignedStart(DateTime.now())),
        ]);
      });

  /// Returns the aligned start of the current period (e.g. today at 00:00).
  DateTime get currentPeriodStart => period.alignedStart(DateTime.now());

  /// Returns the `DateTime` of the next period start.
  DateTime get nextPeriodStart =>
      period.alignedStart(DateTime.now()).add(period.duration);

  /// Returns how much time is left before the next period begins.
  Duration get timeUntilNextPeriod =>
      nextPeriodStart.difference(DateTime.now());

  /// Returns how far into the current period we are (e.g. 3h into daily).
  Duration get elapsedInCurrentPeriod =>
      DateTime.now().difference(currentPeriodStart);

  /// Returns how much of the period has passed, as a percent (0.0–1.0).
  double get percentElapsed {
    final elapsed = elapsedInCurrentPeriod.inMilliseconds;
    final total = period.duration.inMilliseconds;
    return total == 0 ? 1.0 : (elapsed / total).clamp(0.0, 1.0);
  }
}
