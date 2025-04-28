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

  group('DateTimeAdapter', () {
    const adapter = DateTimeAdapter();

    test('decode returns null for null input', () {
      expect(adapter.decode(null), isNull);
    });

    test('decode returns null for invalid base64 string', () {
      expect(adapter.decode('invalid_base64'), isNull);
    });

    test('decode returns null for too short byte array', () {
      // Encodes only 4 bytes instead of 8
      final shortEncoded = base64Encode([0, 1, 2, 3]);
      expect(adapter.decode(shortEncoded), isNull);
    });

    test('encode and decode are inverses', () {
      final now = DateTime.now();
      final encoded = adapter.encode(now);
      final decoded = adapter.decode(encoded);
      expect(decoded, now);
    });

    test('encode produces a valid base64 string', () {
      final now = DateTime.now();
      final encoded = adapter.encode(now);
      expect(() => base64Decode(encoded), returnsNormally);
    });

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_datetime');
      expect(result, isNull);
    });

    test('setter stores and getter retrieves correct value', () async {
      final (preferences, store) = getPreferences();
      final now = DateTime.now();

      await adapter.setter(preferences, 'test_datetime', now);
      final storedBase64 =
          await store.getString('test_datetime', sharedPreferencesOptions);
      expect(storedBase64, isNotNull);

      final retrieved = await adapter.getter(preferences, 'test_datetime');
      expect(retrieved, now);
    });

    test('setter overwrites existing value', () async {
      final (preferences, store) = getPreferences();
      final initial = DateTime(2020, 1, 1);
      final updated = DateTime(2025, 12, 31);

      await adapter.setter(preferences, 'test_datetime', initial);
      await adapter.setter(preferences, 'test_datetime', updated);

      final retrieved = await adapter.getter(preferences, 'test_datetime');
      expect(retrieved, updated);
    });

    test('complete round trip: setter followed by getter', () async {
      final (preferences, _) = getPreferences();
      final now = DateTime.now();

      await adapter.setter(preferences, 'test_datetime', now);
      final result = await adapter.getter(preferences, 'test_datetime');

      expect(result, now);
    });
  });
}
