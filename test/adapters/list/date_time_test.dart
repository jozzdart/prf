import 'dart:convert';

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

  group('DateTimeListAdapter', () {
    const adapter = DateTimeListAdapter();

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();

      final result = await adapter.getter(preferences, 'test_dates');
      expect(result, isNull);
    });

    test('getter returns empty list if empty json array stored', () async {
      final (preferences, store) = getPreferences();
      await store.setString('test_dates', '[]', sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_dates');
      expect(result, []);
    });

    test('getter returns decoded list when value exists', () async {
      final (preferences, store) = getPreferences();
      final dates = [
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2021, 2, 2),
        DateTime.utc(2022, 3, 3, 3, 3, 3),
      ];

      // Manually encode using the adapter
      final encoded = adapter.encode(dates);
      await store.setString('test_dates', encoded, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_dates');

      expect(result, isA<List<DateTime>>());
      expect(result!.length, dates.length);

      for (int i = 0; i < dates.length; i++) {
        expect(result[i].toUtc(), dates[i]);
      }
    });

    test('getter returns null if data is invalid', () async {
      final (preferences, store) = getPreferences();

      final badJson = jsonEncode([
        'invalid_base64', // invalid
        DateTime.now().toUtc().microsecondsSinceEpoch.toString(), // not base64
      ]);
      await store.setString('test_dates', badJson, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_dates');
      expect(result, isNull);
    });

    test('setter stores value correctly', () async {
      final (preferences, store) = getPreferences();
      final dates = [
        DateTime.utc(2010, 5, 15),
        DateTime.utc(2015, 7, 20),
      ];

      await adapter.setter(preferences, 'test_dates', dates);

      final stored =
          await store.getString('test_dates', sharedPreferencesOptions);
      expect(stored, isNotNull);

      final decoded = adapter.decode(stored!);
      expect(decoded, isA<List<DateTime>>());
      expect(decoded!.length, dates.length);

      for (int i = 0; i < dates.length; i++) {
        expect(decoded[i].toUtc(), dates[i]);
      }
    });

    test('encode produces valid JSON string of base64 strings', () {
      final now = DateTime.now().toUtc();
      final later = now.add(Duration(days: 1));

      final encoded = adapter.encode([now, later]);
      expect(() => jsonDecode(encoded), returnsNormally);

      final decodedList = jsonDecode(encoded) as List<dynamic>;
      expect(decodedList.length, 2);
      expect(decodedList.every((e) => e is String), true);
    });

    test('decode returns null for invalid json', () {
      final result = adapter.decode('not a json');
      expect(result, isNull);
    });

    test('round trip: encode and decode match', () {
      final dates = [
        DateTime.utc(2000, 1, 1),
        DateTime.utc(2010, 10, 10, 10, 10, 10),
      ];

      final encoded = adapter.encode(dates);
      final decoded = adapter.decode(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.length, dates.length);

      for (int i = 0; i < dates.length; i++) {
        expect(decoded[i].toUtc(), dates[i]);
      }
    });

    test('handles null decode safely', () {
      expect(adapter.decode(null), isNull);
    });

    test('handles null input in encode', () {
      // List<DateTime> cannot be null here; but empty list can be encoded safely
      final encoded = adapter.encode([]);
      expect(encoded, jsonEncode([]));
    });
  });
}
