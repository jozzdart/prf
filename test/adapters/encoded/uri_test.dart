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

  group('UriAdapter', () {
    const adapter = UriAdapter();

    test('getter returns null when no value exists', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_uri');
      expect(result, isNull);
    });

    test('getter returns Uri when valid string exists', () async {
      final (preferences, store) = getPreferences();
      await store.setString(
          'test_uri', 'https://example.com', sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_uri');
      expect(result, isA<Uri>());
      expect(result.toString(), 'https://example.com');
    });

    test('getter parses weird URI strings and encodes properly', () async {
      final (preferences, store) = getPreferences();
      await store.setString(
          'test_uri', '%%%invalid_uri', sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_uri');
      expect(result, isNotNull);
      expect(result.toString(), '%25%25%25invalid_uri'); // <- fixed expectation
    });

    test('setter stores Uri as string correctly', () async {
      final (preferences, store) = getPreferences();
      final uri = Uri.parse('https://dart.dev');

      await adapter.setter(preferences, 'test_uri', uri);

      final stored =
          await store.getString('test_uri', sharedPreferencesOptions);
      expect(stored, 'https://dart.dev');
    });

    test('complete round-trip: setter then getter', () async {
      final (preferences, _) = getPreferences();
      final originalUri = Uri.parse('https://flutter.dev/path?q=123');

      await adapter.setter(preferences, 'test_uri', originalUri);
      final result = await adapter.getter(preferences, 'test_uri');

      expect(result, originalUri);
    });

    test('decode returns null when given null', () {
      expect(adapter.decode(null), isNull);
    });

    test('encode returns correct string', () {
      final uri = Uri.parse('https://openai.com/');
      final result = adapter.encode(uri);
      expect(result, 'https://openai.com/');
    });

    test('decode correctly parses well-formed string', () {
      final str = 'https://openai.com/research';
      final result = adapter.decode(str);
      expect(result, isA<Uri>());
      expect(result.toString(), str);
    });

    test('decode parses weird string safely', () {
      final str = 'weird://uri?with=oddities';
      final result = adapter.decode(str);
      expect(result, isA<Uri>());
      expect(result.toString(), str);
    });
  });
}
