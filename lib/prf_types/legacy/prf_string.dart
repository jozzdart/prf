import 'package:prf/prf_types/prf.dart';

/// A type-safe wrapper for storing and retrieving string values in SharedPreferences.
///
/// Use this class for storing text data like usernames, tokens, IDs, or any textual content.
///
/// Example:
/// ```dart
/// final username = PrfString('username');
/// await username.set('Joey');
/// final name = await username.get(); // 'Joey'
/// ```
class PrfString extends Prf<String> {
  /// Creates a new string preference variable with the specified [key].
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
  PrfString(super.key, {super.defaultValue});
}
