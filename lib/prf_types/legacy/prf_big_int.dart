import 'package:prf/prf.dart';

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
@Deprecated(
    'Use Prf<BigInt> instead for cached access or Prfy<BigInt> for isolate-safe access')
class PrfBigInt extends Prf<BigInt> {
  /// Creates a new BigInt preference variable with the specified [key].
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
  PrfBigInt(super.key, {super.defaultValue});
}
