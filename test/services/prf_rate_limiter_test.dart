import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

void main() {
  const testPrefix = 'test_limiter';
  const sharedPreferencesOptions = SharedPreferencesOptions();

  group('PrfRateLimiter', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    setUp(() async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);
      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 10,
        refillDuration: Duration(minutes: 1),
      );
      await limiter.removeAll();
    });

    test('initializes with correct default values', () async {
      PrfService.resetOverride();
      final (preferences, store) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 10,
        refillDuration: Duration(minutes: 5),
      );

      final tokenCount = await limiter.getAvailableTokens();
      expect(tokenCount, 10.0);

      // Check that keys were created
      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains('prf_${testPrefix}_rate_tokens'), isTrue);
      expect(keys.contains('prf_${testPrefix}_rate_last_refill'), isTrue);
    });

    test('tryConsume decreases token count when tokens available', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 10,
        refillDuration: Duration(minutes: 5),
      );

      // First consumption should succeed
      final result = await limiter.tryConsume();
      expect(result, isTrue);

      // Check that token count decreased
      final tokenCount = await limiter.getAvailableTokens();
      expect(tokenCount, closeTo(9.0, 0.001));
    });

    test('tryConsume returns false when no tokens available', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 2,
        refillDuration: Duration(minutes: 10),
      );

      // Consume all tokens
      expect(await limiter.tryConsume(), isTrue);
      expect(await limiter.tryConsume(), isTrue);

      // Should be denied
      expect(await limiter.tryConsume(), isFalse);

      // Check token count is less than 1 but not negative
      final tokenCount = await limiter.getAvailableTokens();
      expect(tokenCount, lessThan(1.0));
      expect(tokenCount, greaterThanOrEqualTo(0.0));
    });

    test('tokens refill over time correctly', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      // Test with a small refill duration for quick testing
      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 10,
        refillDuration: Duration(
            seconds: 10), // 10 tokens per 10 seconds = 1 token per second
      );

      // Consume 5 tokens
      for (int i = 0; i < 5; i++) {
        await limiter.tryConsume();
      }

      // Tokens should be approximately 5
      expect(await limiter.getAvailableTokens(), closeTo(5.0, 0.1));

      // Wait for some refill time
      await Future.delayed(Duration(seconds: 2));

      // Should have refilled approximately 2 tokens (1 per second)
      final tokensAfterWait = await limiter.getAvailableTokens();
      expect(tokensAfterWait, greaterThan(6.0));
      expect(tokensAfterWait, lessThan(8.0));
    });

    test('tokens are capped at maxTokens', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 5,
        refillDuration: Duration(seconds: 5),
      );

      // Initial tokens should be maxTokens
      expect(await limiter.getAvailableTokens(), 5.0);

      // Wait longer than needed to refill
      await Future.delayed(Duration(seconds: 3));

      // Tokens should still be capped at maxTokens
      expect(await limiter.getAvailableTokens(), 5.0);
    });

    test('timeUntilNextToken returns Duration.zero when tokens available',
        () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 5,
        refillDuration: Duration(seconds: 5),
      );

      final waitTime = await limiter.timeUntilNextToken();
      expect(waitTime, Duration.zero);
    });

    test(
        'timeUntilNextToken returns positive duration when no tokens available',
        () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 2,
        refillDuration: Duration(seconds: 10), // 0.2 tokens per second
      );

      // Consume all tokens
      await limiter.tryConsume();
      await limiter.tryConsume();
      expect(await limiter.tryConsume(), isFalse);

      // Should need to wait for some time until next token
      final waitTime = await limiter.timeUntilNextToken();
      expect(waitTime.inMilliseconds, greaterThan(0));
      expect(waitTime.inSeconds,
          lessThanOrEqualTo(5)); // Should be around 5 seconds (for 1 token)
    });

    test('reset restores tokens to max', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 10,
        refillDuration: Duration(minutes: 1),
      );

      // Consume some tokens
      await limiter.tryConsume();
      await limiter.tryConsume();
      await limiter.tryConsume();

      // Check that tokens were consumed
      expect(await limiter.getAvailableTokens(), closeTo(7.0, 0.1));

      // Reset the limiter
      await limiter.reset();

      // Should be back to maxTokens
      expect(await limiter.getAvailableTokens(), 10.0);
    });

    test('anyStateExists returns true when state exists', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 5,
        refillDuration: Duration(minutes: 1),
      );

      // Initialize by getting tokens
      await limiter.getAvailableTokens();

      expect(await limiter.anyStateExists(), isTrue);
    });

    test('anyStateExists returns false after removeAll', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 5,
        refillDuration: Duration(minutes: 1),
      );

      // Initialize by getting tokens
      await limiter.getAvailableTokens();
      expect(await limiter.anyStateExists(), isTrue);

      // Remove all state
      await limiter.removeAll();
      expect(await limiter.anyStateExists(), isFalse);
    });

    test('multiple limiters with different prefixes are isolated', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter1 = PrfRateLimiter(
        'prefix1',
        maxTokens: 5,
        refillDuration: Duration(minutes: 1),
      );

      final limiter2 = PrfRateLimiter(
        'prefix2',
        maxTokens: 10,
        refillDuration: Duration(minutes: 2),
      );

      // Consume from first limiter
      await limiter1.tryConsume();
      await limiter1.tryConsume();

      // First limiter should have reduced tokens
      expect(await limiter1.getAvailableTokens(), closeTo(3.0, 0.1));

      // Second limiter should still have full tokens
      expect(await limiter2.getAvailableTokens(), 10.0);
    });

    test('rate limiting works correctly over a sequence of attempts', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 3,
        refillDuration: Duration(seconds: 6), // 0.5 tokens per second
      );

      // First three attempts should succeed
      expect(await limiter.tryConsume(), isTrue);
      expect(await limiter.tryConsume(), isTrue);
      expect(await limiter.tryConsume(), isTrue);

      // Fourth attempt should fail
      expect(await limiter.tryConsume(), isFalse);

      // Wait for 2 seconds (should get 1 token back)
      await Future.delayed(Duration(seconds: 2));

      // Should succeed now
      expect(await limiter.tryConsume(), isTrue);

      // But next attempt should fail again
      expect(await limiter.tryConsume(), isFalse);
    });

    test('isLimitedNow returns correct status', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 3,
        refillDuration: Duration(seconds: 6),
      );

      // Initially not limited
      expect(await limiter.isLimitedNow(), isFalse);

      // Consume all tokens
      await limiter.tryConsume();
      await limiter.tryConsume();
      await limiter.tryConsume();

      // Should be limited now
      expect(await limiter.isLimitedNow(), isTrue);

      // Wait for token refill
      await Future.delayed(Duration(seconds: 2));

      // Should not be limited anymore
      expect(await limiter.isLimitedNow(), isFalse);
    });

    test('isReady returns opposite of isLimitedNow', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 2,
        refillDuration: Duration(seconds: 4),
      );

      // Initially ready
      expect(await limiter.isReady(), isTrue);

      // Consume all tokens
      await limiter.tryConsume();
      await limiter.tryConsume();

      // Should not be ready
      expect(await limiter.isReady(), isFalse);

      // This should match the inverse of isLimitedNow
      expect(await limiter.isReady(), equals(!(await limiter.isLimitedNow())));
    });

    test('runIfAllowed executes function when tokens available', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 2,
        refillDuration: Duration(seconds: 4),
      );

      // Function should execute when tokens available
      bool functionExecuted = false;
      final result = await limiter.runIfAllowed(() async {
        functionExecuted = true;
        return 'success';
      });

      expect(functionExecuted, isTrue);
      expect(result, equals('success'));

      // Consume remaining token
      await limiter.tryConsume();

      // Function should not execute when no tokens available
      functionExecuted = false;
      final result2 = await limiter.runIfAllowed(() async {
        functionExecuted = true;
        return 'success';
      });

      expect(functionExecuted, isFalse);
      expect(result2, isNull);
    });

    test('nextAllowedTime returns correct DateTime', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 2,
        refillDuration: Duration(seconds: 10), // 0.2 tokens per second
      );

      // When tokens available, should be now
      final now = DateTime.now();
      final nextTime = await limiter.nextAllowedTime();
      expect(nextTime.difference(now).inSeconds, lessThanOrEqualTo(1));

      // Consume all tokens
      await limiter.tryConsume();
      await limiter.tryConsume();

      // Next allowed time should be in the future
      final nextTimeAfterConsumption = await limiter.nextAllowedTime();
      expect(nextTimeAfterConsumption.isAfter(DateTime.now()), isTrue);

      // Should be roughly 5 seconds in the future (for 1 token at 0.2 tokens/sec)
      final diff =
          nextTimeAfterConsumption.difference(DateTime.now()).inSeconds;
      expect(diff, greaterThan(3));
      expect(diff, lessThan(7));
    });

    test('debugStats returns correct statistics', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final limiter = PrfRateLimiter(
        testPrefix,
        maxTokens: 5,
        refillDuration: Duration(seconds: 10),
      );

      // Get initial stats
      final initialStats = await limiter.debugStats();
      expect(initialStats.maxTokens, equals(5.0));
      expect(initialStats.refillDuration, equals(Duration(seconds: 10)));
      expect(initialStats.tokens, equals(5.0));
      expect(initialStats.refillRatePerMs, equals(5.0 / 10000));
      expect(initialStats.cappedTokenCount, equals(5.0));

      // Add a small delay to ensure timestamps will be different
      await Future.delayed(Duration(milliseconds: 5));

      // Consume some tokens
      await limiter.tryConsume();
      await limiter.tryConsume();

      // Check stats after consumption
      final statsAfterConsumption = await limiter.debugStats();
      expect(statsAfterConsumption.tokens, closeTo(3.0, 0.1));

      // Stats lastRefill should be updated
      expect(statsAfterConsumption.lastRefill.isAfter(initialStats.lastRefill),
          isTrue);
    });
  });
}
