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

  group('BytesListAdapter', () {
    const adapter = BytesListAdapter();

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_bytes_list');
      expect(result, isNull);
    });

    test('getter returns empty list when stored empty', () async {
      final (preferences, store) = getPreferences();
      await store.setStringList(
        'test_bytes_list',
        [],
        sharedPreferencesOptions,
      );

      final result = await adapter.getter(preferences, 'test_bytes_list');
      expect(result, isEmpty);
    });

    test('getter returns correct list when exists', () async {
      final (preferences, store) = getPreferences();
      final list = [
        Uint8List.fromList([1, 2, 3]),
        Uint8List.fromList([4, 5, 6]),
      ];
      final encoded = adapter.encode(list);

      await store.setStringList(
          'test_bytes_list', encoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_bytes_list');
      expect(result, equals(list));
    });

    test('getter returns null if one entry is corrupted base64', () async {
      final (preferences, store) = getPreferences();
      final encoded = [
        base64Encode(Uint8List.fromList([1, 2, 3])),
        '!!invalid_base64!!'
      ];

      await store.setStringList(
          'test_bytes_list', encoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_bytes_list');
      expect(result, isNull);
    });

    test('setter stores value correctly', () async {
      final (preferences, store) = getPreferences();
      final list = [
        Uint8List.fromList([9, 8, 7]),
        Uint8List.fromList([6, 5, 4]),
      ];

      await adapter.setter(preferences, 'test_bytes_list', list);

      final stored = await store.getStringList(
          'test_bytes_list', sharedPreferencesOptions);
      final decoded = adapter.decode(stored);

      expect(decoded, equals(list));
    });

    test('complete round trip: setter followed by getter', () async {
      final (preferences, _) = getPreferences();
      final list = [
        Uint8List.fromList([255, 0, 255]),
        Uint8List.fromList([10, 20, 30, 40]),
      ];

      await adapter.setter(preferences, 'test_bytes_list', list);
      final result = await adapter.getter(preferences, 'test_bytes_list');

      expect(result, equals(list));
    });

    test('encode produces valid base64 strings for each item', () {
      final list = [
        Uint8List.fromList([1, 2, 3]),
        Uint8List.fromList([4, 5, 6]),
      ];
      final encoded = adapter.encode(list);

      for (final base64 in encoded) {
        expect(() => base64Decode(base64), returnsNormally);
      }
    });

    test('decode returns exact Uint8List values', () {
      final original = [
        Uint8List.fromList([99, 100, 101, 102]),
        Uint8List.fromList([200, 201, 202]),
      ];
      final encoded = adapter.encode(original);
      final decoded = adapter.decode(encoded);

      expect(decoded, equals(original));
    });

    test('handles very large binary items', () async {
      final (preferences, _) = getPreferences();
      final big =
          Uint8List.fromList(List.generate(100000, (i) => i % 256)); // 100KB

      final list = [big, big];
      await adapter.setter(preferences, 'test_bytes_list', list);
      final result = await adapter.getter(preferences, 'test_bytes_list');

      expect(result, equals(list));
    });

    test('handles empty Uint8List values', () async {
      final (preferences, _) = getPreferences();
      final list = [Uint8List(0), Uint8List(0)];

      await adapter.setter(preferences, 'test_bytes_list', list);
      final result = await adapter.getter(preferences, 'test_bytes_list');

      expect(result, equals(list));
    });

    test('returns null if only one of many is corrupted', () async {
      final (preferences, store) = getPreferences();
      final encoded = [
        base64Encode(Uint8List.fromList([1, 2, 3])),
        base64Encode(Uint8List.fromList([4, 5, 6])),
        'not_base64==',
        base64Encode(Uint8List.fromList([7, 8, 9])),
      ];

      await store.setStringList(
          'test_bytes_list', encoded, sharedPreferencesOptions);
      final result = await adapter.getter(preferences, 'test_bytes_list');

      expect(result, isNull);
    });

    test('encode and decode of empty list is empty', () {
      final encoded = adapter.encode([]);
      final decoded = adapter.decode(encoded);
      expect(decoded, isEmpty);
    });

    test('handles mixed-length Uint8Lists', () async {
      final (preferences, _) = getPreferences();
      final list = [
        Uint8List.fromList([1]),
        Uint8List.fromList([2, 3]),
        Uint8List.fromList([4, 5, 6]),
        Uint8List.fromList([]),
      ];

      await adapter.setter(preferences, 'test_bytes_list', list);
      final result = await adapter.getter(preferences, 'test_bytes_list');

      expect(result, equals(list));
    });

    test('Uint8List deep equality works as expected SANITY CHECKGKKGK', () {
      final a = Uint8List.fromList([1, 2, 3]);
      final b = Uint8List.fromList([1, 2, 3]);
      expect(a, equals(b)); // sanity test
    });
  });
}
