import 'package:shared_preferences/shared_preferences.dart';

typedef SharedPrefsGetter<T> = Future<T?> Function(
    SharedPreferences prefs, String key);
typedef SharedPrefsSetter<T> = Future<bool> Function(
    SharedPreferences prefs, String key, T value);
