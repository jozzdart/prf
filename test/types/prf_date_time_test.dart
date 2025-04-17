import 'package:flutter_test/flutter_test.dart';
import 'package:prf/types/prf_datetime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

void main() {
  const key = 'test_datetime';
  const sharedPreferencesOptions = SharedPreferencesOptions();

  group('PrfDateTime', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('saves and retrieves a DateTime correctly', () async {
      final (preferences, _) = getPreferences();
      final prfDateTime = PrfDateTime(key);

      final now = DateTime.now();
      await prfDateTime.setValue(preferences, now);

      final retrieved = await prfDateTime.getValue(preferences);
      expect(retrieved?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('returns null when nothing is set', () async {
      final (preferences, _) = getPreferences();
      final prfDateTime = PrfDateTime(key);

      final value = await prfDateTime.getValue(preferences);
      expect(value, isNull);
    });

    test(
      'returns defaultValue if nothing is set and default is provided',
      () async {
        final (preferences, store) = getPreferences();
        final defaultDate = DateTime(2000);
        final withDefault = PrfDateTime(key, defaultValue: defaultDate);
        final result = await withDefault.getValue(preferences);

        expect(result, defaultDate);

        final keys = await store.getKeys(
          GetPreferencesParameters(filter: PreferencesFilters()),
          sharedPreferencesOptions,
        );
        expect(keys.contains(key), true);
      },
    );

    test('removes the value and returns null afterwards', () async {
      final (preferences, store) = getPreferences();
      final prfDateTime = PrfDateTime(key);

      final now = DateTime.now();
      await prfDateTime.setValue(preferences, now);
      await prfDateTime.removeValue(preferences);

      final value = await prfDateTime.getValue(preferences);
      expect(value, isNull);

      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains(key), false);
    });

    test('base64 encoding and decoding is valid', () async {
      final (preferences, store) = getPreferences();
      final prfDateTime = PrfDateTime(key);

      final date = DateTime(2024, 1, 1);
      await prfDateTime.setValue(preferences, date);

      final rawBase64 = await store.getString(key, sharedPreferencesOptions);
      expect(rawBase64, isNotNull);

      final decodedBytes = base64Decode(rawBase64!);
      final millis = ByteData.sublistView(decodedBytes).getInt64(0, Endian.big);
      expect(millis, date.millisecondsSinceEpoch);
    });

    test('handles corrupted base64 gracefully', () async {
      final (preferences, store) = getPreferences();
      final prfDateTime = PrfDateTime(key);

      await store.setString(key, 'not-valid-base64', sharedPreferencesOptions);
      final value = await prfDateTime.getValue(preferences);
      expect(value, isNull);
    });

    test('caches value after first retrieval', () async {
      final (preferences, store) = getPreferences();
      final prfDateTime = PrfDateTime(key);

      final now = DateTime(2030);
      await prfDateTime.setValue(preferences, now);

      final first = await prfDateTime.getValue(preferences);
      expect(first, isNotNull);

      // Simulate data being removed externally
      await store.clear(
        ClearPreferencesParameters(
          filter: PreferencesFilters(allowList: {key}),
        ),
        sharedPreferencesOptions,
      );

      final cached = await prfDateTime.getValue(preferences);
      // Still returns the cached value, not null
      expect(cached, first);
    });

    test('isValueNull returns true when key not set', () async {
      final (preferences, _) = getPreferences();
      final prfDateTime = PrfDateTime(key);

      final result = await prfDateTime.isValueNull(preferences);
      expect(result, true);
    });

    test('isValueNull returns false when value exists', () async {
      final (preferences, _) = getPreferences();
      final prfDateTime = PrfDateTime(key);

      final now = DateTime.now();
      await prfDateTime.setValue(preferences, now);

      final result = await prfDateTime.isValueNull(preferences);
      expect(result, false);
    });
  });
}
