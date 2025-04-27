import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

abstract class PrfService {
  static SharedPreferencesAsync? _overriddenPrefs;

  PrfService._();

  static SharedPreferencesAsync get instance =>
      _overriddenPrefs ??= SharedPreferencesAsync();

  static void overrideWith(SharedPreferencesAsync prefs) {
    _overriddenPrefs = prefs;
  }

  static void resetOverride() {
    _overriddenPrefs = null;
  }

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
