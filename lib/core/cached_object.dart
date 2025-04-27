import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base class for all prf persistence variables.
///
/// Handles the core functionality for storing, retrieving, and caching values
/// of type [T] in SharedPreferences. This serves as the foundation for all
/// type-specific prf implementations.
abstract class CachedPrfObject<T> extends BasePrfObject<T> {
  /// Cached value to avoid repeated disk reads.
  T? _cachedValue;

  /// Creates a new [Prf] with the specified [key], getter, setter, and optional [defaultValue].
  ///
  /// The [key] must be unique within your application's SharedPreferences storage.
  /// The [_getter] and [_setter] functions handle the actual reading and writing to storage.
  CachedPrfObject(super.key, {super.defaultValue});

  /// Retrieves the current value from cache or SharedPreferences.
  ///
  /// If the value is cached, returns the cached value.
  /// If not cached but exists in SharedPreferences, retrieves, caches, and returns it.
  /// If not found and [defaultValue] is set, stores the default value and returns it.
  /// Returns null if no value is found and no default is set.
  @override
  Future<T?> getValue(SharedPreferencesAsync prefs) async {
    if (_cachedValue != null) return _cachedValue;
    return _cachedValue ??= await super.getValue(prefs);
  }

  /// Saves a new value to SharedPreferences and updates the cache.
  ///
  /// Updates the cache only if the save operation succeeds.
  /// Returns a [Future<bool>] indicating whether the operation was successful.
  @override
  Future<void> setValue(SharedPreferencesAsync prefs, T value) async {
    await super.setValue(prefs, value);
    _cachedValue = value;
  }

  /// Removes the value from both the cache and SharedPreferences.
  ///
  /// Clears the cached value and removes the key from SharedPreferences.
  @override
  Future<void> removeValue(SharedPreferencesAsync prefs) async {
    await super.removeValue(prefs);
    _cachedValue = null;
  }
}
