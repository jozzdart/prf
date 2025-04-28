import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../utils/fake_prefs.dart';

void main() {
  const sharedPreferencesOptions = SharedPreferencesOptions();

  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final SharedPreferencesAsync preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  group('NumAdapter', () {
    const adapter = NumAdapter();

    test('getter returns null when no value exists', () async {
      final (preferences, _) = getPreferences();

      final result = await adapter.getter(preferences, 'test_num');
      expect(result, isNull);
    });

    test('getter returns num when a double value exists', () async {
      final (preferences, store) = getPreferences();
      await store.setDouble('test_num', 42.5, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_num');
      expect(result, 42.5);
    });

    test('setter stores int value as double correctly', () async {
      final (preferences, store) = getPreferences();

      await adapter.setter(preferences, 'test_num', 100);

      final stored =
          await store.getDouble('test_num', sharedPreferencesOptions);
      expect(stored, 100.0); // Should be stored as double
    });

    test('setter stores double value correctly', () async {
      final (preferences, store) = getPreferences();

      await adapter.setter(preferences, 'test_num', 123.456);

      final stored =
          await store.getDouble('test_num', sharedPreferencesOptions);
      expect(stored, 123.456);
    });

    test('round trip int value: setter followed by getter', () async {
      final (preferences, _) = getPreferences();

      await adapter.setter(preferences, 'test_num', 77);

      final result = await adapter.getter(preferences, 'test_num');
      expect(result, 77.0); // Note: read back as double
    });

    test('round trip double value: setter followed by getter', () async {
      final (preferences, _) = getPreferences();

      await adapter.setter(preferences, 'test_num', 88.88);

      final result = await adapter.getter(preferences, 'test_num');
      expect(result, 88.88);
    });

    test('encode returns correct double from int and double inputs', () {
      expect(adapter.encode(5), 5.0);
      expect(adapter.encode(3.1415), 3.1415);
    });

    test('decode returns correct num from stored double', () {
      expect(adapter.decode(7.5), 7.5);
      expect(adapter.decode(null), isNull);
    });
  });
}
