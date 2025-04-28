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

  group('DurationAdapter', () {
    const adapter = DurationAdapter();

    test('decode returns null when stored value is null', () {
      expect(adapter.decode(null), isNull);
    });

    test('decode reconstructs Duration from stored microseconds', () {
      final duration = adapter.decode(1500000);
      expect(duration, Duration(microseconds: 1500000));
    });

    test('encode converts Duration to microseconds', () {
      final stored = adapter.encode(Duration(seconds: 2, milliseconds: 500));
      expect(stored, 2500000);
    });

    test('getter returns null when no value exists', () async {
      final (preferences, _) = getPreferences();
      final result = await adapter.getter(preferences, 'test_duration');
      expect(result, isNull);
    });

    test('getter returns correct Duration when value exists', () async {
      final (preferences, store) = getPreferences();
      await store.setInt('test_duration', 3000000, sharedPreferencesOptions);

      final result = await adapter.getter(preferences, 'test_duration');
      expect(result, Duration(microseconds: 3000000));
    });

    test('setter stores Duration correctly as int', () async {
      final (preferences, store) = getPreferences();
      final duration = Duration(
          minutes: 2, seconds: 30); // 150 seconds → 150000000 microseconds

      await adapter.setter(preferences, 'test_duration', duration);

      final stored =
          await store.getInt('test_duration', sharedPreferencesOptions);
      expect(stored, duration.inMicroseconds);
    });

    test('complete round trip: setter followed by getter', () async {
      final (preferences, _) = getPreferences();
      final original = Duration(hours: 1, minutes: 15, seconds: 42);

      await adapter.setter(preferences, 'test_duration', original);
      final result = await adapter.getter(preferences, 'test_duration');

      expect(result, original);
    });
  });
}
