import 'package:shared_preferences/shared_preferences.dart';

import 'base_object.dart';

/// A preference object that caches values in memory for faster access.
///
/// This extends [BasePrfObject] by maintaining an in-memory cache of the most recent
/// value, reducing disk reads when the same value is accessed multiple times.
/// This improves performance but is not recommended for use in isolates since
/// the cache is not shared between isolates.
abstract class CachedPrfObject<T> extends BasePrfObject<T> {
  /// The cached value stored in memory.
  T? _cachedValue;

  /// Creates a new cached preference object with the given [key] and optional [defaultValue].
  CachedPrfObject(super.key, {super.defaultValue});

  /// Returns the currently cached value without accessing SharedPreferences.
  ///
  /// Warning: This may return null if the value has not been read or initialized.
  ///
  /// Use `get()` or convenience methods instead for safer access.
  T? get cachedValue => _cachedValue;

  /// Initializes the cache by reading the current value from SharedPreferences.
  ///
  /// Call this method to ensure the cache is populated before accessing [cachedValue].
  Future<void> initCache(SharedPreferencesAsync prefs) async {
    _cachedValue = await super.getValue(prefs);
  }

  @override

  /// Gets the value, using the cached value if available or reading from storage if not.
  ///
  /// This prioritizes the cached value to avoid disk reads, updating the cache
  /// when a read from storage is necessary.
  Future<T?> getValue(SharedPreferencesAsync prefs) async {
    if (_cachedValue != null) return _cachedValue;
    return _cachedValue ??= await super.getValue(prefs);
  }

  @override

  /// Stores [value] in SharedPreferences and updates the cached value.
  Future<void> setValue(SharedPreferencesAsync prefs, T value) async {
    await super.setValue(prefs, value);
    _cachedValue = value;
  }

  @override

  /// Removes the value from SharedPreferences and clears the cached value.
  Future<void> removeValue(SharedPreferencesAsync prefs) async {
    await super.removeValue(prefs);
    _cachedValue = null;
  }
}
