import 'package:shared_preferences/shared_preferences.dart';

/// Function type for retrieving values from SharedPreferences.
///
/// Takes a [SharedPreferences] instance and a [key] string, and returns
/// a [Future] containing the retrieved value of type [T] or null.
typedef SharedPrefsGetter<T> = Future<T?> Function(
    SharedPreferences prefs, String key);

/// Function type for saving values to SharedPreferences.
///
/// Takes a [SharedPreferences] instance, a [key] string, and a [value] of type [T],
/// and returns a [Future<bool>] indicating success or failure of the operation.
typedef SharedPrefsSetter<T> = Future<bool> Function(
    SharedPreferences prefs, String key, T value);
