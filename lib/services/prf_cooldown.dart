import 'package:prf/prf.dart';
import 'package:prf/prfy_types/prfi.dart';

/// A utility for managing cooldown logic using persisted DateTime and Activation Count.
///
/// Stores:
/// - the last activation time (`<prefix>_cd_date_time`)
/// - the total activation count (`<prefix>_cd_count`)
///
/// Example:
/// ```dart
/// final cooldown = PrfCooldown('daily_reward', duration: Duration(hours: 24));
/// if (!await cooldown.isCooldownActive()) {
///   await cooldown.activateCooldown();
/// }
/// ```
class PrfCooldown {
  final Prfi<DateTime> _lastActivated;
  final Prfi<int> _activationCount;

  /// The cooldown duration.
  final Duration duration;

  /// Creates a new cooldown with the specified prefix and duration.
  ///
  /// - The [prefix] is used to create unique keys for storing cooldown data.
  /// - The [duration] specifies how long the cooldown should last.
  PrfCooldown(String prefix, {required this.duration})
      : _lastActivated = Prfi<DateTime>('prf_${prefix}_cd_date_time'),
        _activationCount = Prfi<int>('prf_${prefix}_cd_count', defaultValue: 0);

  /// Returns true if the cooldown is still active.
  ///
  /// A cooldown is active if it has been activated and the specified
  /// duration has not yet elapsed.
  Future<bool> isCooldownActive() async {
    final last = await _lastActivated.get();
    if (last == null) return false;
    return DateTime.now().isBefore(last.add(duration));
  }

  /// Returns true if the cooldown has expired or was never activated.
  ///
  /// This is the inverse of [isCooldownActive].
  Future<bool> isExpired() async => !(await isCooldownActive());

  /// Activates the cooldown using the default duration.
  ///
  /// Sets the activation time to the current time and increments
  /// the activation count.
  Future<void> activateCooldown() async {
    await _lastActivated.set(DateTime.now());
    final count = await _activationCount.getOrFallback(0);
    await _activationCount.set(count + 1);
  }

  /// Attempts to activate the cooldown only if it is not currently active.
  ///
  /// Returns `true` if the cooldown was activated (meaning it was not active before).
  /// Returns `false` if the cooldown was already active and no action was taken.
  ///
  /// This is a convenience method that combines checking and activating in one call.
  Future<bool> tryActivate() async {
    if (await isExpired()) {
      await activateCooldown();
      return true;
    }
    return false;
  }

  /// Resets the cooldown by clearing the activation timestamp.
  ///
  /// This effectively ends the cooldown immediately, but preserves
  /// the activation count.
  Future<void> reset() async {
    await _lastActivated.remove();
  }

  /// Completely resets the cooldown and counter.
  ///
  /// Clears the activation timestamp and resets the activation count to zero.
  Future<void> completeReset() async {
    await reset();
    await _activationCount.set(0);
  }

  /// Gets the remaining time until the cooldown ends.
  ///
  /// Returns Duration.zero if the cooldown has expired or was never activated.
  Future<Duration> timeRemaining() async {
    final last = await _lastActivated.get();
    if (last == null) return Duration.zero;
    final end = last.add(duration);
    final now = DateTime.now();
    return end.isAfter(now) ? end.difference(now) : Duration.zero;
  }

  /// Returns the remaining cooldown time in seconds.
  ///
  /// Returns 0 if the cooldown has expired or was never activated.
  Future<int> secondsRemaining() async => (await timeRemaining()).inSeconds;

  /// Returns the percentage of cooldown time remaining as a value between 0.0 and 1.0.
  ///
  /// Returns 0.0 if the cooldown has expired or was never activated.
  /// Returns 1.0 if the cooldown was just activated.
  Future<double> percentRemaining() async {
    final remaining = await timeRemaining();
    final ratio = remaining.inMilliseconds / duration.inMilliseconds;
    return ratio.clamp(0.0, 1.0);
  }

  /// Returns the timestamp of the last activation, or null if never activated.
  Future<DateTime?> getLastActivationTime() async {
    return await _lastActivated.get();
  }

  /// Returns the timestamp when the cooldown will expire, or null if not active.
  Future<DateTime?> getEndTime() async {
    final last = await _lastActivated.get();
    return last?.add(duration);
  }

  /// Completes when the cooldown expires.
  ///
  /// If the cooldown is already expired or was never activated,
  /// this future completes immediately.
  Future<void> whenExpires() async {
    final remaining = await timeRemaining();
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
  }

  /// Returns the number of times the cooldown has been activated.
  Future<int> getActivationCount() async {
    return await _activationCount.getOrFallback(0);
  }

  /// Removes all saved values and duration from persistent storage.
  ///
  /// This method is primarily intended for testing and debugging purposes.
  Future<void> removeAll() async {
    await _lastActivated.remove();
    await _activationCount.remove();
  }

  /// Checks if any values related to this cooldown exist in persistent storage.
  ///
  /// This method is primarily intended for testing and debugging purposes.
  /// Returns true if any of the cooldown values exist in storage.
  Future<bool> anyStateExists() async {
    bool lastActivated = await _lastActivated.existsOnPrefs();
    bool activationCount = await _activationCount.existsOnPrefs();
    return lastActivated || activationCount;
  }
}
