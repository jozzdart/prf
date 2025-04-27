import 'package:prf/prf.dart';

/// A type-safe wrapper for storing and retrieving DateTime values in SharedPreferences.
///
/// This class automatically handles the conversion between DateTime objects and
/// their binary representation (encoded as base64 strings for storage).
///
/// Use this class for storing timestamps, event dates, user registration dates,
/// or any time-related data.
///
/// Example:
/// ```dart
/// final lastLogin = PrfDateTime('last_login');
/// await lastLogin.set(DateTime.now());
/// final loginTime = await lastLogin.get();
/// ```
@Deprecated(
    'Use Prf<DateTime> instead for cached access or Prfy<DateTime> for isolate-safe access')
class PrfDateTime extends Prf<DateTime> {
  /// Creates a new DateTime preference variable with the specified [key].
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
  PrfDateTime(super.key, {super.defaultValue});
}
