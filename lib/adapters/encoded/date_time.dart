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
      if (bytes.length < 8) return null;

      final data = ByteData.sublistView(bytes);
      final high = data.getUint32(0, Endian.big);
      final low = data.getUint32(4, Endian.big);
      final micros = (high << 32) | low;
      return DateTime.fromMicrosecondsSinceEpoch(micros);
    } catch (_) {
      return null;
    }
  }

  @override
  String encode(DateTime dateTime) {
    final micros = dateTime.microsecondsSinceEpoch;
    final buffer = ByteData(8);
    buffer.setUint32(0, micros >> 32, Endian.big); // high bits
    buffer.setUint32(4, micros & 0xFFFFFFFF, Endian.big); // low bits
    return base64Encode(buffer.buffer.asUint8List());
  }
}
