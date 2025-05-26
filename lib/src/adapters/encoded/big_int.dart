import 'dart:convert';
import 'dart:typed_data';

import '../../core/encoded_adapter.dart';
import '../adapters.dart';

/// Adapter for BigInt objects.
///
/// Stores BigInt as base64-encoded binary representation with sign bit.
class BigIntAdapter extends PrfEncodedAdapter<BigInt, String> {
  /// Creates a new BigInt adapter.
  const BigIntAdapter() : super(const StringAdapter());

  @override
  BigInt? decode(String? base64) {
    if (base64 == null) return null;
    try {
      final bytes = base64Decode(base64);
      if (bytes.isEmpty) return BigInt.zero;

      // First byte indicates sign (0 for positive, 1 for negative)
      final isNegative = bytes[0] == 1;

      // Remaining bytes are the magnitude
      var result = BigInt.zero;
      for (var i = 1; i < bytes.length; i++) {
        result = (result << 8) | BigInt.from(bytes[i]);
      }

      return isNegative ? -result : result;
    } catch (_) {
      return null; // Invalid format
    }
  }

  @override
  String encode(BigInt bigInt) {
    // Convert to efficient binary representation
    final isNegative = bigInt.isNegative;
    final magnitude = bigInt.abs();

    // Calculate how many bytes we need
    var tempMag = magnitude;
    var byteCount = 0;
    do {
      byteCount++;
      tempMag = tempMag >> 8;
    } while (tempMag > BigInt.zero);

    // Create a byte array with an extra byte for the sign
    final bytes = Uint8List(byteCount + 1);

    // First byte indicates sign (0 for positive, 1 for negative)
    bytes[0] = isNegative ? 1 : 0;

    // Fill in the magnitude bytes in big-endian order
    var tempValue = magnitude;
    for (var i = byteCount; i > 0; i--) {
      bytes[i] = (tempValue & BigInt.from(0xFF)).toInt();
      tempValue = tempValue >> 8;
    }

    return base64Encode(bytes);
  }
}
