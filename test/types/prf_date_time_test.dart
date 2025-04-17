import 'package:flutter_test/flutter_test.dart';
import 'package:prf/types/prf_datetime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  const key = 'test_datetime';

  group('PrfDateTime', () {
    late SharedPreferences prefs;
    late PrfDateTime prfDateTime;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      prfDateTime = PrfDateTime(key);
    });

    test('saves and retrieves a DateTime correctly', () async {
      final now = DateTime.now();
      await prfDateTime.setValue(prefs, now);

      final retrieved = await prfDateTime.getValue(prefs);
      expect(retrieved?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('returns null when nothing is set', () async {
      final value = await prfDateTime.getValue(prefs);
      expect(value, isNull);
    });

    test(
      'returns defaultValue if nothing is set and default is provided',
      () async {
        final defaultDate = DateTime(2000);
        final withDefault = PrfDateTime(key, defaultValue: defaultDate);
        final result = await withDefault.getValue(prefs);

        expect(result, defaultDate);
        expect(prefs.containsKey(key), true);
      },
    );

    test('removes the value and returns null afterwards', () async {
      final now = DateTime.now();
      await prfDateTime.setValue(prefs, now);
      await prfDateTime.removeValue(prefs);

      final value = await prfDateTime.getValue(prefs);
      expect(value, isNull);
    });

    test('base64 encoding and decoding is valid', () async {
      final date = DateTime(2024, 1, 1);
      await prfDateTime.setValue(prefs, date);

      final rawBase64 = prefs.getString(key);
      expect(rawBase64, isNotNull);

      final decodedBytes = base64Decode(rawBase64!);
      final millis = ByteData.sublistView(decodedBytes).getInt64(0, Endian.big);
      expect(millis, date.millisecondsSinceEpoch);
    });

    test('handles corrupted base64 gracefully', () async {
      await prefs.setString(key, 'not-valid-base64');
      final value = await prfDateTime.getValue(prefs);
      expect(value, isNull);
    });

    test('caches value after first retrieval', () async {
      final now = DateTime(2030);
      await prfDateTime.setValue(prefs, now);

      final first = await prfDateTime.getValue(prefs);
      expect(first, isNotNull);

      // Simulate data being removed externally
      await prefs.remove(key);

      final cached = await prfDateTime.getValue(prefs);
      // Still returns the cached value, not null
      expect(cached, first);
    });

    test('isValueNull returns true when key not set', () async {
      final result = await prfDateTime.isValueNull(prefs);
      expect(result, true);
    });

    test('isValueNull returns false when value exists', () async {
      final now = DateTime.now();
      await prfDateTime.setValue(prefs, now);

      final result = await prfDateTime.isValueNull(prefs);
      expect(result, false);
    });
  });
}
