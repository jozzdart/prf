import 'dart:typed_data';
import 'dart:convert';
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

  group('BytesAdapter', () {
    const adapter = BytesAdapter();

    test('decode returns null for null input', () {
      final result = adapter.decode(null);
      expect(result, isNull);
    });

    test('decode returns null for invalid base64', () {
      final result = adapter.decode('not-a-valid-base64');
      expect(result, isNull);
    });

    test('decode returns correct Uint8List for valid base64', () {
      final original = Uint8List.fromList([1, 2, 3, 4, 5]);
      final base64String = base64Encode(original);

      final result = adapter.decode(base64String);
      expect(result, original);
    });

    test('encode returns correct base64 string', () {
      final original = Uint8List.fromList([10, 20, 30, 40, 50]);
      final expectedBase64 = base64Encode(original);

      final result = adapter.encode(original);
      expect(result, expectedBase64);
    });

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_bytes');
      expect(result, isNull);
    });

    test('getter returns decoded Uint8List when value exists', () async {
      final (preferences, store) = getPreferences();
      final data = Uint8List.fromList([5, 10, 15, 20, 25]);
      final encoded = base64Encode(data);
      await store.setString('test_bytes', encoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_bytes');
      expect(result, data);
    });

    test('getter returns null when stored value is corrupted', () async {
      final (preferences, store) = getPreferences();
      await store.setString(
          'test_bytes', 'invalid-base64', sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_bytes');
      expect(result, isNull);
    });

    test('setter correctly stores base64 string', () async {
      final (preferences, store) = getPreferences();
      final data = Uint8List.fromList([100, 110, 120, 130, 140]);

      await adapter.setter(preferences, 'test_bytes', data);

      final stored =
          await store.getString('test_bytes', sharedPreferencesOptions);
      expect(stored, base64Encode(data));
    });

    test('complete round trip: setter followed by getter', () async {
      final (preferences, _) = getPreferences();
      final data = Uint8List.fromList([200, 210, 220, 230, 240]);

      await adapter.setter(preferences, 'test_bytes', data);
      final result = await adapter.getter(preferences, 'test_bytes');

      expect(result, data);
    });

    test('empty Uint8List stores and retrieves correctly', () async {
      final (preferences, _) = getPreferences();
      final emptyData = Uint8List(0);

      await adapter.setter(preferences, 'test_empty', emptyData);
      final result = await adapter.getter(preferences, 'test_empty');

      expect(result, emptyData);
    });
  });
}
