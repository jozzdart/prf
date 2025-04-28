import 'dart:convert';
import 'dart:typed_data';
import 'package:prf/prf.dart';

/// Adapter for lists of integers.
///
/// Stores integer lists as base64-encoded binary data, with each integer
/// represented as a 4-byte big-endian value.
class IntListAdapter extends PrfEncodedAdapter<List<int>, String> {
  /// Creates a new integer list adapter.
  const IntListAdapter() : super(const StringAdapter());

  @override
  List<int>? decode(String? base64String) {
    if (base64String == null) return null;
    try {
      final bytes = base64Decode(base64String);
      if (bytes.length % 4 != 0) return null; // invalid length

      final result = <int>[];
      final byteData = ByteData.sublistView(bytes);
      for (var i = 0; i < byteData.lengthInBytes; i += 4) {
        result.add(byteData.getInt32(i, Endian.big)); // or Endian.little
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  String encode(List<int> value) {
    final bytes = Uint8List(value.length * 4);
    final byteData = ByteData.sublistView(bytes);
    for (var i = 0; i < value.length; i++) {
      byteData.setInt32(i * 4, value[i], Endian.big); // or Endian.little
    }
    return base64Encode(bytes);
  }
}
