import 'package:prf/prf.dart';
import 'package:synchronized/synchronized.dart';

class PrfActivityCounter extends BaseServiceObject {
  static const _keyPrefix = 'prf';
  static const int _baseYear = 2000;

  static const int _monthsInYear = 13; // index 1..12
  static const int _daysInMonth = 32; // index 1..31
  static const int _hoursInDay = 24;

  final String key;
  final Lock _lock = Lock();
  final DateTime Function() _clock;

  final Map<ActivitySpan, Prf<List<int>>> _data;

  PrfActivityCounter(
    this.key, {
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

  Future<int> get thisHour => amountThis(ActivitySpan.hour);
  Future<int> get today => amountThis(ActivitySpan.day);
  Future<int> get thisMonth => amountThis(ActivitySpan.month);
  Future<int> get thisYear => amountThis(ActivitySpan.year);

  // -------------------------------------------s
  // Core Methods
  // -------------------------------------------

  Future<void> increment() => add(1);

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

  Future<int> amountThis(ActivitySpan span) {
    final now = _clock();
    return _getSafe(_data[span]!, span.info(now).index);
  }

  Future<int> amountFor(ActivitySpan span, DateTime date) {
    return _getSafe(_data[span]!, span.info(date).index);
  }

  Future<Map<ActivitySpan, int>> summary() async {
    return {
      for (final span in ActivitySpan.values) span: await amountThis(span),
    };
  }

  // -------------------------------------------
  // Utilities
  // -------------------------------------------

  Future<int> total(ActivitySpan span) async {
    final list = await _getList(_data[span]!);
    return list.fold<int>(0, (sum, e) => sum + e);
  }

  Future<Map<int, int>> all(ActivitySpan span) async {
    final list = await _getList(_data[span]!);
    final result = <int, int>{};
    for (var i = 0; i < list.length; i++) {
      if (list[i] != 0) result[i] = list[i];
    }
    return result;
  }

  Future<int> maxValue(ActivitySpan span) async {
    final map = await all(span);
    return map.values.fold<int>(0, (max, e) => e > max ? e : max);
  }

  Future<bool> hasAnyData() async {
    for (final span in ActivitySpan.values) {
      if (await total(span) > 0) return true;
    }
    return false;
  }

  Future<List<DateTime>> activeDates(ActivitySpan span) async {
    final keys = await all(span);
    final now = _clock();
    return [for (final i in keys.keys) span.dateFromIndex(now, i)];
  }

  // -------------------------------------------
  // Reset and Cleanup
  // -------------------------------------------

  Future<void> clear(ActivitySpan span) => _data[span]!.set([]);

  Future<void> clearAllKnown(List<ActivitySpan> spans) async {
    await _lock.synchronized(() async {
      for (final span in spans) {
        await clear(span);
      }
    });
  }

  Future<void> reset() => clearAllKnown(ActivitySpan.values);

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

enum ActivitySpan { year, month, day, hour }

extension on ActivitySpan {
  String get keySuffix => switch (this) {
        ActivitySpan.year => 'year',
        ActivitySpan.month => 'month',
        ActivitySpan.day => 'day',
        ActivitySpan.hour => 'hour',
      };

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

  DateTime dateFromIndex(DateTime base, int i) => switch (this) {
        ActivitySpan.year => DateTime(PrfActivityCounter._baseYear + i),
        ActivitySpan.month => DateTime(base.year, i),
        ActivitySpan.day => DateTime(base.year, base.month, i),
        ActivitySpan.hour => DateTime(base.year, base.month, base.day, i),
      };
}

class _SpanInfo {
  final int index;
  final int minLength;

  const _SpanInfo(this.index, this.minLength);
}
