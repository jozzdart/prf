import 'package:flutter_test/flutter_test.dart';
import 'package:prf/types/prf_bool.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

void main() {
  const key = 'test_bool';
  const sharedPreferencesOptions = SharedPreferencesOptions();

  group('PrfBool', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('returns null if not set and no default provided', () async {
      final (preferences, _) = getPreferences();
      final boolPref = PrfBool(key);
      final value = await boolPref.getValue(preferences);
      expect(value, isNull);
    });

    test('returns default if not set and default provided', () async {
      final (preferences, _) = getPreferences();
      final boolPref = PrfBool(key, defaultValue: true);
      final value = await boolPref.getValue(preferences);
      expect(value, true);
    });

    test('sets and gets value correctly', () async {
      final (preferences, _) = getPreferences();
      final boolPref = PrfBool(key);
      await boolPref.setValue(preferences, true);
      final value = await boolPref.getValue(preferences);
      expect(value, true);
    });

    test('updates existing value', () async {
      final (preferences, _) = getPreferences();
      final boolPref = PrfBool(key);
      await boolPref.setValue(preferences, false);
      var value = await boolPref.getValue(preferences);
      expect(value, false);

      await boolPref.setValue(preferences, true);
      value = await boolPref.getValue(preferences);
      expect(value, true);
    });

    test('removes value properly', () async {
      final (preferences, store) = getPreferences();
      final boolPref = PrfBool(key);
      await boolPref.setValue(preferences, true);

      await boolPref.removeValue(preferences);
      final value = await boolPref.getValue(preferences);
      expect(value, isNull);

      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains(key), false);
    });

    test('isValueNull returns true when no value', () async {
      final (preferences, _) = getPreferences();
      final boolPref = PrfBool(key);
      final isNull = await boolPref.isValueNull(preferences);
      expect(isNull, true);
    });

    test('isValueNull returns false when value is set', () async {
      final (preferences, _) = getPreferences();
      final boolPref = PrfBool(key);
      await boolPref.setValue(preferences, true);
      final isNull = await boolPref.isValueNull(preferences);
      expect(isNull, false);
    });

    test('caches value after first access', () async {
      final (preferences, store) = getPreferences();
      final boolPref = PrfBool(key);
      await store.setBool(key, true, sharedPreferencesOptions);

      final value1 = await boolPref.getValue(preferences);
      expect(value1, true);

      // Modify directly, should not affect cached value
      await store.setBool(key, false, sharedPreferencesOptions);
      final value2 = await boolPref.getValue(preferences);
      expect(value2, true); // still cached
    });

    test('default value is persisted after first access', () async {
      final (preferences, store) = getPreferences();
      final boolPref = PrfBool(key, defaultValue: true);

      final first = await boolPref.getValue(preferences);
      expect(first, true);

      final raw = await store.getBool(key, sharedPreferencesOptions);
      expect(raw, true);
    });
  });
}
