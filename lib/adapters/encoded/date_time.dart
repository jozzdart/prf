import 'dart:convert';
import 'dart:typed_data';
import 'package:prf/prf.dart';

/// Adapter for DateTime objects.
///
/// Stores DateTime as base64-encoded binary representation of microseconds since epoch.
class DateTimeAdapter extends PrfEncodedAdapter<DateTime, String> {
  /// Creates a new DateTime adapter.
  const DateTimeAdapter() : super(const StringAdapter());

  @override
  DateTime? decode(String? base64) {
    if (base64 == null) return null;
    try {
      final bytes = base64Decode(base64);
      if (bytes.length < 8) return null; // Too short to contain a timestamp
      final micros = ByteData.sublistView(bytes).getInt64(0, Endian.big);
      return DateTime.fromMicrosecondsSinceEpoch(micros);
    } catch (_) {
      return null;
    }
  }

  @override
  String encode(DateTime dateTime) {
    final buffer = ByteData(8);
    buffer.setInt64(0, dateTime.microsecondsSinceEpoch, Endian.big);
    return base64Encode(buffer.buffer.asUint8List());
  }
}
