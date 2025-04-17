import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/core/prf_variable.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

class PrfStringList extends PrfVariable<List<String>> {
  PrfStringList(String key, {List<String>? defaultValue})
      : super(
          key,
          (prefs, key) async => prefs.getStringList(key),
          (prefs, key, value) async => prefs.setStringList(key, value),
          defaultValue,
        );
}

void main() {
  const testKey = 'test_string_list';
  const sharedPreferencesOptions = SharedPreferencesOptions();

  group('PrfStringList', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test(
      'initial get returns null when no value is set and no default provided',
      () async {
        final (preferences, _) = getPreferences();
        final variable = PrfStringList(testKey);

        final value = await variable.getValue(preferences);
        expect(value, isNull);
      },
    );

    test('initial get returns default value if provided', () async {
      final (preferences, _) = getPreferences();
      final defaultList = ['a', 'b'];
      final variable = PrfStringList(testKey, defaultValue: defaultList);

      final value = await variable.getValue(preferences);
      expect(value, equals(defaultList));
    });

    test('set and get value works correctly', () async {
      final (preferences, _) = getPreferences();
      final variable = PrfStringList(testKey);

      final input = ['one', 'two', 'three'];
      await variable.setValue(preferences, input);
      final value = await variable.getValue(preferences);

      expect(value, equals(input));
    });

    test('setValue caches value for faster access', () async {
      final (preferences, _) = getPreferences();
      final variable = PrfStringList(testKey);

      final input = ['cached'];
      await variable.setValue(preferences, input);

      final value1 = await variable.getValue(preferences);
      final value2 = await variable.getValue(preferences);

      // Should be cached, so same instance
      expect(identical(value1, value2), isTrue);
    });

    test('removeValue clears stored value and cache', () async {
      final (preferences, store) = getPreferences();
      final variable = PrfStringList(testKey);

      await variable.setValue(preferences, ['x']);
      expect(await variable.getValue(preferences), isNotNull);

      await variable.removeValue(preferences);
      expect(await variable.getValue(preferences), isNull);

      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains(testKey), isFalse);
    });

    test('isValueNull returns true if value is not set and no default',
        () async {
      final (preferences, _) = getPreferences();
      final variable = PrfStringList(testKey);

      expect(await variable.isValueNull(preferences), isTrue);
    });

    test('isValueNull returns false after setting value', () async {
      final (preferences, _) = getPreferences();
      final variable = PrfStringList(testKey);

      await variable.setValue(preferences, ['hello']);
      expect(await variable.isValueNull(preferences), isFalse);
    });

    test('getValue persists the default to SharedPreferences', () async {
      final (preferences, store) = getPreferences();
      final defaultValue = ['persisted'];
      final variable = PrfStringList(testKey, defaultValue: defaultValue);

      final value = await variable.getValue(preferences);
      expect(value, equals(defaultValue));

      final raw = await store.getStringList(testKey, sharedPreferencesOptions);
      expect(raw, equals(defaultValue));
    });

    test('setValue overrides existing default value', () async {
      final (preferences, _) = getPreferences();
      final variable = PrfStringList(testKey, defaultValue: ['default']);

      expect(await variable.getValue(preferences), equals(['default']));

      await variable.setValue(preferences, ['new']);
      expect(await variable.getValue(preferences), equals(['new']));
    });

    test('caches value after first read', () async {
      final (preferences, store) = getPreferences();
      final variable = PrfStringList(testKey);

      await store.setStringList(testKey, ['stored'], sharedPreferencesOptions);

      final firstRead = await variable.getValue(preferences);
      await store.setStringList(testKey, ['changed'], sharedPreferencesOptions);
      final secondRead = await variable.getValue(preferences);

      expect(firstRead, equals(['stored']));
      expect(secondRead, equals(['stored'])); // Should return cached value
    });
  });
}
