import 'package:prf/prf.dart';

/// An isolate-safe JSON preference.
///
/// This class is deprecated. Use [PrfIso.json] instead.
///
/// Example:
/// ```dart
/// final settings = PrfIso.json<Settings>(
///   'settings',
///   fromJson: Settings.fromJson,
///   toJson: (settings) => settings.toJson(),
/// );
/// ```
@Deprecated(
    'Use PrfIso.json instead. This class will be removed in a future version.')
class PrfyJson<T> extends BasePrfObject<T> {
  /// The adapter used for JSON conversion.
  final PrfAdapter<T> _adapter;

  @override
  PrfAdapter<T> get adapter => _adapter;

  /// Creates a new isolate-safe JSON preference.
  ///
  /// - [key] is the key to store the preference under.
  /// - [fromJson] is a function that converts a JSON map to an instance of type [T].
  /// - [toJson] is a function that converts an instance of type [T] to a JSON map.
  /// - [defaultValue] is the optional default value to use when no value exists.
  @Deprecated(
      'Use PrfIso.json instead. This constructor will be removed in a future version.')
  PrfyJson(
    super.key, {
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T object) toJson,
    super.defaultValue,
  }) : _adapter = JsonAdapter(fromJson: fromJson, toJson: toJson);
}
