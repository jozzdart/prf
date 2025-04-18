import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

/// Singleton wrapper around [SharedPreferencesAsync] for use in the `prf` package.
///
/// This service provides isolate-safe, always up-to-date access to the
/// native storage without relying on any underlying SharedPreferences cache.
/// `prf` handles its own in-memory caching on top of this.
abstract class Prf {
  static SharedPreferencesAsync? _overriddenPrefs;

  /// Private constructor to prevent instantiation.
  Prf._();

  /// The active [SharedPreferencesAsync] instance.
  ///
  /// By default, uses the singleton instance.
  /// Can be overridden in tests with [overrideWith].
  static SharedPreferencesAsync get instance =>
      _overriddenPrefs ??= SharedPreferencesAsync();

  /// Override the internal [SharedPreferencesAsync] instance (for testing).
  ///
  /// Example:
  /// ```dart
  /// final fakePrefs = SharedPreferencesAsync.inMemory();
  /// Prf.overrideWith(fakePrefs);
  /// ```
  static void overrideWith(SharedPreferencesAsync prefs) {
    _overriddenPrefs = prefs;
  }

  /// Resets any test override and restores the default instance.
  static void resetOverride() {
    _overriddenPrefs = null;
  }

  /// Migrates data from legacy SharedPreferences to SharedPreferencesAsync.
  ///
  /// This method ensures that data stored in the older SharedPreferences system
  /// is properly transferred to the new SharedPreferencesAsync system.
  /// It only performs the migration once, tracking completion with the provided
  /// migration key.
  ///
  /// Parameters:
  /// * [migrationKey]: Key used to track whether migration has already occurred.
  ///   Defaults to 'prf_migrated'.
  static Future<void> migrateFromLegacyPrefsIfNeeded({
    String migrationKey = 'prf_migrated',
  }) async {
    final legacy = await SharedPreferences.getInstance();
    const sharedPreferencesOptions = SharedPreferencesOptions(); // defaults

    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: legacy,
      sharedPreferencesAsyncOptions: sharedPreferencesOptions,
      migrationCompletedKey: 'migrationCompleted',
    );
  }

  // --- DEPRECATED METHODS BELOW ---

  /// Clears all `SharedPreferences` values.
  /// Optionally pass an [allowList] to retain specific keys.
  @Deprecated('Use instance.clear() instead')
  static Future<void> clear({Set<String>? allowList}) async {
    throw UnsupportedError(
        'This method is deprecated. Use Prf.instance.clear() instead.');
  }

  /// Cached SharedPreferences instance
  @Deprecated('Use Prf.instance instead')
  static SharedPreferences? _deprecatedPrefs;

  /// Future holding the initialization process
  @Deprecated('Use Prf.instance instead')
  static Future<SharedPreferences>? _initFuture;

  /// Internal initializer that ensures SharedPreferences is only initialized once.
  ///
  /// This method caches both the Future and the result to prevent
  /// multiple initialization attempts.
  ///
  /// Returns a Future that completes with the SharedPreferences instance.
  @Deprecated('Use Prf.instance instead')
  static Future<SharedPreferences> _init() {
    _initFuture ??= SharedPreferences.getInstance().then((prefs) {
      _deprecatedPrefs = prefs;
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
  @Deprecated('Use Prf.instance instead')
  static Future<SharedPreferences> getInstance() async {
    return _deprecatedPrefs ?? await _init();
  }

  /// Resets the cached SharedPreferences instance and initialization state.
  ///
  /// Useful for testing or after clearing all preferences to ensure
  /// the next call fetches a fresh instance.
  @Deprecated('No longer needed with SharedPreferencesAsync')
  static void reset() {
    _deprecatedPrefs = null;
    _initFuture = null;
  }

  /// Provides synchronous access to the cached SharedPreferences instance.
  ///
  /// Note: This may return null if SharedPreferences has not been initialized.
  /// Use with caution and only in contexts where async/await cannot be used.
  ///
  /// Returns the cached SharedPreferences instance or null if not initialized.
  @Deprecated('Use Prf.instance instead')
  static SharedPreferences? get maybePrefs => _deprecatedPrefs;

  /// Checks if SharedPreferences has been initialized.
  ///
  /// Returns true if the SharedPreferences instance has been loaded,
  /// false otherwise.
  @Deprecated('No longer needed with SharedPreferencesAsync')
  static bool get isInitialized => _deprecatedPrefs != null;
}
