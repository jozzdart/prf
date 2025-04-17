import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/core/prf_variable.dart';

class PrfInt extends PrfVariable<int> {
  PrfInt(String key, {int? defaultValue})
      : super(
          key,
          (prefs, key) async => prefs.getInt(key),
          (prefs, key, value) async => prefs.setInt(key, value),
          defaultValue,
        );
}

void main() {
  const testKey = 'test_int_key';

  setUp(() async {
    SharedPreferences.setMockInitialValues({}); // Reset before each test
  });

  test('Returns null if value is not set and no default is provided', () async {
    final prefs = await SharedPreferences.getInstance();
    final variable = PrfInt(testKey);
    final value = await variable.getValue(prefs);
    expect(value, isNull);
  });

  test('Returns default if value not set, and sets it internally', () async {
    final prefs = await SharedPreferences.getInstance();
    final variable = PrfInt(testKey, defaultValue: 42);

    final value = await variable.getValue(prefs);
    expect(value, 42);

    // Check that it was actually written to SharedPreferences
    expect(prefs.getInt(testKey), 42);
  });

  test('Can set and retrieve a value', () async {
    final prefs = await SharedPreferences.getInstance();
    final variable = PrfInt(testKey);

    await variable.setValue(prefs, 99);
    final value = await variable.getValue(prefs);

    expect(value, 99);
    expect(prefs.getInt(testKey), 99);
  });

  test('Caches value after set', () async {
    final prefs = await SharedPreferences.getInstance();
    final variable = PrfInt(testKey);

    await variable.setValue(prefs, 10);
    prefs.setInt(testKey, 99); // mutate directly

    final cachedValue = await variable.getValue(prefs);
    expect(cachedValue, 10); // still uses cached
  });

  test('Removes value correctly', () async {
    final prefs = await SharedPreferences.getInstance();
    final variable = PrfInt(testKey);

    await variable.setValue(prefs, 777);
    expect(await variable.getValue(prefs), 777);

    await variable.removeValue(prefs);
    expect(await variable.getValue(prefs), isNull);
    expect(prefs.containsKey(testKey), isFalse);
  });

  test('isValueNull works correctly', () async {
    final prefs = await SharedPreferences.getInstance();
    final variable = PrfInt(testKey);

    expect(await variable.isValueNull(prefs), isTrue);
    await variable.setValue(prefs, 3);
    expect(await variable.isValueNull(prefs), isFalse);
  });

  test('getValue uses default only once', () async {
    final prefs = await SharedPreferences.getInstance();
    final variable = PrfInt(testKey, defaultValue: 8);

    // First call sets the default
    final value1 = await variable.getValue(prefs);
    expect(value1, 8);

    // Directly change the prefs (simulate external mutation)
    await prefs.setInt(testKey, 20);

    // Still returns 8 because it's cached
    final value2 = await variable.getValue(prefs);
    expect(value2, 8);
  });
}
