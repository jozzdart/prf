import 'package:prf/prf_types/prf.dart';

/// A type-safe wrapper for storing and retrieving boolean values in SharedPreferences.
///
/// Use this class for storing true/false flags like user preferences, feature toggles,
/// or settings states.
///
/// Example:
/// ```dart
/// final darkMode = PrfBool('dark_mode', defaultValue: false);
/// await darkMode.set(true);
/// final isDarkMode = await darkMode.get(); // true
/// ```
class PrfBool extends Prf<bool> {
  /// Creates a new boolean preference variable with the specified [key].
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
  PrfBool(super.key, {super.defaultValue});
}
