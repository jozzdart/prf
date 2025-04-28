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
    final store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  group('IntListAdapter', () {
    const adapter = IntListAdapter();

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_int_list');
      expect(result, isNull);
    });

    test('setter stores value correctly', () async {
      final (preferences, store) = getPreferences();
      final list = [1, 2, 3, 4, 5];

      await adapter.setter(preferences, 'test_int_list', list);

      final stored =
          await store.getString('test_int_list', sharedPreferencesOptions);
      expect(stored, isNotNull);
      expect(stored, isA<String>());

      // Check that decode brings back the original list
      final decoded = adapter.decode(stored);
      expect(decoded, equals(list));
    });

    test('getter returns correct list when value exists', () async {
      final (preferences, store) = getPreferences();
      final list = [10, 20, 30];

      final encoded = adapter.encode(list);
      await store.setString('test_int_list', encoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_int_list');
      expect(result, equals(list));
    });

    test('decode returns null for invalid base64', () {
      final invalidBase64 = '!!!not_a_valid_base64!!!';
      final result = adapter.decode(invalidBase64);
      expect(result, isNull);
    });

    test('decode returns null for invalid byte length', () {
      final invalidBytes =
          Uint8List.fromList([1, 2, 3]); // Only 3 bytes, not divisible by 4
      final encoded = base64Encode(invalidBytes);
      final result = adapter.decode(encoded);
      expect(result, isNull);
    });

    test('encode and decode round-trip preserves data', () {
      final listsToTest = [
        <int>[],
        [0],
        [1, -1, 2, -2, 123456789, -987654321],
        List.generate(100, (i) => i * 12345),
      ];

      for (final list in listsToTest) {
        final encoded = adapter.encode(list);
        final decoded = adapter.decode(encoded);
        expect(decoded, equals(list));
      }
    });

    test('complete round-trip: setter then getter', () async {
      final (preferences, _) = getPreferences();
      final list = [100, 200, 300];

      await adapter.setter(preferences, 'test_int_list', list);
      final retrieved = await adapter.getter(preferences, 'test_int_list');

      expect(retrieved, equals(list));
    });
  });
}
