import 'package:shared_preferences/shared_preferences.dart';

/// Core service class that manages SharedPreferences initialization and access.
///
/// This abstract class cannot be instantiated directly and provides static
/// methods to safely access the SharedPreferences instance.
///
/// The class implements:
/// - Lazy initialization (SharedPreferences are only loaded when first needed)
/// - Caching (the instance is stored after first retrieval)
/// - Thread-safety (initialization is protected against race conditions)
abstract class Prf {
  /// Cached SharedPreferences instance
  static SharedPreferences? _prefs;

  /// Future holding the initialization process
  static Future<SharedPreferences>? _initFuture;

  /// Private constructor to prevent instantiation
  Prf._();

  /// Internal initializer that ensures SharedPreferences is only initialized once.
  ///
  /// This method caches both the Future and the result to prevent
  /// multiple initialization attempts.
  ///
  /// Returns a Future that completes with the SharedPreferences instance.
  static Future<SharedPreferences> _init() {
    _initFuture ??= SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      return prefs;
    });
    return _initFuture!;
  }

  /// Gets the SharedPreferences instance, initializing it if necessary.
  ///
  /// This is the primary method for obtaining the SharedPreferences instance
  /// throughout the application.
  ///
  /// Returns a Future that completes with the SharedPreferences instance.
  static Future<SharedPreferences> getInstance() async {
    return _prefs ?? await _init();
  }

  /// Resets the cached SharedPreferences instance and initialization state.
  ///
  /// Useful for testing or after clearing all preferences to ensure
  /// the next call fetches a fresh instance.
  static void reset() {
    _prefs = null;
    _initFuture = null;
  }

  /// Provides synchronous access to the cached SharedPreferences instance.
  ///
  /// Note: This may return null if SharedPreferences has not been initialized.
  /// Use with caution and only in contexts where async/await cannot be used.
  ///
  /// Returns the cached SharedPreferences instance or null if not initialized.
  static SharedPreferences? get maybePrefs => _prefs;

  /// Checks if SharedPreferences has been initialized.
  ///
  /// Returns true if the SharedPreferences instance has been loaded,
  /// false otherwise.
  static bool get isInitialized => _prefs != null;
}
