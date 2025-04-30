import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:prf/prf.dart';

import '../utils/fake_prefs.dart';

void main() {
  const testKey = 'test_activity_counter';

  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  group('PrfActivityCounter', () {
    setUp(() async {
      PrfService.resetOverride();
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);
    });

    test('starts at 0 for all spans', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12, 15));
      for (final span in ActivitySpan.values) {
        expect(await tracker.amountThis(span), 0);
      }
    });

    test('increment increases all spans by 1', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12, 15));
      await tracker.increment();
      for (final span in ActivitySpan.values) {
        expect(await tracker.amountThis(span), 1);
      }
    });

    test('add by amount works correctly', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12, 15));
      await tracker.add(5);
      for (final span in ActivitySpan.values) {
        expect(await tracker.amountThis(span), 5);
      }
    });

    test('summary returns correct values', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12, 15));
      await tracker.add(3);
      final summary = await tracker.summary();
      for (final span in ActivitySpan.values) {
        expect(summary[span], 3);
      }
    });

    test('add uses correct indices based on clock', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12, 15));
      await tracker.add(2);
      expect(await tracker.amountFor(ActivitySpan.year, DateTime(2024)), 2);
      expect(await tracker.amountFor(ActivitySpan.month, DateTime(2024, 5)), 2);
      expect(
          await tracker.amountFor(ActivitySpan.day, DateTime(2024, 5, 12)), 2);
      expect(
          await tracker.amountFor(ActivitySpan.hour, DateTime(2024, 5, 12, 15)),
          2);
    });

    test('clearAllKnown removes specific data', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12, 15));
      await tracker.add(1);
      await tracker.clearAllKnown([ActivitySpan.year, ActivitySpan.month]);
      expect(await tracker.amountFor(ActivitySpan.year, DateTime(2024)), 0);
      expect(await tracker.amountFor(ActivitySpan.month, DateTime(2024, 5)), 0);
      expect(
          await tracker.amountFor(ActivitySpan.day, DateTime(2024, 5, 12)), 1);
      expect(
          await tracker.amountFor(ActivitySpan.hour, DateTime(2024, 5, 12, 15)),
          1);
    });

    test('adding negative amount decreases values correctly', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12, 15));
      await tracker.add(5);
      await tracker.add(-3);
      for (final span in ActivitySpan.values) {
        expect(await tracker.amountThis(span), 2);
      }
    });

    test('concurrent increments do not interfere', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12, 15));
      await Future.wait(
          [tracker.increment(), tracker.increment(), tracker.increment()]);
      for (final span in ActivitySpan.values) {
        expect(await tracker.amountThis(span), 3);
      }
    });

    test('correct handling of edge dates (new year)', () async {
      final tracker = PrfActivityCounter(testKey,
          clock: () => DateTime(2024, 12, 31, 23, 59));
      await tracker.add(2);
      expect(await tracker.amountFor(ActivitySpan.year, DateTime(2024)), 2);
      expect(
          await tracker.amountFor(ActivitySpan.day, DateTime(2024, 12, 31)), 2);

      final tracker2 =
          PrfActivityCounter(testKey, clock: () => DateTime(2025, 1, 1, 0));
      await tracker2.add(1);
      expect(await tracker2.amountFor(ActivitySpan.year, DateTime(2025)), 1);
    });

    test('handles leap year correctly', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 2, 29));
      await tracker.add(10);
      expect(await tracker.amountFor(ActivitySpan.year, DateTime(2024)), 10);
      expect(
          await tracker.amountFor(ActivitySpan.day, DateTime(2024, 2, 29)), 10);
    });

    test('reset works correctly', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12, 15));
      await tracker.add(5);
      await tracker.reset();
      for (final span in ActivitySpan.values) {
        expect(await tracker.amountThis(span), 0);
      }
    });

    test('handles large values correctly', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12, 15));
      await tracker.add(1000000);
      expect(await tracker.amountThis(ActivitySpan.year), 1000000);
    });

    test('returns 0 for uninitialized values', () async {
      final tracker = PrfActivityCounter(testKey);
      expect(await tracker.amountThis(ActivitySpan.year), 0);
    });

    test('multiple adds are aggregated correctly', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12, 15));
      await tracker.add(3);
      await tracker.add(7);
      expect(await tracker.amountThis(ActivitySpan.year), 10);
    });

    test('returns 0 for out-of-range indices', () async {
      final tracker = PrfActivityCounter(testKey);

      expect(await tracker.amountFor(ActivitySpan.year, DateTime(1999)), 0);
      expect(await tracker.amountFor(ActivitySpan.month, DateTime(2024, 0)),
          0); // invalid month
      expect(await tracker.amountFor(ActivitySpan.day, DateTime(2024, 1, 0)),
          0); // invalid day
      expect(
          await tracker.amountFor(ActivitySpan.hour, DateTime(2024, 1, 1, 25)),
          0); // invalid hour
    });

    test('removeAll wipes all persisted data', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12, 15));
      await tracker.add(42);
      await tracker.removeAll();
      for (final span in ActivitySpan.values) {
        expect(await tracker.amountThis(span), 0);
      }
    });

    test('amountThis and amountFor return same value for now', () async {
      final now = DateTime(2024, 5, 12, 15);
      final tracker = PrfActivityCounter(testKey, clock: () => now);
      await tracker.add(17);
      for (final span in ActivitySpan.values) {
        expect(
            await tracker.amountThis(span), await tracker.amountFor(span, now));
      }
    });

    test('multiple instances track independently by key', () async {
      final trackerA = PrfActivityCounter('counterA',
          clock: () => DateTime(2024, 5, 12, 15));
      final trackerB = PrfActivityCounter('counterB',
          clock: () => DateTime(2024, 5, 12, 15));

      await trackerA.add(3);
      await trackerB.add(5);

      expect(await trackerA.amountThis(ActivitySpan.year), 3);
      expect(await trackerB.amountThis(ActivitySpan.year), 5);
    });

    test('isolated access is consistent with cached', () async {
      final now = DateTime(2024, 5, 12, 15);
      final cached =
          PrfActivityCounter(testKey, clock: () => now, useCache: true);
      final isolated =
          PrfActivityCounter(testKey, clock: () => now, useCache: false);

      await cached.add(4);
      expect(await isolated.amountThis(ActivitySpan.hour), 4);
    });

    test('values for two different days are stored separately', () async {
      final day1 =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 10));
      final day2 =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 11));

      await day1.add(10);
      await day2.add(20);

      expect(await day1.amountFor(ActivitySpan.day, DateTime(2024, 5, 10)), 10);
      expect(await day2.amountFor(ActivitySpan.day, DateTime(2024, 5, 11)), 20);
    });

    test('values for two different days are stored separately', () async {
      final day1 =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 10));
      final day2 =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 11));

      await day1.add(10);
      await day2.add(20);

      expect(await day1.amountFor(ActivitySpan.day, DateTime(2024, 5, 10)), 10);
      expect(await day2.amountFor(ActivitySpan.day, DateTime(2024, 5, 11)), 20);
    });

    test('does not mutate original list when setting new values', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12, 15));
      await tracker.add(1);
      final before = await tracker.amountThis(ActivitySpan.hour);
      await tracker.add(2);
      final after = await tracker.amountThis(ActivitySpan.hour);

      expect(before, 1);
      expect(after, 3);
    });

    test('full flow over multiple days, months, and years', () async {
      final tracker1 =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 12, 30, 23));
      await tracker1.add(10);

      final tracker2 =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 12, 31, 1));
      await tracker2.add(20);

      final tracker3 =
          PrfActivityCounter(testKey, clock: () => DateTime(2025, 1, 1, 0));
      await tracker3.add(30);

      // Check day separation
      expect(await tracker1.amountFor(ActivitySpan.day, DateTime(2024, 12, 30)),
          10);
      expect(await tracker2.amountFor(ActivitySpan.day, DateTime(2024, 12, 31)),
          20);
      expect(
          await tracker3.amountFor(ActivitySpan.day, DateTime(2025, 1, 1)), 30);

      // Check month aggregation
      expect(await tracker1.amountFor(ActivitySpan.month, DateTime(2024, 12)),
          30); // 10 + 20
      expect(
          await tracker3.amountFor(ActivitySpan.month, DateTime(2025, 1)), 30);

      // Check year aggregation
      expect(await tracker3.amountFor(ActivitySpan.year, DateTime(2024)), 30);
      expect(await tracker3.amountFor(ActivitySpan.year, DateTime(2025)), 30);
    });

    test('reset clears values but allows fresh tracking', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 6, 1));
      await tracker.add(50);
      await tracker.reset();
      expect(await tracker.amountThis(ActivitySpan.year), 0);
      await tracker.add(7);
      expect(await tracker.amountThis(ActivitySpan.year), 7);
    });

    test('time travel accumulation over months', () async {
      final may =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 15));
      await may.add(5);

      final june =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 6, 15));
      await june.add(10);

      final july =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 7, 15));
      await july.add(20);

      expect(await july.amountFor(ActivitySpan.month, DateTime(2024, 5)), 5);
      expect(await july.amountFor(ActivitySpan.month, DateTime(2024, 6)), 10);
      expect(await july.amountFor(ActivitySpan.month, DateTime(2024, 7)), 20);
    });

    test('total returns sum of all entries in span', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 12));
      await tracker.add(5);

      final other =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 13));
      await other.add(15);

      expect(await tracker.total(ActivitySpan.day), 20);
    });

    test('all returns correct index-value pairs', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 10));
      await tracker.add(3);

      final tracker2 =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 5, 11));
      await tracker2.add(7);

      final map = await tracker2.all(ActivitySpan.day);
      expect(map[10], 3);
      expect(map[11], 7);
      expect(map.length, 2);
    });

    test('activeDates returns correct DateTime objects', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 6, 5));
      await tracker.add(4);

      final tracker2 =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 6, 6));
      await tracker2.add(2);

      final active = await tracker.activeDates(ActivitySpan.day);
      expect(active.contains(DateTime(2024, 6, 5)), isTrue);
      expect(active.contains(DateTime(2024, 6, 6)), isTrue);
      expect(active.length, 2);
    });

    test('maxValue returns the highest value in span', () async {
      final tracker =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 6, 10));
      await tracker.add(4);
      final tracker2 =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 6, 11));
      await tracker2.add(9);
      final tracker3 =
          PrfActivityCounter(testKey, clock: () => DateTime(2024, 6, 12));
      await tracker3.add(6);

      expect(await tracker.maxValue(ActivitySpan.day), 9);
      expect(await tracker.maxValue(ActivitySpan.month), 19);
    });

    test('hasAnyData returns true only when data exists', () async {
      final tracker = PrfActivityCounter(testKey);
      expect(await tracker.hasAnyData(), isFalse);
      await tracker.add(1);
      expect(await tracker.hasAnyData(), isTrue);
    });

    test('today/thisHour/thisMonth/thisYear getters reflect live value',
        () async {
      final now = DateTime(2024, 5, 12, 14);
      final tracker = PrfActivityCounter(testKey, clock: () => now);

      await tracker.add(3);
      expect(await tracker.today, 3);
      expect(await tracker.thisHour, 3);
      expect(await tracker.thisMonth, 3);
      expect(await tracker.thisYear, 3);
    });
  });
}
