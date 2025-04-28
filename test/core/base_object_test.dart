import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/core/base_object.dart';
import 'package:prf/core/base_adapter.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

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
  group('BasePrfObject', () {
    const sharedPreferencesOptions = SharedPreferencesOptions();

    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('returns null when no value and no default', () async {
      final (preferences, _) = getPreferences();

      final object = TestPrfObject('test_key');
      final value = await object.getValue(preferences);
      expect(value, isNull);
    });

    test('returns default if key missing, then stores it', () async {
      final (preferences, store) = getPreferences();

      final object = TestPrfObject('test_key', defaultValue: 'default_value');

      final value = await object.getValue(preferences);
      expect(value, 'default_value');

      final stored =
          await store.getString('test_key', sharedPreferencesOptions);
      expect(stored, 'default_value');
    });

    test('returns stored value if it exists', () async {
      final (preferences, store) = getPreferences();

      await store.setString(
          'test_key', 'stored_value', sharedPreferencesOptions);
      final object = TestPrfObject('test_key', defaultValue: 'default_value');

      final value = await object.getValue(preferences);
      expect(value, 'stored_value');
    });

    test('setValue updates SharedPreferences', () async {
      final (preferences, store) = getPreferences();

      final object = TestPrfObject('test_key');
      await object.setValue(preferences, 'new_value');

      final stored =
          await store.getString('test_key', sharedPreferencesOptions);
      expect(stored, 'new_value');
    });

    test('removeValue deletes from prefs', () async {
      final (preferences, store) = getPreferences();

      final object = TestPrfObject('test_key');
      await object.setValue(preferences, 'to_be_removed');

      await object.removeValue(preferences);

      final stored =
          await store.getString('test_key', sharedPreferencesOptions);
      expect(stored, isNull);

      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains('test_key'), false);
    });

    test('isValueNull works correctly', () async {
      final (preferences, store) = getPreferences();

      final object = TestPrfObject('test_key');
      expect(await object.isValueNull(preferences), true);

      await store.setString('test_key', 'not_null', sharedPreferencesOptions);
      expect(await object.isValueNull(preferences), false);
    });
  });
}
