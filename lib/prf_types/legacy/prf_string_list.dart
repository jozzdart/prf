import 'package:prf/prf_types/prf.dart';

/// A type-safe wrapper for storing and retrieving string lists in SharedPreferences.
///
/// Use this class for storing collections of strings like tags, recent searches,
/// selected items, or any array of text data.
///
/// Example:
/// ```dart
/// final recentSearches = PrfStringList('recent_searches', defaultValue: []);
/// await recentSearches.set(['flutter', 'dart', 'prf']);
/// final searches = await recentSearches.get(); // ['flutter', 'dart', 'prf']
/// ```
class PrfStringList extends Prf<List<String>> {
  /// Creates a new string list preference variable with the specified [key].
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
  PrfStringList(super.key, {super.defaultValue});
}
