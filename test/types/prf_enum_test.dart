import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:prf/prf.dart';

import '../utils/fake_prefs.dart';

enum TestStatus { idle, loading, success, error }

void main() {
  const key = 'test_enum';
  const sharedPreferencesOptions = SharedPreferencesOptions();

  group('PrfEnum Tests', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('Returns null when no value is set', () async {
      final (preferences, _) = getPreferences();
      final prfEnum = PrfEnum<TestStatus>(key, values: TestStatus.values);

      final result = await prfEnum.getValue(preferences);
      expect(result, isNull);
    });

    test('Correctly sets and gets enum value', () async {
      final (preferences, _) = getPreferences();
      final prfEnum = PrfEnum<TestStatus>(key, values: TestStatus.values);

      await prfEnum.setValue(preferences, TestStatus.success);
      final result = await prfEnum.getValue(preferences);
      expect(result, TestStatus.success);
    });

    test('Correctly removes enum value', () async {
      final (preferences, store) = getPreferences();
      final prfEnum = PrfEnum<TestStatus>(key, values: TestStatus.values);

      await prfEnum.setValue(preferences, TestStatus.loading);
      await prfEnum.removeValue(preferences);

      final result = await prfEnum.getValue(preferences);
      expect(result, isNull);

      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains(key), isFalse);
    });

    test('Handles invalid index gracefully (too high)', () async {
      final (preferences, store) = getPreferences();
      final prfEnum = PrfEnum<TestStatus>(key, values: TestStatus.values);

      await store.setInt(key, 99, sharedPreferencesOptions); // invalid index
      final result = await prfEnum.getValue(preferences);
      expect(result, isNull);
    });

    test('Handles invalid index gracefully (negative)', () async {
      final (preferences, store) = getPreferences();
      final prfEnum = PrfEnum<TestStatus>(key, values: TestStatus.values);

      await store.setInt(key, -5, sharedPreferencesOptions); // invalid index
      final result = await prfEnum.getValue(preferences);
      expect(result, isNull);
    });

    test('Works with defaultValue when missing', () async {
      final (preferences, _) = getPreferences();
      final prfEnum = PrfEnum<TestStatus>(
        key,
        values: TestStatus.values,
        defaultValue: TestStatus.idle,
      );

      final result = await prfEnum.getValue(preferences);
      expect(result, TestStatus.idle);
    });

    test('Uses defaultValue only when no value is stored', () async {
      final (preferences, _) = getPreferences();
      final prfEnum = PrfEnum<TestStatus>(
        key,
        values: TestStatus.values,
        defaultValue: TestStatus.loading,
      );

      // Value is not yet set → should return default
      final result1 = await prfEnum.getValue(preferences);
      expect(result1, TestStatus.loading);

      // After setting a value → should return that value instead
      await prfEnum.setValue(preferences, TestStatus.error);
      final result2 = await prfEnum.getValue(preferences);
      expect(result2, TestStatus.error);
    });

    test('Caches value after first access', () async {
      final (preferences, store) = getPreferences();
      final prfEnum = PrfEnum<TestStatus>(key, values: TestStatus.values);

      await store.setInt(
          key, TestStatus.success.index, sharedPreferencesOptions);

      final value1 = await prfEnum.getValue(preferences);
      expect(value1, TestStatus.success);

      // Modify directly, should not affect cached value
      await store.setInt(key, TestStatus.error.index, sharedPreferencesOptions);
      final value2 = await prfEnum.getValue(preferences);
      expect(value2, TestStatus.success); // still cached
    });

    test('Default value is persisted after first access', () async {
      final (preferences, store) = getPreferences();
      final prfEnum = PrfEnum<TestStatus>(
        key,
        values: TestStatus.values,
        defaultValue: TestStatus.idle,
      );

      final first = await prfEnum.getValue(preferences);
      expect(first, TestStatus.idle);

      final raw = await store.getInt(key, sharedPreferencesOptions);
      expect(raw, TestStatus.idle.index);
    });

    test('isValueNull returns true when no value', () async {
      final (preferences, _) = getPreferences();
      final prfEnum = PrfEnum<TestStatus>(key, values: TestStatus.values);

      final isNull = await prfEnum.isValueNull(preferences);
      expect(isNull, true);
    });

    test('isValueNull returns false when value is set', () async {
      final (preferences, _) = getPreferences();
      final prfEnum = PrfEnum<TestStatus>(key, values: TestStatus.values);

      await prfEnum.setValue(preferences, TestStatus.loading);
      final isNull = await prfEnum.isValueNull(preferences);
      expect(isNull, false);
    });
  });
}
