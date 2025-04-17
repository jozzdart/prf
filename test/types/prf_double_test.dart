import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/core/prf_variable.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

// PrfDouble class under test
class PrfDouble extends PrfVariable<double> {
  PrfDouble(String key, {double? defaultValue})
      : super(
          key,
          (prefs, key) async => prefs.getDouble(key),
          (prefs, key, value) async => await prefs.setDouble(key, value),
          defaultValue,
        );
}

void main() {
  const testKey = 'test_double';
  const sharedPreferencesOptions = SharedPreferencesOptions();

  group('PrfDouble', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test(
      'should return null if no value is set and no default provided',
      () async {
        final (preferences, _) = getPreferences();
        final prf = PrfDouble(testKey);

        final value = await prf.getValue(preferences);

        expect(value, isNull);
      },
    );

    test(
      'should return default value if no value is set and default is provided',
      () async {
        final (preferences, _) = getPreferences();
        final prf = PrfDouble(testKey, defaultValue: 3.14);

        final value = await prf.getValue(preferences);

        expect(value, 3.14);
      },
    );

    test('should write and read the value correctly', () async {
      final (preferences, _) = getPreferences();
      final prf = PrfDouble(testKey);

      await prf.setValue(preferences, 7.77);
      final value = await prf.getValue(preferences);

      expect(value, 7.77);
    });

    test('should overwrite the value correctly', () async {
      final (preferences, _) = getPreferences();
      final prf = PrfDouble(testKey);

      await prf.setValue(preferences, 1.11);
      await prf.setValue(preferences, 2.22);
      final value = await prf.getValue(preferences);

      expect(value, 2.22);
    });

    test('should remove the value and return default if provided', () async {
      final (preferences, store) = getPreferences();
      final prf = PrfDouble(testKey, defaultValue: 0.5);

      await prf.setValue(preferences, 6.6);
      await prf.removeValue(preferences);

      final value = await prf.getValue(preferences);
      expect(value, 0.5);

      final isNull = await prf.isValueNull(preferences);
      expect(isNull, false);

      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains(testKey), true);
    });

    test('should remove the value and return null if no default', () async {
      final (preferences, store) = getPreferences();
      final prf = PrfDouble(testKey);

      await prf.setValue(preferences, 2.2);
      await prf.removeValue(preferences);

      final value = await prf.getValue(preferences);
      expect(value, isNull);

      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains(testKey), false);
    });

    test('isValueNull should be true when unset and no default', () async {
      final (preferences, _) = getPreferences();
      final prf = PrfDouble(testKey);

      final isNull = await prf.isValueNull(preferences);

      expect(isNull, true);
    });

    test('isValueNull should be false when set', () async {
      final (preferences, _) = getPreferences();
      final prf = PrfDouble(testKey);

      await prf.setValue(preferences, 9.99);

      final isNull = await prf.isValueNull(preferences);

      expect(isNull, false);
    });

    test('should cache after first read', () async {
      final (preferences, store) = getPreferences();
      final prf = PrfDouble(testKey);
      await store.setDouble(testKey, 1.0, sharedPreferencesOptions);

      // First read loads from prefs
      final first = await prf.getValue(preferences);

      // Change value directly in prefs to simulate external change
      await store.setDouble(testKey, 2.0, sharedPreferencesOptions);

      // Cached value should remain the same
      final second = await prf.getValue(preferences);

      expect(first, 1.0);
      expect(second, 1.0);
    });

    test('should update cached value on setValue()', () async {
      final (preferences, _) = getPreferences();
      final prf = PrfDouble(testKey);

      await prf.setValue(preferences, 5.5);
      final first = await prf.getValue(preferences);

      await prf.setValue(preferences, 6.6);
      final second = await prf.getValue(preferences);

      expect(first, 5.5);
      expect(second, 6.6);
    });

    test('default value is persisted after first access', () async {
      final (preferences, store) = getPreferences();
      final prf = PrfDouble(testKey, defaultValue: 4.2);

      final first = await prf.getValue(preferences);
      expect(first, 4.2);

      final raw = await store.getDouble(testKey, sharedPreferencesOptions);
      expect(raw, 4.2);
    });
  });
}
