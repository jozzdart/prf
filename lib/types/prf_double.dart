import 'package:prf/core/prf_variable.dart';

/// A type-safe wrapper for storing and retrieving double values in SharedPreferences.
///
/// Use this class for storing floating-point numbers like ratings, percentages,
/// coordinates, or any decimal values.
///
/// Example:
/// ```dart
/// final userRating = PrfDouble('user_rating', defaultValue: 0.0);
/// await userRating.set(4.5);
/// final rating = await userRating.get(); // 4.5
/// ```
class PrfDouble extends PrfVariable<double> {
  /// Creates a new double preference variable with the specified [key].
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
  PrfDouble(String key, {double? defaultValue})
      : super(
          key,
          (prefs, key) async => await prefs.getDouble(key),
          (prefs, key, value) async => await prefs.setDouble(key, value),
          defaultValue,
        );
}
