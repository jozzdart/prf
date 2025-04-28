import 'package:prf/prf.dart';

/// A cached preference object that provides type-safe access to SharedPreferences.
///
/// This implementation caches values in memory for faster access after initial read,
/// making it more efficient for repeated access but not suitable for use across isolates.
/// For isolate-safe preferences, use [Prfi] instead.
///
/// The class supports various types through adapters, including:
/// - Basic types (String, int, bool, double)
/// - JSON-serializable objects via [json] factory
/// - Enum values via [enumerated] factory
///
/// Example:
/// ```dart
/// // Basic type
/// final username = Prf<String>('username');
/// await username.set('Alice');
/// final name = await username.get(); // Returns 'Alice'
///
/// // JSON object
/// final user = Prf.json<User>(
///   'user',
///   fromJson: User.fromJson,
///   toJson: (user) => user.toJson(),
/// );
///
/// // Enum value
/// final theme = Prf.enumerated<Theme>(
///   'theme',
///   values: Theme.values,
///   defaultValue: Theme.light,
/// );
/// ```
class Prf<T> extends CachedPrfObject<T> {
  /// Creates a new cached preference object with the given [key] and optional [defaultValue].
  Prf(super.key, {super.defaultValue}) : _customAdapter = null {
    _resolvedAdapter = PrfAdapterMap.instance.of<T>();
  }

  /// Internal adapter override (optional).
  final PrfAdapter<T>? _customAdapter;
  late final PrfAdapter<T> _resolvedAdapter;

  @override
  PrfAdapter<T> get adapter => _customAdapter ?? _resolvedAdapter;

  /// Initializes the cache by loading the current value from storage.
  Future<void> init() async {
    await initCache(PrfService.instance);
  }

  /// Creates a new pre-cached preference object.
  ///
  /// This factory method creates a new [Prf] instance and immediately loads its value
  /// into the cache for faster subsequent access. This is not isolate-safe.
  ///
  /// - [key] is the key to store the preference under.
  /// - [defaultValue] is the value to use if no value exists for the key.
  static Future<Prf<T>> value<T>(
    String key, {
    T? defaultValue,
  }) async {
    final object = Prf<T>(key, defaultValue: defaultValue);
    await object.init();
    return object;
  }

  Prf._withAdapter(
    super.key, {
    required PrfAdapter<T> adapter,
    super.defaultValue,
  }) : _customAdapter = adapter {
    _resolvedAdapter = adapter;
  }

  /// Creates a new preference for a JSON-serializable object.
  ///
  /// This factory method sets up a [Prf] instance with a [JsonAdapter] for converting
  /// between the object and its JSON representation.
  ///
  /// - [key] is the key to store the preference under.
  /// - [fromJson] converts a JSON map to an instance of type [T].
  /// - [toJson] converts an instance of type [T] to a JSON map.
  /// - [defaultValue] is the value to use if no value exists for the key.
  static Prf<T> json<T>(
    String key, {
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T object) toJson,
    T? defaultValue,
  }) {
    return Prf._withAdapter(
      key,
      adapter: JsonAdapter<T>(fromJson: fromJson, toJson: toJson),
      defaultValue: defaultValue,
    );
  }

  /// Creates a new preference for an enum value.
  ///
  /// This factory method sets up a [Prf] instance with an [EnumAdapter] for converting
  /// between the enum and its integer index representation.
  ///
  /// - [key] is the key to store the preference under.
  /// - [values] is the list of all possible enum values, typically EnumType.values.
  /// - [defaultValue] is the value to use if no value exists for the key.
  static Prf<T> enumerated<T extends Enum>(
    String key, {
    required List<T> values,
    T? defaultValue,
  }) {
    return Prf._withAdapter(
      key,
      adapter: EnumAdapter<T>(values),
      defaultValue: defaultValue,
    );
  }
}
