import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/types/prf.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

class PrfInt extends Prf<int> {
  PrfInt(super.key, {super.defaultValue});
}

void main() {
  const testKey = 'test_int_key';
  const sharedPreferencesOptions = SharedPreferencesOptions();

  group('PrfInt', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('Returns null if value is not set and no default is provided',
        () async {
      final (preferences, _) = getPreferences();
      final variable = PrfInt(testKey);
      final value = await variable.getValue(preferences);
      expect(value, isNull);
    });

    test('Returns default if value not set, and sets it internally', () async {
      final (preferences, store) = getPreferences();
      final variable = PrfInt(testKey, defaultValue: 42);

      final value = await variable.getValue(preferences);
      expect(value, 42);

      // Check that it was actually written to SharedPreferences
      expect(await store.getInt(testKey, sharedPreferencesOptions), 42);
    });

    test('Can set and retrieve a value', () async {
      final (preferences, store) = getPreferences();
      final variable = PrfInt(testKey);

      await variable.setValue(preferences, 99);
      final value = await variable.getValue(preferences);

      expect(value, 99);
      expect(await store.getInt(testKey, sharedPreferencesOptions), 99);
    });

    test('Caches value after set', () async {
      final (preferences, store) = getPreferences();
      final variable = PrfInt(testKey);

      await variable.setValue(preferences, 10);
      await store.setInt(
          testKey, 99, sharedPreferencesOptions); // mutate directly

      final cachedValue = await variable.getValue(preferences);
      expect(cachedValue, 10); // still uses cached
    });

    test('Removes value correctly', () async {
      final (preferences, store) = getPreferences();
      final variable = PrfInt(testKey);

      await variable.setValue(preferences, 777);
      expect(await variable.getValue(preferences), 777);

      await variable.removeValue(preferences);
      expect(await variable.getValue(preferences), isNull);

      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains(testKey), isFalse);
    });

    test('isValueNull works correctly', () async {
      final (preferences, _) = getPreferences();
      final variable = PrfInt(testKey);

      expect(await variable.isValueNull(preferences), isTrue);
      await variable.setValue(preferences, 3);
      expect(await variable.isValueNull(preferences), isFalse);
    });

    test('getValue uses default only once', () async {
      final (preferences, store) = getPreferences();
      final variable = PrfInt(testKey, defaultValue: 8);

      // First call sets the default
      final value1 = await variable.getValue(preferences);
      expect(value1, 8);

      // Directly change the prefs (simulate external mutation)
      await store.setInt(testKey, 20, sharedPreferencesOptions);

      // Still returns 8 because it's cached
      final value2 = await variable.getValue(preferences);
      expect(value2, 8);
    });
  });
}
