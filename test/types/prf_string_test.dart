import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/core/prf_variable.dart';

class PrfString extends PrfVariable<String> {
  PrfString(String key, {String? defaultValue})
      : super(
          key,
          (prefs, key) async => prefs.getString(key),
          (prefs, key, value) async => prefs.setString(key, value),
          defaultValue,
        );
}

void main() {
  group('PrfString', () {
    const testKey = 'username';
    const testValue = 'dev_pikud';
    const defaultValue = 'default_user';

    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test(
      'initial getValue returns null if key does not exist and no default',
      () async {
        final variable = PrfString(testKey);
        final value = await variable.getValue(prefs);
        expect(value, isNull);
      },
    );

    test(
      'initial getValue returns default if key does not exist and default is provided',
      () async {
        final variable = PrfString(testKey, defaultValue: defaultValue);
        final value = await variable.getValue(prefs);
        expect(value, defaultValue);
      },
    );

    test(
      'getValue sets the default into SharedPreferences if not already set',
      () async {
        final variable = PrfString(testKey, defaultValue: defaultValue);
        await variable.getValue(prefs);
        expect(prefs.getString(testKey), defaultValue);
      },
    );

    test('setValue stores the value and getValue returns it', () async {
      final variable = PrfString(testKey);
      await variable.setValue(prefs, testValue);
      final value = await variable.getValue(prefs);
      expect(value, testValue);
      expect(prefs.getString(testKey), testValue);
    });

    test('getValue caches the value and avoids re-fetching', () async {
      final variable = PrfString(testKey);
      await variable.setValue(prefs, testValue);
      prefs.remove(testKey); // remove from prefs directly
      final second = await variable.getValue(prefs); // should return cached
      expect(second, testValue);
    });

    test('setValue overrides the previous value', () async {
      final variable = PrfString(testKey);
      await variable.setValue(prefs, 'first');
      await variable.setValue(prefs, 'second');
      final value = await variable.getValue(prefs);
      expect(value, 'second');
    });

    test('removeValue clears from prefs and cache', () async {
      final variable = PrfString(testKey);
      await variable.setValue(prefs, testValue);
      await variable.removeValue(prefs);
      expect(prefs.containsKey(testKey), isFalse);
      final value = await variable.getValue(prefs);
      expect(value, isNull);
    });

    test('isValueNull returns true if no value exists', () async {
      final variable = PrfString(testKey);
      final isNull = await variable.isValueNull(prefs);
      expect(isNull, true);
    });

    test('isValueNull returns false if value exists', () async {
      final variable = PrfString(testKey);
      await variable.setValue(prefs, testValue);
      final isNull = await variable.isValueNull(prefs);
      expect(isNull, false);
    });

    test('setting value to empty string still works', () async {
      final variable = PrfString(testKey);
      await variable.setValue(prefs, '');
      final value = await variable.getValue(prefs);
      expect(value, '');
    });

    test('setting value with special characters works', () async {
      final special = '💡🚀✨\n\t~!@#\$%^&*()_+=-';
      final variable = PrfString(testKey);
      await variable.setValue(prefs, special);
      final value = await variable.getValue(prefs);
      expect(value, special);
    });
  });
}
