import 'package:flutter_test/flutter_test.dart';
import 'package:prf/types/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

void main() {
  group('Prf<String>', () {
    const testKey = 'username';
    const testValue = 'dev_pikud';
    const defaultValue = 'default_user';
    const sharedPreferencesOptions = SharedPreferencesOptions();

    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test(
      'initial getValue returns null if key does not exist and no default',
      () async {
        final (preferences, _) = getPreferences();
        final variable = Prf<String>(testKey);
        final value = await variable.getValue(preferences);
        expect(value, isNull);
      },
    );

    test(
      'initial getValue returns default if key does not exist and default is provided',
      () async {
        final (preferences, _) = getPreferences();
        final variable = Prf<String>(testKey, defaultValue: defaultValue);
        final value = await variable.getValue(preferences);
        expect(value, defaultValue);
      },
    );

    test(
      'getValue sets the default into SharedPreferences if not already set',
      () async {
        final (preferences, store) = getPreferences();
        final variable = Prf<String>(testKey, defaultValue: defaultValue);
        await variable.getValue(preferences);
        expect(await store.getString(testKey, sharedPreferencesOptions),
            defaultValue);
      },
    );

    test('setValue stores the value and getValue returns it', () async {
      final (preferences, store) = getPreferences();
      final variable = Prf<String>(testKey);
      await variable.setValue(preferences, testValue);
      final value = await variable.getValue(preferences);
      expect(value, testValue);
      expect(
          await store.getString(testKey, sharedPreferencesOptions), testValue);
    });

    test('getValue caches the value and avoids re-fetching', () async {
      final (preferences, store) = getPreferences();
      final variable = Prf<String>(testKey);
      await variable.setValue(preferences, testValue);

      // Clear the key directly from store
      await store.clear(
        ClearPreferencesParameters(
          filter: PreferencesFilters(allowList: {testKey}),
        ),
        sharedPreferencesOptions,
      );

      final second =
          await variable.getValue(preferences); // should return cached
      expect(second, testValue);
    });

    test('setValue overrides the previous value', () async {
      final (preferences, _) = getPreferences();
      final variable = Prf<String>(testKey);
      await variable.setValue(preferences, 'first');
      await variable.setValue(preferences, 'second');
      final value = await variable.getValue(preferences);
      expect(value, 'second');
    });

    test('removeValue clears from prefs and cache', () async {
      final (preferences, store) = getPreferences();
      final variable = Prf<String>(testKey);
      await variable.setValue(preferences, testValue);
      await variable.removeValue(preferences);
      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains(testKey), isFalse);
      final value = await variable.getValue(preferences);
      expect(value, isNull);
    });

    test('isValueNull returns true if no value exists', () async {
      final (preferences, _) = getPreferences();
      final variable = Prf<String>(testKey);
      final isNull = await variable.isValueNull(preferences);
      expect(isNull, true);
    });

    test('isValueNull returns false if value exists', () async {
      final (preferences, _) = getPreferences();
      final variable = Prf<String>(testKey);
      await variable.setValue(preferences, testValue);
      final isNull = await variable.isValueNull(preferences);
      expect(isNull, false);
    });

    test('setting value to empty string still works', () async {
      final (preferences, _) = getPreferences();
      final variable = Prf<String>(testKey);
      await variable.setValue(preferences, '');
      final value = await variable.getValue(preferences);
      expect(value, '');
    });

    test('setting value with special characters works', () async {
      final (preferences, _) = getPreferences();
      final special = '💡🚀✨\n\t~!@#\$%^&*()_+=-';
      final variable = Prf<String>(testKey);
      await variable.setValue(preferences, special);
      final value = await variable.getValue(preferences);
      expect(value, special);
    });
  });
}
