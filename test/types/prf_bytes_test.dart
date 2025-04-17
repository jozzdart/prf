import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:prf/types/prf_bytes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const key = 'test_bytes';

  late SharedPreferences prefs;
  late PrfBytes prfBytes;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    prfBytes = PrfBytes(key);
  });

  test('Returns null when no value is set', () async {
    final result = await prfBytes.getValue(prefs);
    expect(result, isNull);
  });

  test('Can set and get Uint8List value', () async {
    final original = Uint8List.fromList([1, 2, 3, 4, 5]);
    final success = await prfBytes.setValue(prefs, original);
    expect(success, true);

    final result = await prfBytes.getValue(prefs);
    expect(result, equals(original));
  });

  test('Encoded as base64 and stored as string', () async {
    final bytes = Uint8List.fromList([100, 200, 255]);
    final base64 = base64Encode(bytes);

    await prfBytes.setValue(prefs, bytes);

    final rawStored = prefs.getString(key);
    expect(rawStored, equals(base64));
  });

  test('Handles corrupted base64 data gracefully', () async {
    await prefs.setString(key, '!!not-valid-base64@@');
    final result = await prfBytes.getValue(prefs);
    expect(result, isNull);
  });

  test('Removes value correctly', () async {
    final original = Uint8List.fromList([9, 8, 7]);
    await prfBytes.setValue(prefs, original);
    await prfBytes.removeValue(prefs);

    final result = await prfBytes.getValue(prefs);
    expect(result, isNull);
    expect(prefs.containsKey(key), isFalse);
  });

  test('Returns default value and stores it if not existing', () async {
    final defaultBytes = Uint8List.fromList([1, 1, 1]);
    final withDefault = PrfBytes(key, defaultValue: defaultBytes);

    final result = await withDefault.getValue(prefs);
    expect(result, equals(defaultBytes));

    final stored = await withDefault.getValue(prefs);
    expect(stored, equals(defaultBytes));
  });

  test('Caches value after first fetch', () async {
    final bytes = Uint8List.fromList([42, 42]);
    await prefs.setString(key, base64Encode(bytes));

    final loaded1 = await prfBytes.getValue(prefs);
    expect(loaded1, equals(bytes));

    await prefs.setString(key, base64Encode(Uint8List.fromList([0, 0])));

    final loaded2 = await prfBytes.getValue(prefs);
    expect(loaded2, equals(bytes), reason: 'Should return cached value');
  });
}
