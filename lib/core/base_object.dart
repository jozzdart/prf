import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BasePrfObject<T> {
  final String key;

  PrfAdapter<T> get adapter;

  final T? defaultValue;

  const BasePrfObject(this.key, {this.defaultValue});

  Future<bool> _exists(SharedPreferencesAsync prefs) async {
    return await prefs.containsKey(key);
  }

  Future<T?> getValue(SharedPreferencesAsync prefs) async {
    final exists = await _exists(prefs);
    if (!exists && defaultValue != null) {
      await setValue(prefs, defaultValue as T);
      return defaultValue;
    }
    return await adapter.getter(prefs, key);
  }

  Future<bool> isValueNull(SharedPreferencesAsync prefs) async {
    return await getValue(prefs) == null;
  }

  Future<void> setValue(SharedPreferencesAsync prefs, T value) async {
    await adapter.setter(prefs, key, value);
  }

  Future<void> removeValue(SharedPreferencesAsync prefs) async {
    await prefs.remove(key);
  }
}
