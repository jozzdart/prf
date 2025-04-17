import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/core/prf_encoded.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

void main() {
  group('PrfEncoded<DateTime, String> (via base64)', () {
    const testKey = 'test_date';
    const sharedPreferencesOptions = SharedPreferencesOptions();

    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    PrfEncoded<DateTime, String> buildDatePref({DateTime? defaultValue}) {
      return PrfEncoded<DateTime, String>(
        testKey,
        from: (base64) {
          if (base64 == null) return null;
          try {
            final bytes = base64Decode(base64);
            final millis = ByteData.sublistView(bytes).getInt64(0, Endian.big);
            return DateTime.fromMillisecondsSinceEpoch(millis);
          } catch (_) {
            return null;
          }
        },
        to: (dateTime) {
          final buffer = ByteData(8);
          buffer.setInt64(0, dateTime.millisecondsSinceEpoch, Endian.big);
          return base64Encode(buffer.buffer.asUint8List());
        },
        getter: (prefs, key) async => prefs.getString(key),
        setter: (prefs, key, value) async => prefs.setString(key, value),
        defaultValue: defaultValue,
      );
    }

    test('writes and reads a DateTime correctly', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store,
      ) = getPreferences();

      final now = DateTime.now();
      final pref = buildDatePref();

      await pref.setValue(preferences, now);
      final result = await pref.getValue(preferences);

      expect(result, isNotNull);
      expect(
        result!.millisecondsSinceEpoch,
        equals(now.millisecondsSinceEpoch),
      );
    });

    test('returns default value if key is missing', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store,
      ) = getPreferences();

      final defaultDate = DateTime(2020, 1, 1);
      final pref = buildDatePref(defaultValue: defaultDate);

      final result = await pref.getValue(preferences);
      expect(result, equals(defaultDate));
    });

    test('writes default value to prefs if key is missing', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store,
      ) = getPreferences();

      final defaultDate = DateTime(2021, 6, 1);
      final pref = buildDatePref(defaultValue: defaultDate);

      final result = await pref.getValue(preferences);
      final stored = await store.getString(testKey, sharedPreferencesOptions);

      expect(result, equals(defaultDate));
      expect(stored, isNotNull);
    });

    test('returns null if stored base64 is corrupted', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store,
      ) = getPreferences();

      await store.setString(
          testKey, 'not-a-valid-base64', sharedPreferencesOptions);
      final pref = buildDatePref();

      final result = await pref.getValue(preferences);
      expect(result, isNull);
    });

    test('removes value and clears cache', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store,
      ) = getPreferences();

      final date = DateTime(2000, 1, 1);
      final pref = buildDatePref();

      await pref.setValue(preferences, date);
      await pref.removeValue(preferences);

      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains(testKey), isFalse);
      expect(await pref.getValue(preferences), isNull);
    });

    test('caches value after first read', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store,
      ) = getPreferences();

      final date = DateTime(2030, 5, 1);
      final pref = buildDatePref();

      await pref.setValue(preferences, date);

      final result1 = await pref.getValue(preferences);
      await store.clear(
        ClearPreferencesParameters(
          filter: PreferencesFilters(allowList: {testKey}),
        ),
        sharedPreferencesOptions,
      );

      final result2 = await pref.getValue(preferences); // should return cached

      expect(result1, equals(date));
      expect(result2, equals(date)); // still returned from cache
    });

    test('isValueNull returns true only if value is null', () async {
      final (
        SharedPreferencesAsync preferences,
        FakeSharedPreferencesAsync store,
      ) = getPreferences();

      final pref = buildDatePref();

      expect(await pref.isValueNull(preferences), isTrue);

      await pref.setValue(preferences, DateTime.now());
      expect(await pref.isValueNull(preferences), isFalse);
    });
  });
}
