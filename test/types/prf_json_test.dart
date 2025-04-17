import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:prf/types/prf_json.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final testUser = User(name: 'Alice', age: 30);

  group('PrfJson<User>', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('returns null if not set and no default provided', () async {
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      final value = await prfUser.getValue(prefs);
      expect(value, isNull);
    });

    test('returns default if not set and default provided', () async {
      final fallbackUser = User(name: 'Fallback', age: 99);
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
        defaultValue: fallbackUser,
      );

      final value = await prfUser.getValue(prefs);
      expect(value, equals(fallbackUser));
    });

    test('sets and gets value correctly', () async {
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      await prfUser.setValue(prefs, testUser);
      final value = await prfUser.getValue(prefs);
      expect(value, equals(testUser));
    });

    test('updates existing value', () async {
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      final user1 = User(name: 'Bob', age: 25);
      final user2 = User(name: 'Eve', age: 40);

      await prfUser.setValue(prefs, user1);
      expect(await prfUser.getValue(prefs), equals(user1));

      await prfUser.setValue(prefs, user2);
      expect(await prfUser.getValue(prefs), equals(user2));
    });

    test('removes value properly', () async {
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      await prfUser.setValue(prefs, testUser);
      await prfUser.removeValue(prefs);

      final value = await prfUser.getValue(prefs);
      expect(value, isNull);
    });

    test('isValueNull returns true when no value', () async {
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      final isNull = await prfUser.isValueNull(prefs);
      expect(isNull, true);
    });

    test('isValueNull returns false when value is set', () async {
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      await prfUser.setValue(prefs, testUser);
      final isNull = await prfUser.isValueNull(prefs);
      expect(isNull, false);
    });

    test('caches value after first access', () async {
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      await prefs.setString(key, jsonEncode(testUser.toJson()));
      final value1 = await prfUser.getValue(prefs);
      expect(value1, equals(testUser));

      // overwrite directly in prefs – should not affect cached value
      await prefs.setString(key, jsonEncode({'name': 'Tampered', 'age': 1}));
      final value2 = await prfUser.getValue(prefs);
      expect(value2, equals(testUser)); // Still cached
    });

    test('default value is persisted after first access', () async {
      final fallbackUser = User(name: 'Defaulty', age: 55);
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
        defaultValue: fallbackUser,
      );

      final first = await prfUser.getValue(prefs);
      expect(first, equals(fallbackUser));

      final rawJson = prefs.getString(key);
      final parsed = jsonDecode(rawJson!);
      expect(parsed['name'], equals('Defaulty'));
      expect(parsed['age'], equals(55));
    });

    test('invalid JSON returns null', () async {
      final prfUser = PrfJson<User>(
        key,
        fromJson: User.fromJson,
        toJson: (user) => user.toJson(),
      );

      await prefs.setString(key, 'not a json');
      final result = await prfUser.getValue(prefs);
      expect(result, isNull);
    });
  });
}
