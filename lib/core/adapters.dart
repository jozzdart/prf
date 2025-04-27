import 'package:shared_preferences/shared_preferences.dart';

abstract class PrfAdapter<T> {
  /// Function to retrieve the value from SharedPreferences.
  Future<T?> getter(SharedPreferencesAsync prefs, String key);

  /// Function to save the value to SharedPreferences.
  Future<void> setter(SharedPreferencesAsync prefs, String key, T value);

  const PrfAdapter();
}

/// Bool adapter implementation
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

  const BoolAdapter();
}

/// Int adapter implementation
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

  const IntAdapter();
}

/// Double adapter implementation
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

  const DoubleAdapter();
}

/// String adapter implementation
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

  const StringAdapter();
}

/// StringList adapter implementation
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

  const StringListAdapter();
}
