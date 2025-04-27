import 'package:prf/prf.dart';

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
class PrfDuration extends Prf<Duration> {
  /// Creates a new Duration preference variable with the specified [key].
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
  PrfDuration(super.key, {super.defaultValue});
}
