import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/core/cached_object.dart';
import 'package:prf/core/base_adapter.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../utils/fake_prefs.dart';

class TestAdapter extends PrfAdapter<String> {
  @override
  Future<String?> getter(SharedPreferencesAsync prefs, String key) async {
    return await prefs.getString(key);
  }

  @override
  Future<void> setter(
      SharedPreferencesAsync prefs, String key, String value) async {
    await prefs.setString(key, value);
  }
}

class TestCachedObject extends CachedPrfObject<String> {
  @override
  PrfAdapter<String> get adapter => TestAdapter();

  TestCachedObject(super.key, {super.defaultValue});
}

void main() {
  group('CachedPrfObject', () {
    const sharedPreferencesOptions = SharedPreferencesOptions();

    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('caches value after first read', () async {
      final (preferences, store) = getPreferences();

      final object = TestCachedObject('test_key');
      await store.setString(
          'test_key', 'initial_value', sharedPreferencesOptions);

      final firstValue = await object.getValue(preferences);
      await store.setString(
          'test_key', 'changed_value', sharedPreferencesOptions);
      final secondValue = await object.getValue(preferences);

      expect(firstValue, 'initial_value');
      expect(secondValue, 'initial_value'); // Should still have cached value
      expect(object.cachedValue, 'initial_value');
    });

    test('setValue updates both cache and SharedPreferences', () async {
      final (preferences, store) = getPreferences();

      final object = TestCachedObject('test_key');
      await object.setValue(preferences, 'new_value');

      expect(object.cachedValue, 'new_value');
      final stored =
          await store.getString('test_key', sharedPreferencesOptions);
      expect(stored, 'new_value');
    });

    test('removeValue clears both cache and SharedPreferences', () async {
      final (preferences, store) = getPreferences();

      final object = TestCachedObject('test_key');
      await object.setValue(preferences, 'to_be_removed');
      expect(object.cachedValue, 'to_be_removed');

      await object.removeValue(preferences);
      expect(object.cachedValue, isNull);

      final stored =
          await store.getString('test_key', sharedPreferencesOptions);
      expect(stored, isNull);
    });

    test('initCache populates the cache with stored value', () async {
      final (preferences, store) = getPreferences();

      await store.setString(
          'test_key', 'stored_value', sharedPreferencesOptions);
      final object = TestCachedObject('test_key');

      expect(object.cachedValue, isNull);
      await object.initCache(preferences);
      expect(object.cachedValue, 'stored_value');
    });

    test('initCache populates with default value when no stored value',
        () async {
      final (preferences, _) = getPreferences();

      final object =
          TestCachedObject('test_key', defaultValue: 'default_value');
      await object.initCache(preferences);

      expect(object.cachedValue, 'default_value');
    });

    test('cached value is used instead of reading from storage', () async {
      final (preferences, store) = getPreferences();

      final object = TestCachedObject('test_key');
      await object.setValue(preferences, 'cached_value');

      // Clear the log to verify no reads from storage
      store.log.clear();

      final value = await object.getValue(preferences);
      expect(value, 'cached_value');

      // Verify no getString calls were made
      expect(
          store.log.where((call) => call.method == 'getString').isEmpty, true);
    });
  });
}
