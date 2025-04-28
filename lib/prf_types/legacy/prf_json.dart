import 'package:prf/prf.dart';

/// A cached preference object for JSON-serializable objects.
///
/// This class is deprecated. Use [Prf.json] factory method instead.
///
/// Example:
/// ```dart
/// final user = Prf.json<User>(
///   'user',
///   fromJson: User.fromJson,
///   toJson: (user) => user.toJson(),
/// );
/// ```
@Deprecated(
    'Use Prf.json factory method instead. This class will be removed in a future version.')
class PrfJson<T> extends CachedPrfObject<T> {
  /// The adapter used for JSON conversion.
  final PrfAdapter<T> _adapter;

  @override
  PrfAdapter<T> get adapter => _adapter;

  /// Creates a new cached JSON preference.
  ///
  /// - [key] is the key to store the preference under.
  /// - [fromJson] is a function that converts a JSON map to an instance of type [T].
  /// - [toJson] is a function that converts an instance of type [T] to a JSON map.
  /// - [defaultValue] is the optional default value to use when no value exists.
  @Deprecated(
      'Use Prf.json factory method instead. This constructor will be removed in a future version.')
  PrfJson(
    super.key, {
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T object) toJson,
    super.defaultValue,
  }) : _adapter = JsonAdapter(fromJson: fromJson, toJson: toJson);
}
