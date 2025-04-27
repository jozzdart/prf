import 'package:prf/prf.dart';

/// A cached preference object specialized for storing JSON-serializable objects.
///
/// This class provides type-safe access to complex objects stored in SharedPreferences
/// by serializing them to JSON. It uses in-memory caching for improved performance
/// and requires conversion functions to translate between the object type and JSON.
///
/// Example:
/// ```dart
/// class User {
///   final String name;
///   final int age;
///
///   User({required this.name, required this.age});
///
///   factory User.fromJson(Map<String, dynamic> json) => User(
///     name: json['name'],
///     age: json['age'],
///   );
///
///   Map<String, dynamic> toJson() => {
///     'name': name,
///     'age': age,
///   };
/// }
///
/// final userPreference = PrfJson<User>(
///   'current_user',
///   fromJson: User.fromJson,
///   toJson: (user) => user.toJson(),
/// );
///
/// await userPreference.set(User(name: 'Alice', age: 30));
/// final user = await userPreference.get();
/// ```
class PrfJson<T> extends CachedPrfObject<T> {
  /// The adapter used for JSON conversion.
  final PrfAdapter<T> _adapter;

  @override

  /// Gets the adapter used to convert between the object and its JSON representation.
  PrfAdapter<T> get adapter => _adapter;

  /// Creates a new cached JSON preference.
  ///
  /// - [key] is the key to store the preference under.
  /// - [fromJson] is a function that converts a JSON map to an instance of type [T].
  /// - [toJson] is a function that converts an instance of type [T] to a JSON map.
  /// - [defaultValue] is the optional default value to use when no value exists.
  PrfJson(
    super.key, {
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T object) toJson,
    super.defaultValue,
  }) : _adapter = JsonAdapter(fromJson: fromJson, toJson: toJson);
}
