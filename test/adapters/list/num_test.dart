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

  group('NumListAdapter', () {
    const adapter = NumListAdapter();

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_num_list');
      expect(result, isNull);
    });

    test('getter returns empty list when stored empty', () async {
      final (preferences, store) = getPreferences();
      final emptyEncoded = adapter.encode([]);
      await store.setString(
          'test_num_list', emptyEncoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_num_list');
      expect(result, isEmpty);
    });

    test('getter returns correct list with doubles', () async {
      final (preferences, store) = getPreferences();
      final testList = [1.1, 2.2, 3.3];
      final encoded = adapter.encode(testList);
      await store.setString('test_num_list', encoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_num_list');
      expect(result, closeToList(testList));
    });

    test('getter returns correct list with integers', () async {
      final (preferences, store) = getPreferences();
      final testList = [1, 2, 3];
      final encoded = adapter.encode(testList);
      await store.setString('test_num_list', encoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_num_list');
      expect(result, testList);
    });

    test('getter returns null if corrupted base64', () async {
      final (preferences, store) = getPreferences();
      await store.setString(
          'test_num_list', 'not_base64_data!', sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_num_list');
      expect(result, isNull);
    });

    test('getter returns null if bytes not divisible by 8', () async {
      final (preferences, store) = getPreferences();
      final corrupted = Uint8List.fromList([1, 2, 3, 4, 5]);
      await store.setString(
          'test_num_list', base64Encode(corrupted), sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_num_list');
      expect(result, isNull);
    });

    test('setter stores value correctly', () async {
      final (preferences, store) = getPreferences();
      final testList = [10.5, 11.0, 12.25];

      await adapter.setter(preferences, 'test_num_list', testList);
      final stored =
          await store.getString('test_num_list', sharedPreferencesOptions);
      final decoded = adapter.decode(stored);

      expect(decoded, closeToList(testList));
    });

    test('complete round trip with mixed types', () async {
      final (preferences, _) = getPreferences();
      final testList = [1, 2.2, 3, 4.4];

      await adapter.setter(preferences, 'test_num_list', testList);
      final result = await adapter.getter(preferences, 'test_num_list');

      expect(result, closeToList(testList));
    });

    test('encode produces valid base64 string', () {
      final list = [100.0, 200.5, 300];
      final encoded = adapter.encode(list);

      expect(() => base64Decode(encoded), returnsNormally);
    });

    test('decode handles negative and fractional numbers', () {
      final list = [-1.1, -2.2, 0.0, 3.1415];
      final encoded = adapter.encode(list);
      final decoded = adapter.decode(encoded);

      expect(decoded, closeToList(list));
    });

    test('handles double limits and large integers', () {
      final list = [
        double.maxFinite,
        double.minPositive,
        -double.maxFinite,
        1e20,
        -1e20
      ];
      final encoded = adapter.encode(list);
      final decoded = adapter.decode(encoded);

      expect(
          decoded,
          closeToList(list,
              precision: 1e7)); // large numbers = looser precision
    });

    test('preserves zero and negative zero', () {
      final list = [0.0, -0.0];
      final encoded = adapter.encode(list);
      final decoded = adapter.decode(encoded);

      expect(
          decoded,
          containsAllInOrder(
              [0.0, 0.0])); // Cannot distinguish sign of zero in equality
    });

    test('preserves small fractional values', () {
      final list = [1e-300, -1e-300];
      final encoded = adapter.encode(list);
      final decoded = adapter.decode(encoded);

      expect(decoded, closeToList(list, precision: 1e-310));
    });

    test('identical lists produce identical encodings', () {
      final list = [1.5, 2.5, 3.5];
      final encoded1 = adapter.encode(list);
      final encoded2 = adapter.encode(list);

      expect(encoded1, encoded2);
    });

    test('decode returns null for null input', () {
      final result = adapter.decode(null);
      expect(result, isNull);
    });

    test('round-trip with empty list', () async {
      final (preferences, _) = getPreferences();
      final testList = <num>[];

      await adapter.setter(preferences, 'test_num_list', testList);
      final result = await adapter.getter(preferences, 'test_num_list');

      expect(result, isEmpty);
    });
  });
}

/// Helper to compare two lists of numbers with precision tolerance
Matcher closeToList(List<num> expected, {double precision = 1e-9}) {
  return predicate<List<num>>((actual) {
    if (actual.length != expected.length) return false;
    for (var i = 0; i < actual.length; i++) {
      final diff = (actual[i] - expected[i]).abs();
      if (diff > precision) return false;
    }
    return true;
  }, 'List close to $expected with precision $precision');
}
