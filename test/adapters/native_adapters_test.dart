import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:prf/prf.dart';

import '../utils/fake_prefs.dart';

void main() {
  const sharedPreferencesOptions = SharedPreferencesOptions();

  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final SharedPreferencesAsync preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  group('BoolAdapter', () {
    const adapter = BoolAdapter();

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_bool');
      expect(result, isNull);
    });

    test('getter returns value when exists', () async {
      final (preferences, store) = getPreferences();
      await store.setBool('test_bool', true, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_bool');
      expect(result, true);
    });

    test('setter stores value correctly', () async {
      final (preferences, store) = getPreferences();

      await adapter.setter(preferences, 'test_bool', false);

      final stored = await store.getBool('test_bool', sharedPreferencesOptions);
      expect(stored, false);
    });
  });

  group('IntAdapter', () {
    const adapter = IntAdapter();

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_int');
      expect(result, isNull);
    });

    test('getter returns value when exists', () async {
      final (preferences, store) = getPreferences();
      await store.setInt('test_int', 42, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_int');
      expect(result, 42);
    });

    test('setter stores value correctly', () async {
      final (preferences, store) = getPreferences();

      await adapter.setter(preferences, 'test_int', 123);

      final stored = await store.getInt('test_int', sharedPreferencesOptions);
      expect(stored, 123);
    });
  });

  group('DoubleAdapter', () {
    const adapter = DoubleAdapter();

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_double');
      expect(result, isNull);
    });

    test('getter returns value when exists', () async {
      final (preferences, store) = getPreferences();
      await store.setDouble('test_double', 3.14, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_double');
      expect(result, 3.14);
    });

    test('setter stores value correctly', () async {
      final (preferences, store) = getPreferences();

      await adapter.setter(preferences, 'test_double', 2.71);

      final stored =
          await store.getDouble('test_double', sharedPreferencesOptions);
      expect(stored, 2.71);
    });
  });

  group('StringAdapter', () {
    const adapter = StringAdapter();

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_string');
      expect(result, isNull);
    });

    test('getter returns value when exists', () async {
      final (preferences, store) = getPreferences();
      await store.setString('test_string', 'hello', sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_string');
      expect(result, 'hello');
    });

    test('setter stores value correctly', () async {
      final (preferences, store) = getPreferences();

      await adapter.setter(preferences, 'test_string', 'world');

      final stored =
          await store.getString('test_string', sharedPreferencesOptions);
      expect(stored, 'world');
    });
  });

  group('StringListAdapter', () {
    const adapter = StringListAdapter();

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_list');
      expect(result, isNull);
    });

    test('getter returns value when exists', () async {
      final (preferences, store) = getPreferences();
      final testList = ['one', 'two', 'three'];
      await store.setStringList(
          'test_list', testList, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_list');
      expect(result, testList);
    });

    test('setter stores value correctly', () async {
      final (preferences, store) = getPreferences();
      final testList = ['apple', 'banana', 'cherry'];

      await adapter.setter(preferences, 'test_list', testList);

      final stored =
          await store.getStringList('test_list', sharedPreferencesOptions);
      expect(stored, testList);
    });
  });
}
