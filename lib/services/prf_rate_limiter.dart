import 'dart:math';
import 'package:prf/prf.dart';

/// A robust, industry-grade token bucket rate limiter using `prf`.
///
/// Limits actions to a defined number within a given duration,
/// using a refillable token system with persistent storage.
///
/// Example:
/// ```dart
/// final limiter = PrfRateLimiter('chat_send', maxTokens: 100, refillDuration: Duration(minutes: 15));
/// final canSend = await limiter.tryConsume();
/// ```
class PrfRateLimiter {
  /// The maximum number of tokens that can be accumulated.
  final int maxTokens;

  /// The time period over which tokens are fully replenished.
  final Duration refillDuration;

  final PrfDouble _tokenCount;
  final PrfDateTime _lastRefill;

  /// Creates a new rate limiter with the specified prefix and configuration.
  ///
  /// - [prefix] is used to create unique keys for storing rate limiter data.
  /// - [maxTokens] defines the maximum number of operations allowed in the time period.
  /// - [refillDuration] specifies the time period over which tokens are fully replenished.
  PrfRateLimiter(
    prefix, {
    required this.maxTokens,
    required this.refillDuration,
  })  : _tokenCount = PrfDouble('prf_${prefix}_rate_tokens',
            defaultValue: maxTokens.toDouble()),
        _lastRefill = PrfDateTime('prf_${prefix}_rate_last_refill',
            defaultValue: DateTime.now());

  /// Attempts to consume 1 token.
  ///
  /// Returns `true` if the action is allowed (token consumed), or `false` if rate limited.
  ///
  /// This method automatically handles token refill based on elapsed time since the last check.
  Future<bool> tryConsume() async {
    final now = DateTime.now();
    final tokens = await _tokenCount.getOrFallback(maxTokens.toDouble());
    final last = await _lastRefill.getOrFallback(now);

    final elapsedMs = now.difference(last).inMilliseconds;
    final refillRatePerMs = maxTokens / refillDuration.inMilliseconds;
    final refilledTokens = tokens + (elapsedMs * refillRatePerMs);
    final newTokenCount = min(maxTokens.toDouble(), refilledTokens);

    if (newTokenCount >= 1) {
      await _tokenCount.set(newTokenCount - 1);
      await _lastRefill.set(now);
      return true;
    } else {
      await _tokenCount.set(newTokenCount); // update even if not consumed
      await _lastRefill.set(now);
      return false;
    }
  }

  /// Gets the number of tokens currently available.
  ///
  /// This method calculates the current token count based on the stored value
  /// plus any tokens that would have been refilled since the last check.
  /// The returned value is capped at [maxTokens].
  Future<double> getAvailableTokens() async {
    final now = DateTime.now();
    final tokens = await _tokenCount.getOrFallback(maxTokens.toDouble());
    final last = await _lastRefill.getOrFallback(now);

    final elapsedMs = now.difference(last).inMilliseconds;
    final refillRatePerMs = maxTokens / refillDuration.inMilliseconds;
    final refilledTokens = tokens + (elapsedMs * refillRatePerMs);

    return min(maxTokens.toDouble(), refilledTokens);
  }

  /// Calculates the time remaining until the next token is available.
  ///
  /// Returns Duration.zero if a token is already available.
  /// This is useful for implementing retry mechanisms or displaying wait times to users.
  Future<Duration> timeUntilNextToken() async {
    final available = await getAvailableTokens();
    if (available >= 1) return Duration.zero;

    final refillRatePerMs = maxTokens / refillDuration.inMilliseconds;
    final needed = 1 - available;
    final msUntilNext = (needed / refillRatePerMs).ceil();
    return Duration(milliseconds: msUntilNext);
  }

  /// Fully resets the limiter to its initial state.
  ///
  /// This restores the token count to [maxTokens] and resets the refill timestamp
  /// to the current time. Useful for scenarios where you want to clear rate limits,
  /// such as after a user upgrade or payment.
  Future<void> reset() async {
    await _tokenCount.set(maxTokens.toDouble());
    await _lastRefill.set(DateTime.now());
  }

  /// Removes all persisted state from storage.
  ///
  /// This completely clears all rate limiter data from persistent storage.
  /// Primarily intended for testing and debugging purposes.
  Future<void> removeAll() async {
    await _tokenCount.remove();
    await _lastRefill.remove();
  }

  /// Checks if any rate limiter state exists in persistent storage.
  ///
  /// Returns true if either the token count or last refill timestamp
  /// exists in SharedPreferences. Useful for determining if this is
  /// the first time the rate limiter is being used.
  Future<bool> anyStateExists() async {
    return await _tokenCount.existsOnPrefs() ||
        await _lastRefill.existsOnPrefs();
  }

  /// Returns the `DateTime` when a token will be available.
  /// Returns `DateTime.now()` if already available.
  Future<DateTime> nextAllowedTime() async {
    final remaining = await timeUntilNextToken();
    return DateTime.now().add(remaining);
  }
}
