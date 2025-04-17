import 'package:flutter_test/flutter_test.dart';
import 'package:prf/types/prf_bool.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const key = 'test_bool';

  group('PrfBool', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('returns null if not set and no default provided', () async {
      final boolPref = PrfBool(key);
      final value = await boolPref.getValue(prefs);
      expect(value, isNull);
    });

    test('returns default if not set and default provided', () async {
      final boolPref = PrfBool(key, defaultValue: true);
      final value = await boolPref.getValue(prefs);
      expect(value, true);
    });

    test('sets and gets value correctly', () async {
      final boolPref = PrfBool(key);
      await boolPref.setValue(prefs, true);
      final value = await boolPref.getValue(prefs);
      expect(value, true);
    });

    test('updates existing value', () async {
      final boolPref = PrfBool(key);
      await boolPref.setValue(prefs, false);
      var value = await boolPref.getValue(prefs);
      expect(value, false);

      await boolPref.setValue(prefs, true);
      value = await boolPref.getValue(prefs);
      expect(value, true);
    });

    test('removes value properly', () async {
      final boolPref = PrfBool(key);
      await boolPref.setValue(prefs, true);

      await boolPref.removeValue(prefs);
      final value = await boolPref.getValue(prefs);
      expect(value, isNull);
    });

    test('isValueNull returns true when no value', () async {
      final boolPref = PrfBool(key);
      final isNull = await boolPref.isValueNull(prefs);
      expect(isNull, true);
    });

    test('isValueNull returns false when value is set', () async {
      final boolPref = PrfBool(key);
      await boolPref.setValue(prefs, true);
      final isNull = await boolPref.isValueNull(prefs);
      expect(isNull, false);
    });

    test('caches value after first access', () async {
      final boolPref = PrfBool(key);
      await prefs.setBool(key, true);

      final value1 = await boolPref.getValue(prefs);
      expect(value1, true);

      // Modify directly, should not affect cached value
      await prefs.setBool(key, false);
      final value2 = await boolPref.getValue(prefs);
      expect(value2, true); // still cached
    });

    test('default value is persisted after first access', () async {
      final boolPref = PrfBool(key, defaultValue: true);

      final first = await boolPref.getValue(prefs);
      expect(first, true);

      final raw = prefs.getBool(key);
      expect(raw, true);
    });
  });
}
