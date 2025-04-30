enum TrackerPeriod {
  seconds10,
  seconds20,
  seconds30,
  minutes1,
  minutes2,
  minutes3,
  minutes5,
  minutes10,
  minutes15,
  minutes20,
  minutes30,
  hourly,
  every2Hours,
  every3Hours,
  every6Hours,
  every12Hours,
  daily,
  weekly,
  monthly,
}

extension TrackerPeriodExt on TrackerPeriod {
  /// Duration length of each period
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

  /// Gets the aligned start of the current period
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
