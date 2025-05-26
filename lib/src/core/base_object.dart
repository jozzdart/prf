import 'package:shared_preferences/shared_preferences.dart';

import 'base_adapter.dart';

/// Base class for preference objects that provides core functionality for storing
/// and retrieving typed values from SharedPreferences.
///
/// This class handles the persistence layer for preference objects, working with
/// [SharedPreferencesAsync] and using [PrfAdapter]s for type conversion.
abstract class BasePrfObject<T> {
  /// The key used to store this preference in SharedPreferences.
  final String key;

  /// The adapter used to convert between the type [T] and SharedPreferences.
  PrfAdapter<T> get adapter;

  /// Optional default value to use when no value exists for [key].
  final T? defaultValue;

  /// Creates a new preference object with the given [key] and optional [defaultValue].
  const BasePrfObject(this.key, {this.defaultValue});

  /// Gets the value from SharedPreferences.
  ///
  /// If the value doesn't exist and [defaultValue] is provided,
  /// stores the default value and returns it.
  Future<T?> getValue(SharedPreferencesAsync prefs) async {
    final value = await adapter.getter(prefs, key);
    if (value == null && defaultValue != null) {
      await setValue(prefs, defaultValue as T);
      return defaultValue;
    }
    return value;
  }

  /// Checks if the stored value is null.
  Future<bool> isValueNull(SharedPreferencesAsync prefs) async {
    return await getValue(prefs) == null;
  }

  /// Stores [value] in SharedPreferences.
  Future<void> setValue(SharedPreferencesAsync prefs, T value) async {
    await adapter.setter(prefs, key, value);
  }

  /// Removes the value from SharedPreferences.
  Future<void> removeValue(SharedPreferencesAsync prefs) async {
    await prefs.remove(key);
  }
}
