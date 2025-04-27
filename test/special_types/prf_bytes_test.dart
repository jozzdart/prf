import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf_types/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

void main() {
  const key = 'test_bytes';
  const sharedPreferencesOptions = SharedPreferencesOptions();

  group('Prf<Uint8List>', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('Returns null when no value is set', () async {
      final (preferences, _) = getPreferences();
      final prfBytes = Prf<Uint8List>(key);

      final result = await prfBytes.getValue(preferences);
      expect(result, isNull);
    });

    test('Can set and get Uint8List value', () async {
      final (preferences, _) = getPreferences();
      final prfBytes = Prf<Uint8List>(key);

      final original = Uint8List.fromList([1, 2, 3, 4, 5]);
      await prfBytes.setValue(preferences, original);

      final result = await prfBytes.getValue(preferences);
      expect(result, equals(original));
    });

    test('Encoded as base64 and stored as string', () async {
      final (preferences, store) = getPreferences();
      final prfBytes = Prf<Uint8List>(key);

      final bytes = Uint8List.fromList([100, 200, 255]);
      final base64 = base64Encode(bytes);

      await prfBytes.setValue(preferences, bytes);

      final rawStored = await store.getString(key, sharedPreferencesOptions);
      expect(rawStored, equals(base64));
    });

    test('Handles corrupted base64 data gracefully', () async {
      final (preferences, store) = getPreferences();
      final prfBytes = Prf<Uint8List>(key);

      await store.setString(
          key, '!!not-valid-base64@@', sharedPreferencesOptions);
      final result = await prfBytes.getValue(preferences);
      expect(result, isNull);
    });

    test('Removes value correctly', () async {
      final (preferences, store) = getPreferences();
      final prfBytes = Prf<Uint8List>(key);

      final original = Uint8List.fromList([9, 8, 7]);
      await prfBytes.setValue(preferences, original);
      await prfBytes.removeValue(preferences);

      final result = await prfBytes.getValue(preferences);
      expect(result, isNull);

      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains(key), false);
    });

    test('Returns default value and stores it if not existing', () async {
      final (preferences, store) = getPreferences();
      final defaultBytes = Uint8List.fromList([1, 1, 1]);
      final prfBytes = Prf<Uint8List>(key, defaultValue: defaultBytes);

      final result = await prfBytes.getValue(preferences);
      expect(result, equals(defaultBytes));

      final rawStored = await store.getString(key, sharedPreferencesOptions);
      expect(rawStored, isNotNull);
    });

    test('Caches value after first fetch', () async {
      final (preferences, store) = getPreferences();
      final prfBytes = Prf<Uint8List>(key);

      final bytes = Uint8List.fromList([42, 42]);
      await store.setString(key, base64Encode(bytes), sharedPreferencesOptions);

      final loaded1 = await prfBytes.getValue(preferences);
      expect(loaded1, equals(bytes));

      await store.setString(key, base64Encode(Uint8List.fromList([0, 0])),
          sharedPreferencesOptions);

      final loaded2 = await prfBytes.getValue(preferences);
      expect(loaded2, equals(bytes), reason: 'Should return cached value');
    });

    test('isValueNull returns true when no value', () async {
      final (preferences, _) = getPreferences();
      final prfBytes = Prf<Uint8List>(key);
      final isNull = await prfBytes.isValueNull(preferences);
      expect(isNull, true);
    });

    test('isValueNull returns false when value is set', () async {
      final (preferences, _) = getPreferences();
      final prfBytes = Prf<Uint8List>(key);
      await prfBytes.setValue(preferences, Uint8List.fromList([1, 2, 3]));
      final isNull = await prfBytes.isValueNull(preferences);
      expect(isNull, false);
    });
  });
}
