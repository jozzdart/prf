import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:prf/special_types/prf_big_int.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

void main() {
  const key = 'test_big_int';
  const sharedPreferencesOptions = SharedPreferencesOptions();

  group('PrfBigInt', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('returns null if not set and no default provided', () async {
      final (preferences, _) = getPreferences();
      final bigIntPref = PrfBigInt(key);
      final value = await bigIntPref.getValue(preferences);
      expect(value, isNull);
    });

    test('returns default if not set and default provided', () async {
      final (preferences, _) = getPreferences();
      final defaultValue = BigInt.parse('12345678901234567890');
      final bigIntPref = PrfBigInt(key, defaultValue: defaultValue);
      final value = await bigIntPref.getValue(preferences);
      expect(value, defaultValue);
    });

    test('sets and gets value correctly', () async {
      final (preferences, _) = getPreferences();
      final bigIntPref = PrfBigInt(key);
      final testValue =
          BigInt.parse('9876543210987654321098765432109876543210');
      await bigIntPref.setValue(preferences, testValue);
      final value = await bigIntPref.getValue(preferences);
      expect(value, testValue);
    });

    test('handles zero correctly', () async {
      final (preferences, _) = getPreferences();
      final bigIntPref = PrfBigInt(key);
      await bigIntPref.setValue(preferences, BigInt.zero);
      final value = await bigIntPref.getValue(preferences);
      expect(value, BigInt.zero);
    });

    test('handles negative values correctly', () async {
      final (preferences, _) = getPreferences();
      final bigIntPref = PrfBigInt(key);
      final testValue = BigInt.parse('-123456789012345678901234567890');
      await bigIntPref.setValue(preferences, testValue);
      final value = await bigIntPref.getValue(preferences);
      expect(value, testValue);
    });

    test('updates existing value', () async {
      final (preferences, _) = getPreferences();
      final bigIntPref = PrfBigInt(key);
      final initialValue = BigInt.parse('11111111111111111111');
      final updatedValue = BigInt.parse('22222222222222222222');

      await bigIntPref.setValue(preferences, initialValue);
      var value = await bigIntPref.getValue(preferences);
      expect(value, initialValue);

      await bigIntPref.setValue(preferences, updatedValue);
      value = await bigIntPref.getValue(preferences);
      expect(value, updatedValue);
    });

    test('removes value properly', () async {
      final (preferences, store) = getPreferences();
      final bigIntPref = PrfBigInt(key);
      await bigIntPref.setValue(preferences, BigInt.from(42));

      await bigIntPref.removeValue(preferences);
      final value = await bigIntPref.getValue(preferences);
      expect(value, isNull);

      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains(key), false);
    });

    test('isValueNull returns true when no value', () async {
      final (preferences, _) = getPreferences();
      final bigIntPref = PrfBigInt(key);
      final isNull = await bigIntPref.isValueNull(preferences);
      expect(isNull, true);
    });

    test('isValueNull returns false when value is set', () async {
      final (preferences, _) = getPreferences();
      final bigIntPref = PrfBigInt(key);
      await bigIntPref.setValue(preferences, BigInt.from(1));
      final isNull = await bigIntPref.isValueNull(preferences);
      expect(isNull, false);
    });

    test('caches value after first access', () async {
      final (preferences, store) = getPreferences();
      final bigIntPref = PrfBigInt(key);

      // Set the value directly in the store
      final testValue = BigInt.parse('987654321');

      // Create the binary representation
      final isNegative = testValue.isNegative;
      final magnitude = testValue.abs();

      var tempMag = magnitude;
      var byteCount = 0;
      do {
        byteCount++;
        tempMag = tempMag >> 8;
      } while (tempMag > BigInt.zero);

      final bytes = Uint8List(byteCount + 1);
      bytes[0] = isNegative ? 1 : 0;

      var tempValue = magnitude;
      for (var i = byteCount; i > 0; i--) {
        bytes[i] = (tempValue & BigInt.from(0xFF)).toInt();
        tempValue = tempValue >> 8;
      }

      final base64Value = base64Encode(bytes);
      await store.setString(key, base64Value, sharedPreferencesOptions);

      // Get the value, which should cache it
      final value1 = await bigIntPref.getValue(preferences);
      expect(value1, testValue);

      // Modify directly, should not affect cached value
      final differentValue = BigInt.parse('123456789');

      // Create different binary representation
      final diffIsNegative = differentValue.isNegative;
      final diffMagnitude = differentValue.abs();

      tempMag = diffMagnitude;
      byteCount = 0;
      do {
        byteCount++;
        tempMag = tempMag >> 8;
      } while (tempMag > BigInt.zero);

      final diffBytes = Uint8List(byteCount + 1);
      diffBytes[0] = diffIsNegative ? 1 : 0;

      tempValue = diffMagnitude;
      for (var i = byteCount; i > 0; i--) {
        diffBytes[i] = (tempValue & BigInt.from(0xFF)).toInt();
        tempValue = tempValue >> 8;
      }

      final diffBase64 = base64Encode(diffBytes);
      await store.setString(key, diffBase64, sharedPreferencesOptions);

      // Get again, should return cached value
      final value2 = await bigIntPref.getValue(preferences);
      expect(value2, testValue); // Still the original value due to caching
    });

    test('default value is persisted after first access', () async {
      final (preferences, store) = getPreferences();
      final defaultValue = BigInt.parse('314159265358979323846');
      final bigIntPref = PrfBigInt(key, defaultValue: defaultValue);

      final first = await bigIntPref.getValue(preferences);
      expect(first, defaultValue);

      final raw = await store.getString(key, sharedPreferencesOptions);
      expect(raw, isNotNull);

      // Decode the stored value to verify it matches the default
      final bytes = base64Decode(raw!);
      final isNegative = bytes[0] == 1;
      var result = BigInt.zero;
      for (var i = 1; i < bytes.length; i++) {
        result = (result << 8) | BigInt.from(bytes[i]);
      }
      final decodedValue = isNegative ? -result : result;

      expect(decodedValue, defaultValue);
    });

    test('handles extremely large numbers', () async {
      final (preferences, _) = getPreferences();
      final bigIntPref = PrfBigInt(key);

      // A 1024-bit number
      final testValue = BigInt.parse(
          '17976931348623159077293051907890247336179769789423065727343008115'
          '77326758055009631327084773224075360211201138798713933576587897688'
          '14416622492847430639474124377767893424865485276302219601246094119'
          '45308295208500576883815068234246288147391311054082723716335051068'
          '4586298239947245938479716304835356329624224137216');

      await bigIntPref.setValue(preferences, testValue);
      final value = await bigIntPref.getValue(preferences);
      expect(value, testValue);
    });

    test('handles corrupted base64 data gracefully', () async {
      final (preferences, store) = getPreferences();
      final bigIntPref = PrfBigInt(key);

      await store.setString(
          key, '!!not-valid-base64@@', sharedPreferencesOptions);
      final result = await bigIntPref.getValue(preferences);
      expect(result, isNull);
    });
  });
}
