import 'package:shared_preferences/shared_preferences.dart';

abstract class Prf {
  static SharedPreferences? _prefs;
  static Future<SharedPreferences>? _initFuture;

  Prf._(); // Private constructor

  /// Internal initializer, only called once
  static Future<SharedPreferences> _init() {
    _initFuture ??= SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      return prefs;
    });
    return _initFuture!;
  }

  /// Always use this to get prefs – it ensures lazy initialization
  static Future<SharedPreferences> getInstance() async {
    return _prefs ?? await _init();
  }

  /// Optional: force re-init (e.g., after clearing all prefs)
  static void reset() {
    _prefs = null;
    _initFuture = null;
  }

  /// Optional: non-async access (e.g., in rare sync contexts)
  static SharedPreferences? get maybePrefs => _prefs;

  /// Optional: check if initialized
  static bool get isInitialized => _prefs != null;
}
