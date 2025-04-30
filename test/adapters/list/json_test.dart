import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../utils/fake_prefs.dart';

// Test class for JSON serialization
class TestUser {
  final String name;
  final int age;
  final List<String> hobbies;

  TestUser({
    required this.name,
    required this.age,
    required this.hobbies,
  });

  TestUser.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int,
        hobbies = List<String>.from(json['hobbies'] as List);

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'hobbies': hobbies,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestUser &&
        other.name == name &&
        other.age == age &&
        _listEquals(other.hobbies, hobbies);
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => name.hashCode ^ age.hashCode ^ hobbies.hashCode;
  @override
  String toString() => 'TestUser(name: $name, age: $age, hobbies: $hobbies)';
}

void main() {
  const sharedPreferencesOptions = SharedPreferencesOptions();

  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  group('JsonListAdapter<TestUser>', () {
    final adapter = JsonListAdapter<TestUser>(
      fromJson: TestUser.fromJson,
      toJson: (user) => user.toJson(),
    );

    final users = [
      TestUser(name: 'Alice', age: 30, hobbies: ['reading']),
      TestUser(name: 'Bob', age: 25, hobbies: ['gaming', 'cycling']),
    ];

    users
        .map((u) =>
            '{"name":"${u.name}","age":${u.age},"hobbies":${u.hobbies.map((e) => '"$e"').toList()}}')
        .toList();

    test('encode converts list to list of JSON strings', () {
      final result = adapter.encode(users);
      expect(result, isA<List<String>>());
      expect(result.length, users.length);
      expect(result[0], contains('"name":"Alice"'));
      expect(result[1], contains('"name":"Bob"'));
    });

    test('decode converts list of JSON strings to object list', () {
      final result = adapter.decode(adapter.encode(users));
      expect(result, users);
    });

    test('decode returns null for null input', () {
      expect(adapter.decode(null), isNull);
    });

    test('decode returns null if any JSON is malformed', () {
      final corrupted = ['{"name": "X", "age": 20}', '{invalid_json}'];
      final result = adapter.decode(corrupted);
      expect(result, isNull);
    });

    test('decode returns null if JSON structure is incorrect', () {
      final wrong = ['{"unexpected": "structure"}'];
      expect(adapter.decode(wrong), isNull);
    });

    test('getter returns null when no value exists', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_users');
      expect(result, isNull);
    });

    test('setter stores encoded JSON list correctly', () async {
      final (preferences, store) = getPreferences();
      await adapter.setter(preferences, 'test_users', users);

      final stored =
          await store.getStringList('test_users', sharedPreferencesOptions);
      final expected = adapter.encode(users);

      expect(stored, expected);
    });

    test('getter returns correct list when value exists', () async {
      final (preferences, store) = getPreferences();
      final encoded = adapter.encode(users);

      await store.setStringList(
          'test_users', encoded, sharedPreferencesOptions);
      final result = await adapter.getter(preferences, 'test_users');

      expect(result, users);
    });

    test('complete round trip: setter then getter returns original', () async {
      final (preferences, _) = getPreferences();

      await adapter.setter(preferences, 'test_users', users);
      final result = await adapter.getter(preferences, 'test_users');

      expect(result, users);
    });

    test('encode works for empty list', () {
      final encoded = adapter.encode([]);
      expect(encoded, []);
    });

    test('decode works for empty list', () {
      final result = adapter.decode([]);
      expect(result, []);
    });

    test('decode returns null if a valid JSON is not a Map', () {
      final result = adapter.decode(['"just a string"', '42', 'true']);
      expect(result, isNull);
    });

    test('encode and decode with duplicate objects maintains list structure',
        () {
      final duplicates = [users.first, users.first, users.first];
      final encoded = adapter.encode(duplicates);
      final decoded = adapter.decode(encoded);
      expect(decoded, duplicates);
    });

    test('encode and decode with duplicate objects maintains list structure',
        () {
      final duplicates = [users.first, users.first, users.first];
      final encoded = adapter.encode(duplicates);
      final decoded = adapter.decode(encoded);
      expect(decoded, duplicates);
    });

    test('decode returns new object instances (not same references)', () {
      final decoded = adapter.decode(adapter.encode(users));
      for (int i = 0; i < users.length; i++) {
        expect(decoded![i], equals(users[i]));
        expect(identical(decoded[i], users[i]), isFalse);
      }
    });

    test('encode output can be parsed back to JSON safely', () {
      final encoded = adapter.encode(users);
      for (final jsonStr in encoded) {
        expect(() => jsonDecode(jsonStr), returnsNormally);
      }
    });

    test(
        'getter returns null if SharedPreferences contains invalid JSON strings',
        () async {
      final (preferences, store) = getPreferences();
      final badList = ['{"name":"Valid"}', '{not_a_json}'];

      await store.setStringList(
          'test_users', badList, sharedPreferencesOptions);
      final result = await adapter.getter(preferences, 'test_users');

      expect(result, isNull);
    });
  });
}
