import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/prf.dart';

enum TestStatus { idle, loading, success, error }

void main() {
  const key = 'test_enum';
  late SharedPreferences prefs;
  late PrfEnum<TestStatus> prfEnum;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    prfEnum = PrfEnum<TestStatus>(key, values: TestStatus.values);
  });

  group('PrfEnum Tests', () {
    test('Returns null when no value is set', () async {
      final result = await prfEnum.getValue(prefs);
      expect(result, isNull);
    });

    test('Correctly sets and gets enum value', () async {
      await prfEnum.setValue(prefs, TestStatus.success);
      final result = await prfEnum.getValue(prefs);
      expect(result, TestStatus.success);
    });

    test('Correctly removes enum value', () async {
      await prfEnum.setValue(prefs, TestStatus.loading);
      await prfEnum.removeValue(prefs);

      final result = await prfEnum.getValue(prefs);
      expect(result, isNull);
    });

    test('Handles invalid index gracefully (too high)', () async {
      await prefs.setInt(key, 99); // invalid index
      final result = await prfEnum.getValue(prefs);
      expect(result, isNull);
    });

    test('Handles invalid index gracefully (negative)', () async {
      await prefs.setInt(key, -5); // invalid index
      final result = await prfEnum.getValue(prefs);
      expect(result, isNull);
    });

    test('Works with defaultValue when missing', () async {
      prfEnum = PrfEnum<TestStatus>(
        key,
        values: TestStatus.values,
        defaultValue: TestStatus.idle,
      );

      final result = await prfEnum.getValue(prefs);
      expect(result, TestStatus.idle);
    });

    test('Uses defaultValue only when no value is stored', () async {
      prfEnum = PrfEnum<TestStatus>(
        key,
        values: TestStatus.values,
        defaultValue: TestStatus.loading,
      );

      // Value is not yet set → should return default
      final result1 = await prfEnum.getValue(prefs);
      expect(result1, TestStatus.loading);

      // After setting a value → should return that value instead
      await prfEnum.setValue(prefs, TestStatus.error);
      final result2 = await prfEnum.getValue(prefs);
      expect(result2, TestStatus.error);
    });
  });
}
