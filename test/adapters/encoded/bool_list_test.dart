import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:prf/adapters/encoded/bool_list.dart';
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

  group('BoolListAdapter', () {
    const adapter = BoolListAdapter();

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_bool_list');
      expect(result, isNull);
    });

    test('setter and getter round trip small list', () async {
      final (preferences, store) = getPreferences();
      final value = [true, false, true, false, false, true];

      await adapter.setter(preferences, 'test_bool_list', value);

      final stored =
          await store.getString('test_bool_list', sharedPreferencesOptions);
      expect(stored, isNotNull);

      final result = await adapter.getter(preferences, 'test_bool_list');
      expect(result, value);
    });

    test('setter and getter round trip empty list', () async {
      final (preferences, _) = getPreferences();
      final value = <bool>[];

      await adapter.setter(preferences, 'test_empty_list', value);
      final result = await adapter.getter(preferences, 'test_empty_list');

      expect(result, value);
    });

    test('round trip with list size not multiple of 8', () async {
      final (preferences, _) = getPreferences();
      final value = [true, false, true]; // 3 elements only

      await adapter.setter(preferences, 'test_short_list', value);
      final result = await adapter.getter(preferences, 'test_short_list');

      expect(result, value);
    });

    test('round trip with exactly 8 booleans', () async {
      final (preferences, _) = getPreferences();
      final value = [true, false, true, false, true, false, true, false];

      await adapter.setter(preferences, 'test_8_list', value);
      final result = await adapter.getter(preferences, 'test_8_list');

      expect(result, value);
    });

    test('round trip with more than 8 booleans', () async {
      final (preferences, _) = getPreferences();
      final value = List.generate(13, (i) => i.isEven); // 13 elements

      await adapter.setter(preferences, 'test_13_list', value);
      final result = await adapter.getter(preferences, 'test_13_list');

      expect(result, value);
    });

    test('decode corrupted base64 returns null safely', () async {
      final (preferences, store) = getPreferences();

      await store.setString(
          'corrupt_list', '!!!INVALID_BASE64!!!', sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'corrupt_list');
      expect(result, isNull);
    });

    test('decoding of a manually stored encoded list', () async {
      final (preferences, store) = getPreferences();

      // Original list: [true, false, true, true, false, false, true, false]
      final list = [true, false, true, true, false, false, true, false];

      final length = list.length;
      final byteLength = (length + 7) ~/ 8;
      final bytes = Uint8List(4 + byteLength);

      final byteData = ByteData.sublistView(bytes);
      byteData.setUint32(0, length, Endian.big); // first 4 bytes = length

      // Manually encode bits
      if (list[0]) bytes[4] |= 1 << 0;
      if (list[1]) bytes[4] |= 1 << 1;
      if (list[2]) bytes[4] |= 1 << 2;
      if (list[3]) bytes[4] |= 1 << 3;
      if (list[4]) bytes[4] |= 1 << 4;
      if (list[5]) bytes[4] |= 1 << 5;
      if (list[6]) bytes[4] |= 1 << 6;
      if (list[7]) bytes[4] |= 1 << 7;

      final encoded = base64Encode(bytes);

      await store.setString('manual_list', encoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'manual_list');
      expect(result, list);
    });

    test('full byte (8 booleans) encoding and decoding', () async {
      final (preferences, store) = getPreferences();

      final original = List.generate(8, (index) => index.isOdd);

      await adapter.setter(preferences, 'full_byte', original);
      final stored =
          await store.getString('full_byte', sharedPreferencesOptions);
      expect(stored, isNotNull);

      final decoded = await adapter.getter(preferences, 'full_byte');
      expect(decoded, original);
    });

    test('multiple bytes encoding and decoding', () async {
      final (preferences, _) = getPreferences();

      final original = List.generate(20, (index) => index % 3 == 0);

      await adapter.setter(preferences, 'multi_byte', original);
      final decoded = await adapter.getter(preferences, 'multi_byte');

      expect(decoded, original);
    });
  });
}
