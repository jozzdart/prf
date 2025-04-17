import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/core/prf_variable.dart';

// PrfDouble class under test
class PrfDouble extends PrfVariable<double> {
  PrfDouble(String key, {double? defaultValue})
      : super(
          key,
          (prefs, key) async => prefs.getDouble(key),
          (prefs, key, value) async => await prefs.setDouble(key, value),
          defaultValue,
        );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testKey = 'test_double';

  group('PrfDouble', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test(
      'should return null if no value is set and no default provided',
      () async {
        final prf = PrfDouble(testKey);

        final value = await prf.getValue(prefs);

        expect(value, isNull);
      },
    );

    test(
      'should return default value if no value is set and default is provided',
      () async {
        final prf = PrfDouble(testKey, defaultValue: 3.14);

        final value = await prf.getValue(prefs);

        expect(value, 3.14);
      },
    );

    test('should write and read the value correctly', () async {
      final prf = PrfDouble(testKey);

      await prf.setValue(prefs, 7.77);
      final value = await prf.getValue(prefs);

      expect(value, 7.77);
    });

    test('should overwrite the value correctly', () async {
      final prf = PrfDouble(testKey);

      await prf.setValue(prefs, 1.11);
      await prf.setValue(prefs, 2.22);
      final value = await prf.getValue(prefs);

      expect(value, 2.22);
    });

    test('should remove the value and return default if provided', () async {
      final prf = PrfDouble(testKey, defaultValue: 0.5);

      await prf.setValue(prefs, 6.6);
      await prf.removeValue(prefs);

      final value = await prf.getValue(prefs);
      expect(value, 0.5);
    });

    test('should remove the value and return null if no default', () async {
      final prf = PrfDouble(testKey);

      await prf.setValue(prefs, 2.2);
      await prf.removeValue(prefs);

      final value = await prf.getValue(prefs);
      expect(value, isNull);
    });

    test('isValueNull should be true when unset and no default', () async {
      final prf = PrfDouble(testKey);

      final isNull = await prf.isValueNull(prefs);

      expect(isNull, true);
    });

    test('isValueNull should be false when set', () async {
      final prf = PrfDouble(testKey);

      await prf.setValue(prefs, 9.99);

      final isNull = await prf.isValueNull(prefs);

      expect(isNull, false);
    });

    test('should cache after first read', () async {
      final prf = PrfDouble(testKey);
      await prefs.setDouble(testKey, 1.0);

      // First read loads from prefs
      final first = await prf.getValue(prefs);

      // Change value directly in prefs to simulate external change
      await prefs.setDouble(testKey, 2.0);

      // Cached value should remain the same
      final second = await prf.getValue(prefs);

      expect(first, 1.0);
      expect(second, 1.0);
    });

    test('should update cached value on setValue()', () async {
      final prf = PrfDouble(testKey);

      await prf.setValue(prefs, 5.5);
      final first = await prf.getValue(prefs);

      await prf.setValue(prefs, 6.6);
      final second = await prf.getValue(prefs);

      expect(first, 5.5);
      expect(second, 6.6);
    });
  });
}
