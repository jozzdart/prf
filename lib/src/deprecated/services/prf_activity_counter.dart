import 'package:synchronized/synchronized.dart';

import '../../prf.dart';

/// A utility class for tracking user activity over time across various spans
/// such as hour, day, month, and year. It provides persistent storage and
/// retrieval of activity data, making it suitable for usage statistics,
/// trend analysis, and generating long-term activity reports.
@Deprecated(
    'PrfActivityCounter has been moved to the track package. Please update your imports to use the new package.')
class PrfActivityCounter extends BaseServiceObject {
  static const _keyPrefix = 'prf';
  static const int _baseYear = 2000;

  static const int _monthsInYear = 13; // index 1..12
  static const int _daysInMonth = 32; // index 1..31
  static const int _hoursInDay = 24;

  final Lock _lock = Lock();
  final DateTime Function() _clock;

  final Map<ActivitySpan, Prf<List<int>>> _data;

  /// Creates a new instance of [PrfActivityCounter] with the given [key].
  ///
  /// The [useCache] parameter determines whether to use cached values for
  /// performance optimization. The [clock] parameter allows for custom
  /// time sources, defaulting to [DateTime.now].
  PrfActivityCounter(
    String key, {
    super.useCache,
    DateTime Function()? clock,
  })  : _clock = clock ?? DateTime.now,
        _data = {
          for (final span in ActivitySpan.values)
            span: Prf<List<int>>('${_keyPrefix}_${key}_${span.keySuffix}')
        };

  // -------------------------------------------
  // Convenience Getters
  // -------------------------------------------

  /// Returns the activity count for the current hour.
  Future<int> get thisHour => amountThis(ActivitySpan.hour);

  /// Returns the activity count for the current day.
  Future<int> get today => amountThis(ActivitySpan.day);

  /// Returns the activity count for the current month.
  Future<int> get thisMonth => amountThis(ActivitySpan.month);

  /// Returns the activity count for the current year.
  Future<int> get thisYear => amountThis(ActivitySpan.year);

  // -------------------------------------------
  // Core Methods
  // -------------------------------------------

  /// Increments the activity count by 1 for the current time bucket.
  Future<void> increment() => add(1);

  /// Adds the specified [amount] to the current time bucket across all spans.
  Future<void> add(int amount) async {
    final now = _clock();
    await _lock.synchronized(() async {
      for (final span in ActivitySpan.values) {
        final info = span.info(now);
        final prf = _data[span]!;
        final list = await _getListOrDefault(prf, info.minLength);
        list[info.index] += amount;
        await prf.set(list);
      }
    });
  }

  /// Returns the activity count for the current time in the specified [span].
  Future<int> amountThis(ActivitySpan span) {
    final now = _clock();
    return _getSafe(_data[span]!, span.info(now).index);
  }

  /// Returns the activity count for the specified [date] in the given [span].
  Future<int> amountFor(ActivitySpan span, DateTime date) {
    return _getSafe(_data[span]!, span.info(date).index);
  }

  /// Returns a summary map of activity counts for all spans at the current time.
  Future<Map<ActivitySpan, int>> summary() async {
    return {
      for (final span in ActivitySpan.values) span: await amountThis(span),
    };
  }

  // -------------------------------------------
  // Utilities
  // -------------------------------------------

  /// Returns the total sum of all recorded entries in the specified [span].
  Future<int> total(ActivitySpan span) async {
    final list = await _getList(_data[span]!);
    return list.fold<int>(0, (sum, e) => sum + e);
  }

  /// Returns a map of non-zero entries for the specified [span].
  Future<Map<int, int>> all(ActivitySpan span) async {
    final list = await _getList(_data[span]!);
    final result = <int, int>{};
    for (var i = 0; i < list.length; i++) {
      if (list[i] != 0) result[i] = list[i];
    }
    return result;
  }

  /// Returns the largest value ever recorded for the specified [span].
  Future<int> maxValue(ActivitySpan span) async {
    final map = await all(span);
    return map.values.fold<int>(0, (max, e) => e > max ? e : max);
  }

  /// Returns `true` if any activity has ever been recorded.
  Future<bool> hasAnyData() async {
    for (final span in ActivitySpan.values) {
      if (await total(span) > 0) return true;
    }
    return false;
  }

  /// Returns a list of `DateTime` objects where any activity was tracked for the specified [span].
  Future<List<DateTime>> activeDates(ActivitySpan span) async {
    final keys = await all(span);
    final now = _clock();
    return [for (final i in keys.keys) span.dateFromIndex(now, i)];
  }

  // -------------------------------------------
  // Reset and Cleanup
  // -------------------------------------------

  /// Clears all data in the specified [span].
  Future<void> clear(ActivitySpan span) => _data[span]!.set([]);

  /// Clears data for multiple spans specified in [spans].
  Future<void> clearAllKnown(List<ActivitySpan> spans) async {
    await _lock.synchronized(() async {
      for (final span in spans) {
        await clear(span);
      }
    });
  }

  /// Clears all data across all spans.
  Future<void> reset() => clearAllKnown(ActivitySpan.values);

  /// Permanently deletes all stored data for this counter.
  Future<void> removeAll() async {
    await _lock.synchronized(() async {
      for (final span in ActivitySpan.values) {
        await _data[span]!.remove();
      }
    });
  }

  // -------------------------------------------
  // Internal Helpers
  // -------------------------------------------

  Future<int> _getSafe(Prf<List<int>> prf, int index) async {
    final list = await _getList(prf);
    if (index < 0 || index >= list.length) return 0;
    return list[index];
  }

  Future<List<int>> _getList(Prf<List<int>> prf) async {
    return await (useCache ? prf : prf.isolated).get() ?? const [];
  }

  Future<List<int>> _getListOrDefault(Prf<List<int>> prf, int minLength) async {
    final list = await _getList(prf);
    return list.length >= minLength
        ? list
        : [...list, ...List.filled(minLength - list.length, 0)];
  }
}

// -------------------------------------------
// Span Metadata
// -------------------------------------------

/// Enum representing the different spans of activity tracking.
@Deprecated(
    'ActivitySpan has been moved to the track package. Please update your imports to use the new package.')
enum ActivitySpan { year, month, day, hour }

@Deprecated(
    'This extension on ActivitySpan has been moved to the track package. Please update your imports to use the new package.')
extension on ActivitySpan {
  /// Returns the key suffix for the span.
  String get keySuffix => switch (this) {
        ActivitySpan.year => 'year',
        ActivitySpan.month => 'month',
        ActivitySpan.day => 'day',
        ActivitySpan.hour => 'hour',
      };

  /// Returns span information for the given [date].
  _SpanInfo info(DateTime date) => switch (this) {
        ActivitySpan.year =>
          _SpanInfo(date.year - PrfActivityCounter._baseYear, date.year + 1),
        ActivitySpan.month =>
          _SpanInfo(date.month, PrfActivityCounter._monthsInYear),
        ActivitySpan.day =>
          _SpanInfo(date.day, PrfActivityCounter._daysInMonth),
        ActivitySpan.hour =>
          _SpanInfo(date.hour, PrfActivityCounter._hoursInDay),
      };

  /// Returns a `DateTime` object from the given [base] date and index [i].
  DateTime dateFromIndex(DateTime base, int i) => switch (this) {
        ActivitySpan.year => DateTime(PrfActivityCounter._baseYear + i),
        ActivitySpan.month => DateTime(base.year, i),
        ActivitySpan.day => DateTime(base.year, base.month, i),
        ActivitySpan.hour => DateTime(base.year, base.month, base.day, i),
      };
}

/// A helper class containing span information.
class _SpanInfo {
  final int index;
  final int minLength;

  const _SpanInfo(this.index, this.minLength);
}
