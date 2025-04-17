import 'dart:convert';
import 'package:prf/core/prf_encoded.dart';

class PrfJson<T> extends PrfEncoded<T, String> {
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
          getter: (prefs, key) async => prefs.getString(key),
          setter: (prefs, key, value) async =>
              await prefs.setString(key, value),
        );
}
