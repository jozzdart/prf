import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/core/prf_variable.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrfVariable', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('returns null when no value and no default', () async {
      final variable = _createStringVar('username');
      final value = await variable.getValue(prefs);
      expect(value, isNull);
    });

    test('returns default if key missing, then stores it', () async {
      final variable = _createStringVar('username', defaultValue: 'guest');

      final value = await variable.getValue(prefs);
      expect(value, 'guest');

      final stored = prefs.getString('username');
      expect(stored, 'guest');
    });

    test('caches value after first read', () async {
      final variable = _createStringVar('username');
      await prefs.setString('username', 'cached_user');

      final first = await variable.getValue(prefs);
      await prefs.setString('username', 'changed'); // Should not affect result
      final second = await variable.getValue(prefs);

      expect(first, 'cached_user');
      expect(second, 'cached_user'); // same due to cache
    });

    test('setValue updates SharedPreferences and cache', () async {
      final variable = _createStringVar('username');

      final success = await variable.setValue(prefs, 'new_user');
      final result = await variable.getValue(prefs);

      expect(success, true);
      expect(result, 'new_user');
      expect(prefs.getString('username'), 'new_user');
    });

    test('removeValue clears cache and deletes from prefs', () async {
      final variable = _createStringVar('username');
      await variable.setValue(prefs, 'to_be_removed');

      await variable.removeValue(prefs);

      expect(await variable.getValue(prefs), isNull);
      expect(prefs.containsKey('username'), false);
    });

    test('isValueNull works correctly', () async {
      final variable = _createStringVar('username');
      expect(await variable.isValueNull(prefs), true);

      await variable.setValue(prefs, 'not_null');
      expect(await variable.isValueNull(prefs), false);
    });

    test('getValue does not overwrite existing value with default', () async {
      await prefs.setString('username', 'existing');
      final variable = _createStringVar('username', defaultValue: 'default');

      final value = await variable.getValue(prefs);
      expect(value, 'existing');
    });
  });
}

/// Returns a simple PrfVariable instance
PrfVariable<String> _createStringVar(String key, {String? defaultValue}) {
  return PrfVariable<String>(
    key,
    (prefs, key) async => prefs.getString(key),
    (prefs, key, value) async => prefs.setString(key, value),
    defaultValue,
  );
}
