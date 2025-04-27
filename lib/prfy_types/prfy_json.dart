import 'package:prf/prf.dart';

/// An isolate-safe preference object specialized for storing JSON-serializable objects.
///
/// This class provides type-safe access to complex objects stored in SharedPreferences
/// by serializing them to JSON. Unlike [PrfJson], it doesn't use in-memory caching,
/// making it suitable for use across multiple isolates where cached values might
/// become stale.
///
/// Example:
/// ```dart
/// class Settings {
///   final bool darkMode;
///   final String locale;
///
///   Settings({required this.darkMode, required this.locale});
///
///   factory Settings.fromJson(Map<String, dynamic> json) => Settings(
///     darkMode: json['darkMode'] ?? false,
///     locale: json['locale'] ?? 'en_US',
///   );
///
///   Map<String, dynamic> toJson() => {
///     'darkMode': darkMode,
///     'locale': locale,
///   };
/// }
///
/// final settingsPreference = PrfyJson<Settings>(
///   'app_settings',
///   fromJson: Settings.fromJson,
///   toJson: (settings) => settings.toJson(),
///   defaultValue: Settings(darkMode: false, locale: 'en_US'),
/// );
///
/// await settingsPreference.set(Settings(darkMode: true, locale: 'fr_FR'));
/// final settings = await settingsPreference.get(); // Always reads from disk
/// ```
class PrfyJson<T> extends BasePrfObject<T> {
  /// The adapter used for JSON conversion.
  final PrfAdapter<T> _adapter;

  @override

  /// Gets the adapter used to convert between the object and its JSON representation.
  PrfAdapter<T> get adapter => _adapter;

  /// Creates a new isolate-safe JSON preference.
  ///
  /// - [key] is the key to store the preference under.
  /// - [fromJson] is a function that converts a JSON map to an instance of type [T].
  /// - [toJson] is a function that converts an instance of type [T] to a JSON map.
  /// - [defaultValue] is the optional default value to use when no value exists.
  PrfyJson(
    super.key, {
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T object) toJson,
    super.defaultValue,
  }) : _adapter = JsonAdapter(fromJson: fromJson, toJson: toJson);
}
