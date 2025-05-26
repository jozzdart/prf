import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import 'package:prf/prf.dart';

import '../utils/fake_prefs.dart';

void main() {
  group('PrfVariable', () {
    const sharedPreferencesOptions = SharedPreferencesOptions();

    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('returns null when no value and no default', () async {
      final (preferences, _) = getPreferences();

      final variable = _createStringVar('username');
      final value = await variable.getValue(preferences);
      expect(value, isNull);
    });

    test('returns default if key missing, then stores it', () async {
      final (preferences, store) = getPreferences();

      final variable = _createStringVar('username', defaultValue: 'guest');

      final value = await variable.getValue(preferences);
      expect(value, 'guest');

      final stored =
          await store.getString('username', sharedPreferencesOptions);
      expect(stored, 'guest');
    });

    test('caches value after first read', () async {
      final (preferences, store) = getPreferences();

      final variable = _createStringVar('username');
      await store.setString(
          'username', 'cached_user', sharedPreferencesOptions);

      final first = await variable.getValue(preferences);
      await store.setString('username', 'changed',
          sharedPreferencesOptions); // Should not affect result
      final second = await variable.getValue(preferences);

      expect(first, 'cached_user');
      expect(second, 'cached_user'); // same due to cache
    });

    test('setValue updates SharedPreferences and cache', () async {
      final (preferences, store) = getPreferences();

      final variable = _createStringVar('username');

      await variable.setValue(preferences, 'new_user');
      final result = await variable.getValue(preferences);

      expect(result, 'new_user');
      expect(await store.getString('username', sharedPreferencesOptions),
          'new_user');
    });

    test('removeValue clears cache and deletes from prefs', () async {
      final (preferences, store) = getPreferences();

      final variable = _createStringVar('username');
      await variable.setValue(preferences, 'to_be_removed');

      await variable.removeValue(preferences);

      expect(await variable.getValue(preferences), isNull);
      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains('username'), false);
    });

    test('isValueNull works correctly', () async {
      final (preferences, _) = getPreferences();

      final variable = _createStringVar('username');
      expect(await variable.isValueNull(preferences), true);

      await variable.setValue(preferences, 'not_null');
      expect(await variable.isValueNull(preferences), false);
    });

    test('getValue does not overwrite existing value with default', () async {
      final (preferences, store) = getPreferences();

      await store.setString('username', 'existing', sharedPreferencesOptions);
      final variable = _createStringVar('username', defaultValue: 'default');

      final value = await variable.getValue(preferences);
      expect(value, 'existing');
    });
  });
}

/// Returns a simple PrfVariable instance
Prf<String> _createStringVar(String key, {String? defaultValue}) {
  return Prf<String>(
    key,
    defaultValue: defaultValue,
  );
}
