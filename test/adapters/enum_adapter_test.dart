import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:prf/prf.dart';

import '../utils/fake_prefs.dart';

enum TestEnum { first, second, third }

void main() {
  const sharedPreferencesOptions = SharedPreferencesOptions();

  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final SharedPreferencesAsync preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  group('EnumAdapter', () {
    final adapter = EnumAdapter<TestEnum>(TestEnum.values);

    test('decode returns correct enum from index', () {
      expect(adapter.decode(0), TestEnum.first);
      expect(adapter.decode(1), TestEnum.second);
      expect(adapter.decode(2), TestEnum.third);
    });

    test('decode returns null for null or invalid index', () {
      expect(adapter.decode(null), isNull);
      expect(adapter.decode(-1), isNull);
      expect(adapter.decode(3), isNull);
    });

    test('encode returns correct index for enum', () {
      expect(adapter.encode(TestEnum.first), 0);
      expect(adapter.encode(TestEnum.second), 1);
      expect(adapter.encode(TestEnum.third), 2);
    });

    test('getter returns null when no value exists', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_enum');
      expect(result, isNull);
    });

    test('getter returns correct enum when value exists', () async {
      final (preferences, store) = getPreferences();
      await store.setInt('test_enum', 1, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_enum');
      expect(result, TestEnum.second);
    });

    test('setter stores correct index value', () async {
      final (preferences, store) = getPreferences();

      await adapter.setter(preferences, 'test_enum', TestEnum.third);

      final stored = await store.getInt('test_enum', sharedPreferencesOptions);
      expect(stored, 2);
    });

    test('complete round trip: setter followed by getter', () async {
      final (preferences, _) = getPreferences();

      await adapter.setter(preferences, 'test_enum', TestEnum.second);
      final result = await adapter.getter(preferences, 'test_enum');

      expect(result, TestEnum.second);
    });
  });
}
