import 'package:prf/prf.dart';

/// A cached Duration preference.
///
/// This class is deprecated. Use [Prf] instead.
///
/// Example:
/// ```dart
/// final timeout = Prf<Duration>('timeout');
/// ```
@Deprecated('Use Prf instead. This class will be removed in a future version.')
class PrfDuration extends Prf<Duration> {
  /// Creates a new Duration preference.
  @Deprecated(
      'Use Prf instead. This constructor will be removed in a future version.')
  PrfDuration(super.key, {super.defaultValue});
}
