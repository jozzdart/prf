import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf_types/prf_json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(name: json['name'] as String, age: json['age'] as int);

  Map<String, dynamic> toJson() => {'name': name, 'age': age};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          age == other.age;

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}

void main() {
  const key = 'user';
  const sharedPreferencesOptions = SharedPreferencesOptions();
  final testUser = User(name: 'Alice', age: 30);

  group('PrfJson<User>', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('returns null if not set and no default provided', () async {
      final (preferences, _) = getPreferences();
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      final value = await prfUser.getValue(preferences);
      expect(value, isNull);
    });

    test('returns default if not set and default provided', () async {
      final (preferences, _) = getPreferences();
      final fallbackUser = User(name: 'Fallback', age: 99);
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
        defaultValue: fallbackUser,
      );

      final value = await prfUser.getValue(preferences);
      expect(value, equals(fallbackUser));
    });

    test('sets and gets value correctly', () async {
      final (preferences, _) = getPreferences();
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      await prfUser.setValue(preferences, testUser);
      final value = await prfUser.getValue(preferences);
      expect(value, equals(testUser));
    });

    test('updates existing value', () async {
      final (preferences, _) = getPreferences();
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      final user1 = User(name: 'Bob', age: 25);
      final user2 = User(name: 'Eve', age: 40);

      await prfUser.setValue(preferences, user1);
      expect(await prfUser.getValue(preferences), equals(user1));

      await prfUser.setValue(preferences, user2);
      expect(await prfUser.getValue(preferences), equals(user2));
    });

    test('removes value properly', () async {
      final (preferences, store) = getPreferences();
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      await prfUser.setValue(preferences, testUser);
      await prfUser.removeValue(preferences);

      final value = await prfUser.getValue(preferences);
      expect(value, isNull);

      final keys = await store.getKeys(
        GetPreferencesParameters(filter: PreferencesFilters()),
        sharedPreferencesOptions,
      );
      expect(keys.contains(key), false);
    });

    test('isValueNull returns true when no value', () async {
      final (preferences, _) = getPreferences();
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      final isNull = await prfUser.isValueNull(preferences);
      expect(isNull, true);
    });

    test('isValueNull returns false when value is set', () async {
      final (preferences, _) = getPreferences();
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      await prfUser.setValue(preferences, testUser);
      final isNull = await prfUser.isValueNull(preferences);
      expect(isNull, false);
    });

    test('caches value after first access', () async {
      final (preferences, store) = getPreferences();
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      await store.setString(
          key, jsonEncode(testUser.toJson()), sharedPreferencesOptions);
      final value1 = await prfUser.getValue(preferences);
      expect(value1, equals(testUser));

      // overwrite directly in prefs – should not affect cached value
      await store.setString(key, jsonEncode({'name': 'Tampered', 'age': 1}),
          sharedPreferencesOptions);
      final value2 = await prfUser.getValue(preferences);
      expect(value2, equals(testUser)); // Still cached
    });

    test('default value is persisted after first access', () async {
      final (preferences, store) = getPreferences();
      final fallbackUser = User(name: 'Defaulty', age: 55);
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
        defaultValue: fallbackUser,
      );

      final first = await prfUser.getValue(preferences);
      expect(first, equals(fallbackUser));

      final rawJson = await store.getString(key, sharedPreferencesOptions);
      final parsed = jsonDecode(rawJson!);
      expect(parsed['name'], equals('Defaulty'));
      expect(parsed['age'], equals(55));
    });

    test('invalid JSON returns null', () async {
      final (preferences, store) = getPreferences();
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      await store.setString(key, 'not a json', sharedPreferencesOptions);
      final result = await prfUser.getValue(preferences);
      expect(result, isNull);
    });
  });
}
