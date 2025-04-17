import 'package:prf/core/typedefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrfVariable<T> {
  final String key;
  final SharedPrefsGetter<T> _getter;
  final SharedPrefsSetter<T> _setter;
  final T? defaultValue;

  T? _cachedValue;

  PrfVariable(this.key, this._getter, this._setter, this.defaultValue);

  Future<bool> _exists(SharedPreferences prefs) async {
    return prefs.containsKey(key);
  }

  Future<T?> getValue(SharedPreferences prefs) async {
    if (_cachedValue != null) return _cachedValue;

    final exists = await _exists(prefs);
    if (!exists && defaultValue != null) {
      await setValue(prefs, defaultValue as T);
      return defaultValue;
    }

    return _cachedValue ??= await _getter(prefs, key);
  }

  Future<bool> isValueNull(SharedPreferences prefs) async {
    return await getValue(prefs) == null;
  }

  Future<bool> setValue(SharedPreferences prefs, T value) async {
    final result = await _setter(prefs, key, value);
    if (result) _cachedValue = value;
    return result;
  }

  Future<void> removeValue(SharedPreferences prefs) async {
    _cachedValue = null;
    await prefs.remove(key);
  }
}
