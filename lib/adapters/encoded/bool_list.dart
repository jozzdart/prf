import 'dart:convert';
import 'dart:typed_data';
import 'package:prf/prf.dart';

/// Adapter for lists of booleans.
///
/// Stores boolean lists as base64-encoded binary data.
/// Format: first 4 bytes = length, following bytes = 8 booleans per byte.
class BoolListAdapter extends PrfEncodedAdapter<List<bool>, String> {
  const BoolListAdapter() : super(const StringAdapter());

  @override
  List<bool>? decode(String? base64String) {
    if (base64String == null) return null;
    try {
      final bytes = base64Decode(base64String);
      if (bytes.length < 4) return null; // too short to have length

      final length = ByteData.sublistView(bytes, 0, 4).getUint32(0, Endian.big);
      final result = <bool>[];

      for (var i = 4; i < bytes.length; i++) {
        final byte = bytes[i];
        for (var bit = 0; bit < 8; bit++) {
          result.add((byte & (1 << bit)) != 0);
        }
      }
      if (result.length > length) {
        result.length = length; // truncate any extra padding
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  String encode(List<bool> value) {
    final length = value.length;
    final byteLength = (length + 7) ~/ 8;
    final bytes = Uint8List(4 + byteLength); // first 4 bytes for length

    final byteData = ByteData.sublistView(bytes);
    byteData.setUint32(0, length, Endian.big);

    for (var i = 0; i < length; i++) {
      if (value[i]) {
        bytes[4 + (i >> 3)] |= (1 << (i & 7));
      }
    }
    return base64Encode(bytes);
  }
}
