import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import '../../utils/fake_prefs.dart';

void main() {
  const sharedPreferencesOptions = SharedPreferencesOptions();

  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final SharedPreferencesAsync preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  group('DoubleListAdapter', () {
    const adapter = DoubleListAdapter();

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_double_list');
      expect(result, isNull);
    });

    test('getter returns empty list when stored empty', () async {
      final (preferences, store) = getPreferences();
      final emptyEncoded = adapter.encode([]);
      await store.setString(
          'test_double_list', emptyEncoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_double_list');
      expect(result, isEmpty);
    });

    test('getter returns correct list when exists', () async {
      final (preferences, store) = getPreferences();
      final testList = [1.1, 2.2, 3.3];
      final encoded = adapter.encode(testList);
      await store.setString(
          'test_double_list', encoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_double_list');
      expect(result, testList);
    });

    test('getter returns null if corrupted base64', () async {
      final (preferences, store) = getPreferences();
      await store.setString(
          'test_double_list', 'invalid_base64', sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_double_list');
      expect(result, isNull);
    });

    test('getter returns null if bytes not divisible by 8', () async {
      final (preferences, store) = getPreferences();

      // Create corrupted bytes that are not a multiple of 8
      final corruptedBytes = Uint8List.fromList([1, 2, 3]); // 3 bytes only
      final corruptedBase64 =
          base64Encode(corruptedBytes); // just raw base64 encoding

      await store.setString(
          'test_double_list', corruptedBase64, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_double_list');
      expect(result, isNull);
    });

    test('setter stores value correctly', () async {
      final (preferences, store) = getPreferences();
      final testList = [5.5, 6.6, 7.7];

      await adapter.setter(preferences, 'test_double_list', testList);

      final storedString =
          await store.getString('test_double_list', sharedPreferencesOptions);
      final decoded = adapter.decode(storedString);

      expect(decoded, testList);
    });

    test('complete round trip: setter followed by getter', () async {
      final (preferences, _) = getPreferences();
      final testList = [9.9, 8.8, 7.7];

      await adapter.setter(preferences, 'test_double_list', testList);
      final result = await adapter.getter(preferences, 'test_double_list');

      expect(result, testList);
    });

    test('encode produces valid base64 string', () {
      final list = [10.1, 20.2, 30.3];
      final encoded = adapter.encode(list);

      expect(() => base64Decode(encoded), returnsNormally);
    });

    test('decode returns exact doubles', () {
      final list = [0.123456789, -98765.4321];
      final encoded = adapter.encode(list);
      final decoded = adapter.decode(encoded);

      expect(decoded, closeToList(list, precision: 1e-9));
    });
  });
}

/// Helper to compare two lists of doubles with precision tolerance
Matcher closeToList(List<double> expected, {double precision = 1e-9}) {
  return predicate<List<double>>((actual) {
    if (actual.length != expected.length) return false;
    for (var i = 0; i < actual.length; i++) {
      if ((actual[i] - expected[i]).abs() > precision) {
        return false;
      }
    }
    return true;
  }, 'List close to $expected with precision $precision');
}
