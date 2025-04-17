import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/core/prf_variable.dart';

class PrfStringList extends PrfVariable<List<String>> {
  PrfStringList(String key, {List<String>? defaultValue})
      : super(
          key,
          (prefs, key) async => prefs.getStringList(key),
          (prefs, key, value) async => prefs.setStringList(key, value),
          defaultValue,
        );
}

void main() {
  const testKey = 'test_string_list';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'initial get returns null when no value is set and no default provided',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final variable = PrfStringList(testKey);

      final value = await variable.getValue(prefs);
      expect(value, isNull);
    },
  );

  test('initial get returns default value if provided', () async {
    final prefs = await SharedPreferences.getInstance();
    final defaultList = ['a', 'b'];
    final variable = PrfStringList(testKey, defaultValue: defaultList);

    final value = await variable.getValue(prefs);
    expect(value, equals(defaultList));
  });

  test('set and get value works correctly', () async {
    final prefs = await SharedPreferences.getInstance();
    final variable = PrfStringList(testKey);

    final input = ['one', 'two', 'three'];
    await variable.setValue(prefs, input);
    final value = await variable.getValue(prefs);

    expect(value, equals(input));
  });

  test('setValue caches value for faster access', () async {
    final prefs = await SharedPreferences.getInstance();
    final variable = PrfStringList(testKey);

    final input = ['cached'];
    await variable.setValue(prefs, input);

    final value1 = await variable.getValue(prefs);
    final value2 = await variable.getValue(prefs);

    // Should be cached, so same instance
    expect(identical(value1, value2), isTrue);
  });

  test('removeValue clears stored value and cache', () async {
    final prefs = await SharedPreferences.getInstance();
    final variable = PrfStringList(testKey);

    await variable.setValue(prefs, ['x']);
    expect(await variable.getValue(prefs), isNotNull);

    await variable.removeValue(prefs);
    expect(await variable.getValue(prefs), isNull);
  });

  test('isValueNull returns true if value is not set and no default', () async {
    final prefs = await SharedPreferences.getInstance();
    final variable = PrfStringList(testKey);

    expect(await variable.isValueNull(prefs), isTrue);
  });

  test('isValueNull returns false after setting value', () async {
    final prefs = await SharedPreferences.getInstance();
    final variable = PrfStringList(testKey);

    await variable.setValue(prefs, ['hello']);
    expect(await variable.isValueNull(prefs), isFalse);
  });

  test('getValue persists the default to SharedPreferences', () async {
    final prefs = await SharedPreferences.getInstance();
    final defaultValue = ['persisted'];
    final variable = PrfStringList(testKey, defaultValue: defaultValue);

    final value = await variable.getValue(prefs);
    expect(value, equals(defaultValue));

    final raw = prefs.getStringList(testKey);
    expect(raw, equals(defaultValue));
  });

  test('setValue overrides existing default value', () async {
    final prefs = await SharedPreferences.getInstance();
    final variable = PrfStringList(testKey, defaultValue: ['default']);

    expect(await variable.getValue(prefs), equals(['default']));

    await variable.setValue(prefs, ['new']);
    expect(await variable.getValue(prefs), equals(['new']));
  });
}
