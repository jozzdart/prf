import 'package:prf/prf.dart';

/// A cached BigInt preference.
///
/// This class is deprecated. Use [Prf] instead.
///
/// Example:
/// ```dart
/// final balance = Prf<BigInt>('balance');
/// ```
@Deprecated('Use Prf instead. This class will be removed in a future version.')
class PrfBigInt extends Prf<BigInt> {
  /// Creates a new BigInt preference.
  @Deprecated(
      'Use Prf instead. This constructor will be removed in a future version.')
  PrfBigInt(super.key, {super.defaultValue});
}
