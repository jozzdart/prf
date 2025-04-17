import 'dart:convert';
import 'dart:typed_data';
import 'package:prf/core/prf_encoded.dart';

/// A type-safe wrapper for storing and retrieving BigInt values in SharedPreferences.
///
/// This class automatically handles the conversion between BigInt objects and
/// their binary representation (encoded as base64 strings) for efficient storage.
///
/// Use this class for storing large integers that exceed the range of regular integers,
/// such as very large IDs, cryptographic values, or mathematical calculations.
///
/// Example:
/// ```dart
/// final largeNumber = PrfBigInt('large_number');
/// await largeNumber.set(BigInt.parse('1234567890123456789012345678901234567890'));
/// final number = await largeNumber.get();
/// ```
class PrfBigInt extends PrfEncoded<BigInt, String> {
  /// Creates a new BigInt preference variable with the specified [key].
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
  PrfBigInt(super.key, {super.defaultValue})
      : super(
          from: (base64) {
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
          },
          to: (bigInt) {
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
          },
          getter: (prefs, key) async => await prefs.getString(key),
          setter: (prefs, key, value) async =>
              await prefs.setString(key, value),
        );
}
