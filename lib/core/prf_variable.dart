import 'package:prf/core/typedefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base class for all prf persistence variables.
///
/// Handles the core functionality for storing, retrieving, and caching values
/// of type [T] in SharedPreferences. This serves as the foundation for all
/// type-specific prf implementations.
class PrfVariable<T> {
  /// Unique key used to store this variable in SharedPreferences.
  final String key;

  /// Function to retrieve the value from SharedPreferences.
  final SharedPrefsGetter<T> _getter;

  /// Function to save the value to SharedPreferences.
  final SharedPrefsSetter<T> _setter;

  /// Default value to use when no value is stored yet.
  final T? defaultValue;

  /// Cached value to avoid repeated disk reads.
  T? _cachedValue;

  /// Creates a new [PrfVariable] with the specified [key], getter, setter, and optional [defaultValue].
  ///
  /// The [key] must be unique within your application's SharedPreferences storage.
  /// The [_getter] and [_setter] functions handle the actual reading and writing to storage.
  PrfVariable(this.key, this._getter, this._setter, this.defaultValue);

  /// Checks if this variable exists in SharedPreferences.
  ///
  /// Returns a [Future<bool>] that completes with true if the key exists.
  Future<bool> _exists(SharedPreferencesAsync prefs) async {
    return await prefs.containsKey(key);
  }

  /// Retrieves the current value from cache or SharedPreferences.
  ///
  /// If the value is cached, returns the cached value.
  /// If not cached but exists in SharedPreferences, retrieves, caches, and returns it.
  /// If not found and [defaultValue] is set, stores the default value and returns it.
  /// Returns null if no value is found and no default is set.
  Future<T?> getValue(SharedPreferencesAsync prefs) async {
    if (_cachedValue != null) return _cachedValue;

    final exists = await _exists(prefs);
    if (!exists && defaultValue != null) {
      await setValue(prefs, defaultValue as T);
      return defaultValue;
    }

    return _cachedValue ??= await _getter(prefs, key);
  }

  /// Checks if the current value is null.
  ///
  /// Returns a [Future<bool>] that completes with true if the value is null.
  Future<bool> isValueNull(SharedPreferencesAsync prefs) async {
    return await getValue(prefs) == null;
  }

  /// Saves a new value to SharedPreferences and updates the cache.
  ///
  /// Updates the cache only if the save operation succeeds.
  /// Returns a [Future<bool>] indicating whether the operation was successful.
  Future<void> setValue(SharedPreferencesAsync prefs, T value) async {
    await _setter(prefs, key, value);
    _cachedValue = value;
  }

  /// Removes the value from both the cache and SharedPreferences.
  ///
  /// Clears the cached value and removes the key from SharedPreferences.
  Future<void> removeValue(SharedPreferencesAsync prefs) async {
    await prefs.remove(key);
    _cachedValue = null;
  }
}
