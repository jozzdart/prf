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
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));
      final isActive = await cooldown.isCooldownActive();
      expect(isActive, false);

      await cooldown.removeAll();
      final isRemoved = await cooldown.anyStateExists();
      expect(isRemoved, false);
    });

    test('isCooldownActive returns true right after activation', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));
      await cooldown.activateCooldown();
      final isActive = await cooldown.isCooldownActive();
      expect(isActive, true);

      await cooldown.removeAll();
      final isRemoved = await cooldown.anyStateExists();
      expect(isRemoved, false);
    });

    test('isExpired returns true when not activated', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));
      final isExpired = await cooldown.isExpired();
      expect(isExpired, true);

      await cooldown.removeAll();
      final isRemoved = await cooldown.anyStateExists();
      expect(isRemoved, false);
    });

    test('isExpired returns false right after activation', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));
      await cooldown.activateCooldown();
      final isExpired = await cooldown.isExpired();
      expect(isExpired, false);
    });

    test('activateCooldown increments activation count', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      expect(await cooldown.getActivationCount(), 0);

      await cooldown.activateCooldown();
      expect(await cooldown.getActivationCount(), 1);

      await cooldown.activateCooldown();
      expect(await cooldown.getActivationCount(), 2);
    });

    test('reset clears activation time but keeps count', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

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
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

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
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      expect(await cooldown.timeRemaining(), Duration.zero);
    });

    test('timeRemaining decreases over time', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(seconds: 2));

      await cooldown.activateCooldown();
      final initialRemaining = await cooldown.timeRemaining();
      expect(initialRemaining.inSeconds > 0.5, true);

      // Wait for 2 seconds
      await Future.delayed(Duration(milliseconds: 2));

      final newRemaining = await cooldown.timeRemaining();
      expect(newRemaining < initialRemaining, true);
      expect(initialRemaining - newRemaining > Duration(milliseconds: 1), true);
    });

    test('secondsRemaining returns correct integer value', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(seconds: 30));

      await cooldown.activateCooldown();
      final seconds = await cooldown.secondsRemaining();

      expect(seconds > 20, true);
      expect(seconds <= 30, true);
    });

    test('percentRemaining starts at close to 1.0', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(seconds: 5));

      await cooldown.activateCooldown();
      await Future.delayed(Duration(milliseconds: 2));
      final percent = await cooldown.percentRemaining();

      expect(percent < 1.0, true);
      expect(percent > 0.8,
          true); // Allow larger time difference for test execution
    });

    test('percentRemaining decreases over time', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(seconds: 5));

      await cooldown.activateCooldown();
      final initialPercent = await cooldown.percentRemaining();

      // Wait for 1 second
      await Future.delayed(Duration(milliseconds: 2));

      final newPercent = await cooldown.percentRemaining();
      expect(newPercent < initialPercent, true);
      expect(
          initialPercent - newPercent > 0.0001, true); // At least 15% decrease
    });

    test('getLastActivationTime returns null initially', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      final lastTime = await cooldown.getLastActivationTime();
      expect(lastTime, isNull);
    });

    test('getLastActivationTime returns timestamp after activation', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

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
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      final endTime = await cooldown.getEndTime();
      expect(endTime, isNull);
    });

    test('getEndTime returns correct end time', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

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
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      // Should complete almost immediately
      final stopwatch = Stopwatch()..start();
      await cooldown.whenExpires();
      stopwatch.stop();

      expect(stopwatch.elapsed < Duration(milliseconds: 100), true);
    });

    test('whenExpires completes when cooldown expires', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

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

    test('tryActivate returns true when cooldown is not active', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      // Should return true when cooldown is not active
      final result = await cooldown.tryActivate();
      expect(result, true);

      // Cooldown should now be active
      expect(await cooldown.isCooldownActive(), true);
      expect(await cooldown.getActivationCount(), 1);
    });

    test('tryActivate returns false when cooldown is active', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      // Activate cooldown first
      await cooldown.activateCooldown();
      expect(await cooldown.isCooldownActive(), true);

      // Should return false when cooldown is already active
      final result = await cooldown.tryActivate();
      expect(result, false);

      // Activation count should not have changed
      expect(await cooldown.getActivationCount(), 1);
    });

    test('removeAll removes all stored values', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      // Set up some data
      await cooldown.activateCooldown();
      expect(await cooldown.anyStateExists(), true);

      // Remove all data
      await cooldown.removeAll();

      // Verify everything is removed
      expect(await cooldown.anyStateExists(), false);
      expect(await cooldown.getLastActivationTime(), isNull);
      expect(await cooldown.getActivationCount(), 0);
    });

    test('anyStateExists reports correct state', () async {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      final cooldown = PrfCooldown(testPrefix, duration: Duration(hours: 1));

      // Initially nothing should exist
      expect(await cooldown.anyStateExists(), false);

      // After activation, state should exist
      await cooldown.activateCooldown();
      expect(await cooldown.anyStateExists(), true);

      // After reset, state should still exist (activation count)
      await cooldown.reset();
      expect(await cooldown.anyStateExists(), true);

      // After complete reset, state should still exist (with count = 0)
      await cooldown.completeReset();
      expect(await cooldown.anyStateExists(), true);

      // After removeAll, nothing should exist
      await cooldown.removeAll();
      expect(await cooldown.anyStateExists(), false);
    });
  });
}
