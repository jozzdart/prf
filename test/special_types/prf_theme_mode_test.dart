import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

void main() {
  const key = 'test_theme_mode';
  const sharedPreferencesOptions = SharedPreferencesOptions();

  group('PrfThemeMode', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test(
        'Returns system theme as default when no value is set and no default provided',
        () async {
      final (preferences, _) = getPreferences();
      final themeModePref = PrfThemeMode(key);
      final value = await themeModePref.getValue(preferences);
      expect(value, ThemeMode.system);
    });

    test('Returns provided default when no value is set', () async {
      final (preferences, _) = getPreferences();
      final themeModePref = PrfThemeMode(key, defaultValue: ThemeMode.dark);
      final value = await themeModePref.getValue(preferences);
      expect(value, ThemeMode.dark);
    });

    test('Correctly sets and gets theme mode value', () async {
      final (preferences, _) = getPreferences();
      final themeModePref = PrfThemeMode(key);
      await themeModePref.setValue(preferences, ThemeMode.light);
      final value = await themeModePref.getValue(preferences);
      expect(value, ThemeMode.light);
    });

    test('Updates existing theme mode value', () async {
      final (preferences, _) = getPreferences();
      final themeModePref = PrfThemeMode(key);
      await themeModePref.setValue(preferences, ThemeMode.dark);
      var value = await themeModePref.getValue(preferences);
      expect(value, ThemeMode.dark);

      await themeModePref.setValue(preferences, ThemeMode.light);
      value = await themeModePref.getValue(preferences);
      expect(value, ThemeMode.light);
    });

    test('Removes theme mode value properly', () async {
      final (preferences, store) = getPreferences();
      final themeModePref = PrfThemeMode(key);
      await themeModePref.setValue(preferences, ThemeMode.dark);

      await themeModePref.removeValue(preferences);
      final value = await themeModePref.getValue(preferences);
      expect(value,
          ThemeMode.system); // After removal, should return to system default

      await themeModePref.removeValue(preferences);
      final exists = await themeModePref.existsOnPrefs();
      expect(exists, false);
    });

    test('isValueNull returns false even with system as default', () async {
      final (preferences, _) = getPreferences();
      final themeModePref = PrfThemeMode(key);
      final isNull = await themeModePref.isValueNull(preferences);
      expect(isNull, false); // Because system is the default
    });

    test('isValueNull returns false when value is explicitly set', () async {
      final (preferences, _) = getPreferences();
      final themeModePref = PrfThemeMode(key);
      await themeModePref.setValue(preferences, ThemeMode.dark);
      final isNull = await themeModePref.isValueNull(preferences);
      expect(isNull, false);
    });

    test('Caches value after first access', () async {
      final (preferences, store) = getPreferences();
      final themeModePref = PrfThemeMode(key);
      await store.setString(
          key, ThemeMode.dark.toString(), sharedPreferencesOptions);

      final value1 = await themeModePref.getValue(preferences);
      expect(value1, ThemeMode.dark);

      // Modify directly, should not affect cached value
      await store.setString(
          key, ThemeMode.light.toString(), sharedPreferencesOptions);
      final value2 = await themeModePref.getValue(preferences);
      expect(value2, ThemeMode.dark); // still cached
    });

    test('Default value is persisted after first access', () async {
      final (preferences, store) = getPreferences();
      final themeModePref = PrfThemeMode(key, defaultValue: ThemeMode.dark);

      final first = await themeModePref.getValue(preferences);
      expect(first, ThemeMode.dark);

      final raw = await store.getString(key, sharedPreferencesOptions);
      expect(raw, ThemeMode.dark.toString());
    });

    test('System theme default is persisted after first access', () async {
      final (preferences, store) = getPreferences();
      final themeModePref = PrfThemeMode(key); // Uses system as default

      final first = await themeModePref.getValue(preferences);
      expect(first, ThemeMode.system);

      final raw = await store.getString(key, sharedPreferencesOptions);
      expect(raw, ThemeMode.system.toString());
    });

    test('Handles invalid string value gracefully', () async {
      final (preferences, store) = getPreferences();
      final themeModePref = PrfThemeMode(key);

      // Store invalid value
      await store.setString(
          key, 'invalid_theme_mode', sharedPreferencesOptions);

      // Should return null or system default
      final value = await themeModePref.getValue(preferences);
      expect(value, ThemeMode.system); // Falls back to system theme
    });

    test('Can distinguish between all three theme modes', () async {
      final (preferences, _) = getPreferences();
      final themeModePref = PrfThemeMode(key);

      await themeModePref.setValue(preferences, ThemeMode.system);
      var value = await themeModePref.getValue(preferences);
      expect(value, ThemeMode.system);

      await themeModePref.setValue(preferences, ThemeMode.light);
      value = await themeModePref.getValue(preferences);
      expect(value, ThemeMode.light);

      await themeModePref.setValue(preferences, ThemeMode.dark);
      value = await themeModePref.getValue(preferences);
      expect(value, ThemeMode.dark);
    });

    test('Correctly serializes and deserializes theme mode values', () async {
      final (preferences, store) = getPreferences();

      // Test each theme mode value
      for (final mode in ThemeMode.values) {
        // Clear any previous value
        await store.clear(
            ClearPreferencesParameters(filter: PreferencesFilters()),
            sharedPreferencesOptions);

        final themeModePref = PrfThemeMode(key);
        await themeModePref.setValue(preferences, mode);

        // Verify raw storage format
        final storedValue =
            await store.getString(key, sharedPreferencesOptions);
        expect(storedValue, mode.toString());

        // Verify retrieval
        final retrievedValue = await themeModePref.getValue(preferences);
        expect(retrievedValue, mode);
      }
    });
  });
}
