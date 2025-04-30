/// Represents different time periods for tracking purposes.
enum TrackerPeriod {
  /// 10 seconds period.
  seconds10,

  /// 20 seconds period.
  seconds20,

  /// 30 seconds period.
  seconds30,

  /// 1 minute period.
  minutes1,

  /// 2 minutes period.
  minutes2,

  /// 3 minutes period.
  minutes3,

  /// 5 minutes period.
  minutes5,

  /// 10 minutes period.
  minutes10,

  /// 15 minutes period.
  minutes15,

  /// 20 minutes period.
  minutes20,

  /// 30 minutes period.
  minutes30,

  /// 1 hour period.
  hourly,

  /// 2 hours period.
  every2Hours,

  /// 3 hours period.
  every3Hours,

  /// 6 hours period.
  every6Hours,

  /// 12 hours period.
  every12Hours,

  /// 1 day period.
  daily,

  /// 1 week period.
  weekly,

  /// 1 month period (approximated as 31 days).
  monthly,
}

/// Extension on [TrackerPeriod] to provide additional functionality.
extension TrackerPeriodExt on TrackerPeriod {
  /// Returns the [Duration] corresponding to the [TrackerPeriod].
  ///
  /// This method provides the exact duration for each period type.
  Duration get duration {
    switch (this) {
      case TrackerPeriod.seconds10:
        return Duration(seconds: 10);
      case TrackerPeriod.seconds20:
        return Duration(seconds: 20);
      case TrackerPeriod.seconds30:
        return Duration(seconds: 30);
      case TrackerPeriod.minutes1:
        return Duration(minutes: 1);
      case TrackerPeriod.minutes2:
        return Duration(minutes: 2);
      case TrackerPeriod.minutes3:
        return Duration(minutes: 3);
      case TrackerPeriod.minutes5:
        return Duration(minutes: 5);
      case TrackerPeriod.minutes10:
        return Duration(minutes: 10);
      case TrackerPeriod.minutes15:
        return Duration(minutes: 15);
      case TrackerPeriod.minutes20:
        return Duration(minutes: 20);
      case TrackerPeriod.minutes30:
        return Duration(minutes: 30);
      case TrackerPeriod.hourly:
        return Duration(hours: 1);
      case TrackerPeriod.every2Hours:
        return Duration(hours: 2);
      case TrackerPeriod.every3Hours:
        return Duration(hours: 3);
      case TrackerPeriod.every6Hours:
        return Duration(hours: 6);
      case TrackerPeriod.every12Hours:
        return Duration(hours: 12);
      case TrackerPeriod.daily:
        return Duration(days: 1);
      case TrackerPeriod.weekly:
        return Duration(days: 7);
      case TrackerPeriod.monthly:
        return Duration(days: 31); // special case
    }
  }

  /// Calculates the aligned start of the current period based on [now].
  ///
  /// This method returns the start of the period that the given [now] falls into.
  /// For example, if the period is daily, it returns the start of the current day.
  DateTime alignedStart(DateTime now) {
    switch (this) {
      case TrackerPeriod.daily:
        return DateTime(now.year, now.month, now.day);
      case TrackerPeriod.weekly:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        return DateTime(monday.year, monday.month, monday.day);
      case TrackerPeriod.monthly:
        return DateTime(now.year, now.month);
      default:
        final seconds = duration.inSeconds;
        final epochSeconds = now.toUtc().millisecondsSinceEpoch ~/ 1000;
        final alignedEpoch = (epochSeconds ~/ seconds) * seconds;
        return DateTime.fromMillisecondsSinceEpoch(alignedEpoch * 1000,
                isUtc: true)
            .toLocal();
    }
  }
}
