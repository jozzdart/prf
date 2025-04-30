import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../utils/fake_prefs.dart';

/// A simple test adapter for List&lt;int> using 4-byte int encoding.
class TestInt32ListAdapter extends BinaryListAdapter<int> {
  const TestInt32ListAdapter() : super(4);

  @override
  int read(ByteData data, int offset) => data.getInt32(offset, Endian.big);

  @override
  void write(ByteData data, int offset, int value) =>
      data.setInt32(offset, value, Endian.big);
}

void main() {
  const adapter = TestInt32ListAdapter();
  const sharedPreferencesOptions = SharedPreferencesOptions();

  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  group('BinaryListAdapter<int>', () {
    test('getter returns null when no value is stored', () async {
      final (prefs, _) = getPreferences();
      final result = await adapter.getter(prefs, 'missing_key');
      expect(result, isNull);
    });

    test('setter and getter round trip with empty list', () async {
      final (prefs, _) = getPreferences();
      final input = <int>[];

      await adapter.setter(prefs, 'empty', input);
      final result = await adapter.getter(prefs, 'empty');

      expect(result, equals(input));
    });

    test('setter and getter round trip with small values', () async {
      final (prefs, _) = getPreferences();
      final input = [1, 2, 3, 4, 5];

      await adapter.setter(prefs, 'small_values', input);
      final result = await adapter.getter(prefs, 'small_values');

      expect(result, equals(input));
    });

    test('setter and getter round trip with large and negative integers',
        () async {
      final (prefs, _) = getPreferences();
      final input = [-2147483648, -1, 0, 1, 2147483647];

      await adapter.setter(prefs, 'signed_values', input);
      final result = await adapter.getter(prefs, 'signed_values');

      expect(result, equals(input));
    });

    test('getter returns null if stored base64 is malformed', () async {
      final (prefs, store) = getPreferences();

      await prefs.setString('corrupted', '!!!invalid_base64!!!');
      final result = await adapter.getter(prefs, 'corrupted');

      expect(result, isNull);
    });

    test('getter returns null if stored byte length is invalid', () async {
      final (prefs, store) = getPreferences();

      // 3 bytes is not divisible by 4 (int32)
      final corrupted = base64Encode(Uint8List.fromList([1, 2, 3]));
      await prefs.setString('bad_length', corrupted);

      final result = await adapter.getter(prefs, 'bad_length');
      expect(result, isNull);
    });

    test('round trip with long list', () async {
      final (prefs, _) = getPreferences();
      final input = List.generate(1000, (i) => i * 7 - 50); // some large list

      await adapter.setter(prefs, 'long_list', input);
      final result = await adapter.getter(prefs, 'long_list');

      expect(result, equals(input));
    });

    test('stored base64 is correct for known input', () async {
      final (prefs, store) = getPreferences();
      final input = [0x11223344];

      await adapter.setter(prefs, 'known_value', input);
      final stored =
          await store.getString('known_value', sharedPreferencesOptions);

      // 0x11223344 → [17, 34, 51, 68] → base64: ESIzRA==
      expect(stored, equals('ESIzRA=='));

      final result = await adapter.getter(prefs, 'known_value');
      expect(result, equals(input));
    });

    test('setter overwrites previous value', () async {
      final (prefs, _) = getPreferences();
      await adapter.setter(prefs, 'key', [1, 2, 3]);
      await adapter.setter(prefs, 'key', [9, 8]);
      final result = await adapter.getter(prefs, 'key');
      expect(result, equals([9, 8]));
    });

    test('decode null returns null', () {
      final result = adapter.decode(null);
      expect(result, isNull);
    });

    test('encode never returns null', () {
      final result = adapter.encode([42]);
      expect(result, isNotNull);
    });

    test('valid base64 but invalid byte length returns null', () async {
      final (prefs, _) = getPreferences();

      // 5 bytes: valid base64, invalid structure
      final b64 = base64Encode(Uint8List.fromList([1, 2, 3, 4, 5]));
      await prefs.setString('off_size', b64);
      final result = await adapter.getter(prefs, 'off_size');
      expect(result, isNull);
    });

    test('edge overflow values round trip', () async {
      final (prefs, _) = getPreferences();
      final input = [2147483647, -2147483648]; // int32 max, min
      await adapter.setter(prefs, 'edge', input);
      final result = await adapter.getter(prefs, 'edge');
      expect(result, equals(input));
    });

    test('round trip with alternating sign pattern', () async {
      final (prefs, _) = getPreferences();
      final input = List.generate(50, (i) => i.isEven ? i : -i);
      await adapter.setter(prefs, 'alt_sign', input);
      final result = await adapter.getter(prefs, 'alt_sign');
      expect(result, equals(input));
    });
  });
}
