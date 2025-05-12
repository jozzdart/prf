import 'package:prf/prf.dart';

/// Extension methods for [BasePrfObject] to provide convenient access.
///
/// These methods simplify common operations by automatically using the default
/// [PrfService] instance, reducing boilerplate in client code.
extension PrfOperationExtensions<T> on BasePrfObject<T> {
  /// Gets the value from the default [PrfService] instance.
  ///
  /// Returns null if the value doesn't exist and no default was provided.
  Future<T?> get() async {
    return await getValue(PrfService.instance);
  }

  /// Sets the value using the default [PrfService] instance.
  Future<void> set(T value) async {
    await setValue(PrfService.instance, value);
  }

  /// Removes the value from the default [PrfService] instance.
  Future<void> remove() async {
    await removeValue(PrfService.instance);
  }

  /// Checks if the value is null in the default [PrfService] instance.
  Future<bool> isNull() async {
    return await isValueNull(PrfService.instance);
  }

  /// Gets the value or returns the provided fallback if the value is null.
  ///
  /// This is a convenience method that combines [get] with a null check.
  Future<T> getOrFallback(T fallback) async {
    return (await get()) ?? fallback;
  }

  /// Checks if the key exists in the default [PrfService] instance.
  Future<bool> existsOnPrefs() async {
    return await PrfService.instance.containsKey(key);
  }

  /// Retrieves the stored value or throws an exception if no default value is defined.
  Future<T> getOrDefault() async {
    final value = await get(); // for type safety
    if (value != null) {
      return value;
    }
    throw Exception(
        'Default value not defined for preference of type $T with key $key');
  }
}
