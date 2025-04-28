import 'package:shared_preferences/shared_preferences.dart';

/// Abstract adapter for converting between Dart types and SharedPreferences.
///
/// Adapters enable type-safe access to SharedPreferences by handling
/// the conversion between a Dart type [T] and the native types
/// supported by SharedPreferences.
abstract class PrfAdapter<T> {
  /// Retrieves a value of type [T] from SharedPreferences.
  ///
  /// Returns null if the value doesn't exist or cannot be converted.
  Future<T?> getter(SharedPreferencesAsync prefs, String key);

  /// Stores a value of type [T] in SharedPreferences.
  Future<void> setter(SharedPreferencesAsync prefs, String key, T value);

  /// Creates a new adapter.
  const PrfAdapter();
}
