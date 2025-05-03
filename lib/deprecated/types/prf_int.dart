import 'package:prf/prf.dart';

/// A cached integer preference.
///
/// This class is deprecated. Use [Prf] instead.
///
/// Example:
/// ```dart
/// final count = Prf<int>('count');
/// ```
@Deprecated('Use Prf instead. This class will be removed in a future version.')
class PrfInt extends Prf<int> {
  /// Creates a new integer preference.
  @Deprecated(
      'Use Prf instead. This constructor will be removed in a future version.')
  PrfInt(super.key, {super.defaultValue});
}
