import 'dart:convert';

import '../../core/encoded_adapter.dart';
import '../adapters.dart';

/// Adapter for lists of objects that can be serialized to/from JSON.
///
/// Each object is stored as a JSON string in a native `List<String>`
/// using SharedPreferences' `setStringList` and `getStringList`.
class JsonListAdapter<T> extends PrfEncodedAdapter<List<T>, List<String>> {
  /// Converts a JSON map to a [T] instance.
  final T Function(Map<String, dynamic> json) fromJson;

  /// Converts a [T] instance to a JSON map.
  final Map<String, dynamic> Function(T value) toJson;

  /// Creates a new adapter for a list of JSON-serializable objects.
  const JsonListAdapter({
    required this.fromJson,
    required this.toJson,
  }) : super(const StringListAdapter());

  @override
  List<T>? decode(List<String>? stored) {
    if (stored == null) return null;
    final result = <T>[];
    for (final jsonStr in stored) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map<String, dynamic>) {
          result.add(fromJson(decoded));
        } else {
          return null;
        }
      } catch (_) {
        return null;
      }
    }
    return result;
  }

  @override
  List<String> encode(List<T> values) {
    return values.map((e) => jsonEncode(toJson(e))).toList();
  }
}
