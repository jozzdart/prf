import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/core/prf_encoded.dart';

void main() {
  group('PrfEncoded<DateTime, String> (via base64)', () {
    late SharedPreferences prefs;
    const testKey = 'test_date';

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    PrfEncoded<DateTime, String> buildDatePref({DateTime? defaultValue}) {
      return PrfEncoded<DateTime, String>(
        testKey,
        from: (base64) {
          if (base64 == null) return null;
          try {
            final bytes = base64Decode(base64);
            final millis = ByteData.sublistView(bytes).getInt64(0, Endian.big);
            return DateTime.fromMillisecondsSinceEpoch(millis);
          } catch (_) {
            return null;
          }
        },
        to: (dateTime) {
          final buffer = ByteData(8);
          buffer.setInt64(0, dateTime.millisecondsSinceEpoch, Endian.big);
          return base64Encode(buffer.buffer.asUint8List());
        },
        getter: (prefs, key) async => prefs.getString(key),
        setter: (prefs, key, value) async => prefs.setString(key, value),
        defaultValue: defaultValue,
      );
    }

    test('writes and reads a DateTime correctly', () async {
      final now = DateTime.now();
      final pref = buildDatePref();

      await pref.setValue(prefs, now);
      final result = await pref.getValue(prefs);

      expect(result, isNotNull);
      expect(
        result!.millisecondsSinceEpoch,
        equals(now.millisecondsSinceEpoch),
      );
    });

    test('returns default value if key is missing', () async {
      final defaultDate = DateTime(2020, 1, 1);
      final pref = buildDatePref(defaultValue: defaultDate);

      final result = await pref.getValue(prefs);
      expect(result, equals(defaultDate));
    });

    test('writes default value to prefs if key is missing', () async {
      final defaultDate = DateTime(2021, 6, 1);
      final pref = buildDatePref(defaultValue: defaultDate);

      final result = await pref.getValue(prefs);
      final stored = prefs.getString(testKey);

      expect(result, equals(defaultDate));
      expect(stored, isNotNull);
    });

    test('returns null if stored base64 is corrupted', () async {
      await prefs.setString(testKey, 'not-a-valid-base64');
      final pref = buildDatePref();

      final result = await pref.getValue(prefs);
      expect(result, isNull);
    });

    test('removes value and clears cache', () async {
      final date = DateTime(2000, 1, 1);
      final pref = buildDatePref();

      await pref.setValue(prefs, date);
      await pref.removeValue(prefs);

      expect(prefs.containsKey(testKey), isFalse);
      expect(await pref.getValue(prefs), isNull);
    });

    test('caches value after first read', () async {
      final date = DateTime(2030, 5, 1);
      final pref = buildDatePref();

      await pref.setValue(prefs, date);

      final result1 = await pref.getValue(prefs);
      await prefs.remove(testKey); // simulate external delete

      final result2 = await pref.getValue(prefs); // should return cached

      expect(result1, equals(date));
      expect(result2, equals(date)); // still returned from cache
    });

    test('isValueNull returns true only if value is null', () async {
      final pref = buildDatePref();

      expect(await pref.isValueNull(prefs), isTrue);

      await pref.setValue(prefs, DateTime.now());
      expect(await pref.isValueNull(prefs), isFalse);
    });
  });
}
