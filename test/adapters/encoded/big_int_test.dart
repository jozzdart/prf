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

  group('BigIntAdapter', () {
    const adapter = BigIntAdapter();

    test('decode returns null for null input', () {
      expect(adapter.decode(null), isNull);
    });

    test('decode returns BigInt.zero for empty bytes', () {
      final encodedEmpty = adapter.encode(BigInt.zero);
      final decoded = adapter.decode(encodedEmpty);
      expect(decoded, BigInt.zero);
    });

    test('encode and decode positive BigInt correctly', () {
      final testValues = [
        BigInt.zero,
        BigInt.from(1),
        BigInt.from(127),
        BigInt.from(128),
        BigInt.from(255),
        BigInt.from(256),
        BigInt.from(65535),
        BigInt.parse('123456789012345678901234567890'),
      ];

      for (final value in testValues) {
        final encoded = adapter.encode(value);
        final decoded = adapter.decode(encoded);
        expect(decoded, value, reason: 'Failed roundtrip for $value');
      }
    });

    test('encode and decode negative BigInt correctly', () {
      final testValues = [
        BigInt.from(-1),
        BigInt.from(-127),
        BigInt.from(-128),
        BigInt.from(-255),
        BigInt.from(-256),
        BigInt.from(-65535),
        BigInt.parse('-123456789012345678901234567890'),
      ];

      for (final value in testValues) {
        final encoded = adapter.encode(value);
        final decoded = adapter.decode(encoded);
        expect(decoded, value, reason: 'Failed roundtrip for $value');
      }
    });

    test('getter returns null when no value exists', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_bigint');
      expect(result, isNull);
    });

    test('setter and getter store and retrieve BigInt correctly (positive)',
        () async {
      final (preferences, store) = getPreferences();
      final testValue = BigInt.parse('9876543210123456789');

      await adapter.setter(preferences, 'test_bigint', testValue);

      final rawStored =
          await store.getString('test_bigint', sharedPreferencesOptions);
      expect(rawStored, isNotNull,
          reason: 'Raw stored value should not be null');

      final result = await adapter.getter(preferences, 'test_bigint');
      expect(result, testValue);
    });

    test('setter and getter store and retrieve BigInt correctly (negative)',
        () async {
      final (preferences, store) = getPreferences();
      final testValue = BigInt.parse('-9876543210123456789');

      await adapter.setter(preferences, 'test_bigint', testValue);

      final rawStored =
          await store.getString('test_bigint', sharedPreferencesOptions);
      expect(rawStored, isNotNull,
          reason: 'Raw stored value should not be null');

      final result = await adapter.getter(preferences, 'test_bigint');
      expect(result, testValue);
    });

    test('round-trip through SharedPreferencesAsync (positive and negative)',
        () async {
      final (preferences, _) = getPreferences();
      final testValues = [
        BigInt.zero,
        BigInt.from(42),
        BigInt.from(-42),
        BigInt.parse('9223372036854775807'), // Max int64
        BigInt.parse('-9223372036854775808'), // Min int64
        BigInt.parse('123456789012345678901234567890'),
        BigInt.parse('-123456789012345678901234567890'),
      ];

      for (final value in testValues) {
        await adapter.setter(preferences, 'key', value);
        final result = await adapter.getter(preferences, 'key');
        expect(result, value,
            reason: 'Failed SharedPreferences roundtrip for $value');
      }
    });

    test('decode returns null on invalid base64', () {
      final result = adapter.decode('not a base64 string');
      expect(result, isNull);
    });
  });
}
