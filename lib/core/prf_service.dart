import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

/// Service for accessing and managing SharedPreferences.
///
/// This singleton service provides access to the [SharedPreferencesAsync] instance
/// used by the PRF library, with support for testing through override functionality
/// and migration from legacy SharedPreferences.
abstract class PrfService {
  /// Optional override for the SharedPreferences instance.
  static SharedPreferencesAsync? _overriddenPrefs;

  /// Private constructor to prevent instantiation.
  PrfService._();

  /// Returns the singleton instance of SharedPreferencesAsync.
  ///
  /// If an override has been set via [overrideWith], returns that instance.
  /// Otherwise, returns a new instance of SharedPreferencesAsync.
  static SharedPreferencesAsync get instance =>
      _overriddenPrefs ??= SharedPreferencesAsync();

  /// Overrides the default SharedPreferencesAsync instance.
  ///
  /// Useful for testing and dependency injection.
  static void overrideWith(SharedPreferencesAsync prefs) {
    _overriddenPrefs = prefs;
  }

  /// Resets any override, allowing the default instance to be used.
  static void resetOverride() {
    _overriddenPrefs = null;
  }

  /// Migrates data from legacy SharedPreferences to SharedPreferencesAsync.
  ///
  /// This method should be called once during app initialization if migrating
  /// from a previous version that used the legacy SharedPreferences API.
  ///
  /// [migrationKey] is used to mark that migration has been completed.
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

  @Deprecated('Use Prf.instance instead')
  static SharedPreferences? _deprecatedPrefs;

  @Deprecated('Use Prf.instance instead')
  static Future<SharedPreferences>? _initFuture;

  @Deprecated('Use Prf.instance instead')
  static Future<SharedPreferences> _init() {
    _initFuture ??= SharedPreferences.getInstance().then((prefs) {
      _deprecatedPrefs = prefs;
      return prefs;
    });
    return _initFuture!;
  }

  @Deprecated('Use Prf.instance instead')
  static Future<SharedPreferences> getInstance() async {
    return _deprecatedPrefs ?? await _init();
  }

  @Deprecated('No longer needed with SharedPreferencesAsync')
  static void reset() {
    _deprecatedPrefs = null;
    _initFuture = null;
  }

  @Deprecated('Use Prf.instance instead')
  static SharedPreferences? get maybePrefs => _deprecatedPrefs;

  @Deprecated('No longer needed with SharedPreferencesAsync')
  static bool get isInitialized => _deprecatedPrefs != null;
}
