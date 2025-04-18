import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../utils/fake_prefs.dart';

void main() {
  const testPrefix = 'test_cooldown';

  group('PrfCooldown', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('isCooldownActive returns false when not activated', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));
      final isActive = await cooldown.isCooldownActive();
      expect(isActive, false);

      await cooldown.removeAll();
      final isRemoved = await cooldown.anyStateExists();
      expect(isRemoved, false);
    });

    test('isCooldownActive returns true right after activation', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));
      await cooldown.activateCooldown();
      final isActive = await cooldown.isCooldownActive();
      expect(isActive, true);

      await cooldown.removeAll();
      final isRemoved = await cooldown.anyStateExists();
      expect(isRemoved, false);
    });

    test('isExpired returns true when not activated', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));
      final isExpired = await cooldown.isExpired();
      expect(isExpired, true);

      await cooldown.removeAll();
      final isRemoved = await cooldown.anyStateExists();
      expect(isRemoved, false);
    });

    test('isExpired returns false right after activation', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));
      await cooldown.activateCooldown();
      final isExpired = await cooldown.isExpired();
      expect(isExpired, false);
    });

    test('activateCooldown increments activation count', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      expect(await cooldown.getActivationCount(), 0);

      await cooldown.activateCooldown();
      expect(await cooldown.getActivationCount(), 1);

      await cooldown.activateCooldown();
      expect(await cooldown.getActivationCount(), 2);
    });

    test('reset clears activation time but keeps count', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      await cooldown.activateCooldown();
      expect(await cooldown.isCooldownActive(), true);
      expect(await cooldown.getActivationCount(), 1);

      await cooldown.reset();
      expect(await cooldown.isCooldownActive(), false);
      expect(await cooldown.getActivationCount(), 1);

      await cooldown.removeAll();
      final isRemoved = await cooldown.anyStateExists();
      expect(isRemoved, false);
    });

    test('completeReset clears activation time and resets count', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      await cooldown.activateCooldown();
      await cooldown.activateCooldown();
      expect(await cooldown.isCooldownActive(), true);
      expect(await cooldown.getActivationCount(), 2);

      await cooldown.completeReset();
      expect(await cooldown.isCooldownActive(), false);
      expect(await cooldown.getActivationCount(), 0);
    });

    test('timeRemaining returns zero if not activated', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      expect(await cooldown.timeRemaining(), Duration.zero);
    });

    test('timeRemaining decreases over time', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(seconds: 10));

      await cooldown.activateCooldown();
      final initialRemaining = await cooldown.timeRemaining();
      expect(initialRemaining.inSeconds > 5, true);

      // Wait for 2 seconds
      await Future.delayed(Duration(seconds: 2));

      final newRemaining = await cooldown.timeRemaining();
      expect(newRemaining < initialRemaining, true);
      expect(initialRemaining - newRemaining > Duration(seconds: 1), true);
    });

    test('secondsRemaining returns correct integer value', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(seconds: 30));

      await cooldown.activateCooldown();
      final seconds = await cooldown.secondsRemaining();

      expect(seconds > 20, true);
      expect(seconds <= 30, true);
    });

    test('percentRemaining starts at close to 1.0', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(seconds: 10));

      await cooldown.activateCooldown();
      final percent = await cooldown.percentRemaining();

      expect(percent < 1.0, true);
      expect(percent > 0.9, true); // Allow small time difference
    });

    test('percentRemaining decreases over time', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(seconds: 5));

      await cooldown.activateCooldown();
      final initialPercent = await cooldown.percentRemaining();

      // Wait for 1 second
      await Future.delayed(Duration(seconds: 1));

      final newPercent = await cooldown.percentRemaining();
      expect(newPercent < initialPercent, true);
      expect(initialPercent - newPercent > 0.15, true); // At least 15% decrease
    });

    test('getLastActivationTime returns null initially', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      final lastTime = await cooldown.getLastActivationTime();
      expect(lastTime, isNull);
    });

    test('getLastActivationTime returns timestamp after activation', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      final beforeActivation = DateTime.now();
      await cooldown.activateCooldown();
      final afterActivation = DateTime.now();

      final lastTime = await cooldown.getLastActivationTime();
      expect(lastTime, isNotNull);
      expect(
          lastTime!.isAfter(beforeActivation) ||
              lastTime.isAtSameMomentAs(beforeActivation),
          true);
      expect(
          lastTime.isBefore(afterActivation) ||
              lastTime.isAtSameMomentAs(afterActivation),
          true);
    });

    test('getEndTime returns null initially', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      final endTime = await cooldown.getEndTime();
      expect(endTime, isNull);
    });

    test('getEndTime returns correct end time', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final duration = Duration(hours: 2);
      final cooldown = PrfCooldown(testPrefix, duration: duration);

      final beforeActivation = DateTime.now();
      await cooldown.activateCooldown();

      final endTime = await cooldown.getEndTime();
      expect(endTime, isNotNull);

      final expectedEnd = beforeActivation.add(duration);
      // Allow 1 second tolerance for test execution time
      final difference = endTime!.difference(expectedEnd).abs().inSeconds;
      expect(difference <= 1, true);
    });

    test('whenExpires completes quickly when cooldown is not active', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      // Should complete almost immediately
      final stopwatch = Stopwatch()..start();
      await cooldown.whenExpires();
      stopwatch.stop();

      expect(stopwatch.elapsed < Duration(milliseconds: 100), true);
    });

    test('whenExpires completes when cooldown expires', () async {
      Prf.resetOverride();
      final (preferences, _) = getPreferences();
      Prf.overrideWith(preferences);

      final cooldown =
          PrfCooldown(testPrefix, duration: Duration(milliseconds: 500));

      await cooldown.activateCooldown();

      final stopwatch = Stopwatch()..start();
      await cooldown.whenExpires();
      stopwatch.stop();

      // Should complete after ~500ms
      expect(stopwatch.elapsed >= Duration(milliseconds: 450), true);
      expect(stopwatch.elapsed < Duration(milliseconds: 800), true);
    });
  });
}
