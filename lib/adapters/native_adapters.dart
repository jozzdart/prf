import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adapter for boolean values.
///
/// Uses the native bool support in SharedPreferences.
class BoolAdapter extends PrfAdapter<bool> {
  @override
  Future<bool?> getter(SharedPreferencesAsync prefs, String key) async {
    return await prefs.getBool(key);
  }

  @override
  Future<void> setter(
      SharedPreferencesAsync prefs, String key, bool value) async {
    await prefs.setBool(key, value);
  }

  /// Creates a new boolean adapter.
  const BoolAdapter();
}

/// Adapter for integer values.
///
/// Uses the native int support in SharedPreferences.
class IntAdapter extends PrfAdapter<int> {
  @override
  Future<int?> getter(SharedPreferencesAsync prefs, String key) async {
    return await prefs.getInt(key);
  }

  @override
  Future<void> setter(
      SharedPreferencesAsync prefs, String key, int value) async {
    await prefs.setInt(key, value);
  }

  /// Creates a new integer adapter.
  const IntAdapter();
}

/// Adapter for double values.
///
/// Uses the native double support in SharedPreferences.
class DoubleAdapter extends PrfAdapter<double> {
  @override
  Future<double?> getter(SharedPreferencesAsync prefs, String key) async {
    return await prefs.getDouble(key);
  }

  @override
  Future<void> setter(
      SharedPreferencesAsync prefs, String key, double value) async {
    await prefs.setDouble(key, value);
  }

  /// Creates a new double adapter.
  const DoubleAdapter();
}

/// Adapter for string values.
///
/// Uses the native string support in SharedPreferences.
class StringAdapter extends PrfAdapter<String> {
  @override
  Future<String?> getter(SharedPreferencesAsync prefs, String key) async {
    return await prefs.getString(key);
  }

  @override
  Future<void> setter(
      SharedPreferencesAsync prefs, String key, String value) async {
    await prefs.setString(key, value);
  }

  /// Creates a new string adapter.
  const StringAdapter();
}

/// Adapter for lists of strings.
///
/// Uses the native string list support in SharedPreferences.
class StringListAdapter extends PrfAdapter<List<String>> {
  @override
  Future<List<String>?> getter(SharedPreferencesAsync prefs, String key) async {
    return await prefs.getStringList(key);
  }

  @override
  Future<void> setter(
      SharedPreferencesAsync prefs, String key, List<String> value) async {
    await prefs.setStringList(key, value);
  }

  /// Creates a new string list adapter.
  const StringListAdapter();
}
