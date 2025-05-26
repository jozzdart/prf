import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:prf/prf.dart';

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

class TestPrfObject extends BasePrfObject<String> {
  @override
  PrfAdapter<String> get adapter => TestAdapter();

  const TestPrfObject(super.key, {super.defaultValue});
}

void main() {
  group('PrfOperationExtensions', () {
    SharedPreferencesAsync setupPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final preferences = SharedPreferencesAsync();

      // Override PrfService instance with our test preferences
      PrfService.overrideWith(preferences);

      return preferences;
    }

    tearDown(() {
      // Reset the override after each test
      PrfService.resetOverride();
    });

    test('get() retrieves value from default service', () async {
      final preferences = setupPreferences();
      await preferences.setString('test_key', 'value_from_service');

      final object = TestPrfObject('test_key');
      final value = await object.get();

      expect(value, 'value_from_service');
    });

    test('set() stores value in default service', () async {
      final preferences = setupPreferences();

      final object = TestPrfObject('test_key');
      await object.set('value_to_store');

      final stored = await preferences.getString('test_key');
      expect(stored, 'value_to_store');
    });

    test('remove() deletes value from default service', () async {
      final preferences = setupPreferences();

      final object = TestPrfObject('test_key');
      await object.set('temp_value');
      await object.remove();

      final exists = await preferences.containsKey('test_key');
      expect(exists, false);
    });

    test('isNull() correctly checks if value is null', () async {
      setupPreferences();

      final object = TestPrfObject('test_key');
      expect(await object.isNull(), true);

      await object.set('not_null');
      expect(await object.isNull(), false);
    });

    test('getOrFallback() returns fallback when value is null', () async {
      setupPreferences();

      final object = TestPrfObject('test_key');
      final value = await object.getOrFallback('fallback_value');

      expect(value, 'fallback_value');
    });

    test('getOrFallback() returns actual value when available', () async {
      setupPreferences();

      final object = TestPrfObject('test_key');
      await object.set('actual_value');

      final value = await object.getOrFallback('fallback_value');
      expect(value, 'actual_value');
    });

    test('existsOnPrefs() correctly checks if key exists', () async {
      final preferences = setupPreferences();

      final object = TestPrfObject('test_key');
      expect(await object.existsOnPrefs(), false);

      await preferences.setString('test_key', 'some_value');
      expect(await object.existsOnPrefs(), true);
    });
  });
}
