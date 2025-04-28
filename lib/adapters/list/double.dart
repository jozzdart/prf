import 'dart:convert';
import 'dart:typed_data';
import 'package:prf/prf.dart';

/// Adapter for lists of doubles.
///
/// Stores double lists as base64-encoded binary data, with each double
/// represented as an 8-byte IEEE 754 double-precision floating-point number.
class DoubleListAdapter extends PrfEncodedAdapter<List<double>, String> {
  /// Creates a new double list adapter.
  const DoubleListAdapter() : super(const StringAdapter());

  @override
  List<double>? decode(String? base64String) {
    if (base64String == null) return null;
    try {
      final bytes = base64Decode(base64String);
      if (bytes.length % 8 != 0) return null; // invalid length

      final result = <double>[];
      final byteData = ByteData.sublistView(bytes);
      for (var i = 0; i < byteData.lengthInBytes; i += 8) {
        result.add(byteData.getFloat64(i, Endian.big)); // or Endian.little
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  String encode(List<double> value) {
    final bytes = Uint8List(value.length * 8);
    final byteData = ByteData.sublistView(bytes);
    for (var i = 0; i < value.length; i++) {
      byteData.setFloat64(i * 8, value[i], Endian.big); // or Endian.little
    }
    return base64Encode(bytes);
  }
}
