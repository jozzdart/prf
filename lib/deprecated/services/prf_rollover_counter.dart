import 'package:prf/prf.dart';
import 'package:synchronized/synchronized.dart';

/// `PrfRolloverCounter` is a persistent counter designed to automatically reset
/// after a specified duration from the last update. This is particularly useful
/// for tracking rolling activity windows, such as "submissions per hour" or
/// "attempts every 10 minutes".
@Deprecated(
    'PrfRolloverCounter has been moved to the track package. Please update your imports to use the new package.')
class PrfRolloverCounter extends BaseCounterTracker {
  /// The duration after which the counter will automatically reset.
  final Duration resetEvery;
  final _lock = Lock();

  /// Constructs a [PrfRolloverCounter] with a unique [key] and a specified
  /// [resetEvery] duration. Optionally, caching can be enabled with [useCache].
  ///
  /// - [key]: A unique identifier for the counter.
  /// - [resetEvery]: The duration after which the counter resets.
  /// - [useCache]: Optional parameter to enable caching.
  PrfRolloverCounter(super.key, {required this.resetEvery, super.useCache})
      : super(suffix: 'roll');

  /// Determines if the counter is expired based on the current time [now] and
  /// the [last] update time.
  ///
  /// Returns `true` if the counter is expired, otherwise `false`.
  @override
  bool isExpired(DateTime now, DateTime? last) =>
      last == null || now.difference(last) >= resetEvery;

  /// Resets the counter value to zero and updates the last update time to now.
  ///
  /// This operation is synchronized to ensure thread safety.
  @override
  Future<void> reset() => _lock.synchronized(() async {
        await Future.wait([
          value.set(0),
          lastUpdate.set(DateTime.now()),
        ]);
      });

  /// Calculates and returns the remaining time until the counter auto-resets.
  ///
  /// Returns a [Duration] representing the time left until reset, or `null`
  /// if the last update time is not available.
  Future<Duration?> timeRemaining() async {
    final last = await lastUpdate.get();
    if (last == null) return null;
    final elapsed = DateTime.now().difference(last);
    final remaining = resetEvery - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Calculates and returns the number of seconds remaining until the counter resets.
  ///
  /// Returns an [int] representing the seconds left until reset, or `null`
  /// if the last update time is not available.
  Future<int?> secondsRemaining() async {
    final remaining = await timeRemaining();
    return remaining?.inSeconds;
  }

  /// Computes and returns the progress as a percentage of the reset window.
  ///
  /// Returns a [double] between `0.0` and `1.0` indicating the progress of
  /// the current reset window, or `null` if the last update time is not available.
  Future<double?> percentElapsed() async {
    final last = await lastUpdate.get();
    if (last == null) return null;
    final elapsed = DateTime.now().difference(last);
    return (elapsed.inMilliseconds / resetEvery.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Determines and returns the [DateTime] when the current period will end.
  ///
  /// Returns a [DateTime] indicating the end of the current period, or `null`
  /// if the last update time is not available.
  Future<DateTime?> getEndTime() async {
    final last = await lastUpdate.get();
    return last?.add(resetEvery);
  }

  /// Returns a [Future] that completes when the rollover period ends.
  ///
  /// This method will delay completion until the remaining time of the current
  /// period has elapsed.
  Future<void> whenExpires() async {
    final remaining = await timeRemaining();
    if (remaining == null || remaining.inMilliseconds == 0) return;
    await Future.delayed(remaining);
  }
}
