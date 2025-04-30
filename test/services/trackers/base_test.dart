import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../utils/fake_prefs.dart';

class TestIntTracker extends BaseTracker<int> {
  int resetCount = 0;

  TestIntTracker(super.key, {super.useCache}) : super(suffix: 'test');

  @override
  bool isExpired(DateTime now, DateTime? last) =>
      last == null || now.difference(last).inSeconds >= 1;

  @override
  Future<void> reset() async {
    resetCount++;
    await Future.wait([
      value.set(0),
      lastUpdate.set(DateTime.now()),
    ]);
  }

  @override
  int fallbackValue() => -1;
}

void main() {
  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final prefs = SharedPreferencesAsync();
    return (prefs, store);
  }

  group('BaseTracker', () {
    setUp(() {
      PrfService.resetOverride();
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);
    });

    test('returns reset value if state does not exist', () async {
      final tracker = TestIntTracker('tracker_no_state');
      final value = await tracker.get();

      expect(value, equals(0));
      expect(tracker.resetCount, equals(1));
    });

    test('returns existing value if update is recent', () async {
      final tracker = TestIntTracker('tracker_fresh');
      await tracker.value.set(77);
      await tracker.lastUpdate.set(DateTime.now());

      final result = await tracker.get();
      expect(result, equals(77));
      expect(tracker.resetCount, equals(0));
    });

    test('resets if timestamp is expired', () async {
      final tracker = TestIntTracker('tracker_expired');
      await tracker.value.set(123);
      await tracker.lastUpdate
          .set(DateTime.now().subtract(Duration(seconds: 2)));

      final result = await tracker.get();
      expect(result, equals(0));
      expect(tracker.resetCount, equals(1));
    });

    test('clear() removes both value and timestamp', () async {
      final tracker = TestIntTracker('tracker_clear');
      await tracker.value.set(88);
      await tracker.lastUpdate.set(DateTime.now());

      expect(await tracker.hasState(), isTrue);
      await tracker.clear();
      expect(await tracker.hasState(), isFalse);
    });

    test('reset() updates value and timestamp and increments counter',
        () async {
      final tracker = TestIntTracker('tracker_reset_direct');

      expect(tracker.resetCount, equals(0));
      await tracker.reset();

      expect(await tracker.value.get(), equals(0));
      expect(await tracker.lastUpdate.get(), isA<DateTime>());
      expect(tracker.resetCount, equals(1));
    });

    test('get() returns fallback if no reset occurs but value is null',
        () async {
      final tracker = TestIntTracker('tracker_null_but_fresh');
      await tracker.lastUpdate.set(DateTime.now());

      final result = await tracker.get();
      expect(result, equals(-1)); // fallback value
      expect(tracker.resetCount, equals(0));
    });

    test('multiple instances with different keys are isolated', () async {
      final tracker1 = TestIntTracker('tracker_1');
      final tracker2 = TestIntTracker('tracker_2');

      await tracker1.value.set(111);
      await tracker1.lastUpdate.set(DateTime.now());

      await tracker2.value.set(222);
      await tracker2.lastUpdate.set(DateTime.now());

      final value1 = await tracker1.get();
      final value2 = await tracker2.get();

      expect(value1, 111);
      expect(value2, 222);
      expect(value1 != value2, isTrue);
    });

    test('tracker behaves deterministically within short window', () async {
      final tracker = TestIntTracker('tracker_deterministic');
      await tracker.value.set(50);
      await tracker.lastUpdate.set(DateTime.now());

      final first = await tracker.get();
      final second = await tracker.get();
      expect(first, second);
      expect(tracker.resetCount, 0);
    });

    // === NEW UTILITIES ===

    test('isCurrentlyExpired returns true if expired', () async {
      final tracker = TestIntTracker('tracker_expired_check');
      await tracker.lastUpdate
          .set(DateTime.now().subtract(Duration(seconds: 2)));

      final expired = await tracker.isCurrentlyExpired();
      expect(expired, isTrue);
    });

    test('isCurrentlyExpired returns false if not expired', () async {
      final tracker = TestIntTracker('tracker_not_expired_check');
      await tracker.lastUpdate.set(DateTime.now());

      final expired = await tracker.isCurrentlyExpired();
      expect(expired, isFalse);
    });

    test('getLastUpdateTime returns null when never updated', () async {
      final tracker = TestIntTracker('tracker_last_time_null');
      expect(await tracker.getLastUpdateTime(), isNull);
    });

    test('getLastUpdateTime returns correct DateTime', () async {
      final tracker = TestIntTracker('tracker_last_time_exists');
      final now = DateTime.now();
      await tracker.lastUpdate.set(now);

      final stored = await tracker.getLastUpdateTime();
      expect(stored?.difference(now).inMilliseconds.abs(), lessThan(10));
    });

    test('timeSinceLastUpdate returns null if no update stored', () async {
      final tracker = TestIntTracker('tracker_since_null');
      expect(await tracker.timeSinceLastUpdate(), isNull);
    });

    test('timeSinceLastUpdate returns valid duration', () async {
      final tracker = TestIntTracker('tracker_since_delta');
      final now = DateTime.now().subtract(Duration(seconds: 3));
      await tracker.lastUpdate.set(now);

      final delta = await tracker.timeSinceLastUpdate();
      expect(delta!.inSeconds, greaterThanOrEqualTo(2));
    });

    test('peek returns raw value without resetting or checking expiry',
        () async {
      final tracker = TestIntTracker('tracker_peek');
      await tracker.value.set(42);

      final peeked = await tracker.peek();
      expect(peeked, equals(42));
      expect(tracker.resetCount, 0);
    });

    test(
        'useCache determines whether value and lastUpdate are cached or isolated',
        () async {
      final cachedTracker =
          TestIntTracker('tracker_cache_true', useCache: true);
      final isolatedTracker =
          TestIntTracker('tracker_cache_false', useCache: false);

      expect(cachedTracker.value.runtimeType.toString(), contains('Prf<'));
      expect(cachedTracker.lastUpdate.runtimeType.toString(), contains('Prf<'));

      expect(isolatedTracker.value.runtimeType.toString(), contains('PrfIso<'));
      expect(isolatedTracker.lastUpdate.runtimeType.toString(),
          contains('PrfIso<'));
    });
  });
}
