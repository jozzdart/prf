import 'package:prf/prf.dart';
import 'package:synchronized/synchronized.dart';

class PrfRolloverCounter extends BaseCounterTracker {
  final Duration resetEvery;
  final _lock = Lock();

  PrfRolloverCounter(super.key, {required this.resetEvery, super.useCache})
      : super(suffix: 'roll');

  @override
  bool isExpired(DateTime now, DateTime? last) =>
      last == null || now.difference(last) >= resetEvery;

  @override
  Future<void> reset() => _lock.synchronized(() async {
        await Future.wait([
          value.set(0),
          lastUpdate.set(DateTime.now()),
        ]);
      });

  /// Returns how much time is left until the counter auto-resets
  Future<Duration?> timeRemaining() async {
    final last = await lastUpdate.get();
    if (last == null) return null;
    final elapsed = DateTime.now().difference(last);
    final remaining = resetEvery - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Returns how many seconds remain until reset
  Future<int?> secondsRemaining() async {
    final remaining = await timeRemaining();
    return remaining?.inSeconds;
  }

  /// Returns progress as a percentage of the reset window (0.0 to 1.0)
  Future<double?> percentElapsed() async {
    final last = await lastUpdate.get();
    if (last == null) return null;
    final elapsed = DateTime.now().difference(last);
    return (elapsed.inMilliseconds / resetEvery.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Returns the DateTime when the current period will end
  Future<DateTime?> getEndTime() async {
    final last = await lastUpdate.get();
    return last?.add(resetEvery);
  }

  /// Returns a Future that completes when the rollover period ends
  Future<void> whenExpires() async {
    final remaining = await timeRemaining();
    if (remaining == null || remaining.inMilliseconds == 0) return;
    await Future.delayed(remaining);
  }
}
