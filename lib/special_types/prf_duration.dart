import 'package:prf/core/prf_encoded.dart';

/// A type-safe wrapper for storing and retrieving Duration values in SharedPreferences.
///
/// This class automatically handles the conversion between Duration objects and
/// their integer representation (microseconds) for storage.
///
/// Use this class for storing time intervals, timeouts, animation durations,
/// or any duration-related data.
///
/// Example:
/// ```dart
/// final timeout = PrfDuration('request_timeout', defaultValue: Duration(seconds: 30));
/// await timeout.set(Duration(seconds: 60));
/// final duration = await timeout.get(); // Duration(seconds: 60)
/// ```
class PrfDuration extends PrfEncoded<Duration, int> {
  /// Creates a new Duration preference variable with the specified [key].
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
  PrfDuration(super.key, {super.defaultValue})
      : super(
          from: (micros) {
            if (micros == null) return null;
            return Duration(microseconds: micros);
          },
          to: (duration) => duration.inMicroseconds,
          getter: (prefs, key) async => await prefs.getInt(key),
          setter: (prefs, key, value) async => await prefs.setInt(key, value),
        );
}
