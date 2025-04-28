import 'package:flutter_test/flutter_test.dart';
import 'package:prf/adapters/json_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../utils/fake_prefs.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'hobbies': hobbies,
    };
  }

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
    final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final SharedPreferencesAsync preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  group('JsonAdapter', () {
    final adapter = JsonAdapter<TestUser>(
      fromJson: TestUser.fromJson,
      toJson: (user) => user.toJson(),
    );

    final testUser = TestUser(
      name: 'Alice',
      age: 30,
      hobbies: ['reading', 'coding', 'hiking'],
    );

    final testUserJson =
        '{"name":"Alice","age":30,"hobbies":["reading","coding","hiking"]}';

    test('encode converts object to JSON string', () {
      final encoded = adapter.encode(testUser);
      expect(encoded, testUserJson);
    });

    test('decode converts JSON string to object', () {
      final decoded = adapter.decode(testUserJson);
      expect(decoded, testUser);
    });

    test('decode returns null for null input', () {
      expect(adapter.decode(null), isNull);
    });

    test('decode returns null for invalid JSON', () {
      expect(adapter.decode('{invalid json}'), isNull);
    });

    test('decode returns null for valid JSON with wrong structure', () {
      expect(adapter.decode('{"not_a_user": true}'), isNull);
    });

    test('getter returns null when no value exists', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_user');
      expect(result, isNull);
    });

    test('getter returns object when value exists', () async {
      final (preferences, store) = getPreferences();
      await store.setString(
          'test_user', testUserJson, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_user');
      expect(result, testUser);
    });

    test('setter stores correct JSON string', () async {
      final (preferences, store) = getPreferences();

      await adapter.setter(preferences, 'test_user', testUser);

      final stored =
          await store.getString('test_user', sharedPreferencesOptions);
      expect(stored, testUserJson);
    });

    test('complete round trip: setter followed by getter', () async {
      final (preferences, _) = getPreferences();

      await adapter.setter(preferences, 'test_user', testUser);
      final result = await adapter.getter(preferences, 'test_user');

      expect(result, testUser);
    });
  });
}
