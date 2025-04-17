import 'package:prf/core/prf_variable.dart';
import 'package:prf/services/prf.dart';

/// Extensions on [PrfVariable] that provide convenient methods for accessing
/// and manipulating persisted values.
///
/// These extensions simplify working with stored preferences by handling the
/// SharedPreferences instance internally, allowing for cleaner, more readable code.
extension PrfVariableExtensions<T> on PrfVariable<T> {
  /// Gets the stored value associated with this variable.
  ///
  /// Uses the internal SharedPreferences instance to retrieve the value.
  /// Returns null if the value doesn't exist or can't be retrieved.
  ///
  /// Example:
  /// ```dart
  /// final username = PrfString('username');
  /// final value = await username.get();
  /// ```
  Future<T?> get() async {
    return await getValue(Prf.instance);
  }

  /// Sets the value for this variable in persistent storage.
  ///
  /// Uses the internal SharedPreferences instance to store the value.
  /// Returns true if the operation was successful, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// final username = PrfString('username');
  /// await username.set('Joey');
  /// ```
  Future<void> set(T value) async {
    await setValue(Prf.instance, value);
  }

  /// Removes the value from persistent storage.
  ///
  /// Uses the internal SharedPreferences instance to delete the value.
  /// After calling this method, [get()] will return null until a new value is set.
  ///
  /// Example:
  /// ```dart
  /// final username = PrfString('username');
  /// await username.remove();
  /// ```
  Future<void> remove() async {
    await removeValue(Prf.instance);
  }

  /// Checks if the current value is null in storage.
  ///
  /// Returns true if the value doesn't exist or is explicitly set to null.
  ///
  /// Example:
  /// ```dart
  /// final username = PrfString('username');
  /// if (await username.isNull()) {
  ///   // Handle null case
  /// }
  /// ```
  Future<bool> isNull() async {
    return await isValueNull(Prf.instance);
  }

  /// Gets the stored value or returns a fallback if the value is null.
  ///
  /// This is a convenience method that combines [get()] with a null check.
  ///
  /// Example:
  /// ```dart
  /// final coins = PrfInt('coins');
  /// final value = await coins.getOrFallback(0); // Returns 0 if not set
  /// ```
  Future<T> getOrFallback(T fallback) async {
    return (await get()) ?? fallback;
  }

  /// Checks if the key exists in SharedPreferences.
  ///
  /// Returns true if the key exists, even if its value is null.
  ///
  /// Example:
  /// ```dart
  /// final username = PrfString('username');
  /// if (await username.existsOnPrefs()) {
  ///   // The key exists in storage
  /// }
  /// ```
  Future<bool> existsOnPrefs() async {
    return await Prf.instance.containsKey(key);
  }
}
