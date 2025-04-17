import 'package:prf/core/prf_variable.dart';

/// A type-safe wrapper for storing and retrieving integer values in SharedPreferences.
///
/// Use this class for storing whole numbers like scores, counts, identifiers, or indexes.
///
/// Example:
/// ```dart
/// final playerScore = PrfInt('player_score', defaultValue: 0);
/// await playerScore.set(100);
/// final score = await playerScore.get(); // 100
/// ```
class PrfInt extends PrfVariable<int> {
  /// Creates a new integer preference variable with the specified [key].
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
  PrfInt(String key, {int? defaultValue})
      : super(
          key,
          (prefs, key) async => prefs.getInt(key),
          (prefs, key, value) async => await prefs.setInt(key, value),
          defaultValue,
        );
}
