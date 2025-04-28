import 'package:prf/prf.dart';

/// An isolate-safe preference object that provides type-safe access to SharedPreferences.
///
/// Unlike [Prf], this implementation does not cache values in memory, making it
/// suitable for use across isolates but requiring disk reads for each access.
/// For non-isolate-safe preferences with caching, use [Prf] instead.
///
/// The class supports various types through adapters, including:
/// - Basic types (String, int, bool, double, Uint8List & more!)
/// - JSON-serializable objects via [json] factory
/// - Enum values via [enumerated] factory
///
/// Example:
/// ```dart
/// // Basic type
/// final username = PrfIso<String>('username');
/// await username.set('Alice');
/// final name = await username.get(); // Always reads from disk
///
/// // JSON object
/// final user = PrfIso.json<User>(
///   'user',
///   fromJson: User.fromJson,
///   toJson: (user) => user.toJson(),
/// );
///
/// // Enum value
/// final theme = PrfIso.enumerated<Theme>(
///   'theme',
///   values: Theme.values,
///   defaultValue: Theme.light,
/// );
/// ```
class PrfIso<T> extends BasePrfObject<T> {
  /// Creates a new isolate-safe preference object with the given [key] and optional [defaultValue].
  PrfIso(super.key, {super.defaultValue}) : _customAdapter = null {
    _resolvedAdapter = PrfAdapterMap.instance.of<T>();
  }

  /// Internal adapter override (optional).
  final PrfAdapter<T>? _customAdapter;
  late final PrfAdapter<T> _resolvedAdapter;

  @override
  PrfAdapter<T> get adapter => _customAdapter ?? _resolvedAdapter;

  /// Creates a new preference for a JSON-serializable object.
  ///
  /// This factory method sets up a [PrfIso] instance with a [JsonAdapter] for converting
  /// between the object and its JSON representation.
  ///
  /// - [key] is the key to store the preference under.
  /// - [fromJson] converts a JSON map to an instance of type [T].
  /// - [toJson] converts an instance of type [T] to a JSON map.
  /// - [defaultValue] is the value to use if no value exists for the key.
  static PrfIso<T> json<T>(
    String key, {
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T object) toJson,
    T? defaultValue,
  }) {
    return PrfIso._withAdapter(
      key,
      adapter: JsonAdapter<T>(fromJson: fromJson, toJson: toJson),
      defaultValue: defaultValue,
    );
  }

  /// Creates a new preference for an enum value.
  ///
  /// This factory method sets up a [PrfIso] instance with an [EnumAdapter] for converting
  /// between the enum and its integer index representation.
  ///
  /// - [key] is the key to store the preference under.
  /// - [values] is the list of all possible enum values, typically EnumType.values.
  /// - [defaultValue] is the value to use if no value exists for the key.
  static PrfIso<T> enumerated<T extends Enum>(
    String key, {
    required List<T> values,
    T? defaultValue,
  }) {
    return PrfIso._withAdapter(
      key,
      adapter: EnumAdapter<T>(values),
      defaultValue: defaultValue,
    );
  }

  PrfIso._withAdapter(
    super.key, {
    required PrfAdapter<T> adapter,
    super.defaultValue,
  }) : _customAdapter = adapter;
}
