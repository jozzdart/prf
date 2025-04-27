import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CachedPrfObject<T> extends BasePrfObject<T> {
  T? _cachedValue;

  CachedPrfObject(super.key, {super.defaultValue});

  @override
  Future<T?> getValue(SharedPreferencesAsync prefs) async {
    if (_cachedValue != null) return _cachedValue;
    return _cachedValue ??= await super.getValue(prefs);
  }

  @override
  Future<void> setValue(SharedPreferencesAsync prefs, T value) async {
    await super.setValue(prefs, value);
    _cachedValue = value;
  }

  @override
  Future<void> removeValue(SharedPreferencesAsync prefs) async {
    await super.removeValue(prefs);
    _cachedValue = null;
  }
}
