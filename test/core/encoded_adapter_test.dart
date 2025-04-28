import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../utils/fake_prefs.dart';

// Test implementation that encodes/decodes a Person class to/from a string
class Person {
  final String name;
  final int age;

  Person(this.name, this.age);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Person && other.name == name && other.age == age;
  }

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}

class PersonAdapter extends PrfEncodedAdapter<Person, String> {
  const PersonAdapter() : super(const StringAdapter());

  @override
  String encode(Person value) {
    return '${value.name}|${value.age}';
  }

  @override
  Person? decode(String? stored) {
    if (stored == null) return null;

    final parts = stored.split('|');
    if (parts.length != 2) return null;

    final name = parts[0];
    final age = int.tryParse(parts[1]);
    if (age == null) return null;

    return Person(name, age);
  }
}

void main() {
  group('PrfEncodedAdapter', () {
    const sharedPreferencesOptions = SharedPreferencesOptions();

    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    test('encodes object properly when setting value', () async {
      final (preferences, store) = getPreferences();

      final adapter = PersonAdapter();
      final person = Person('John', 30);

      await adapter.setter(preferences, 'person_key', person);

      final stored =
          await store.getString('person_key', sharedPreferencesOptions);
      expect(stored, 'John|30');
    });

    test('decodes string properly to object when getting value', () async {
      final (preferences, store) = getPreferences();

      final adapter = PersonAdapter();
      await store.setString('person_key', 'Alice|25', sharedPreferencesOptions);

      final person = await adapter.getter(preferences, 'person_key');

      expect(person, isNotNull);
      expect(person?.name, 'Alice');
      expect(person?.age, 25);
    });

    test('returns null when stored value is null', () async {
      final (preferences, _) = getPreferences();

      final adapter = PersonAdapter();
      final person = await adapter.getter(preferences, 'nonexistent_key');

      expect(person, isNull);
    });

    test('returns null when stored value cannot be decoded', () async {
      final (preferences, store) = getPreferences();

      final adapter = PersonAdapter();
      await store.setString(
          'invalid_key', 'invalid_format', sharedPreferencesOptions);

      final person = await adapter.getter(preferences, 'invalid_key');

      expect(person, isNull);
    });

    test('handles numeric parsing failures gracefully', () async {
      final (preferences, store) = getPreferences();

      final adapter = PersonAdapter();
      await store.setString(
          'bad_age', 'Bob|not_a_number', sharedPreferencesOptions);

      final person = await adapter.getter(preferences, 'bad_age');

      expect(person, isNull);
    });
  });
}
