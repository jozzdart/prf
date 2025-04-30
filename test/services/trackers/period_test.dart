import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../utils/fake_prefs.dart';

void main() {
  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final SharedPreferencesAsync preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  group('TrackerPeriod', () {
    setUp(() {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);
    });

    test('duration returns expected values', () {
      expect(TrackerPeriod.seconds10.duration, Duration(seconds: 10));
      expect(TrackerPeriod.minutes5.duration, Duration(minutes: 5));
      expect(TrackerPeriod.hourly.duration, Duration(hours: 1));
      expect(TrackerPeriod.daily.duration, Duration(days: 1));
      expect(TrackerPeriod.weekly.duration, Duration(days: 7));
      expect(TrackerPeriod.monthly.duration, Duration(days: 31));
    });

    test('alignedStart aligns correctly for fixed periods', () {
      final now = DateTime(2024, 3, 10, 13, 47, 56);

      expect(
        TrackerPeriod.daily.alignedStart(now),
        DateTime(2024, 3, 10),
      );

      expect(
        TrackerPeriod.weekly.alignedStart(now),
        DateTime(2024, 3, 4),
      );

      expect(
        TrackerPeriod.monthly.alignedStart(now),
        DateTime(2024, 3),
      );
    });

    test('alignedStart aligns correctly for short periods', () {
      final now = DateTime(2024, 3, 10, 13, 47, 56).toUtc();

      final aligned10s = TrackerPeriod.seconds10.alignedStart(now);
      expect(aligned10s.second % 10, 0);
      expect(
          aligned10s.isBefore(now) || aligned10s.isAtSameMomentAs(now), isTrue);

      final aligned5m = TrackerPeriod.minutes5.alignedStart(now);
      expect(aligned5m.minute % 5, 0);
      expect(aligned5m.second, 0);
      expect(
          aligned5m.isBefore(now) || aligned5m.isAtSameMomentAs(now), isTrue);

      final aligned3h = TrackerPeriod.every3Hours.alignedStart(now).toUtc();
      expect(aligned3h.hour % 3, 0);
      expect(aligned3h.minute, 0);
      expect(aligned3h.second, 0);
    });

    test('alignedStart is consistent within same period', () {
      for (final period in TrackerPeriod.values) {
        final base = DateTime(2024, 4, 30, 13, 24, 45);
        final a = period.alignedStart(base);
        final b = period.alignedStart(base.add(Duration(milliseconds: 100)));
        expect(a, b, reason: 'Expected consistent alignment for $period');
      }
    });
  });
}
