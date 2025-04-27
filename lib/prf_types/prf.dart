import 'package:prf/prf.dart';

/// A cached preference object that provides type-safe access to SharedPreferences.
///
/// This implementation caches values in memory for faster access after initial read,
/// making it more efficient for repeated access but not suitable for use across isolates.
/// For isolate-safe preferences, use [Prfy] instead.
///
/// Example:
/// ```dart
/// final username = Prf<String>('username');
/// await username.set('Alice');
/// final name = await username.get(); // Returns 'Alice'
/// ```
class Prf<T> extends CachedPrfObject<T> {
  /// Creates a new cached preference object with the given [key] and optional [defaultValue].
  Prf(super.key, {super.defaultValue});

  /// Gets the appropriate adapter for type [T] from the adapter registry.
  @override
  PrfAdapter<T> get adapter => PrfAdapterMap.instance.of<T>();

  /// Creates a new pre-cached preference object.
  ///
  /// This factory method creates a new [Prf] instance and immediately loads its value
  /// into the cache for faster subsequent access. This is not isolate-safe.
  ///
  /// - [key] is the key to store the preference under.
  /// - [defaultValue] is the value to use if no value exists for the key.
  Future<Prf<T>> value(
    String key, {
    T? defaultValue,
  }) async {
    final object = Prf<T>(key, defaultValue: defaultValue);
    await object.initCache(PrfService.instance);
    return object;
  }
}
