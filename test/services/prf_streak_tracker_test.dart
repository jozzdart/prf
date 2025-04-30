import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../utils/fake_prefs.dart';

void main() {
  const testKey = 'test_streak_tracker';

  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  group('PrfStreakTracker', () {
    setUp(() async {
      PrfService.resetOverride();
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);
      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      await tracker.clear();
    });

    test('starts at 0 on first use', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      expect(await tracker.get(), 0);
    });

    test('first bump returns 1', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      expect(await tracker.bump(), 1);
    });

    test('bump by custom amount', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      expect(await tracker.bump(3), 3);
      expect(await tracker.bump(2), 5);
    });

    test('streak persists if within same period', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      await tracker.bump();
      expect(await tracker.bump(), 2);
    });

    test('streak resets after expiration', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      await tracker.bump();

      final old = DateTime.now().subtract(Duration(days: 3));
      await tracker.lastUpdate.set(old);

      expect(await tracker.bump(), 1); // reset to 0, then +1
    });

    test('peek returns current value without reset', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      await tracker.bump(2);
      expect(await tracker.peek(), 2);
    });

    test('isStreakBroken returns true after long delay', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      final old = DateTime.now().subtract(Duration(days: 3));
      await tracker.lastUpdate.set(old);

      expect(await tracker.isStreakBroken(), isTrue);
    });

    test('isStreakBroken returns false when streak is alive', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      await tracker.bump();
      expect(await tracker.isStreakBroken(), isFalse);
    });

    test('streakAge returns non-null after bump', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      await tracker.bump();
      final age = await tracker.streakAge();
      expect(age, isNotNull);
      expect(age!.inSeconds, greaterThanOrEqualTo(0));
    });

    test('currentStreak reflects correct value', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      await tracker.bump(5);
      expect(await tracker.currentStreak(), 5);
    });

    test('nextResetTime returns valid future time', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      await tracker.bump();
      final next = await tracker.nextResetTime();
      expect(next!.isAfter(DateTime.now()), isTrue);
    });

    test('percentRemaining is non-null and between 0.0 and 1.0 after bump',
        () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      await tracker.bump();
      final percent = await tracker.percentRemaining();

      expect(percent, isNotNull);
      expect(percent, inInclusiveRange(0.0, 1.0));
    });

    test('percentRemaining near 0 before reset threshold', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      await tracker.bump();

      final justBeforeBreak =
          DateTime.now().subtract(Duration(days: 1, hours: 23));
      await tracker.lastUpdate.set(justBeforeBreak);

      final percent = await tracker.percentRemaining();
      expect(percent, lessThan(0.2));
    });

    test('clear resets everything', () async {
      final (prefs, store) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      await tracker.bump();
      await tracker.clear();

      final keys = await store.getKeys(
        const GetPreferencesParameters(filter: PreferencesFilters()),
        const SharedPreferencesOptions(),
      );
      expect(keys.any((k) => k.contains(testKey)), isFalse);
    });

    test('hasState returns true after bump', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      expect(await tracker.hasState(), isFalse);
      await tracker.bump();
      expect(await tracker.hasState(), isTrue);
    });

    test('reset clears value and last update', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      await tracker.bump();
      await tracker.reset();

      expect(await tracker.get(), 0);
      expect(await tracker.getLastUpdateTime(), isNull);
    });

    test('multiple trackers are isolated', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final t1 = PrfStreakTracker('t1', period: TrackerPeriod.daily);
      final t2 = PrfStreakTracker('t2', period: TrackerPeriod.daily);

      await t1.bump();
      await t2.bump(3);

      expect(await t1.get(), 1);
      expect(await t2.get(), 3);
    });

    test('percentRemaining is ~1.0 at aligned start using injected now',
        () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final tracker = PrfStreakTracker(testKey, period: TrackerPeriod.daily);
      final fakeNow = DateTime(2024, 1, 1, 0, 0, 0); // exact aligned time
      final aligned = TrackerPeriod.daily.alignedStart(fakeNow);

      await tracker.lastUpdate.set(aligned);
      await tracker.value.set(1);

      final percent = await tracker.percentRemainingAt(fakeNow);
      expect(percent, closeTo(1.0, 0.0001));
    });
  });
}

extension PrfStreakTrackerTestExt on PrfStreakTracker {
  Future<double?> percentRemainingAt(DateTime now) async {
    final last = await lastUpdate.get();
    if (last == null) return null;
    final end = period.alignedStart(last).add(period.duration * 2);
    final total = period.duration * 2;
    final remaining = end.difference(now);
    return remaining.inMilliseconds.clamp(0, total.inMilliseconds) /
        total.inMilliseconds;
  }
}
