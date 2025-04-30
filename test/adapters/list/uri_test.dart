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

  group('UriListAdapter', () {
    const adapter = UriListAdapter();

    test('getter returns null when no value', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_uri_list');
      expect(result, isNull);
    });

    test('getter returns empty list when stored empty', () async {
      final (preferences, store) = getPreferences();
      final encoded = adapter.encode([]);
      await store.setStringList(
        'test_uri_list',
        encoded,
        sharedPreferencesOptions,
      );

      final result = await adapter.getter(preferences, 'test_uri_list');
      expect(result, isEmpty);
    });

    test('getter returns correct list when stored properly', () async {
      final (preferences, store) = getPreferences();
      final testList = [
        Uri.parse('https://example.com'),
        Uri.parse('https://openai.com'),
        Uri.parse('mailto:test@example.org')
      ];
      final encoded = adapter.encode(testList);
      await store.setStringList(
        'test_uri_list',
        encoded,
        sharedPreferencesOptions,
      );

      final result = await adapter.getter(preferences, 'test_uri_list');
      expect(result, testList);
    });

    test('getter returns null if any Uri is invalid', () async {
      final (preferences, store) = getPreferences();
      final corrupted = [
        'https://example.com',
        '🤷‍♂️not_a_uri',
        'https://valid.com'
      ];
      await store.setStringList(
        'test_uri_list',
        corrupted,
        sharedPreferencesOptions,
      );

      final result = await adapter.getter(preferences, 'test_uri_list');
      expect(result, isNotNull);
    });

    test('setter stores URI list correctly', () async {
      final (preferences, store) = getPreferences();
      final testList = [
        Uri.parse('https://dart.dev'),
        Uri.parse('https://pub.dev'),
        Uri.parse('customscheme://hello/world')
      ];

      await adapter.setter(preferences, 'test_uri_list', testList);
      final stored = await store.getStringList(
        'test_uri_list',
        sharedPreferencesOptions,
      );

      expect(stored, adapter.encode(testList));
    });

    test('round trip: setter followed by getter returns original list',
        () async {
      final (preferences, _) = getPreferences();
      final testList = [
        Uri.parse('https://flutter.dev'),
        Uri.parse('tel:+123456789'),
        Uri.parse('file:///some/path')
      ];

      await adapter.setter(preferences, 'test_uri_list', testList);
      final result = await adapter.getter(preferences, 'test_uri_list');

      expect(result, testList);
    });

    test('encode produces string representation of Uris', () {
      final list = [
        Uri.parse('https://google.com'),
        Uri.parse('ftp://files.com/resource'),
      ];
      final encoded = adapter.encode(list);
      expect(encoded, equals(list.map((u) => u.toString()).toList()));
    });

    test('decode parses string list into Uri list', () {
      final encoded = [
        'https://a.com',
        'mailto:me@example.com',
        'custom://path/to/resource'
      ];
      final expected = encoded.map(Uri.parse).toList();
      final result = adapter.decode(encoded);
      expect(result, expected);
    });

    test('getter returns null if list contains empty string', () async {
      final (preferences, store) = getPreferences();
      final corrupted = ['https://valid.com', '', 'https://also-valid.com'];
      await store.setStringList(
        'test_uri_list',
        corrupted,
        sharedPreferencesOptions,
      );

      final result = await adapter.getter(preferences, 'test_uri_list');
      expect(result, isNotNull);
    });

    test('decode preserves duplicate URIs in list', () {
      final list = [
        Uri.parse('https://repeat.com'),
        Uri.parse('https://repeat.com'),
        Uri.parse('https://repeat.com'),
      ];
      final encoded = adapter.encode(list);
      final decoded = adapter.decode(encoded);
      expect(decoded, list);
    });

    test('round trip works with Unicode and percent-encoded URIs', () async {
      final (preferences, _) = getPreferences();
      final testList = [
        Uri.parse('https://example.com/שלום'),
        Uri.parse('https://domain.com/search?q=café'),
        Uri.parse('https://test.com/٪20'), // percent-encoded space
      ];

      await adapter.setter(preferences, 'test_uri_list', testList);
      final result = await adapter.getter(preferences, 'test_uri_list');

      expect(result, testList);
    });

    test('round trip for empty list returns empty list', () {
      final original = <Uri>[];
      final encoded = adapter.encode(original);
      final decoded = adapter.decode(encoded);
      expect(decoded, isEmpty);
    });
  });
}
