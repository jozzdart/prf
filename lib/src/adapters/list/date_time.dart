import 'dart:convert';
import 'package:prf/prf.dart';

/// Adapter for lists of DateTime objects.
///
/// Stores each DateTime as a base64-encoded string, and the list as a JSON array of strings.
class DateTimeListAdapter extends PrfEncodedAdapter<List<DateTime>, String> {
  /// Creates a new DateTime list adapter.
  const DateTimeListAdapter() : super(const StringAdapter());

  @override
  List<DateTime>? decode(String? jsonString) {
    if (jsonString == null) return null;
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      final list = <DateTime>[];

      for (final base64 in decoded.cast<String>()) {
        final dt = const DateTimeAdapter().decode(base64);
        if (dt == null) {
          // If any entry fails decoding -> abort.
          return null;
        }
        list.add(dt);
      }

      return list;
    } catch (_) {
      return null;
    }
  }

  @override
  String encode(List<DateTime> dateTimes) {
    final encodedList =
        dateTimes.map((dt) => const DateTimeAdapter().encode(dt)).toList();
    return jsonEncode(encodedList);
  }
}
