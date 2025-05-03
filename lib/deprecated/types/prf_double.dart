import 'package:prf/prf.dart';

/// A cached double preference.
///
/// This class is deprecated. Use [Prf] instead.
///
/// Example:
/// ```dart
/// final price = Prf<double>('price');
/// ```
@Deprecated('Use Prf instead. This class will be removed in a future version.')
class PrfDouble extends Prf<double> {
  /// Creates a new double preference.
  @Deprecated(
      'Use Prf instead. This constructor will be removed in a future version.')
  PrfDouble(super.key, {super.defaultValue});
}
