import 'package:flutter_test/flutter_test.dart';
import 'package:prf/special_types/prf_duration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

void main() {
  const key = 'test_duration';
  const sharedPreferencesOptions = SharedPreferencesOptions();

  group('PrfDuration', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('returns null if not set and no default provided', () async {
      final (preferences, _) = getPreferences();
      final durationPref = PrfDuration(key);
      final value = await durationPref.getValue(preferences);
      expect(value, isNull);
    });

    test('returns default if not set and default provided', () async {
      final (preferences, _) = getPreferences();
      final defaultDuration = Duration(minutes: 5);
      final durationPref = PrfDuration(key, defaultValue: defaultDuration);
      final value = await durationPref.getValue(preferences);
      expect(value, defaultDuration);
    });

    test('sets and gets value correctly', () async {
      final (preferences, _) = getPreferences();
      final durationPref = PrfDuration(key);
      final testDuration = Duration(hours: 2, minutes: 30);

      await durationPref.setValue(preferences, testDuration);
      final value = await durationPref.getValue(preferences);

      expect(value, testDuration);
    });

    test('updates existing value', () async {
      final (preferences, _) = getPreferences();
      final durationPref = PrfDuration(key);

      await durationPref.setValue(preferences, Duration(seconds: 30));
      var value = await durationPref.getValue(preferences);
      expect(value, Duration(seconds: 30));

      await durationPref.setValue(preferences, Duration(minutes: 1));
      value = await durationPref.getValue(preferences);
      expect(value, Duration(minutes: 1));
    });

    test('stores duration as microseconds using int', () async {
      final (preferences, store) = getPreferences();
      final durationPref = PrfDuration(key);
      final testDuration = Duration(milliseconds: 1500); // 1.5 seconds

      await durationPref.setValue(preferences, testDuration);

      final storedValue = await store.getInt(key, sharedPreferencesOptions);
      expect(storedValue, testDuration.inMicroseconds);
    });

    test('restores duration from microseconds int value', () async {
      final (preferences, store) = getPreferences();
      final durationPref = PrfDuration(key);

      // Set directly as int (1.5 seconds = 1,500,000 microseconds)
      final microseconds = 1500000;
      await store.setInt(key, microseconds, sharedPreferencesOptions);

      final value = await durationPref.getValue(preferences);
      expect(value, Duration(milliseconds: 1500));
    });

    test('handles zero duration', () async {
      final (preferences, _) = getPreferences();
      final durationPref = PrfDuration(key);

      await durationPref.setValue(preferences, Duration.zero);
      final value = await durationPref.getValue(preferences);

      expect(value, Duration.zero);
    });

    test('handles very large durations', () async {
      final (preferences, _) = getPreferences();
      final durationPref = PrfDuration(key);

      final largeDuration = Duration(days: 365 * 10); // 10 years
      await durationPref.setValue(preferences, largeDuration);
      final value = await durationPref.getValue(preferences);

      expect(value, largeDuration);
    });

    test('handles negative durations', () async {
      final (preferences, _) = getPreferences();
      final durationPref = PrfDuration(key);

      final negativeDuration = Duration(days: -30); // -30 days
      await durationPref.setValue(preferences, negativeDuration);
      final value = await durationPref.getValue(preferences);

      expect(value, negativeDuration);
    });

    test('caches value after first fetch', () async {
      final (preferences, store) = getPreferences();
      final durationPref = PrfDuration(key);

      final initialDuration = Duration(minutes: 10);
      await store.setInt(
          key, initialDuration.inMicroseconds, sharedPreferencesOptions);

      final firstRead = await durationPref.getValue(preferences);
      expect(firstRead, initialDuration);

      // Change the underlying value directly
      await store.setInt(
          key, Duration(minutes: 20).inMicroseconds, sharedPreferencesOptions);

      // Second read should return cached value
      final secondRead = await durationPref.getValue(preferences);
      expect(secondRead, initialDuration);
    });

    test('removes value correctly', () async {
      final (preferences, store) = getPreferences();
      final durationPref = PrfDuration(key);

      await durationPref.setValue(preferences, Duration(hours: 1));
      await durationPref.removeValue(preferences);

      final value = await durationPref.getValue(preferences);
      expect(value, isNull);

      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains(key), false);
    });

    test('isValueNull returns true when no value', () async {
      final (preferences, _) = getPreferences();
      final durationPref = PrfDuration(key);
      final isNull = await durationPref.isValueNull(preferences);
      expect(isNull, true);
    });

    test('isValueNull returns false when value is set', () async {
      final (preferences, _) = getPreferences();
      final durationPref = PrfDuration(key);
      await durationPref.setValue(preferences, Duration(seconds: 45));
      final isNull = await durationPref.isValueNull(preferences);
      expect(isNull, false);
    });

    test('getValue sets default value if not exists and default is provided',
        () async {
      final (preferences, store) = getPreferences();
      final defaultDuration = Duration(days: 1);
      final durationPref = PrfDuration(key, defaultValue: defaultDuration);

      final value = await durationPref.getValue(preferences);
      expect(value, defaultDuration);

      // Verify it was stored
      final storedValue = await store.getInt(key, sharedPreferencesOptions);
      expect(storedValue, defaultDuration.inMicroseconds);
    });
  });
}
