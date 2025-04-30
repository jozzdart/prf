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

  group('DurationListAdapter64', () {
    const adapter = DurationListAdapter64();

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_duration_list');
      expect(result, isNull);
    });

    test('getter returns empty list when stored empty', () async {
      final (preferences, store) = getPreferences();
      final emptyEncoded = adapter.encode([]);
      await store.setString(
          'test_duration_list', emptyEncoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_duration_list');
      expect(result, isEmpty);
    });

    test('getter returns correct list when exists', () async {
      final (preferences, store) = getPreferences();
      final testList = [
        Duration(microseconds: 100),
        Duration(milliseconds: 200),
        Duration(seconds: 3),
        Duration(days: 4)
      ];
      final encoded = adapter.encode(testList);
      await store.setString(
          'test_duration_list', encoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_duration_list');
      expect(result, testList);
    });

    test('getter returns null if corrupted base64', () async {
      final (preferences, store) = getPreferences();
      await store.setString(
          'test_duration_list', 'invalid_base64', sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_duration_list');
      expect(result, isNull);
    });

    test('getter returns null if bytes not divisible by 8', () async {
      final (preferences, store) = getPreferences();
      final corruptedBytes = Uint8List.fromList([1, 2, 3, 4, 5]); // not % 8
      final corruptedBase64 = base64Encode(corruptedBytes);
      await store.setString(
          'test_duration_list', corruptedBase64, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_duration_list');
      expect(result, isNull);
    });

    test('setter stores value correctly', () async {
      final (preferences, store) = getPreferences();
      final testList = [
        Duration(hours: 1),
        Duration(minutes: 42),
        Duration(milliseconds: 987),
      ];

      await adapter.setter(preferences, 'test_duration_list', testList);
      final storedString =
          await store.getString('test_duration_list', sharedPreferencesOptions);
      final decoded = adapter.decode(storedString);

      expect(decoded, testList);
    });

    test('complete round trip: setter followed by getter', () async {
      final (preferences, _) = getPreferences();
      final testList = [
        Duration(microseconds: 123456789),
        Duration(days: 9999),
        Duration(hours: 8760)
      ];

      await adapter.setter(preferences, 'test_duration_list', testList);
      final result = await adapter.getter(preferences, 'test_duration_list');

      expect(result, testList);
    });

    test('encode produces valid base64 string', () {
      final list = [
        Duration(minutes: 1),
        Duration(seconds: 15),
        Duration(milliseconds: 300)
      ];
      final encoded = adapter.encode(list);

      expect(() => base64Decode(encoded), returnsNormally);
    });

    test('decode returns exact durations', () {
      final list = [
        Duration(microseconds: 123),
        Duration(milliseconds: 456),
        Duration(seconds: 789),
        Duration(days: 1),
      ];
      final encoded = adapter.encode(list);
      final decoded = adapter.decode(encoded);

      expect(decoded, list);
    });

    test('handles large list of durations', () {
      final list = List.generate(10000, (i) => Duration(microseconds: i * 100));
      final encoded = adapter.encode(list);
      final decoded = adapter.decode(encoded);
      expect(decoded, list);
    });

    test('handles negative durations correctly', () {
      final list = [
        Duration(seconds: -5),
        Duration(milliseconds: -123),
        Duration(microseconds: -7890),
      ];
      final encoded = adapter.encode(list);
      final decoded = adapter.decode(encoded);
      expect(decoded, list);
    });

    test('decode returns null when input is null', () {
      final result = adapter.decode(null);
      expect(result, isNull);
    });

    test('decode fails if bytes are valid base64 but nonsensical', () {
      final garbageBytes = List.filled(16, 0xFF); // valid length, but nonsense
      final encoded = base64Encode(garbageBytes);
      final decoded = adapter.decode(encoded);
      // this will succeed because we don’t validate semantics, just length
      expect(decoded!.length, 2);
    });
  });
}
