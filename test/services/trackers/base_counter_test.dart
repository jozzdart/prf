import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../utils/fake_prefs.dart';

class TestCounterTracker extends BaseCounterTracker {
  TestCounterTracker(super.key) : super(suffix: 'test');

  @override
  bool isExpired(DateTime now, DateTime? last) =>
      last == null || now.difference(last) >= Duration(seconds: 1);

  @override
  Future<void> reset() async {
    await Future.wait([
      value.set(0),
      lastUpdate.set(DateTime.now()),
    ]);
  }
}

void main() {
  const testPrefix = 'test_counter';

  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final prefs = SharedPreferencesAsync();
    return (prefs, store);
  }

  setUp(() async {
    PrfService.resetOverride();
    final (prefs, _) = getPreferences();
    PrfService.overrideWith(prefs);
    final tracker = TestCounterTracker(testPrefix);
    await tracker.clear();
  });

  test('initializes to 0', () async {
    final tracker = TestCounterTracker(testPrefix);

    // Before any access, should have no state
    expect(await tracker.hasState(), isFalse);

    final value = await tracker.get();
    expect(value, 0);

    // After get() (which may reset), should have state
    expect(await tracker.hasState(), isTrue);
  });

  test('increments by default amount (1)', () async {
    final tracker = TestCounterTracker(testPrefix);
    final result = await tracker.increment();
    expect(result, 1);
    expect(await tracker.get(), 1);
    expect(await tracker.hasState(), isTrue);
  });

  test('increments by custom amount', () async {
    final tracker = TestCounterTracker(testPrefix);
    final result = await tracker.increment(5);
    expect(result, 5);
    expect(await tracker.get(), 5);
  });

  test('resets back to 0', () async {
    final tracker = TestCounterTracker(testPrefix);
    await tracker.increment(10);
    await tracker.reset();
    expect(await tracker.get(), 0);
  });

  test('clear removes all state', () async {
    final tracker = TestCounterTracker(testPrefix);
    await tracker.increment();
    expect(await tracker.hasState(), isTrue);
    await tracker.clear();
    expect(await tracker.hasState(), isFalse);
  });

  test('multiple increments accumulate correctly', () async {
    final tracker = TestCounterTracker(testPrefix);
    await tracker.increment(2);
    await tracker.increment(3);
    expect(await tracker.get(), 5);
  });

  test('auto-reset occurs after expiration', () async {
    final tracker = TestCounterTracker(testPrefix);
    await tracker.increment(3);
    final beforeReset = await tracker.get();
    expect(beforeReset, 3);

    await Future.delayed(Duration(seconds: 2));
    final afterReset = await tracker.get();
    expect(afterReset, 0); // reset due to expiration
  });

  test('lastUpdate timestamp is updated on reset', () async {
    final tracker = TestCounterTracker(testPrefix);
    await tracker.increment(2);
    final firstTime = await tracker.lastUpdate.get();
    expect(firstTime, isNotNull);

    await Future.delayed(Duration(milliseconds: 50));
    await tracker.reset();
    final secondTime = await tracker.lastUpdate.get();
    expect(secondTime!.isAfter(firstTime!), isTrue);
  });

  test('get after clear returns 0 again', () async {
    final tracker = TestCounterTracker(testPrefix);
    await tracker.increment(7);
    await tracker.clear();
    expect(await tracker.get(), 0);
  });

  test('separate instances use isolated keys', () async {
    final a = TestCounterTracker('counter_a');
    final b = TestCounterTracker('counter_b');

    await a.increment(5);
    await b.increment(2);

    expect(await a.get(), 5);
    expect(await b.get(), 2);
  });

  test('hasState returns true only after data is written', () async {
    final tracker = TestCounterTracker(testPrefix);
    expect(await tracker.hasState(), isFalse);
    await tracker.increment();
    expect(await tracker.hasState(), isTrue);
    await tracker.clear();
    expect(await tracker.hasState(), isFalse);
  });

  test('peek returns value without triggering reset', () async {
    final tracker = TestCounterTracker(testPrefix);
    await tracker.increment(3);
    final peeked = await tracker.peek();
    expect(peeked, 3);
    expect(await tracker.get(), 3);
  });

  test('raw returns current persisted value', () async {
    final tracker = TestCounterTracker(testPrefix);
    await tracker.increment(4);
    final rawValue = await tracker.raw();
    expect(rawValue, 4);
  });

  test('isNonZero returns correct value', () async {
    final tracker = TestCounterTracker(testPrefix);
    expect(await tracker.isNonZero(), isFalse);
    await tracker.increment();
    expect(await tracker.isNonZero(), isTrue);
  });

  test('clearValueOnly resets value but preserves lastUpdate', () async {
    final tracker = TestCounterTracker(testPrefix);
    await tracker.increment(9);
    final timeBefore = await tracker.lastUpdate.get();
    await tracker.clearValueOnly();

    expect(await tracker.raw(), 0);
    final timeAfter = await tracker.lastUpdate.get();
    expect(timeAfter, timeBefore);
  });

  test('getLastUpdateTime returns correct value', () async {
    final tracker = TestCounterTracker(testPrefix);
    expect(await tracker.getLastUpdateTime(), isNull);
    await tracker.increment();
    final last = await tracker.getLastUpdateTime();
    expect(last, isA<DateTime>());
  });

  test('timeSinceLastUpdate returns null if never updated', () async {
    final tracker = TestCounterTracker(testPrefix);
    expect(await tracker.timeSinceLastUpdate(), isNull);
    await tracker.increment();
    final since = await tracker.timeSinceLastUpdate();
    expect(since, isA<Duration>());
    expect(since!.inMilliseconds, greaterThanOrEqualTo(0));
  });

  test('isCurrentlyExpired returns true/false appropriately', () async {
    final tracker = TestCounterTracker(testPrefix);
    expect(await tracker.isCurrentlyExpired(), isTrue);
    await tracker.increment();
    expect(await tracker.isCurrentlyExpired(), isFalse);
    await Future.delayed(Duration(seconds: 2));
    expect(await tracker.isCurrentlyExpired(), isTrue);
  });
}
