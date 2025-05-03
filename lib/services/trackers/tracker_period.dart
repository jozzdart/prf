@Deprecated(
    'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
enum TrackerPeriod {
  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  seconds10,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  seconds20,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  seconds30,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  minutes1,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  minutes2,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  minutes3,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  minutes5,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  minutes10,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  minutes15,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  minutes20,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  minutes30,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  hourly,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  every2Hours,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  every3Hours,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  every6Hours,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  every12Hours,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  daily,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  weekly,

  @Deprecated(
      'TrackerPeriod has been moved to the track package. Please update your imports to use the new package.')
  monthly,
}

@Deprecated(
    'TrackerPeriodExt has been moved to the track package. Please update your imports to use the new package.')
extension TrackerPeriodExt on TrackerPeriod {
  @Deprecated(
      'TrackerPeriodExt has been moved to the track package. Please update your imports to use the new package.')
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

  @Deprecated(
      'TrackerPeriodExt has been moved to the track package. Please update your imports to use the new package.')
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
