import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

void main() {
  const testKey = 'test_periodic_counter';

  group('PrfPeriodicCounter', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    setUp(() async {
      PrfService.resetOverride();
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);
      final counter = PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);
      await counter.clear();
    });

    test('starts at 0 on first use', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);
      expect(await counter.get(), 0);
    });

    test('increments correctly with default amount', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);
      expect(await counter.increment(), 1);
      expect(await counter.increment(), 2);
    });

    test('increment by custom amount', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);
      expect(await counter.increment(5), 5);
      expect(await counter.increment(2), 7);
    });

    test('resets after aligned period passes (manually injected date)',
        () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);
      await counter.increment(); // 1

      final old = DateTime.now().subtract(const Duration(days: 3));
      await counter.lastUpdate.set(old);

      final result = await counter.get(); // should auto-reset
      expect(result, 0);
    });

    test('reset aligns timestamp exactly to period', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);
      await counter.increment();
      await counter.reset();

      final aligned = TrackerPeriod.daily.alignedStart(DateTime.now());
      final last = await counter.lastUpdate.get();

      expect(last, isNotNull);
      expect(last!.difference(aligned).inSeconds.abs(), lessThan(2));
    });

    test('hasState returns true after increment', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);
      expect(await counter.hasState(), isFalse);
      await counter.increment();
      expect(await counter.hasState(), isTrue);
    });

    test('clear removes all state from preferences', () async {
      final (prefs, store) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);
      await counter.increment();
      expect(await counter.hasState(), isTrue);
      await counter.clear();
      expect(await counter.hasState(), isFalse);

      final keys = await store.getKeys(
        const GetPreferencesParameters(filter: PreferencesFilters()),
        const SharedPreferencesOptions(),
      );
      expect(keys.any((k) => k.contains(testKey)), isFalse);
    });

    test('state is preserved across instances', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      {
        final counter =
            PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);
        await counter.increment(); // 1
      }

      {
        final counter =
            PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);
        expect(await counter.get(), 1); // persists across instances
      }
    });

    test('different keys are isolated', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final c1 = PrfPeriodicCounter('c1', period: TrackerPeriod.daily);
      final c2 = PrfPeriodicCounter('c2', period: TrackerPeriod.daily);

      await c1.increment();
      await c1.increment();
      await c2.increment();

      expect(await c1.get(), 2);
      expect(await c2.get(), 1);
    });

    test('aligned period math works across TrackerPeriod options', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final periods = [
        TrackerPeriod.minutes5,
        TrackerPeriod.minutes10,
        TrackerPeriod.hourly,
        TrackerPeriod.daily,
      ];

      for (final period in periods) {
        final counter =
            PrfPeriodicCounter('period_${period.name}', period: period);
        await counter.increment();
        final aligned = period.alignedStart(DateTime.now());
        final stamp = await counter.lastUpdate.get();
        expect(stamp, isNotNull);
        expect(stamp!.difference(aligned).inSeconds.abs(), lessThan(2));
      }
    });

    test('fallback logic returns 0 if nothing stored', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);
      final counter =
          PrfPeriodicCounter('no_state', period: TrackerPeriod.daily);
      expect(await counter.get(), 0);
    });

    test('exposes correct currentPeriodStart and nextPeriodStart', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final now = DateTime.now();
      final counter = PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);

      final aligned = TrackerPeriod.daily.alignedStart(now);
      final nextAligned = aligned.add(TrackerPeriod.daily.duration);

      expect(counter.currentPeriodStart.difference(aligned).inSeconds.abs(),
          lessThan(2));
      expect(counter.nextPeriodStart.difference(nextAligned).inSeconds.abs(),
          lessThan(2));
    });

    test('timeUntilNextPeriod is within expected bounds', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);
      final remaining = counter.timeUntilNextPeriod;

      expect(remaining, greaterThan(Duration.zero));
      expect(remaining, lessThanOrEqualTo(TrackerPeriod.daily.duration));
    });

    test('elapsedInCurrentPeriod is less than full duration', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);
      final elapsed = counter.elapsedInCurrentPeriod;

      expect(elapsed, greaterThanOrEqualTo(Duration.zero));
      expect(elapsed, lessThanOrEqualTo(TrackerPeriod.daily.duration));
    });

    test('percentElapsed is within 0.0 to 1.0', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = PrfPeriodicCounter(testKey, period: TrackerPeriod.daily);
      final percent = counter.percentElapsed;

      expect(percent, inInclusiveRange(0.0, 1.0));
    });
  });
}
