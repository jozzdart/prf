import 'dart:convert';
import 'package:prf/core/prf_encoded.dart';

/// A type-safe wrapper for storing and retrieving JSON-serializable objects in SharedPreferences.
///
/// This class automatically handles the conversion between Dart objects and their
/// JSON string representation for storage in SharedPreferences.
///
/// Use this class for storing complex objects like user profiles, app configurations,
/// or any other structured data that can be serialized to JSON.
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
/// final currentUser = PrfJson<User>(
///   'current_user',
///   fromJson: User.fromJson,
///   toJson: (user) => user.toJson(),
/// );
///
/// await currentUser.set(User(name: 'Joey', age: 30));
/// final user = await currentUser.get();
/// ```
class PrfJson<T> extends PrfEncoded<T, String> {
  /// Creates a new JSON preference variable with the specified [key].
  ///
  /// [fromJson] is a required function that converts a JSON map to your object type.
  /// [toJson] is a required function that converts your object to a JSON map.
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
  PrfJson(
    super.key, {
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T object) toJson,
    super.defaultValue,
  }) : super(
          from: (jsonString) {
            if (jsonString == null) return null;
            try {
              final map = jsonDecode(jsonString);
              if (map is Map<String, dynamic>) {
                return fromJson(map);
              }
              return null;
            } catch (_) {
              return null;
            }
          },
          to: (obj) => jsonEncode(toJson(obj)),
          getter: (prefs, key) async => await prefs.getString(key),
          setter: (prefs, key, value) async =>
              await prefs.setString(key, value),
        );
}
