import 'package:prf/core/prf_variable.dart';
import 'package:prf/services/prf.dart';

extension PrfVariableExtensions<T> on PrfVariable<T> {
  /// Get the value using internal SharedPreferences instance
  Future<T?> get() async {
    final prefs = await Prf.getInstance();
    return await getValue(prefs);
  }

  /// Set the value using internal SharedPreferences instance
  Future<bool> set(T value) async {
    final prefs = await Prf.getInstance();
    return await setValue(prefs, value);
  }

  /// Remove the value using internal SharedPreferences instance
  Future<void> remove() async {
    final prefs = await Prf.getInstance();
    return await removeValue(prefs);
  }

  /// Check if the current value is null
  Future<bool> isNull() async {
    final prefs = await Prf.getInstance();
    return await isValueNull(prefs);
  }

  /// Allows providing a fallback inline
  Future<T> getOrFallback(T fallback) async {
    return (await get()) ?? fallback;
  }

  Future<bool> existsOnPrefs() async {
    final prefs = await Prf.getInstance();
    return prefs.containsKey(key);
  }
}
