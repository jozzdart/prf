import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

void main() {
  const testKey = 'test_rollover_counter';

  group('PrfRolloverCounter', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    setUp(() async {
      PrfService.resetOverride();
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);
      final counter =
          PrfRolloverCounter(testKey, resetEvery: Duration(hours: 1));
      await counter.clear();
    });

    test('starts at 0 on first use', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter =
          PrfRolloverCounter(testKey, resetEvery: Duration(hours: 1));
      expect(await counter.get(), 0);
    });

    test('increments correctly with default and custom amounts', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter =
          PrfRolloverCounter(testKey, resetEvery: Duration(hours: 1));
      expect(await counter.increment(), 1);
      expect(await counter.increment(4), 5);
    });

    test('resets after expiration (manual timestamp injection)', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter =
          PrfRolloverCounter(testKey, resetEvery: Duration(minutes: 10));
      await counter.increment(); // 1

      final old = DateTime.now().subtract(Duration(minutes: 15));
      await counter.lastUpdate.set(old);

      expect(await counter.get(), 0); // should reset
    });

    test('reset sets value to 0 and updates timestamp', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter =
          PrfRolloverCounter(testKey, resetEvery: Duration(minutes: 10));
      await counter.increment();
      await counter.reset();

      expect(await counter.get(), 0);
      final stamp = await counter.lastUpdate.get();
      expect(stamp, isNotNull);
      expect(stamp!.difference(DateTime.now()).inSeconds.abs(), lessThan(2));
    });

    test('timeRemaining returns correct values', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter =
          PrfRolloverCounter(testKey, resetEvery: Duration(minutes: 10));
      await counter.increment();
      await Future.delayed(Duration(milliseconds: 1));
      final remaining = await counter.timeRemaining();
      expect(remaining, isNotNull);
      expect(remaining!, greaterThan(Duration.zero));
      expect(remaining, lessThan(Duration(minutes: 10)));
    });

    test('percentElapsed is within [0.0, 1.0]', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter =
          PrfRolloverCounter(testKey, resetEvery: Duration(minutes: 1));
      await counter.increment();
      final percent = await counter.percentElapsed();
      expect(percent, isNotNull);
      expect(percent, inInclusiveRange(0.0, 1.0));
    });

    test('getEndTime returns valid future time', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter =
          PrfRolloverCounter(testKey, resetEvery: Duration(minutes: 2));
      await counter.increment();
      final end = await counter.getEndTime();
      expect(end, isNotNull);
      expect(end!.isAfter(DateTime.now()), isTrue);
    });

    test('secondsRemaining returns expected integer value', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter =
          PrfRolloverCounter(testKey, resetEvery: Duration(seconds: 15));
      await counter.increment();
      final secs = await counter.secondsRemaining();
      expect(secs, isNotNull);
      expect(secs, greaterThanOrEqualTo(0));
      expect(secs, lessThanOrEqualTo(15));
    });

    test('hasState reflects persisted status', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);
      final counter =
          PrfRolloverCounter(testKey, resetEvery: Duration(seconds: 5));

      expect(await counter.hasState(), isFalse);
      await counter.increment();
      expect(await counter.hasState(), isTrue);
    });

    test('clear removes all stored keys', () async {
      final (prefs, store) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter =
          PrfRolloverCounter(testKey, resetEvery: Duration(seconds: 10));
      await counter.increment();
      expect(await counter.hasState(), isTrue);
      await counter.clear();
      expect(await counter.hasState(), isFalse);

      final keys = await store.getKeys(
        const GetPreferencesParameters(filter: PreferencesFilters()),
        const SharedPreferencesOptions(),
      );
      expect(keys.any((k) => k.contains(testKey)), isFalse);
    });

    test('state is preserved across instances', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      {
        final counter =
            PrfRolloverCounter(testKey, resetEvery: Duration(seconds: 30));
        await counter.increment();
      }

      {
        final counter =
            PrfRolloverCounter(testKey, resetEvery: Duration(seconds: 30));
        expect(await counter.get(), 1);
      }
    });

    test('isCurrentlyExpired returns correct logic', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter =
          PrfRolloverCounter(testKey, resetEvery: Duration(seconds: 3));
      await counter.increment();
      expect(await counter.isCurrentlyExpired(), isFalse);

      await counter.lastUpdate
          .set(DateTime.now().subtract(Duration(seconds: 10)));
      expect(await counter.isCurrentlyExpired(), isTrue);
    });

    test('whenExpires waits until period is done', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter =
          PrfRolloverCounter(testKey, resetEvery: Duration(seconds: 2));
      await counter.increment();
      final before = DateTime.now();
      await counter.whenExpires();
      final after = DateTime.now();

      expect(
          after.difference(before).inMilliseconds, greaterThanOrEqualTo(1900));
    });
  });
}
