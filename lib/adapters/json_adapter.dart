import 'dart:convert';
import 'package:prf/prf.dart';

/// Adapter for objects that can be converted to and from JSON.
///
/// Allows storing complex objects by serializing them to JSON strings.
class JsonAdapter<T> extends PrfEncodedAdapter<T, String> {
  /// Function to convert from a JSON map to type [T].
  final T Function(Map<String, dynamic> json) fromJson;

  /// Function to convert from type [T] to a JSON map.
  final Map<String, dynamic> Function(T object) toJson;

  /// Creates a new JSON adapter with the specified conversion functions.
  ///
  /// [fromJson] converts a JSON map to the target type [T].
  /// [toJson] converts an instance of [T] to a JSON map.
  const JsonAdapter({required this.fromJson, required this.toJson})
      : super(const StringAdapter());

  @override
  T? decode(String? jsonString) {
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
  }

  @override
  String encode(T value) => jsonEncode(toJson(value));
}
