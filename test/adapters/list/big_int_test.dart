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

  group('BigIntListAdapter', () {
    const adapter = BigIntListAdapter();

    test('getter returns null when no value is stored', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_bigint_list');
      expect(result, isNull);
    });

    test('getter returns empty list when stored empty', () async {
      final (preferences, store) = getPreferences();
      final encoded = adapter.encode([]);
      await store.setStringList(
          'test_bigint_list', encoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_bigint_list');
      expect(result, isEmpty);
    });

    test('getter returns correct list when exists', () async {
      final (preferences, store) = getPreferences();
      final testList = [
        BigInt.zero,
        BigInt.from(123456789),
        BigInt.parse('98765432109876543210')
      ];
      final encoded = adapter.encode(testList);
      await store.setStringList(
          'test_bigint_list', encoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_bigint_list');
      expect(result, testList);
    });

    test('getter returns null if a single value is corrupted', () async {
      final (preferences, store) = getPreferences();
      final encoded = adapter.encode([BigInt.from(42)]);
      final corrupted = [...encoded];
      corrupted[0] = 'not_base64';

      await store.setStringList(
          'test_bigint_list', corrupted, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_bigint_list');
      expect(result, isNull);
    });

    test('setter stores list correctly', () async {
      final (preferences, store) = getPreferences();
      final testList = [BigInt.from(999), BigInt.parse('12345678901234567890')];

      await adapter.setter(preferences, 'test_bigint_list', testList);

      final stored = await store.getStringList(
          'test_bigint_list', sharedPreferencesOptions);
      final decoded = adapter.decode(stored);

      expect(decoded, testList);
    });

    test('complete round trip: setter then getter', () async {
      final (preferences, _) = getPreferences();
      final testList = [BigInt.parse('123456789012345678901234567890')];

      await adapter.setter(preferences, 'test_bigint_list', testList);
      final result = await adapter.getter(preferences, 'test_bigint_list');

      expect(result, testList);
    });

    test('encode produces valid base64 strings', () {
      final list = [BigInt.one, BigInt.from(10000)];
      final encoded = adapter.encode(list);

      for (final str in encoded) {
        expect(() => base64Decode(str), returnsNormally);
      }
    });

    test('decode returns original BigInt values', () {
      final list = [
        BigInt.from(42),
        BigInt.from(-999),
        BigInt.parse('12345678901234567890'),
        BigInt.parse('-987654321098765432109876543210')
      ];

      final encoded = adapter.encode(list);
      final decoded = adapter.decode(encoded);

      expect(decoded, list);
    });

    test('decode returns null when input is null', () {
      final result = adapter.decode(null);
      expect(result, isNull);
    });

    test('getter decodes empty string as BigInt.zero', () async {
      final (preferences, store) = getPreferences();
      await store.setStringList(
          'test_bigint_list', [''], sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_bigint_list');
      expect(result, [BigInt.zero]);
    });

    test('round trip for a large list of BigInt', () async {
      final (preferences, _) = getPreferences();
      final testList =
          List.generate(1000, (i) => BigInt.from(i) * BigInt.from(999999));

      await adapter.setter(preferences, 'test_bigint_list', testList);
      final result = await adapter.getter(preferences, 'test_bigint_list');

      expect(result, testList);
    });

    test('encodes and decodes BigInt.zero and BigInt.one correctly', () {
      final list = [BigInt.zero, BigInt.one];
      final encoded = adapter.encode(list);
      final decoded = adapter.decode(encoded);

      expect(decoded, list);
    });

    test('getter decodes "/////w==" to BigInt.from(16777215)', () async {
      final (preferences, store) = getPreferences();
      await store.setStringList(
          'test_bigint_list', ['/////w=='], sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_bigint_list');
      expect(result, [BigInt.from(16777215)]);
    });
  });
}
