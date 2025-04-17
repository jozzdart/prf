import 'package:shared_preferences/shared_preferences.dart';

/// Function type for retrieving values from SharedPreferences.
///
/// Takes a [SharedPreferencesAsync] instance and a [key] string, and returns
/// a [Future] containing the retrieved value of type [T] or null.
typedef SharedPrefsGetter<T> = Future<T?> Function(
    SharedPreferencesAsync prefs, String key);

/// Function type for saving values to SharedPreferences.
///
/// Takes a [SharedPreferencesAsync] instance, a [key] string, and a [value] of type [T],
/// and returns a [Future<bool>] indicating success or failure of the operation.
typedef SharedPrefsSetter<T> = Future<void> Function(
    SharedPreferencesAsync prefs, String key, T value);
